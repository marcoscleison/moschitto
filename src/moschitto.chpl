/* Documentation for moschitto */
module moschitto {
  
  use SysCTypes;
  require"mosquitto.h","-lmosquitto";
  use Mosquitto;
  use moschittoUtils;

proc my_log_callback(mosq:c_ptr(mosquitto), userdata:c_void_ptr, level:c_int, str:c_string){

}

proc my_connect_callback(mosq:c_ptr(mosquitto), userdata:c_void_ptr, result:c_int){

}

proc my_message_callback(mosq:c_ptr(mosquitto), userdata:c_void_ptr, message:c_ptr(mosquitto_message)){

}

proc my_subscribe_callback(mosq:c_ptr(mosquitto), userdata:c_void_ptr, mid:c_int, qos_count:c_int, granted_qos:c_ptr(c_int)){

}

class MoschittoPublisher{
  var host:string;
  var port:int;
  var keepalive:int;
  var clean_session:bool;
  var mosq:c_ptr(mosquitto);

 
  proc init(host:string="localhost", port:int=1883,keepalive:int=60,clean_session:bool=true){
    this.host=host;
    this.port=port;
    this.keepalive=keepalive;
    this.clean_session=clean_session;
    this.mosq=c_nil:c_ptr(mosquitto);
  }
  proc Connect(){
      mosquitto_lib_init();
      this.mosq = mosquitto_new(c_nil:c_string, this.clean_session:c_int,this:c_void_ptr);
      if(this.mosq==c_nil){
        writeln("Error: Out of memory.\n");
        halt();
      }
      mosquitto_log_callback_set(this.mosq, c_ptrTo(my_log_callback));
      mosquitto_connect_callback_set(this.mosq, c_ptrTo(my_connect_callback));
      mosquitto_message_callback_set(this.mosq, c_ptrTo(my_message_callback));
      mosquitto_subscribe_callback_set(this.mosq, c_ptrTo(my_subscribe_callback));

      if(mosquitto_connect(this.mosq, this.host.localize().c_str(), this.port:c_int, this.keepalive:c_int)){
        writeln("Unable to connect.");
        halt();
      }

      var loop:c_int = mosquitto_loop_start(mosq);

      if(loop != MOSQ_ERR_SUCCESS){
        writeln("Unable to start loop: ", loop);
        halt();
      }
   }
   proc Close(){
     mosquitto_loop_stop(this.mosq,true:c_int);
     mosquitto_destroy(this.mosq);
	   mosquitto_lib_cleanup();
   }

   proc Publish(topic:string, msg:string,qos:int=0, retain:bool=false,mid:c_void_ptr=c_nil ):c_int{
     return mosquitto_publish(this.mosq, mid, topic.localize().c_str(), msg.length:c_int, msg.localize().c_str():c_void_ptr, qos:c_int, retain:c_int);
   }
   
   proc PublishObj(topic:string, data:?eltType,qos:int=0, retain:bool=false,mid:c_void_ptr=c_nil ):c_int{
     var msg:string=objectToJson(data);
     return this.Publish(topic,msg,qos,retain,mid);
   }

}


class MochittoController{
  proc init(){

  }
  proc this(){

  }
}

class MoschittoControllerInterface{
  forwarding var controler:MochittoController;
}




module Mosquitto{

    extern "struct mosquitto_message" record mosquitto_message{
      var mid: c_int;
      var topic: c_ptr(c_char);
      var payload: c_void_ptr;
      var payloadlen: c_int;
      var qos: c_int;
      var retain: c_int;
    }

    extern "struct mosquitto" record mosquitto{
    }

    extern const MOSQ_ERR_SUCCESS:c_int;

    extern proc  mosquitto_lib_version(minor: c_ptr(c_int), revision: c_ptr(c_int) ):c_int;
    extern proc  mosquitto_lib_init():c_int;
    extern proc  mosquitto_lib_cleanup():c_int;

    extern proc  mosquitto_new(id: c_string, clean_session: c_int, obj: c_void_ptr ):c_ptr(mosquitto );
    extern proc  mosquitto_destroy(mosq: c_ptr(mosquitto ) ):c_void_ptr;
    extern proc  mosquitto_reinitialise(mosq: c_ptr(mosquitto ), id: c_string, clean_session: c_int, obj: c_void_ptr ):c_int;
    extern proc  mosquitto_will_set(mosq: c_ptr(mosquitto ),topic: c_string, payloadlen: c_int, payload: c_void_ptr, qos: c_int, retain: c_int ):c_int;
    extern proc  mosquitto_will_clear(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_username_pw_set(mosq: c_ptr(mosquitto ),username: c_string, password: c_string ):c_int;
    extern proc  mosquitto_connect(mosq: c_ptr(mosquitto ),host: c_string, port: c_int, keepalive: c_int ):c_int;
    extern proc  mosquitto_connect_bind(mosq: c_ptr(mosquitto ),host: c_string, port: c_int, keepalive: c_int, bind_address: c_string ):c_int;
    extern proc  mosquitto_connect_async(mosq: c_ptr(mosquitto ),host: c_string, port: c_int, keepalive: c_int ):c_int;
    extern proc  mosquitto_connect_bind_async(mosq: c_ptr(mosquitto ),host: c_string, port: c_int, keepalive: c_int, bind_address: c_string ):c_int;
    extern proc  mosquitto_connect_srv(mosq: c_ptr(mosquitto ),host: c_string, keepalive: c_int, bind_address: c_string ):c_int;
    extern proc  mosquitto_reconnect(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_reconnect_async(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_disconnect(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_publish(mosq: c_ptr(mosquitto ),mid:c_ptr(c_int), topic: c_string, payloadlen: c_int, payload: c_void_ptr, qos: c_int, retain: c_int ):c_int;
    extern proc  mosquitto_publish(mosq: c_ptr(mosquitto ),mid:c_void_ptr, topic: c_string, payloadlen: c_int, payload: c_void_ptr, qos: c_int, retain: c_int ):c_int;
    extern proc  mosquitto_subscribe(mosq: c_ptr(mosquitto ),mid: c_ptr(c_int), sub: c_string, qos: c_int ):c_int;
    extern proc  mosquitto_subscribe(mosq: c_ptr(mosquitto ),mid: c_void_ptr, sub: c_string, qos: c_int ):c_int;
    extern proc  mosquitto_unsubscribe(mosq: c_ptr(mosquitto ),mid: c_ptr(c_int), sub: c_string ):c_int;
    extern proc  mosquitto_message_copy(dst: c_ptr(mosquitto_message),src: c_ptr(mosquitto_message) ):c_int;
    extern proc  mosquitto_message_free(message: c_ptr(mosquitto_message ) ):c_void_ptr;
    extern proc  mosquitto_loop(mosq: c_ptr(mosquitto ),timeout: c_int, max_packets: c_int ):c_int;
    extern proc  mosquitto_loop_forever(mosq: c_ptr(mosquitto ),timeout: c_int, max_packets: c_int ):c_int;
    extern proc  mosquitto_loop_start(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_loop_stop(mosq: c_ptr(mosquitto ),force: c_int ):c_int;
    extern proc  mosquitto_socket(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_loop_read(mosq: c_ptr(mosquitto ),max_packets: c_int ):c_int;
    extern proc  mosquitto_loop_write(mosq: c_ptr(mosquitto ),max_packets: c_int ):c_int;
    extern proc  mosquitto_loop_misc(mosq: c_ptr(mosquitto ) ):c_int;
    extern proc  mosquitto_want_write(mosq: c_ptr(mosquitto )):c_int;
    extern proc  mosquitto_threaded_set(mosq: c_ptr(mosquitto ),threaded: c_int ):c_int;

    extern proc  mosquitto_opts_set(mosq: c_ptr(mosquitto ),option:c_int, value: c_void_ptr ):c_int;
    extern proc  mosquitto_tls_set(mosq: c_ptr(mosquitto ),cafile: c_string, capath: c_string, certfile: c_string, keyfile: c_string, pw_callback: c_fn_ptr ):c_int;
    extern proc  mosquitto_tls_insecure_set(mosq: c_ptr(mosquitto ),value: c_int ):c_int;
    extern proc  mosquitto_tls_opts_set(mosq: c_ptr(mosquitto ),cert_reqs: c_int, tls_version: c_string, ciphers: c_string ):c_int;
    extern proc  mosquitto_tls_psk_set(mosq: c_ptr(mosquitto ),psk: c_string, identity: c_string, ciphers: c_string ):c_int;
    extern proc  mosquitto_connect_callback_set(mosq: c_ptr(mosquitto ),on_connect: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_disconnect_callback_set(mosq: c_ptr(mosquitto ),on_disconnect: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_publish_callback_set(mosq: c_ptr(mosquitto ),on_publish: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_message_callback_set(mosq: c_ptr(mosquitto ),on_message: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_subscribe_callback_set(mosq: c_ptr(mosquitto ),on_subscribe: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_unsubscribe_callback_set(mosq: c_ptr(mosquitto ),on_unsubscribe: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_log_callback_set(mosq: c_ptr(mosquitto ),on_log: c_fn_ptr ):c_void_ptr;
    extern proc  mosquitto_reconnect_delay_set(mosq: c_ptr(mosquitto ),reconnect_delay: c_uint, reconnect_delay_max: c_uint, reconnect_exponential_backoff: c_int ):c_int;
    extern proc  mosquitto_max_inflight_messages_set(mosq: c_ptr(mosquitto ),max_inflight_messages: c_uint ):c_int;
    extern proc  mosquitto_message_retry_set(mosq: c_ptr(mosquitto ),message_retry: c_uint ):c_void_ptr;
    extern proc  mosquitto_user_data_set(mosq: c_ptr(mosquitto ),obj: c_void_ptr ):c_void_ptr;
    extern proc  mosquitto_socks5_set(mosq: c_ptr(mosquitto ),host: c_string, port: c_int, username: c_string, password: c_string ):c_int;
    extern proc  mosquitto_strerror(mosq_errno: c_int ):c_string;
    extern proc  mosquitto_connack_string(connack_code: c_int ):c_string;
    extern proc  mosquitto_sub_topic_tokenise(topics: c_string, count: c_ptr(c_int) ):c_int;
    extern proc  mosquitto_sub_topic_tokens_free(count: c_int ):c_int;
    extern proc  mosquitto_topic_matches_sub(topic: c_string, result: c_ptr(c_int) ):c_int;
    extern proc  mosquitto_pub_topic_check(topic: c_string ):c_int;
    extern proc  mosquitto_sub_topic_check(topic: c_string ):c_int;
  }//mosquitto module
}