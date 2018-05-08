module Main{
use moschitto;
use Time;

record AgentPosition{
    var x:real;
    var y:real;
}
    proc main(){
        var cli  = new MoschittoPublisher();
        
        cli.Connect();
        sleep(1);
        for i in 1..60{

            var agent =  new AgentPosition(x=i,y=cos(i/10));
            //cli.Publish("/data/hello","oi mundo: "+i:string);
            cli.PublishObj("/data/hello",agent);
            writeln("publishing ",i);
            sleep(1);
            
        }

        cli.Close();
    }

}