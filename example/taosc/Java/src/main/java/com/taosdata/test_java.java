package com.taosdata;
import java.sql.*;
import java.util.*;
 
public class test_java {
 
    public static void main(String[] args) throws Exception {
        Connection conn = getConn();
        Statement stmt = conn.createStatement();
        stmt.executeUpdate("use db01");
        stmt.executeUpdate("create table if not exists test04 (ts timestamp, v1 int)");
        int affectedRows = stmt.executeUpdate("insert into test04 values(1643731200000,1)");
        System.out.println("Insert rows:" + affectedRows);
        ResultSet resultSet = stmt.executeQuery("select * from test04");
        Timestamp ts = null;
        int v1 = 0;
        while(resultSet.next()){
            ts = resultSet.getTimestamp(1);
            v1 = resultSet.getInt(2);
            System.out.printf("%s, %d\n", ts, v1);
        }
    }
 
    public static Connection getConn() throws Exception{
        Class.forName("com.taosdata.jdbc.TSDBDriver");
        String jdbcUrl = "jdbc:TAOS:///db01?user=root&password=taosdata";
        Properties connProps = new Properties();
        Connection conn = DriverManager.getConnection(jdbcUrl, connProps);
        return conn;
    }
 
}