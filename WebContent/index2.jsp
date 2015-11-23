<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>

<html>
    <head>
        <title>TweetGet</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width">
        <!-- Bootstrap core CSS -->
    <link href="bootstrap\css\bootstrap.min.css" rel="stylesheet">
    <!-- Custom styles for this template -->
    <link href="navbar.css" rel="stylesheet">
        <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      #map {
        height: 100%;
      }
#floating-panel {
  position: absolute;
  top: 10px;
  right:5%;
  z-index: 5;

  padding: 5px;
  border: 1px solid #999;
  text-align: center;
  font-family: 'Roboto','sans-serif';
  line-height: 30px;
  padding-left: 10px;

}

      #floating-panel {

        border: 1px solid #999;

        padding: 5px;
        position: absolute;
        top: 10px;
        z-index: 5;

      }
    </style>
    </head>
    <body>
     <nav class="navbar navbar-default" style="bgcolor:red">
        <div class="container-fluid">
          <div class="navbar-header" style="bgcolor:red;">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <h1 style="color:black;"><b>TweetGet</b></h1>

             <ul class="nav navbar-nav" style="left:50%;">

       <a class="btn btn-primary" onclick="openSocket();" >Start Live Feed</a>
        <a class="btn btn-info" onclick="closeSocket();" >End</a>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
            <a class="btn btn-warning" onclick="send();" >Search For Keyword</a>

            <input type="text" id="messageinput"/>
  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp

            <a class="btn btn-danger" href="">TweetGeo</a>
       <a class="btn btn-success" href="">TweetApp</a>
       </ul>

          </div>
          <div id="navbar" class="navbar-collapse collapse">


          </div><!--/.nav-collapse -->
        </div><!--/.container-fluid -->
      </nav>



    	<div id="map"></div>

    	<script>

var map, heatmap;

var pointArray;

function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    zoom:2,
    center: {lat: 37.775, lng: -122.434},
    mapTypeId: google.maps.MapTypeId.SATELLITE
  });

  pointArray = new google.maps.MVCArray();
  //pointArray.push(new google.maps.LatLng(-34.397,150.644));
  heatmap = new google.maps.visualization.HeatmapLayer({
    data: pointArray,
    map: map
  });


}

function toggleHeatmap() {
  heatmap.setMap(heatmap.getMap() ? null : map);
}

function changeGradient() {
  var gradient = [
    'rgba(0, 255, 255, 0)',
    'rgba(0, 255, 255, 1)',
    'rgba(0, 191, 255, 1)',
    'rgba(0, 127, 255, 1)',
    'rgba(0, 63, 255, 1)',
    'rgba(0, 0, 255, 1)',
    'rgba(0, 0, 223, 1)',
    'rgba(0, 0, 191, 1)',
    'rgba(0, 0, 159, 1)',
    'rgba(0, 0, 127, 1)',
    'rgba(63, 0, 91, 1)',
    'rgba(127, 0, 63, 1)',
    'rgba(191, 0, 31, 1)',
    'rgba(255, 0, 0, 1)'
  ]
  heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
}

function changeRadius() {
  heatmap.set('radius', heatmap.get('radius') ? null : 20);
}

function changeOpacity() {
  heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
}

// Heatmap data: 500 Points
function getPoints() {
  return [
    new google.maps.LatLng(37.782551, -122.445368),
    new google.maps.LatLng(37.782745, -122.444586),
    new google.maps.LatLng(37.782842, -122.443688),
  ];
}



            var webSocket;
            var messages = document.getElementById("messages");


            function openSocket(){
                // Ensures only one connection is open at a time
                if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
                   writeResponse("WebSocket is already opened.");
                    return;
                }
                // Create a new instance of the websocket
                //webSocket = new WebSocket("ws://localhost:8085/websock/echo");
              webSocket = new WebSocket("");

                /**
                 * Binds functions to the listeners for the websocket.
                 */
                webSocket.onopen = function(event){
                    // For reasons I can't determine, onopen gets called twice
                    // and the first time event.data is undefined.
                    // Leave a comment if you know the answer.
                    if(event.data === undefined)
                        return;

                    writeResponse(event.data);
                };

                webSocket.onmessage = function(event){
                    //writeResponse(event.data);
                    var x = event.data.split(",");
                    var newLoc = new google.maps.LatLng(parseFloat(x[0]),parseFloat(x[1]));
                    pointArray.push(newLoc);


                };

                webSocket.onclose = function(event){
                    writeResponse("Connection closed");
                };
            }

            /**
             * Sends the value of the text input to the server
             */
            function send(){
            	while (pointArray.getLength()>0){
            		pointArray.pop();
            	}
                var text = document.getElementById("messageinput").value;
                webSocket.send(text);

            }

            function closeSocket(){
                webSocket.close();
            }

            function writeResponse(text){
                //messages.innerHTML += "<br/>" + text;
            	document.getElementById("messageinput").value = "Server:" + text;
            }

        </script>

     	<script async defer
        src="">
    	</script>
    </body>
</html>
