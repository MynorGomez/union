package modelo;

import java.sql.*;
import utils.ConexionDB;

public class VentaDetalle {
    private int id_detalle, id_venta, id_producto, cantidad;
    private double precio_unitario, subtotal;

    public void setId_venta(int id) { this.id_venta = id; }
    public void setId_producto(int id) { this.id_producto = id; }
    public void setCantidad(int c) { this.cantidad = c; this.subtotal = c * precio_unitario; }
    public void setPrecio_unitario(double p) { this.precio_unitario = p; this.subtotal = cantidad * p; }

    public boolean agregar(Connection con) throws SQLException {
        String q = "INSERT INTO ventas_detalle (id_venta,id_producto,cantidad,precio_unitario,subtotal) VALUES (?,?,?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(q)) {
            ps.setInt(1, id_venta);
            ps.setInt(2, id_producto);
            ps.setInt(3, cantidad);
            ps.setDouble(4, precio_unitario);
            ps.setDouble(5, subtotal);
            return ps.executeUpdate() > 0;
        }
    }
}
