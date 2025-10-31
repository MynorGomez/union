package modelo;

<<<<<<< HEAD
import java.sql.*;
import java.util.*;
=======
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
>>>>>>> fusion
import utils.ConexionDB;

public class Marca {
    private int id_marca;
    private String marca;
<<<<<<< HEAD
    ConexionDB cn = new ConexionDB();

    // Constructores
    public Marca() {}
=======
    private ConexionDB cn;
    
    public Marca() {
        cn = new ConexionDB();
    }
    
>>>>>>> fusion
    public Marca(int id_marca, String marca) {
        this.id_marca = id_marca;
        this.marca = marca;
    }
<<<<<<< HEAD

    // Getters y Setters
    public int getId_marca() { return id_marca; }
    public void setId_marca(int id_marca) { this.id_marca = id_marca; }
    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    // ==========================================================
    // CRUD MODERNO - Devuelve booleanos (para AJAX)
    // ==========================================================

    // 🔹 AGREGAR
    public boolean agregar() {
        String sql = "INSERT INTO marcas (marca) VALUES (?)";
        try (Connection con = cn.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, marca);
            ps.executeUpdate();
            System.out.println("✅ Marca agregada: " + marca);
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al agregar marca: " + e.getMessage());
            return false;
        }
    }

    // 🔹 ACTUALIZAR
    public boolean actualizar() {
        String sql = "UPDATE marcas SET marca=? WHERE id_marca=?";
        try (Connection con = cn.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, marca);
            ps.setInt(2, id_marca);
            ps.executeUpdate();
            System.out.println("✅ Marca actualizada: ID " + id_marca);
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar marca: " + e.getMessage());
            return false;
        }
    }

    // 🔹 ELIMINAR
    public boolean eliminar() {
        String sql = "DELETE FROM marcas WHERE id_marca=?";
        try (Connection con = cn.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id_marca);
            ps.executeUpdate();
            System.out.println("✅ Marca eliminada: ID " + id_marca);
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar marca: " + e.getMessage());
            return false;
        }
    }

    // 🔹 LEER
    public List<Marca> leer() {
        List<Marca> lista = new ArrayList<>();
        String sql = "SELECT * FROM marcas ORDER BY marca";
        try (Connection con = cn.getConexion();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                lista.add(new Marca(
                    rs.getInt("id_marca"),
                    rs.getString("marca")
                ));
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al leer marcas: " + e.getMessage());
        }
        return lista;
    }
}
=======
    
    // Getters y Setters
    public int getId_marca() { return id_marca; }
    public void setId_marca(int id_marca) { this.id_marca = id_marca; }
    
    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }
    
    public HashMap<String, String> insertar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "INSERT INTO marcas(marca) VALUES(?)";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setString(1, getMarca());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Marca agregada correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }
    
    public HashMap<String, String> actualizar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "UPDATE marcas SET marca=? WHERE id_marca=?";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setString(1, getMarca());
            stmt.setInt(2, getId_marca());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Marca actualizada correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }
    
    public HashMap<String, String> eliminar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "DELETE FROM marcas WHERE id_marca = ?";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setInt(1, getId_marca());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Marca eliminada correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }
    
    public List<Marca> leer() {
        List<Marca> lista = new ArrayList<>();
        try {
            String sql = "SELECT * FROM marcas ORDER BY marca";
            ResultSet rs = cn.getConexion().createStatement().executeQuery(sql);
            while(rs.next()) {
                Marca marca = new Marca();
                marca.setId_marca(rs.getInt("id_marca"));
                marca.setMarca(rs.getString("marca"));
                lista.add(marca);
            }
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
        return lista;
    }
}
>>>>>>> fusion
