package com.microsoft.azuresample.javawebapp.Utils;

import org.springframework.stereotype.Component;
import javax.annotation.PostConstruct;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class PostgreSqlHelper {
    static final Logger LOG = LoggerFactory.getLogger(PostgreSqlHelper.class);

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

        LOG.info("### INIT of PostgreSqlHelper called.");
    }
}
