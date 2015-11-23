<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>


<html>
    <script language="javascript" type="text/javascript">


    		var map;

            var wsUri = "";

            function init() {
                output = document.getElementById("output");
            }
            function send_message() {
                websocket = new WebSocket(wsUri);
                websocket.onopen = function(evt) {
                    onOpen(evt)
                };
                websocket.onmessage = function(evt) {
                    onMessage(evt)
                };
                websocket.onerror = function(evt) {
                    onError(evt)
                };
            }
            function onOpen(evt) {
             //   writeToScreen("Connected to Endpoint!");
               doSend(textID.value);
               initMap();

            }
            function onMessage(evt) {

            	var data=evt.data;
                var pos1=data.indexOf('=');
                var pos2=data.indexOf(',');
                var lati=parseFloat(data.substring(pos1+1,pos2));



                pos1=data.lastIndexOf('=');
                pos2=data.lastIndexOf('}');
                var loni=parseFloat(data.substring(pos1+1,pos2));
            	//var lat=JSON.parse(evt.latitude);
            	//writeToScreen("Message Received: " + lat + "," + lon);
            	var myLatLng = {};
            	myLatLng.lat=lati;
            	myLatLng.lng=loni;
            	addMarker(myLatLng);

            }
            function onError(evt) {
                writeToScreen('ERROR: ' + evt.data);
            }
            function doSend(message) {
                //writeToScreen("Message Sent: " + message);
                websocket.send(message);
                //websocket.close();
            }
            function writeToScreen(message) {
                var pre = document.createElement("p");
                pre.style.wordWrap = "break-word";
                pre.innerHTML = message;

                output.appendChild(pre);
            }
            window.addEventListener("load", init, false);


            function initMap() {
         	   var myLatLng = {lat: 25.363, lng: 131.044};

         	   // Create a map object and specify the DOM element for display.
         	    map = new google.maps.Map(document.getElementById('map'), {
         	     center: myLatLng,
         	     scrollwheel: true,
         	     zoom:4
         	   });


         	   addMarker(myLatLng);

         	   }

            function addMarker(myLatLng)
            {


            	//writeToScreen("Sent : " + lati.data + "," + lngi.data);
            	//var myLatLng = {lat:lati , lng: lngi};
              var marker = new google.maps.Marker({
                map: map,
                position: myLatLng
              });

              map.panTo(myLatLng);

            }





        </script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"  name="viewport" content="initial-scale=1.0, user-scalable=yes ">
<title>Insert title here</title>
</head>
<style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      #map {
        height: 100%;
      }
    </style>
<body>
<br>
        <div style="text-align: center;">
            <form action="">
                <input onclick="send_message()" value="Send" type="button">
                <input id="textID" name="message" value="Hello WebSocket!" type="text"><br>
            </form>
        </div>
        <div id="output"></div>

        <body>
    <div id="map"></div>
    <script async defer
        src=""></script>
  </body>
</body>
</html>
