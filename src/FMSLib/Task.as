// ActionScript file
package FMSLib
{
  [Bindable]
  public class Task
  {
    public function Task(UID:String, MinToEnd:String, IP:String, chatState:String, state:String)
    {
      this.UID = UID;
      this.MinToEnd = MinToEnd;
      this.IP = IP;
      this.chatState = chatState;
      this.state = state;
    }
   
    public var UID:String;
    public var MinToEnd:String;
    public var IP:String;
    public var chatState:String;
    public var state:String;
  }
}