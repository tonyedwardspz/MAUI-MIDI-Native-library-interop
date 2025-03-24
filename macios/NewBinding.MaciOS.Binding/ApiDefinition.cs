using System;
using Foundation;

namespace NewBindingMaciOS
{
	// @interface MIDILightController : NSObject
	[BaseType (typeof(NSObject), Name = "_TtC10NewBinding19MIDILightController")]
	interface MIDILightController
	{
		// -(BOOL)initializeAndReturnError:(NSError * _Nullable * _Nullable)error;
		[Export ("initializeAndReturnError:")]
		bool InitializeAndReturnError ([NullAllowed] out NSError error);

		// -(void)setMIDIReceiveCallback:(void (^ _Nonnull)(uint8_t, uint8_t, uint8_t))callback;
		[Export ("setMIDIReceiveCallback:")]
		void SetMIDIReceiveCallback (Action<byte, byte, byte> callback);

		// -(BOOL)connectSourceAt:(NSInteger)sourceIndex error:(NSError * _Nullable * _Nullable)error;
		[Export ("connectSourceAt:error:")]
		bool ConnectSourceAt (nint sourceIndex, [NullAllowed] out NSError error);

		// -(NSArray<NSString *> * _Nonnull)getAvailableSourcesWithContaining:(NSString * _Nonnull)filterText __attribute__((warn_unused_result("")));
		[Export ("getAvailableSourcesWithContaining:")]
		string[] GetAvailableSourcesWithContaining (string filterText);

		// -(BOOL)connectTo:(NSInteger)destinationIndex error:(NSError * _Nullable * _Nullable)error;
		[Export ("connectTo:error:")]
		bool ConnectTo (nint destinationIndex, [NullAllowed] out NSError error);

		// -(NSArray<NSString *> * _Nonnull)getAvailableDevicesWithContaining:(NSString * _Nonnull)filterText __attribute__((warn_unused_result("")));
		[Export ("getAvailableDevicesWithContaining:")]
		string[] GetAvailableDevicesWithContaining (string filterText);

		// -(BOOL)sendRawMIDIMessage:(NSArray<NSNumber *> * _Nonnull)messageBytes error:(NSError * _Nullable * _Nullable)error;
		[Export ("sendRawMIDIMessage:error:")]
		bool SendRawMIDIMessage (NSNumber[] messageBytes, [NullAllowed] out NSError error);

		// -(BOOL)turnLightOnChannel:(uint8_t)channel lightNumber:(uint8_t)lightNumber brightness:(uint8_t)brightness error:(NSError * _Nullable * _Nullable)error;
		[Export ("turnLightOnChannel:lightNumber:brightness:error:")]
		bool TurnLightOnChannel (byte channel, byte lightNumber, byte brightness, [NullAllowed] out NSError error);

		// -(BOOL)turnLightOffWithChannel:(uint8_t)channel lightNumber:(uint8_t)lightNumber error:(NSError * _Nullable * _Nullable)error;
		[Export ("turnLightOffWithChannel:lightNumber:error:")]
		bool TurnLightOffWithChannel (byte channel, byte lightNumber, [NullAllowed] out NSError error);
	}
}
