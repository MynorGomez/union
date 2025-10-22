package modelo;

import java.sql.*;
import utils.ConexionDB;

public class VentaDetalle {
    private int id_detalle;
    private int id_venta;
    private int id_producto;
    private int cantidad;
    private double precio_unitario;
    private double subtotal;

    ConexionDB cn = new ConexionDB();

    public boolean agregar() {
        String sql = "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id_venta);
            ps.setInt(2, id_producto);
            ps.setInt(3, cantidad);
            ps.setDouble(4, precio_unitario);
            ps.setDouble(5, subtotal);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println("❌ Error al agregar detalle: " + e.getMessage());
            return false;
        }
    }

    // Getters y setters
    public void setId_venta(int id) { this.id_venta = id; }
    public void setId_producto(int id) { this.id_producto = id; }
    public void setCantidad(int c) { this.cantidad = c; }
    public void setPrecio_unitario(double p) { this.precio_unitario = p; }
    public void setSubtotal(double s) { this.subtotal = s; }

    public int getId_detalle() {
        return id_detalle;
    }

    public int getId_venta() {
        return id_venta;
    }

    public int getId_producto() {
        return id_producto;
    }

    public int getCantidad() {
        return cantidad;
    }

    public double getPrecio_unitario() {
        return precio_unitario;
    }

    public double getSubtotal() {
        return subtotal;
    }
}
