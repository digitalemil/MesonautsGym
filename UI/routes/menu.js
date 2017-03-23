var express = require('express');
var router = express.Router();
var app = express();
var url= require('url');
var request = require('request');
var http = require("http");
var fs = require('fs');

let json= new String(process.env.APPDEF);
json= json.replace(/\'/g, '\"');
let appdef= JSON.parse(json);
let fields= new Array(); 
let types= new Array();

for(var i= 0; i< appdef.fields.length; i++) {
  fields[i] = appdef.fields[i].name;
  types[i] = appdef.fields[i].type;
}

var messages= new Object();
var nmessages= 0;
var messageoffset= -1;
let listener= process.env.LISTENER;

var cassandra = require('cassandra-driver');
let cas_contact= process.env.CASSANDRA_SERVICE;
//let cas_contact= "node-0.cassandra.mesos:9042,node-1.cassandra.mesos:9042,node-2.cassandra.mesos:9042";
var cas_client = new cassandra.Client({contactPoints: [cas_contact]});

var kafka = require('kafka-node');
let kafka_dns= process.env.KAFKA_SERVICE;
//kafka_dns= "master.mesos:2181/dcos-service-kafka";
var kafka_client = new kafka.Client(kafka_dns);
console.log("Kafka client: "+JSON.stringify(kafka_client));
Consumer = kafka.Consumer;
var kafka_consumer = new Consumer(
    kafka_client,
    [
      { topic: appdef.topic, offset: 0}
    ],
    {
      fromOffset: true
    }
  );

kafka_consumer.on('message', function (message) {
  let obj= JSON.parse(message.value);
  let user= obj.user;
  messages[user]= obj;
//  console.log("Kafka, received message: ", JSON.stringify(messages));
});

//"http://dcosappstudio-"+appdef.path+"workerlistener.marathon.l4lb.thisdcos.directory:0/data";

  
router.get('/zeppelin.html', function(req, res, next) {
//let obj= require(process.env.MESOS_SANDBOX+"/zeppelin-notebook.json");
let obj= require("/"+process.env.APPDIR+"/zeppelin-notebook.json");
let txt= JSON.stringify(obj).replace(/TOPIC/g, appdef.topic);
txt= txt.replace(/TABLE/g, appdef.table);
txt= txt.replace(/APPNAME/g, appdef.name);
let l1= "";
let l2= "";
for(let i= 0; i< fields.length; i++) {
  l1+= "(msg \\\\ \\\""+fields[i]+"\\\").as[String]";
  l2+= "\\\""+fields[i]+"\\\"";
  if(i< fields.length-1) {
    l1+= ", ";
    l2+= ", ";
  }
}

txt= txt.replace(/REPLACE1/g, l1);
txt= txt.replace(/REPLACE2/g, l2);

  res.setHeader('Content-disposition', 'attachment; filename=zeppelin-notebook.json');
  // (msg \\ \"handle\").as[String], (tweet \\ \"content\").as[String], (tweet \\ \"created_at\").as[String]
  // \"handle\", \"content\", \"created_at\"
  //let config= JSON.stringify(groupconfig).replace(/REPLACEME/g, myapp);
  //config= config.replace(/\$PATH/g, "-"+app.get("apppath"));
  res.write(txt);
  res.end();
});

router.get('/', function(req, res, next) {
  res.render('index', { title: appdef.name, name:appdef.name });
});


router.get('/senddata*', function(req, res, next) {
  var url_parts = url.parse(req.url, true);
  var query = url_parts.query;
  console.log("UI /data: "+query.json);
  console.log("POST: "+listener);
  request.post(listener, {form:query.json}, function(err, response, body) {
  if(err==null) {
    res.statusCode= 200;  
  }
  else {
    res.statusCode= 503;
  }
});
});

router.get('/cassandra.html', function(req, res, next) {
  res.render('cassandra', { table: appdef.table, keyspace: appdef.keyspace});
});

router.get('/map.html', function(req, res, next) {
  res.render('map', { table: appdef.table, keyspace: appdef.keyspace, name:appdef.name});
});


router.get('/cql', function(req, res, next) {
  let url_parts = url.parse(req.url, true);
  let query = url_parts.query;
  let cql= query.cmd;
  console.log("cql: "+cql);
  cas_client.execute(cql, function (err, result) {
           if (!err){
               if ( result.rows.length > 0 ) {
                   for(let r= 0; r< result.rows.length; r++) {
                      console.log(JSON.stringify(result.rows[r]));
                      res.write(JSON.stringify(result.rows[r])+"\n\n");
                   }
               } else {
                   console.log("Cassandra data: No results");
               }
           }
           res.end();
});
});

router.get('/sessions', function(req, res, next) {

   let ret = "{\"session\":{\"begincomment\":null,\"dayssince01012012\":0,\"dummy\":null,\"endcomment\":null,\"ended\":null,\"groupid\":{\"id\":1,\"name\":\"Default\"},\"id\":0,\"start\":0},\"users\":[";

  let data= new Array();
 
  let i= 0;
  let first= true;
  let now= new Date().getTime();
   
  for(var key in messages) {
    
    try {
    let dt= messages[key].event_timestamp;
    dt= dt.replace('T', ' ');
    dt = new Date(dt);
    let ms= dt.getTime();
  //  console.log("ms: "+ms);
     
  //   console.log(now+" "+ms);
    if(now> ms + 1000*60) {
      console.log("Deleting: "+key);
 //   console.log(now+" "+ms+" "+dt);
      delete messages.key;
      continue;
    }
    }
    catch(ex) {
      console.log(ex);
   } 
   
    let color= messages[key].color;
    let hr= messages[key].heartrate;
    let user= messages[key].user;
    let deviceid= messages[key].deviceid; 
    if (!first)
      ret+= ", ";
    else
      first = false;
    ret+= "{\"calories\":\"\",\"color\":\""+color+"\",\"hr\":\""+hr+"\",\"name\":\""+user+"\",\"recovery\":\"\",\"zone\":\""+deviceid+"\"}";
  }
  ret= ret+ "]}";

let r= JSON.parse(ret);
  console.log("users.length: "+ r.users.length);
  res.write(ret);
  res.end();
});


router.get('/mapdata', function(req, res, next) {
  let data= new Object();
  data.total= nmessages;
  data.locations= new Array();
  console.log("Data: "+JSON.stringify(data));

  let j= 0;
   let now= new Date().getTime();
   
  for(var key in messages) {
    let location= new Object();
    let dt= location.event_timestamp;
    let ms= new Date(dt).getTime();
    if(now> ms + 1000*60) {
      delete messages.key;
      continue;
    }
    let latlong=  messages[key].location.split(",");
    location.latitude= latlong[0];
    location.longitude= latlong[1];
    location.n= 1;
    data.locations[j++]= location;
  }
  console.log("MapData: "+JSON.stringify(data));
  res.write(JSON.stringify(data));
  res.end();
});

router.get('/data.html', function(req, res, next) {
  let f;
  f="<p><div>id:</div> "+"<input id='id' style='text-align: center; width: 40%; font-size: 24px; font-family: \'Gill Sans\', \'Gill Sans MT\', Calibri, \'Trebuchet MS\', sans-serif' type='text' value='"+new Date().getTime()+"'></input>";
  f+= "<p>";
  if(appdef.showLocation) {
    f+="<div>location:</div> "+"<input id='location' style='text-align: center; width: 40%; font-size: 24px; font-family: \'Gill Sans\', \'Gill Sans MT\', Calibri, \'Trebuchet MS\', sans-serif' type='text' value=''></input>";
    f+= "<p>";
  }
  f+="<div>event_timestamp:</div> "+"<input id='timestamp' style='text-align: center; width: 40%; font-size: 24px; font-family: \'Gill Sans\', \'Gill Sans MT\', Calibri, \'Trebuchet MS\', sans-serif' type='text' value=''></input>";
  f+= "<p>";
  let sf='';
  console.log(JSON.stringify(fields));
  for(let i= 0; i< fields.length; i++) {
    if(fields[i] === "id" || fields[i] === "location" || fields[i] === "event_timestamp")
      continue;
      
   sf+= "json+= ', \""+fields[i]+"\":\"'+document.getElementById('"+fields[i]+"').value+'\"';";
   f+="<div>"+fields[i]+":</div> <input id='"+fields[i]+"' style='text-align: center; width: 40%; font-size: 24px; font-family: \'Gill Sans\', \'Gill Sans MT\', Calibri, \'Trebuchet MS\', sans-serif' type='text' value=''></input>";
   f+= "<p>";
  }
 
  res.render('data', { title: appdef.name, name: appdef.name, fields:f, showLocation: appdef.showLocation, getFields: sf});
});


module.exports = router;

/*
var kafka = require('kafka-node');
var Consumer = kafka.Consumer;

var kafka_client = new kafka.Client("master.mesos:2181/dcos-service-kafka");

var consumer = new Consumer(
    kafka_client,
    [
      { topic: topic, offset: 0}
    ],
    {
      fromOffset: true
    }
  );

consumer.on('message', function (message) {
  console.log("Kafka, received message: ", message);
});
*/
