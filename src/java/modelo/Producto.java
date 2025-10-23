package modelo;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;


public class Producto {
    private int id_producto;
    private String producto;
    private int id_marca;
    private String descripcion;
    private String imagen_url;
    private double precio_costo;
    private double precio_venta;
    private int existencia;
    private String marca;  // Para mostrar el nombre de la marca
    private ConexionDB cn;

    public Producto() {
        cn = new ConexionDB();
    }

    public Producto(int id_producto, String producto, int id_marca, String descripcion, String imagen_url, 
                   double precio_costo, double precio_venta, int existencia, String marca) {
        this.id_producto = id_producto;
        this.producto = producto;
        this.id_marca = id_marca;
        this.descripcion = descripcion;
        this.imagen_url = imagen_url;
        this.precio_costo = precio_costo;
        this.precio_venta = precio_venta;
        this.existencia = existencia;
        this.marca = marca;
    }

    // Getters y Setters
    public int getId_producto() { return id_producto; }
    public void setId_producto(int id_producto) { this.id_producto = id_producto; }
    
    public String getProducto() { return producto; }
    public void setProducto(String producto) { this.producto = producto; }
    
    public int getId_marca() { return id_marca; }
    public void setId_marca(int id_marca) { this.id_marca = id_marca; }
    
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    
    public String getImagen_url() { return imagen_url; }
    public void setImagen_url(String imagen_url) { this.imagen_url = imagen_url; }
    
    public double getPrecio_costo() { return precio_costo; }
    public void setPrecio_costo(double precio_costo) { this.precio_costo = precio_costo; }
    
    public double getPrecio_venta() { return precio_venta; }
    public void setPrecio_venta(double precio_venta) { this.precio_venta = precio_venta; }
    
    public int getExistencia() { return existencia; }
    public void setExistencia(int existencia) { this.existencia = existencia; }
    
    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    public HashMap<String, String> insertar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "INSERT INTO productos(producto, id_marca, descripcion, imagen_url, precio_costo, precio_venta, existencia) " +
                        "VALUES(?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setString(1, getProducto());
            stmt.setInt(2, getId_marca());
            stmt.setString(3, getDescripcion());
            stmt.setString(4, getImagen_url());
            stmt.setDouble(5, getPrecio_costo());
            stmt.setDouble(6, getPrecio_venta());
            stmt.setInt(7, getExistencia());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto agregado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }

    public HashMap<String, String> actualizar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "UPDATE productos SET producto=?, id_marca=?, descripcion=?, " +
                        "imagen_url=?, precio_costo=?, precio_venta=?, existencia=? " +
                        "WHERE id_producto=?";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setString(1, getProducto());
            stmt.setInt(2, getId_marca());
            stmt.setString(3, getDescripcion());
            stmt.setString(4, getImagen_url());
            stmt.setDouble(5, getPrecio_costo());
            stmt.setDouble(6, getPrecio_venta());
            stmt.setInt(7, getExistencia());
            stmt.setInt(8, getId_producto());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto actualizado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }

    public HashMap<String, String> eliminar() {
        HashMap<String, String> resultado = new HashMap<>();
        try {
            String sql = "DELETE FROM productos WHERE id_producto = ?";
            PreparedStatement stmt = cn.getConexion().prepareStatement(sql);
            stmt.setInt(1, getId_producto());
            stmt.executeUpdate();
            resultado.put("resultado", "1");
            resultado.put("mensaje", "Producto eliminado correctamente");
        } catch (SQLException e) {
            resultado.put("resultado", "0");
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        return resultado;
    }

    public List<Producto> leer() {
        List<Producto> lista = new ArrayList<>();
        try {
            String sql = "SELECT p.*, m.marca FROM productos p " +
                        "LEFT JOIN marcas m ON p.id_marca = m.id_marca " +
                        "ORDER BY p.id_producto";
            ResultSet rs = cn.getConexion().createStatement().executeQuery(sql);
            while(rs.next()) {
                Producto producto = new Producto();
                producto.setId_producto(rs.getInt("id_producto"));
                producto.setProducto(rs.getString("producto"));
                producto.setId_marca(rs.getInt("id_marca"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setImagen_url(rs.getString("imagen_url"));
                producto.setPrecio_costo(rs.getDouble("precio_costo"));
                producto.setPrecio_venta(rs.getDouble("precio_venta"));
                producto.setExistencia(rs.getInt("existencia"));
                producto.setMarca(rs.getString("marca"));
                lista.add(producto);
            }
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
        return lista;
    }
}