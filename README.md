# moschitto
Mosquitto MQTT client for Chapel Language

Moschitto é a Chapel wrapper on the Mosquitto MQTT client library.

# Installation

1. Install mosquito server.
```bash
apt install mosquitto
```
2. Install mosquitto libmosquitto.
```bash
apt install mosquitto-dev
```

# Configure mosquitto websocket

1. Stop the mosquitto server service.

```bash
service mosquitto stop
```
2. Creates a new websocket config file.

```bash
sudo vim /etc/mosquitto/conf.d/websocket.conf
```
3. Defines the port of MQTT broker and the port of websocket server listens.

```
port 1883
listener 8081
protocol websockets
```
The parameter ```port``` specifies the port of mosquitto MQTT server. The parameter ```listner``` specifies the port of the websocket server.


# Example of publisher

```chapel

module Main{
use moschitto;
use Time;

//Data to be serialized
record AgentPosition{
    var x:real;
    var y:real;
}
    proc main(){
        //Creates the publisher. You can define the host and port in the contructor
        var cli  = new MoschittoPublisher();
        
        cli.Connect();//Connects to the mosquitto server and begin the thread to send data.
        
        sleep(1);// Give some time to connect.

        for i in 1..1000000{ //Runs your own simulation

            var agent =  new AgentPosition(x=i,y=cos(i/10)); // Do some calculus.
            //cli.Publish("/data/hello","oi mundo: "+i:string); //If you want you can publish raw strings
            
            cli.PublishObj("/data/hello",agent); //Publishes the agent object as json.
            writeln("publishing ",i);
            
            //sleep(1);// It is not necessary to delay the loop 
            
        }

        cli.Close();
    }

}
```

# Receiving published data.

In order to receive data from the above example you can use any mqtt client, subscribing the "/data/hello" topic.

If you have mosquitto-tools installed you can subscribe with:

```bash
mosquitto_sub -t /data/hello -q 0
```

# Receiving data via websocket in the browser.

1. Install the MQTT.js for browser.

(https://github.com/mqttjs/MQTT.js/)[https://github.com/mqttjs/MQTT.js/]

You can use:
(https://unpkg.com/mqtt@2.17.0/dist/mqtt.min.js)[https://unpkg.com/mqtt@2.17.0/dist/mqtt.min.js]

2. Create an HTML file:

```html
<script src="https://unpkg.com/mqtt@2.17.0/dist/mqtt.min.js"></script>
<script>
  var client = mqtt.connect("ws://localhost:8081"); // Connect to mosquitto websocket server
  
  client.subscribe("/data/hello"); //Subscribe the data channel.

  client.on("message", function (topic, payload) { // On message event is called when data arrives.
//topic is the topic name
//payload is an binary array of published data.
    console.log("Topic: ",topic);
    //Converts binary array to javascript string
    var str = new TextDecoder("utf-8").decode(payload);
    console.log("Data from server",str);
  })
//You can also publish.
  client.publish("mqtt/demo", "hello world!")
</script>
```

3. Run a webserver to serve the html file. Warning, you cannot open the file directly with the browser because websocket has origin restriction.
