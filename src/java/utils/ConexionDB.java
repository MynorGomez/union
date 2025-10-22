package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/db_empresa";
    private static final String USER = "root";
    private static final String PASSWORD = "Minato15@"; // ⚠️ cambia si tu contraseña es diferente

    private Connection conexion;

    public ConexionDB() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conexion = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ Conexión exitosa a MySQL.");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error: No se encontró el driver MySQL JDBC.");
        } catch (SQLException e) {
            System.err.println("❌ Error al conectar a MySQL: " + e.getMessage());
        }
    }

    public Connection getConexion() {
        return conexion;
    }

    public void cerrarConexion() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("🔒 Conexión cerrada correctamente.");
            }
        } catch (SQLException e) {
            System.err.println("⚠️ Error al cerrar conexión: " + e.getMessage());
        }
    }
}
