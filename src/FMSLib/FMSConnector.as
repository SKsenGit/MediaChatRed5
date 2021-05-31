package  FMSLib
{
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	
	public class FMSConnector extends EventDispatcher
	{

		public var id_member:String="unknown";
		public var id_partner:String="unknown";
		

		
		
		public function FMSConnector()
		{
		}
		
		public function serverMessage(Response:String):void
		{
				Alert.show(Response,"Сервисное сообщение");
		}	
		
		public function onSetStatusOfPartner(status:String):void
		{
			dispatchEvent(new FMSEvents(FMSEvents.onSetStatusOfPartner,status));
		}
		
		public function onRequestFromPartner(_id_partner:String):void
		{
			dispatchEvent(new FMSEvents(FMSEvents.onRequestFromPartner,_id_partner));
		}
		public function AnswerFromPartner(answer:Boolean):void
		{
			if (answer)
			{
				dispatchEvent(new FMSEvents(FMSEvents.onStartSession,"Start session"));
			}
			else 
			{
				Alert.show("Собеседник не отвечает!","Сервисное сообщение");
			}
		}
		
		public function onEndSession(_id_partner:String):void
		{
				dispatchEvent(new FMSEvents(FMSEvents.onEndSession,"End session"));
		}
		
	}
}