import CoreMIDI
//import Foundation

@objc public class MIDILightController: NSObject {
    private var client: MIDIClientRef = 0
    private var outPort: MIDIPortRef = 0
    private var inPort: MIDIPortRef = 0
    private var destination: MIDIEndpointRef = 0
    private var midiReceiveCallback: ((UInt8, UInt8, UInt8) -> Void)?
    
    @objc public enum MIDIError: Int, Error {
        case clientCreateFailed
        case portCreateFailed
        case destinationNotFound
        case sendFailed
        case invalidMessage
        case inputPortCreateFailed
    }
    
    @objc public override init() {
        super.init()
    }
    
    @objc public func initialize() throws {
        // Create MIDI client
        let status = MIDIClientCreate("MIDI Light Controller" as CFString, nil, nil, &client)
        if status != noErr {
            throw MIDIError.clientCreateFailed
        }
        
        // Create output port
        let portStatus = MIDIOutputPortCreate(client, "Output Port" as CFString, &outPort)
        if portStatus != noErr {
            throw MIDIError.portCreateFailed
        }
        
        // Create input port with read callback
        let readCallback: MIDIReadProc = { pktList, readProcRefCon, srcConnRefCon in
            let controller = unsafeBitCast(readProcRefCon, to: MIDILightController.self)
            controller.handleMIDIInput(pktList.pointee)
        }
        
        let inputPortStatus = MIDIInputPortCreate(client, "Input Port" as CFString, readCallback, Unmanaged.passUnretained(self).toOpaque(), &inPort)
        if inputPortStatus != noErr {
            throw MIDIError.inputPortCreateFailed
        }
    }
    
    private func handleMIDIInput(_ packetList: MIDIPacketList) {
        var packet = packetList.packet
        for _ in 0..<packetList.numPackets {
            let data = withUnsafePointer(to: packet.data) { ptr in
                Array(UnsafeBufferPointer(start: ptr.withMemoryRebound(to: UInt8.self, capacity: Int(packet.length)) { $0 }, count: Int(packet.length)))
            }
            
            // Process MIDI message if it has at least 3 bytes (status + data1 + data2)
            if data.count >= 3 {
                let status = data[0]
                let data1 = data[1]
                let data2 = data[2]
                midiReceiveCallback?(status, data1, data2)
            }
            
            packet = MIDIPacketNext(&packet).pointee
        }
    }
    
    @objc public func setMIDIReceiveCallback(_ callback: @escaping (UInt8, UInt8, UInt8) -> Void) {
        midiReceiveCallback = callback
    }
    
    @objc public func connectSource(at sourceIndex: Int) throws {
        let sourceCount = MIDIGetNumberOfSources()
        guard sourceIndex < sourceCount else {
            throw MIDIError.destinationNotFound
        }
        
        let source = MIDIGetSource(sourceIndex)
        let connectStatus = MIDIPortConnectSource(inPort, source, nil)
        if connectStatus != noErr {
            throw MIDIError.portCreateFailed
        }
    }
    
    @objc public func getAvailableSources(containing filterText: String = "") -> [String] {
        var sources = [String]()
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0..<sourceCount {
            let endpoint = MIDIGetSource(i)
            var name: Unmanaged<CFString>?
            
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            if let nameUnmanaged = name {
                let sourceName = nameUnmanaged.takeRetainedValue() as String
                sources.append("\(i): \(sourceName)")
            }
        }
        
        return sources
    }
    
    @objc public func connect(to destinationIndex: Int) throws {
        // Get the total number of destinations
        let destinationCount = MIDIGetNumberOfDestinations()
        
        if destinationIndex < destinationCount {
            destination = MIDIGetDestination(destinationIndex)
        } else {
            throw MIDIError.destinationNotFound
        }
    }
    
    @objc public func getAvailableDevices(containing filterText: String = "") -> [String] {
        var devices = [String]()
        let destinationCount = MIDIGetNumberOfDestinations()
        
        for i in 0..<destinationCount {
            let endpoint = MIDIGetDestination(i)
            var name: Unmanaged<CFString>?
            
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            if let nameUnmanaged = name {
                let deviceName = nameUnmanaged.takeRetainedValue() as String
                devices.append("\(i): \(deviceName)")
            }
        }
        
        return devices
    }
    
    @objc public func sendRawMIDIMessage(_ messageBytes: [UInt8]) throws {
        // Validate message
        guard messageBytes.count >= 3 else {
            throw MIDIError.invalidMessage
        }
        
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = UInt16(messageBytes.count)
        
        // Copy bytes into packet data
        // The MIDIPacket data property only has space for the first 256 bytes
        // For simplicity, we're assuming the message is short (which MIDI typically is)
        for i in 0..<min(messageBytes.count, 256) {
            withUnsafeMutablePointer(to: &packet.data) { ptr in
                let bytePtr = ptr.withMemoryRebound(to: UInt8.self, capacity: 256) { $0 }
                bytePtr[i] = messageBytes[i]
            }
        }
        
        // Create a packet list containing our single packet
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        
        // Send the packet
        let sendStatus = MIDISend(outPort, destination, &packetList)
        if sendStatus != noErr {
            throw MIDIError.sendFailed
        }
    }
    
    // Convenience methods for light control
    @objc public func turnLightOn(channel: UInt8 = 0, lightNumber: UInt8 = 0, brightness: UInt8 = 127) throws {
        let noteOnCommand: UInt8 = 0x90 + channel
        try sendRawMIDIMessage([noteOnCommand, lightNumber, brightness])
    }
    
    @objc public func turnLightOff(channel: UInt8 = 0, lightNumber: UInt8 = 0) throws {
        try turnLightOn(channel: channel, lightNumber: lightNumber, brightness: 0)
    }
    
    deinit {
        if inPort != 0 {
            MIDIPortDispose(inPort)
        }
        MIDIClientDispose(client)
    }
}
