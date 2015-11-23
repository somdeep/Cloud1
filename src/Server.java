

import javax.websocket.server.ServerEndpoint;

import java.io.IOException;



import javax.websocket.*;
import javax.websocket.server.*;

import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterException;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.conf.ConfigurationBuilder;
import twitter4j.GeoLocation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;



@ServerEndpoint("/server")

public class Server {

	DBReader reader = null;
	private static Statement stmt;
	TwitterStream twitterStream;

	public static void connectDB() throws SQLException, ClassNotFoundException {

		//for connecting to RDS
    	Class.forName("com.mysql.jdbc.Driver");
    	Connection con = DriverManager.getConnection(
    			
    			);
    	ResultSet rs = con.getMetaData().getCatalogs();

    	while (rs.next()) {
    	    System.out.println("TABLE_CAT = " + rs.getString("TABLE_CAT") );
    	}

    	 System.out.println("Creating table in given database...");
         stmt = con.createStatement();



		String sql = "SHOW TABLES LIKE 'tweet1'";
		if (stmt.executeUpdate(sql)==0){

          sql = "CREATE TABLE tweet1" +
				  "(id	INTEGER NOT NULL auto_increment," +
				  "userName varchar(255) NOT NULL," +
				  "longitude DECIMAL(15,10)," +
				  "latitude DECIMAL(15,10)," +
				  "place varchar(255)," +
				  "source varchar(255)," +
				  "text varchar(255)," +
				  "PRIMARY KEY (id))";






         stmt.executeUpdate(sql);
		}
         //sql="insert into tweet1(userName,longitude,latitude,place,source,text) values (\"first\",10,15,\"work\",\"Somdeep\",\"Somdeep\")";

         //stmt.executeUpdate(sql);
         System.out.println("Created table in given database...");
      }

	public static void insertRecord (String userName, Double lon, Double lat,String place,String source, String text) throws SQLException{
		String sql = "INSERT INTO tweet1 (userName, longitude, latitude, place,source,text) "+
  			  "VALUES (\"" + userName + "\", \"" + lon + "\", \"" + lat + "\", \""+ place + "\", \"" + source + "\", \"" + text + "\")";
		//System.out.println(sql);
  		stmt.executeUpdate(sql);

	}

	@OnOpen
    public void onOpen(Session session)throws TwitterException,SQLException,ClassNotFoundException
	{


		System.out.println("in websocket");
		System.out.println(session.getId() + " has opened a connection");
        try {
            session.getBasicRemote().sendText("Connection Established");
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        reader = new DBReader(session);
        //reader.start();






       reader.start();

    }

	@OnMessage
	public void onMessage(String message, Session session){
        System.out.println("Message from " + session.getId() + ": " + message);
        reader.setFilter(message);

    }

	@OnClose
    public void onClose(Session session){
        System.out.println("Session " +session.getId()+" has ended");
       // twitterStream.cleanUp(); // shutdown internal stream consuming thread
       // twitterStream.shutdown();


        reader.kill();
    }




}
