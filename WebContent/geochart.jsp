<html>
  <head>
  <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>GeoChart</title>

    <!-- Bootstrap core CSS -->
    <link href="bootstrap\css\bootstrap.min.css" rel="stylesheet">
    <!-- Custom styles for this template -->
    <link href="navbar.css" rel="stylesheet">

    
  
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>    
  </head>
  <body>
  
   <div class="container">

      <!-- Static navbar -->
      <nav class="navbar navbar-inverse">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="http://sm11-frm72nkcpb.elasticbeanstalk.com/index2.jsp">TweetGet</a>
            <a href="http://sm11-frm72nkcpb.elasticbeanstalk.com/Trend.jsp">TweetApp</a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">
                        
            
          </div><!--/.nav-collapse -->
        </div><!--/.container-fluid -->
      </nav>

      <!-- Main component for a primary marketing message or call to action -->
      <div class="jumbotron">
        <h1>TweetGeo</h1>
        <p>A quick look at which countries tweet what the most! </p>
        <p>
          
          <a class = "btn btn-lg btn-primary"  onclick="openSocket();" >Get trends</a>
           
            <a class="btn btn-lg btn-info" onclick="closeSocket();" >End</a>
            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
            
             <a class="btn btn-lg btn-warning" onclick="send();" >Search for Keyword</a>
             <input type="text" id="messageinput"/>
        </p>
      </div>
      
      <div>
            
        </div>

    </div> <!-- /container -->
  		<div>
           
        </div>
  		<div>
           
            
           
        </div>
        <div id="regions_div" style="width: 1300px; height: 700px;"></div>
        
        <script type="text/javascript">
        
        google.load("visualization", "1", {packages:["geochart"]});
        google.setOnLoadCallback(drawRegionsMap);
		var data, chart, options;
		var array2, array1;
	
        function drawRegionsMap() {
        	/**
        	map = new Map;
        	map.put('Country', 'Popularity');
        	map.put('Germany', 200);
        	*/
        	array1 = ['United States'];
        		
			array2 = new Array(
			                   ['Country', 'Popularity'],
							   ['United States',0]				                   			           
			                 )	;
			
            data = google.visualization.arrayToDataTable(array2);

          options = {};

          chart = new google.visualization.GeoChart(document.getElementById('regions_div'));

          chart.draw(data, options);
        }
                      
            var webSocket;            
            function openSocket(){
                // Ensures only one connection is open at a time
                if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
                   writeResponse("WebSocket is already opened.");
                    return;
                }
                // Create a new instance of the websocket
                webSocket = new WebSocket("ws://54.84.199.31:8080/echo");
               // webSocket = new WebSocket("ws://localhost:8085/websock/echo");
                 
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
                	var country = event.data.split(",")[2];
                    var i = array1.indexOf(country);
                    if (i==-1){
                    	array1.push(country);
                    	data.addRows([[country,1]]);                   	
                    }
                    else {
                    	var old = data.getValue(i,1);
                    	data.setValue(i,1,old+1);
                    }
                    chart.draw(data, options); 
                    
                };
 
                webSocket.onclose = function(event){
                    writeResponse("Connection closed");
                };
            }  
            function send(){             	
            	//data = google.visualization.arrayToDataTable(array);
            	//chart.draw(data, options); 
            	
            	/**
            	array1.push('Canada');
            	data.addRows([['Canada',2]]);
            	
            	var i = array1.indexOf('Canada');
            	//writeResponse(i);
            	var old = data.getValue(i,1);
            	//writeResponse(old);
            	data.setValue(i,1,old+2);
            	
            	//var _new = data.getValue(i,1);
            	//data = google.visualization.arrayToDataTable(array2);
            	chart.draw(data, options); 
            	*/
            	
                var text = document.getElementById("messageinput").value;
                webSocket.send(text);
                array1 = ['United States'];
                array2 = new Array(
		                   ['Country', 'Popularity'],
						   ['United States',0]				                   			           
		                 )	;
		
     			data = google.visualization.arrayToDataTable(array2);
                chart.draw(data, options);
            }
                        
           
            function closeSocket(){
                webSocket.close();
            }
 
            function writeResponse(text){
            	document.getElementById("messageinput").value = "Server:" + text;
            }
           
        </script>
    	
  </body>
</html>