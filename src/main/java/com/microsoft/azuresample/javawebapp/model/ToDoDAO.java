package com.microsoft.azuresample.javawebapp.model;

import org.springframework.stereotype.Component;
import com.microsoft.azuresample.javawebapp.Utils.PostgreSqlHelper;
import java.sql.Connection;
import javax.annotation.PostConstruct;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by vazvadsk on 2016-12-05.
 */
@Component
public class ToDoDAO {
    static final Logger LOG = LoggerFactory.getLogger(ToDo.class);

    @PostConstruct
    public void init(){
        LOG.info("### INIT of ToDoDAO called.");

        try {
            Connection conn = PostgreSqlHelper.GetConnection();
            try (PreparedStatement stmt = conn.prepareStatement(
                            "CREATE TABLE IF NOT EXISTS ToDo(\n" +
                            " Id varchar(50) NOT NULL,\n" +
                            " Category varchar(50) NULL,\n" +
                            " Comment varchar(500) NULL,\n" +
                            " Created timestamp NOT NULL,\n" +
                            " Updated timestamp NOT NULL\n" +
                            ");"))
            {
                stmt.executeUpdate();
            }finally {
                conn.close();
            }
        } catch (SQLException e) {
            LOG.error("ERROR: cannot connect to PostgreSQL Server.");
        }
    }

    public List<ToDo> query(){
        List<ToDo> ret = new ArrayList<ToDo>();
        try {
            Connection conn = PostgreSqlHelper.GetConnection();
            try (PreparedStatement selectStatement = conn.prepareStatement(
                    "SELECT Id, Comment, Category, Created, Updated FROM ToDo"))
            {
                ResultSet rs = selectStatement.executeQuery();
                while(rs.next()) {
                    ret.add(new ToDo(
                            rs.getString("Id"),
                            rs.getString("Comment"),
                            rs.getString("Category"),
                            rs.getDate("Created"),
                            rs.getDate("Updated")
                            ));
                }
                rs.close();
            }finally {
                conn.close();
            }
        } catch (SQLException e) {
            LOG.error("ERROR: cannot connect to PostgreSQL Server.");
        }
        return ret;
    }

    public ToDo create(ToDo item){

        try {
            Connection conn = PostgreSqlHelper.GetConnection();
            try (PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO ToDo(Id, Comment, Category, Created, Updated) VALUES(?,?,?,?,?)"))
            {
                stmt.setString(1, item.getId());
                stmt.setString(2, item.getComment());
                stmt.setString(3, item.getCategory());
                stmt.setDate(4, new java.sql.Date(item.getCreated().getTime()));
                stmt.setDate(5, new java.sql.Date(item.getUpdated().getTime()));
                System.out.println("INSERT: before insert call.");
                stmt.executeUpdate();
            }finally {
                conn.close();
            }
        } catch (SQLException e) {
            LOG.error("ERROR: cannot connect to PostgreSQL Server.");
        }

        return item;
    }

    public ToDo update(ToDo item){
        
                try {
                    Connection conn = PostgreSqlHelper.GetConnection();
                    try (PreparedStatement stmt = conn.prepareStatement(
                            "UPDATE ToDo SET Comment=?, Category=?, Updated=? WHERE id=?"))
                    {
                        stmt.setString(4, item.getId());
                        stmt.setString(1, item.getComment());
                        stmt.setString(2, item.getCategory());
                        stmt.setDate(3, new java.sql.Date(item.getUpdated().getTime()));
                        System.out.println("UPDATE: before update call.");
                        stmt.executeUpdate();
                    }finally {
                        conn.close();
                    }
                } catch (SQLException e) {
                    LOG.error("ERROR: cannot connect to PostgreSQL Server.");
                }
        
                return item;
            }
        }
