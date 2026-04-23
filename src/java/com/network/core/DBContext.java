package com.network.core;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext - Manages database connections.
 * 
 * Updated configuration for SQL Server.
 */
public class DBContext {
    private static final String HOST = "localhost";
    private static final String PORT = "1433"; // Default SQL Server port
    private static final String DB_NAME = "web_chat_db";
    private static final String USER = "sa"; // Default SQL Server admin
    private static final String PASS = "123"; // Updated password

    public static Connection getConnection() throws ClassNotFoundException, SQLException {
        // SQL Server Connection URL
        String url = "jdbc:sqlserver://" + HOST + ":" + PORT + ";"
                + "databaseName=" + DB_NAME + ";"
                + "encrypt=true;trustServerCertificate=true;";
        
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, USER, PASS);
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ex) {
                Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
}
