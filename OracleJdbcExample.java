import java.lang.*;
import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import oracle.jdbc.OracleDriver;

public class OracleJdbcExample
{

    public static void main(String args[]) throws Exception {

    //String url = "jdbc:oracle:thin:@<SCAN-NAME>:<PORT>/<SERVICE_NAME>";
    String url="";
	String scan_hostname="";
	String lsnr_port="";
	String service_name="";
	String user="";
	String password="";

        if (args.length==5)
        {
            scan_hostname = args[0];
            lsnr_port     = args[1];
            service_name  = args[2];
	        user          = args[3];
	        password      = args[4]; 
            url = "jdbc:oracle:thin:@" + scan_hostname + ":" + lsnr_port + "/" + service_name;
        }
        else 
        {   
            System.out.println("Usage: java OracleJdbcExample <SCAN/HOST_NAME/IP> <PORT> <SERVICE NAME> <USERNAME> <PASSWORD>");
            System.exit(1);
        }

        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", password);

        DriverManager.registerDriver(new OracleDriver());

        Connection conn = DriverManager.getConnection(url,props);

        String sql ="select instance_name as instance_name, host_name as host_name from gv$instance";


        PreparedStatement preStatement = conn.prepareStatement(sql);

        ResultSet result = preStatement.executeQuery();

        System.out.println("");
        while(result.next()){
            System.out.println("Instance Name from Oracle : " + result.getString("instance_name"));
            System.out.println("Host Name from Oracle : " + result.getString("host_name"));
        }
        System.out.println("");

    }
}

// [oracle@oraclevm jdbc]$ export CLASSPATH=$ORACLE_HOME/jdbc/lib/ojdbc8.jar:.
// [oracle@oraclevm jdbc]$ export PATH=$ORACLE_HOME/jdk/bin:$PATH
// [oracle@oraclevm jdbc]$ which java
// /u01/app/oracle/product/19.0.0/dbhome_1/jdk/bin/java
// [oracle@oraclevm jdbc]$ which javac
// /u01/app/oracle/product/19.0.0/dbhome_1/jdk/bin/javac
// [oracle@oraclevm jdbc]$ javac OracleJdbcExample.java 
// [oracle@oraclevm jdbc]$ java OracleJdbcExample 
// Usage: java OracleJdbcExample <SCAN/HOST_NAME/IP> <PORT> <SERVICE NAME> <USERNAME> <PASSWORD>
// [oracle@oraclevm jdbc]$ java OracleJdbcExample oraclevm 1521 ORADB test test
// 
// Instance Name from Oracle : ORADB
// Host Name from Oracle : oraclevm.localdomain.com
// 
// [oracle@oraclevm jdbc]$