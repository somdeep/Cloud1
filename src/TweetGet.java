import com.alchemyapi.*;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import com.alchemyapi.test.*;

import com.alchemyapi.api.AlchemyAPI;
import com.alchemyapi.api.*;

import java.io.StringWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterException;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.conf.ConfigurationBuilder;

/**
 * <p>This is a code example of Twitter4J Streaming API - sample method support.<br>
 * Usage: java twitter4j.examples.PrintSampleStream<br>
 * </p>
 *
 * @author Yusuke Yamamoto - yusuke at mac.com
 */
public final class TweetGet {

	//private static Connection con;
	private static Statement stmt;

	public static void connectDB() throws SQLException, ClassNotFoundException {

		//for connectiong to RDS
    	Class.forName("com.mysql.jdbc.Driver");
    	Connection con = DriverManager.getConnection(    			);
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
         //System.out.println("Created table in given database...");
      }



	public static void insertRecord (String userName, Double lon, Double lat,String place,String source, String text) throws SQLException{
		String sql = "INSERT INTO tweet1 (userName, longitude, latitude, place,source,text) "+
  			  "VALUES (\"" + userName + "\", \"" + lon + "\", \"" + lat + "\", \""+ place + "\", \"" + source + "\", \"" + text + "\")";
		//System.out.println(sql);
  		stmt.executeUpdate(sql);

	}


    public static void main(String[] args) throws Exception {

		connectDB();
    	//just fill this
		Document doc;
		  AlchemyAPI alchemyObj = AlchemyAPI.GetInstanceFromFile("src/api_key.txt");
		 //doc=alchemyObj.TextGetTextSentiment("Y");
		  AlchemyAPI_TargetedSentimentParams sentimentParams = new AlchemyAPI_TargetedSentimentParams();
			sentimentParams.setShowSourceText(true);
		  doc = alchemyObj.TextGetTextSentiment("screw you");
		  NodeList part=doc.getElementsByTagName("docSentiment");
		 org.w3c.dom.Element el =(org.w3c.dom.Element)part.item(0);
		 // System.out.println(getStringFromDocument(doc));
		 System.out.println(el.getTextContent());
		  ConfigurationBuilder cb = new ConfigurationBuilder();
		 cb.setDebugEnabled(true)
         .setOAuthConsumerKey("")
         .setOAuthConsumerSecret("")
         .setOAuthAccessToken("")
         .setOAuthAccessTokenSecret("");


        TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
        StatusListener listener = new StatusListener() {
            @Override
            public void onStatus(Status status) {
            	if (status.getGeoLocation()!=null  ){
            		System.out.println("@" + status.getUser().getScreenName() + " - "+ status.getPlace().getCountry()+ " - " + status.getText());
            		System.out.println(status.getGeoLocation());
            		try
            		{
            		Document doc = alchemyObj.TextGetTextSentiment(status.getText());
            		NodeList part=doc.getElementsByTagName("docSentiment");
           		 org.w3c.dom.Element el =(org.w3c.dom.Element)part.item(0);
           		 // System.out.println(getStringFromDocument(doc));
           		 System.out.println("Sentiment" + el.getTextContent());

            		}
            		catch(Exception e)
            		{
            			System.out.println(e);
            		}
            		//System.out.println(status.getPlace());
            		String source,place;
            		double lon = status.getGeoLocation().getLongitude();
            		double lat = status.getGeoLocation().getLatitude();


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



					try {
						insertRecord(status.getUser().getScreenName(), lon, lat,place,source,status.getText());
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}


            	}
            }

            @Override
            public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
                //System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
            }

            @Override
            public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
         //       System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
            }

            @Override
            public void onScrubGeo(long userId, long upToStatusId) {
     //           System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
            }

            @Override
            public void onStallWarning(StallWarning warning) {
       //         System.out.println("Got stall warning:" + warning);
            }

            @Override
            public void onException(Exception ex) {
                ex.printStackTrace();
            }
        };
        FilterQuery fq = new FilterQuery();

        String keywords[] = {"love"};

        fq.track(keywords);


        twitterStream.addListener(listener);
        twitterStream.filter(fq);
       // twitterStream.sample();
    }
    private static String getStringFromDocument(Document doc) {
        try {
            DOMSource domSource = new DOMSource(doc);
            StringWriter writer = new StringWriter();
            StreamResult result = new StreamResult(writer);

            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            transformer.transform(domSource, result);

            return writer.toString();
        } catch (TransformerException ex) {
            ex.printStackTrace();
            return null;
        }
    }

}
