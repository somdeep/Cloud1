

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



@ServerEndpoint("/echo")

public class WebSocketDemo {

	DBReader reader = null;
	private static Statement stmt;
	TwitterStream twitterStream;

	public static void connectDB() throws SQLException, ClassNotFoundException {

		//for connecting to RDS
    	Class.forName("com.mysql.jdbc.Driver");
    	Connection con = DriverManager.getConnection();
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



		connectDB();

		ConfigurationBuilder cb = new ConfigurationBuilder();
        cb.setDebugEnabled(true)
        .setOAuthConsumerKey("")
        .setOAuthConsumerSecret("")
        .setOAuthAccessToken("")
        .setOAuthAccessTokenSecret("");

       twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
       System.out.println();
       StatusListener listener = new StatusListener() {
           @Override
           public void onStatus(Status status) {
           	if(status.getGeoLocation()!=null || status.getPlace()!=null || status.getSource()!=null || status.getScopes()!=null)
           	{
           		System.out.println("@" + status.getUser().getScreenName() + " - \n" + status.getText()+ "  \nLocation : "+ status.getGeoLocation().toString()+ "\n Place : " + status.getPlace()+"\nSource:"+status.getSource()+"\nScopes:"+status.getScopes()+"\n\n");
           		try {
                    if (session.isOpen()) {
                    	double a=status.getGeoLocation().getLatitude();
                    	double b=status.getGeoLocation().getLongitude();
                    	String source,place;
                    	/*JSONObject js=new JSONObject();
                    	js.put("latitude", a);
                    	js.put("longitude", b);

                    	session.getBasicRemote().sendObject(status.getGe);;*/

                    	String s1=String.valueOf(a);
                    	String s2=String.valueOf(b);


                    	if(status.getSource()==null)
                			source="Twitter";
                		else
                		{
                			int first=status.getSource().indexOf('>');
                    		int last=status.getSource().indexOf("</");
                			source=status.getSource().substring(first+1,last);

                		}

                		if(status.getPlace()==null)
                			place="none";
                		else
                		{
                			//int first=status.getPlace().toString().indexOf('>');
                    		//int last=status.getPlace().toString().indexOf('<');

                			place=status.getPlace().getCountry();
                		}

                    	session.getBasicRemote().sendText(s1+","+s2+","+place+","+source);
                    	try {
    						insertRecord(status.getUser().getScreenName(), a, b,place,source,status.getText());
    					} catch (SQLException e) {
    						// TODO Auto-generated catch block
    						e.printStackTrace();
    					}

                    }
                } catch (Exception e) {
                    try {
                        session.close();
                    } catch (IOException e1) {
                        // Ignore
                    }
                }
           	}
           }

           @Override
           public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
           //      System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
           }

           @Override
           public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
             //  System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
           }

           @Override
           public void onScrubGeo(long userId, long upToStatusId) {
               //System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
           }

           @Override
           public void onStallWarning(StallWarning warning) {
               //System.out.println("Got stall warning:" + warning);
           }

           @Override
           public void onException(Exception ex) {
               //ex.printStackTrace();
           }
       };
       twitterStream.addListener(listener);
       twitterStream.sample();



      // reader.start();

    }

	@OnMessage
	public void onMessage(String message, Session session){
        System.out.println("Message from " + session.getId() + ": " + message);
        reader.setFilter(message);
    }

	@OnClose
    public void onClose(Session session){
        System.out.println("Session " +session.getId()+" has ended");
        twitterStream.cleanUp(); // shutdown internal stream consuming thread
       twitterStream.shutdown();


        reader.kill();
    }




}
