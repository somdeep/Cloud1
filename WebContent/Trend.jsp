<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>Trends</title>

    <!-- Bootstrap core CSS -->
    <link href="bootstrap\css\bootstrap.min.css" rel="stylesheet">
    <!-- Custom styles for this template -->
    <link href="navbar.css" rel="stylesheet">


  </head>

  <body>

  <%



  %>

    <div class="container">

      <!-- Static navbar -->
      <nav class="navbar navbar-default">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
             <a class="navbar-brand" href="http://sm11-frm72nkcpb.elasticbeanstalk.com/index2.jsp">TweetGet</a>
            <a class="btn btn-primary" href="http://sm11-frm72nkcpb.elasticbeanstalk.com/geochart.jsp">TweetGeo</a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">


          </div><!--/.nav-collapse -->
        </div><!--/.container-fluid -->
      </nav>

      <!-- Main component for a primary marketing message or call to action -->
      <div class="jumbotron">
        <h1>TweetApp</h1>
        <p>A quick look at what apps users are using to connect to twitter</p>
        <p>

          <a class = "btn btn-lg btn-primary"  onclick="openSocket();" >Get trends</a>

            <a class="btn btn-lg btn-info" onclick="closeSocket();" >End</a>
        </p>
      </div>

      <div>

        </div>

    </div> <!-- /container -->
<script type="text/javascript" src="https://www.google.com/jsapi?autoload={'modules':[{'name':'visualization','version':'1.1','packages':['corechart']}]}"></script>
       <div id="piechart" style="width: 900px; height: 500px;"></div>

  <script>
  google.load("visualization", "1", {packages:["corechart"]});
         google.setOnLoadCallback(drawChart);
     var array;
     var chart;
     var data;
     var options;

         function drawChart() {

         data = google.visualization.arrayToDataTable([
          ['Task', 'Hours per Day'],
          ['Twitter',      1],
          ['Instagram',  1],
          ['Foursquare', 1],
          ['Path',    1],
          ['TweetMyJOBS',1],
          ['Other',1]
        ]);


        array=['Task','Twitter','Instagram','Foursquare','Path','Other'];
         options = {      };

        chart = new google.visualization.PieChart(document.getElementById('piechart'));

        chart.draw(data, options);
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
  // webSocket = new WebSocket("ws://localhost:8085/websock/echo");
  // webSocket = new WebSocket("ws://localhost:8085/websock/echo");
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
        var app = (x[3]);
       //alert(app);
        var i=array.indexOf(app);
        //var j=array.indexOf('Facebook');


        //var val1=data.getValue(j-1,1);
        //data.setValue(j-1,1,val1+1);

        if(i<0)
        {
        	if(app.indexOf("Twitter")> -1)
        		{
        		i=array.indexOf("Twitter");
        		}
        	else{
      		var j= array.indexOf('Other');
        	var val1=data.getValue(j-1,1);
        	data.setValue(j-1,1,val1+1);
        	chart.draw(data,options);

        	}
        }

        if(i>=0)
        {
        	var val=data.getValue(i-1,1);

        	data.setValue(i-1,1,val+1);
           // var chart = new google.visualization.PieChart(document.getElementById('piechart'));

            chart.draw(data, options);

        	}



        //pointArray.push(newLoc);

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


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="../../dist/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>
