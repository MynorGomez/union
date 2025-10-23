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
    
    public VentaDetalle() {
        // No mantenemos una ConexionDB con estado; cada método solicitará su propia Connection.
    }

    public int getId_detalle() { return id_detalle; }
    public void setId_detalle(int id) { this.id_detalle = id; }

    public int getId_venta() { return id_venta; }
    public void setId_venta(int id_venta) { this.id_venta = id_venta; }

    public int getId_producto() { return id_producto; }
    public void setId_producto(int id_producto) { 
        this.id_producto = id_producto;
        this.precio_unitario = obtenerPrecioProducto(id_producto);
        if (this.cantidad > 0) {
            this.subtotal = this.cantidad * this.precio_unitario;
        }
    }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { 
        this.cantidad = cantidad;
        if (this.precio_unitario > 0) {
            this.subtotal = this.cantidad * this.precio_unitario;
        }
    }

    public double getPrecio_unitario() { return precio_unitario; }
    public void setPrecio_unitario(double precio_unitario) { 
        this.precio_unitario = precio_unitario;
        if (this.cantidad > 0) {
            this.subtotal = this.cantidad * this.precio_unitario;
        }
    }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    private double obtenerPrecioProducto(int idProducto) {
        double precio = 0;
        String query = "SELECT precio_venta FROM productos WHERE id_producto = ?";
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, idProducto);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                precio = rs.getDouble("precio_venta");
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener precio: " + e.getMessage());
        }
        return precio;
    }

    public boolean existe(int idVenta, int idProducto) {
        String query = "SELECT COUNT(*) FROM ventas_detalle WHERE id_venta = ? AND id_producto = ?";
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, idVenta);
            ps.setInt(2, idProducto);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error al verificar existencia: " + e.getMessage());
        }
        return false;
    }

    public void actualizarCantidad(int idVenta, int idProducto, int cantidadAdicional) {
        String query = "UPDATE ventas_detalle SET cantidad = cantidad + ?, " +
                      "subtotal = (cantidad + ?) * precio_unitario " +
                      "WHERE id_venta = ? AND id_producto = ?";
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, cantidadAdicional);
            ps.setInt(2, cantidadAdicional);
            ps.setInt(3, idVenta);
            ps.setInt(4, idProducto);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Error al actualizar cantidad: " + e.getMessage());
        }
    }

    public boolean agregar() throws SQLException {
        // Validar que el producto existe
        if (!existeProducto(id_producto)) {
            throw new SQLException("El producto con ID " + id_producto + " no existe");
        }
        
        // Validar que la cantidad sea positiva
        if (cantidad <= 0) {
            throw new SQLException("La cantidad debe ser mayor que 0");
        }
        
        // Validar que el precio sea positivo
        if (precio_unitario <= 0) {
            throw new SQLException("El precio debe ser mayor que 0");
        }
        
        // Calcular el subtotal
        this.subtotal = this.cantidad * this.precio_unitario;
        
        String query = "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, " +
                      "precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, id_venta);
            ps.setInt(2, id_producto);
            ps.setInt(3, cantidad);
            ps.setDouble(4, precio_unitario);
            ps.setDouble(5, subtotal);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.out.println("Error al agregar detalle: " + e.getMessage());
            throw e; // Re-lanzar la excepción para manejarla en la transacción
        }
    }

    // Versión que usa la Connection de la transacción (no la cierra)
    public boolean agregar(Connection con) throws SQLException {
        // Validar que el producto existe usando la misma conexión
        if (!existeProducto(con, id_producto)) {
            throw new SQLException("El producto con ID " + id_producto + " no existe");
        }
        if (cantidad <= 0) {
            throw new SQLException("La cantidad debe ser mayor que 0");
        }
        if (precio_unitario <= 0) {
            throw new SQLException("El precio debe ser mayor que 0");
        }
        this.subtotal = this.cantidad * this.precio_unitario;

        String query = "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, id_venta);
            ps.setInt(2, id_producto);
            ps.setInt(3, cantidad);
            ps.setDouble(4, precio_unitario);
            ps.setDouble(5, subtotal);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.out.println("Error al agregar detalle (conexión externa): " + e.getMessage());
            throw e;
        }
    }
    
    private boolean existeProducto(int idProducto) {
        // Por compatibilidad, llama a la versión que crea su propia conexión
        try (Connection con = new ConexionDB().getConexion()) {
            return existeProducto(con, idProducto);
        } catch (SQLException e) {
            System.out.println("Error al verificar producto: " + e.getMessage());
            return false;
        }
    }

    private boolean existeProducto(Connection con, int idProducto) {
        String query = "SELECT COUNT(*) FROM productos WHERE id_producto = ?";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, idProducto);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error al verificar producto (conexión externa): " + e.getMessage());
        }
        return false;
    }
}