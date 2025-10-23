package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.ConexionDB;

public class Venta {
    private int id_venta;
    private String no_factura;
    private String serie;
    private Timestamp fecha_venta;
    private int id_cliente;
    private int id_empleado;
    private double total;
    private String cliente;
    private String empleado;

    ConexionDB cn = new ConexionDB();

    public Venta() {}

    public Venta(int id, String factura, String serie, Timestamp fecha, int idCliente, int idEmpleado, double total, String cliente, String empleado) {
        this.id_venta = id;
        this.no_factura = factura;
        this.serie = serie;
        this.fecha_venta = fecha;
        this.id_cliente = idCliente;
        this.id_empleado = idEmpleado;
        this.total = total;
        this.cliente = cliente;
        this.empleado = empleado;
    }

    // Getters y setters
    public int getId_venta() { return id_venta; }
    public void setId_venta(int id) { this.id_venta = id; }
    public String getNo_factura() { return no_factura; }
    public void setNo_factura(String nf) { this.no_factura = nf; }
    public String getSerie() { return serie; }
    public void setSerie(String s) { this.serie = s; }
    public Timestamp getFecha_venta() { return fecha_venta; }
    public void setFecha_venta(Timestamp f) { this.fecha_venta = f; }
    public int getId_cliente() { return id_cliente; }
    public void setId_cliente(int id) { this.id_cliente = id; }
    public int getId_empleado() { return id_empleado; }
    public void setId_empleado(int id) { this.id_empleado = id; }
    public double getTotal() { return total; }
    public void setTotal(double t) { this.total = t; }
    public String getCliente() { return cliente; }
    public void setCliente(String c) { this.cliente = c; }
    public String getEmpleado() { return empleado; }
    public void setEmpleado(String e) { this.empleado = e; }

    // Insertar venta
    public boolean agregar() {
        // Delegar a la versión que recibe Connection para compatibilidad con transacciones
        try (Connection con = cn.getConexion()) {
            return agregar(con);
        } catch (SQLException e) {
            System.out.println("❌ Error al agregar venta: " + e.getMessage());
            return false;
        }
    }
    
    // Versión que usa la Connection proporcionada (no cierra la conexión)
    public boolean agregar(Connection con) {
        String sql = "INSERT INTO ventas (no_factura, serie, fecha_venta, id_cliente, id_empleado, total) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, no_factura);
            ps.setString(2, serie);
            ps.setTimestamp(3, fecha_venta);
            ps.setInt(4, id_cliente);
            ps.setInt(5, id_empleado);
            ps.setDouble(6, total);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    this.id_venta = rs.getInt(1);
                }
            }
            return true;
        } catch (SQLException e) {
            System.out.println("❌ Error al agregar venta (conexión externa): " + e.getMessage());
            return false;
        }
    }
    
    public int getUltimoId() {
        return this.id_venta;
    }

    // Devuelve la lista de ventas (incluye nombres de cliente y empleado si existen)
    public List<Venta> listar() {
        List<Venta> lista = new ArrayList<>();
        String sql = "SELECT v.id_venta, v.no_factura, v.serie, v.fecha_venta, v.id_cliente, v.id_empleado, v.total, "
                   + "COALESCE(c.nombres, '') AS cliente, COALESCE(e.nombres, '') AS empleado "
                   + "FROM ventas v "
                   + "LEFT JOIN clientes c ON v.id_cliente = c.id_cliente "
                   + "LEFT JOIN empleados e ON v.id_empleado = e.id_empleado "
                   + "ORDER BY v.id_venta DESC";
        try (Connection con = cn.getConexion(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Venta v = new Venta(
                    rs.getInt("id_venta"),
                    rs.getString("no_factura"),
                    rs.getString("serie"),
                    rs.getTimestamp("fecha_venta"),
                    rs.getInt("id_cliente"),
                    rs.getInt("id_empleado"),
                    rs.getDouble("total"),
                    rs.getString("cliente"),
                    rs.getString("empleado")
                );
                lista.add(v);
            }
        } catch (SQLException e) {
            System.out.println("❌ Error al listar ventas: " + e.getMessage());
        }
        return lista;
    }
}