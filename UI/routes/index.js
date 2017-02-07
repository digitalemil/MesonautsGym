var express = require('express');
var router = express.Router();
var app = express();
var url= require('url');
var request = require('request');
var http = require("http");

let modeltopic= "mesonautsgym-model";
let listener= process.env.LISTENER;
let modelevaluator= process.env.MODELEVALUATOR;
let model= "";

let kafka = require('kafka-node');
let kafka_dns= process.env.KAFKA_SERVICE;
let kafka_client = new kafka.Client(kafka_dns);
let Consumer = kafka.Consumer;
let Producer= kafka.Producer;
let kafka_consumer;

let producer = new Producer(kafka_client);
producer.on('error', function (err) {
  console.log("Kafka producer on error()");
  console.log(err);
});

function listenOnTopic() {
  kafka_consumer = new Consumer(
    kafka_client,
    [
      { topic: modeltopic, offset: 0}
    ],
    {
      fromOffset: true
    }
  );
        kafka_consumer.on('message', function (message) {
  model= message.value;
  console.log("Model: "+model);
});
};

producer.on('ready', function () {
  console.log("Producer ready.");
      producer.createTopics([modeltopic], false, function (err, data) {
        console.log("Topic: "+modeltopic+" created or existed already");
        setTimeout(listenOnTopic, 1000);
      });
});


router.get('/sessions/running', function(req, res, next) {
});

router.post('/model', function(req, res, next) {
  let m = req.body;
  m= m.replace(/\"/g, '\'');
 payloads= [ { topic: modeltopic, messages: m, partition: 0 } ];
  
  console.log("Payload: "+JSON.stringify(payloads));
   
  producer.send(payloads, function (err, data) {      
        console.log("Kafka payload sent: "+JSON.stringify(data)+" "+err);
    }); 
  res.end();
});



var nodemailer = require('nodemailer');

// create reusable transporter object using the default SMTP transport
var transporter = nodemailer.createTransport('smtps://mesonaut@digitalemil.de%40smtp.strato.de:C74WfetlOrbdMOKG@smtp.strato.de');

// setup e-mail data with unicode symbols
var mailOptions = {
    from: '"digitalemil" <mesonaut@digitalemil.de>', // sender address
    to: '', // list of receivers
    subject: 'Mesonauts Gym', // Subject line
    text: '', // plaintext body
};

// send mail with defined transport object
function sendMail(mailOptions) {
transporter.sendMail(mailOptions, function(error, info){
    if(error){
        return console.log(error);
    }
    console.log('Message sent: ' + info.response);
});
};

router.post('/mail', function(req, res, next) {
 let msg= req.body;
 let json= JSON.parse(msg);
 mailOptions.to=json.mailaddress;
 mailOptions.text= 'Please use the following server:\n'+json.server+"\n\nPlease remove any ending /.";

 sendMail(mailOptions);
 console.log("Sending mail invite to: "+ json.mailaddress);
 console.log("Content: "+ json.server);
 
 //console.log("appdef");
});

router.post('/data', function(req, res, next) {
 let msg= req.body;
 msg.model= model;
 console.log("Msg: "+ msg);
 let jsonobj= JSON.parse(msg);
 jsonobj.model= model;
 let color= "0x80FFFFFF";
 request.post(modelevaluator, {form:JSON.stringify(jsonobj)}, function(err, response, body) {
    if(err== null) {
      color= body;
    }
    else{
    }
    console.log("Color: "+color);
    jsonobj.color= color;
    delete jsonobj.model;
    console.log("to Listener: "+ JSON.stringify(jsonobj)); 
request.post(listener, {form:JSON.stringify(jsonobj)}, function(err, response, body) {
});


 res.statusCode= 200;
 res.end();
 });
 
});

module.exports = router;

