// ActionScript file
import FMSLib.*;

import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;

import mx.controls.Alert;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.managers.PopUpManager;

public var bConnect:Boolean = false;
public var videoMy:Video = new Video(320,249);
public var video_partner:Video = new Video(320,249);
public var videoHolder:UIComponent = new UIComponent();
public var mClient:FMSConnector=new FMSConnector();


private var baseAddr:String = "www.1618.ru:2036";
private var id_member:String, id_partner:String;

public var cam:Camera = null;
public var videoModel:Video = new Video;
public var mic:Microphone = null;
public var volumeTransform:SoundTransform = new SoundTransform;
public var fullVolumeTransform:SoundTransform = new SoundTransform;
private var nc:NetConnection = new NetConnection();
private var timeRefreshInterval:Number = 9000;
public var dataTimer:Timer;

//public var mClient:FMSConnector=new FMSConnector();

private var ns:NetStream = null;
private var ns_partner:NetStream = null;

private var partnerConnect:Boolean = false;


public function Initialize():void {
 	
 	txtVersion.text = "v1.05";
 	
 	dataTimer = new Timer(timeRefreshInterval,0);
 	dataTimer.addEventListener(TimerEvent.TIMER,checkStatusOfPartner);
 	
 fullVolumeTransform.volume = 1;
 	
 btnStartVideo.enabled = false;
 btnMyVideo.enabled = false;
 btnMyAudio.enabled = false;

	mClient.id_member = Application.application.parameters.id_member;
	mClient.id_partner = Application.application.parameters.id_partner;
	
	
	mClient.addEventListener(FMSEvents.onSetStatusOfPartner,onSetStatusOfPartner);
	mClient.addEventListener(FMSEvents.onRequestFromPartner,onRequestFromPartner);
	mClient.addEventListener(FMSEvents.onStartSession,onStartSession);
	mClient.addEventListener(FMSEvents.onEndSession,onEndSession);
	
        // Добавляем обработчики событий для объекта NetConnection
        nc.addEventListener(NetStatusEvent.NET_STATUS, onNCStatus);
        nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
        
		nc.objectEncoding=ObjectEncoding.AMF0;		
		nc.client = mClient;
		lvlVolume.value = 1;

 }
 
 private function btnStartOnClick():void {
 	


 	if (btnStart.label == "Старт")
 	{
    	nc.connect("rtmp://" + baseAddr + "/MediaChat", mClient.id_member, mClient.id_partner);
    	btnMyVideo.label = "Выкл. видео";
    	btnMyAudio.label = "Выкл. микрофон";

  	}
  	else
  	{
  		btnStart.label = "Старт";
  		btnStartVideo.label = "Пригласить";
 		btnStartVideo.enabled = false;
 		btnMyVideo.enabled = false;
 		btnMyAudio.enabled = false;
  		ns.close();
  		nc.close();
  		cam = null;
  		videoMy.attachCamera(cam);
  		videoMy.clear();
  		videoOut.removeChild(videoMy);
  		if (bConnect) EndSession();
  		dataTimer.stop();
  	


  	
  	}
 
 }
 
 	private function onSetStatusOfPartner(event:FMSEvents):void
 	{
 		if(event.Data == "online")
 		{
 			btnStartVideo.enabled = true;
 		}
 		else
 		{
 			btnStartVideo.enabled = false;
 			btnStartVideo.label = "Пригласить";
 		}
 	}
 
    private function securityErrorHandler(event:SecurityErrorEvent):void
    {
    }

    private function asyncErrorHandler(event:AsyncErrorEvent):void
    {
    }

    private function onNSStatus(event:NetStatusEvent):void
    {	
    	
    	if (event.info.code == "NetStream.Publish.Start"){

 			dataTimer.start();
    	}
    }
    // Обработчик статуса соединения
    private function onNCStatus(event:NetStatusEvent):void
    {
        
        
        switch (event.info.code) {
        	case "NetConnection.Connect.Closed":
        	Alert.show("Соединение было закрыто. Повторите попытку позже.","Сервисное сообщение");
        	if(btnStartVideo.label == "Остановить")	btnStartOnClick();
        	else btnStart.label = "Старт";
        	break;
            // При успешном соединении
            case "NetConnection.Connect.Success":
                // Создаём стрим на основе объекта соединения
                ns = new NetStream(nc);
                // Добавляем обработчики событий чтобы не ругался
                ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
                ns.addEventListener(NetStatusEvent.NET_STATUS, onNSStatus);
 				if (cam == null)	
				 	{
 					cam = Camera.getCamera();
 					if (cam==null)
 						{
		
						Alert.show("Камера не обнаружена!");
						
	
 						}
 						else {
					cam.setMode(320, 249, 10);
					cam.setQuality(50000, 90);
 						}
 					}
 				if (mic == null)
 				{	
 					mic = Microphone.getMicrophone();
 					mic.rate = 44;
 					mic.gain = 100;
 					mic.setUseEchoSuppression(true);
 					mic.setSilenceLevel(0,-1);
 					
 					
 					mic.soundTransform = fullVolumeTransform;
 				}
                
                // Соединяем стрим с вебкамерой
                ns.attachCamera(cam);
                ns.attachAudio(mic);
				videoMy.attachCamera(cam);
        		videoOut.addChild(videoMy);
                // Запускаем передачу данных
                ns.publish(mClient.id_member,"live");
 				//btnStartVideo.enabled = true;
 				btnMyVideo.enabled = true;
 				btnMyAudio.enabled = true;
 				btnStart.label = "Стоп";
                break;
            default:
            
				Alert.show("Невозможно установить соединение с сервером.","Сервисное сообщение");	
        }   

    }
   
   public function checkStatusOfPartner(event:TimerEvent):void
   {
   	 nc.call("getStatusOfPartner",null,mClient.id_member, mClient.id_partner);
   	 

   }
   
    public function btnStartVideoOnClick():void
    {	
    	if (btnStartVideo.label == "Пригласить")
    	{
      		nc.call("sendRequestToPartner",null,mClient.id_member, mClient.id_partner);
     	}	
     	else
     	{
     		nc.call("endSession",null,mClient.id_member,mClient.id_partner);
     		EndSession();
     		     	
     	}
     	
    }
    
    public function onRequestFromPartner(event:FMSEvents):void
    {
    	 var helpWindow:IFlexDisplayObject =
         PopUpManager.createPopUp(this, RequestWindow, false);
    }
    
    public function sendAnswer(answer:Boolean):void
    {
    	nc.call("sendAnswer",null,answer, mClient.id_partner, mClient.id_member);
    	if (answer)
    	{
			StartSession();
    		
    	}
    }	
    public function onStartSession(event:FMSEvents):void
    {
    	StartSession();
    }
    
    private function StartSession():void
    {
    	if (!bConnect)
    	{
    	ns_partner = new NetStream(nc);
    	video_partner.attachNetStream(ns_partner);

		
//    	videoHolder.addChild(video_partner);
//    	videoHolder.soundTransform = fullVolumeTransform;
//		videoIn.addChild(videoHolder);
		videoIn.addChild(video_partner);
		bConnect = true;
		lvlVolumeOnChange();
		ns_partner.receiveAudio(true);
		ns_partner.receiveVideo(true);
		ns_partner.play(mClient.id_partner);
    	}
		btnStartVideo.label = "Остановить";
    }
    
       public function onEndSession(event:FMSEvents):void
    {
    	EndSession();
    }
    
    private function EndSession():void
    {
		if (bConnect)
		{
//		videoIn.removeChild(videoHolder); 
//		videoHolder.removeChild(video_partner);
		videoIn.removeChild(video_partner); 
		ns_partner.close();
		bConnect = false;
		}
		btnStartVideo.label = "Пригласить";
		   
    }	
    
   public function btnMyAudioOnClick():void
   {
   	if(btnMyAudio.label == "Выкл. микрофон") 
   	{
   		btnMyAudio.label = "Вкл. микрофон";
   		//mic.setSilenceLevel(100,-1);
   		mic.gain = 0;
   	} 
   	else 
   	{
   		btnMyAudio.label = "Выкл. микрофон";
   		//mic.setSilenceLevel(5,-1);
   		mic.gain = 100;
   		}
   }
   
   public function btnMyVideoOnClick():void
   {
   	if(btnMyVideo.label == "Выкл. видео") 
   	{
   		btnMyVideo.label = "Вкл. видео";
   		if (cam == null)	cam = Camera.getCamera();
   		if (cam != null) cam.setMode(0,0,0);
   		
   	} 
   	else 
   	{
   		btnMyVideo.label = "Выкл. видео";
   		if (cam == null)	cam = Camera.getCamera();
   		if (cam != null) cam.setMode(320, 249, 10);
   		
   		}
   }
   public function lvlVolumeOnChange():void
   {
   	if(bConnect) 
   		
   	{
   		if (chkMutePartner.selected)
   		{
   		   	volumeTransform.volume = 0; 
   			ns_partner.soundTransform = volumeTransform; 
   			
   		}
   		else
   		{
   			volumeTransform.volume = lvlVolume.value; 
   			ns_partner.soundTransform = volumeTransform; 
   			
   		}
   	}  
   }
   
   
   