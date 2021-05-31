package FMSLib
{
	import flash.events.Event;
	
	public class FMSEvents extends Event
	{
		public static const onSetStatusOfPartner:String = "onSetStatusOfPartner";
		public static const onRequestFromPartner:String = "onRequestFromPartner";
		public static const onStartSession:String="onStartSession";
		public static const onEndSession:String="onEndSession";
	
		
		public var Data:*;
		
		public function FMSEvents(type:String,data:*)
		{
			
			this.Data=data;
			super(type);
		}

	}
}