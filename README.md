# MIDI Light Controller Interop

A .NET MAUI NativeInteropLibrary that provides native bindings for MIDI functionality on macOS platforms. Currently its setup for switching a light on for my controller (which is just sending a MIDI Message), but should provide a starting point for anyone looking to do more with Midi in MAUI.

## Requirements

- .NET 9.0 SDK or later
- Xcode (for iOS/macOS development)
- Dev environment with .NET MAUI setup

## Usage

Add the Interop Library rto you .csproj. E.g:

```
<ItemGroup Condition="$(TargetFramework.Contains('maccatalyst'))">
		<ProjectReference Include="..\MIDILightControllerInterop\macios\NewBinding.MaciOS.Binding\NewBinding.MaciOS.Binding.csproj" />
</ItemGroup>
```

You can then get started using it like so:

```
		NSError? error;
		var midiController = new MIDILightController();
		midiController.InitializeAndReturnError(out error);
		var output = midiController.GetAvailableDevicesWithContaining("Does not matter")[0];
		midiController.ConnectTo(0, out error);
		
		byte channel = (byte)0;
		byte note = (byte)0x10;
		byte color = (byte)0x05;

		midiController.TurnLightOnChannel(channel, note, color, out error);
```

## Project Structure

The solution is organized into the following components:

- **macios/**
  - **NewBinding.MaciOS.Binding/** - The .NET binding project that exposes native MIDI functionality
  - **native/** - The Xcode project containing the native Objective-C implementation

## Development

The project uses the .NET MAUI Native Library Interop pattern to create bindings between .NET and native iOS/macOS code. The binding project (`NewBinding.MaciOS.Binding`) provides the .NET API that you can use in your MAUI applications.

### Key Components

- **ApiDefinition.cs** - Defines the .NET API interface
- **StructsAndEnums.cs** - Contains shared structures and enumerations
- **native/** - Contains the native implementation in Objective-C

## License

MIT

## Contributing
If you want to contribute, clone the project and make your changes. Then make a pull request.

