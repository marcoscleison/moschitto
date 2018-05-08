module Main{
use moschitto;
use Time;


class MyController:MoschittoController{
  proc init(){

  }
  proc this(topic:string, data:string, msg:mosquitto_message){
    writeln("receiving from :",topic);
    writeln("receiving data :",data);
  }
}


    proc main(){
        var cli  = new MoschittoSubscriber();
        
        cli.Connect();
        sleep(1);
        var controller = new MyController();
        cli.Subscribe("/data/hello",controller);
        cli.Listen();
        cli.Close();
    }

}