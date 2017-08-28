package com.microsoft.azuresample.javawebapp.Utils;

import org.springframework.stereotype.Component;
import javax.annotation.PostConstruct;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Map;

@Component
public class PostgreSqlHelper {

    public static String sqlurl;

    public static Connection GetConnection() throws SQLException {
        if(sqlurl==null){
            new PostgreSqlHelper().Init();
        }

        Connection connection = (Connection) DriverManager.getConnection(sqlurl);
        return connection;
    }

    public void Init(){
        Map<String, String> env = System.getenv();
        sqlurl = env.get("POSTGRESQLSERVER_URL");

        System.out.println("### INIT of PostgreSqlHelper called.");
    }
}
