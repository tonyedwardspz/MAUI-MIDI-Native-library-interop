using ObjCRuntime;

namespace NewBindingMaciOS
{
	[Native]
	public enum MIDIError : long
	{
		ClientCreateFailed = 0,
		PortCreateFailed = 1,
		DestinationNotFound = 2,
		SendFailed = 3,
		InvalidMessage = 4
	}
}