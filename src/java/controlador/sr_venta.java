package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import modelo.*;
public class sr_venta extends HttpServlet {
    
    private int obtenerIdCliente(String nit) {
        String sql = "SELECT id_cliente FROM clientes WHERE nit = ?";
        try (Connection con = new utils.ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nit);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id_cliente");
            }
        } catch (SQLException e) {
            System.out.println("Error al buscar cliente: " + e.getMessage());
        }
        return 0;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String nit = request.getParameter("nit");
            String nombres = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String direccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");

            int id_cliente = obtenerIdCliente(nit);

            // Si el cliente no existe → lo creamos
            if (id_cliente == 0) {
                String sql = "INSERT INTO clientes (nit, nombres, apellidos, direccion, telefono) VALUES (?, ?, ?, ?, ?)";
                try (Connection con = new utils.ConexionDB().getConexion();
                     PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, nit);
                    ps.setString(2, nombres);
                    ps.setString(3, apellidos);
                    ps.setString(4, direccion);
                    ps.setString(5, telefono);
                    ps.executeUpdate();

                    ResultSet rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        id_cliente = rs.getInt(1);
                    }
                }
            }

            // Crear venta
            Venta v = new Venta();
            v.setNo_factura(request.getParameter("no_factura"));
            v.setSerie(request.getParameter("serie"));
            v.setFecha_venta(Timestamp.valueOf(LocalDateTime.now()));
            v.setId_cliente(id_cliente);
            v.setId_empleado(Integer.parseInt(request.getParameter("id_empleado")));
            v.setTotal(Double.parseDouble(request.getParameter("total")));

            if (v.agregar()) {
                int idVenta = v.getUltimoId();

                // Procesar detalles de JSON
                String detallesJson = request.getParameter("detalles");
                if (detallesJson != null && !detallesJson.isEmpty()) {
                    try {
                        org.json.JSONArray detalles = new org.json.JSONArray(detallesJson);
                        for (int i = 0; i < detalles.length(); i++) {
                            org.json.JSONObject detalle = detalles.getJSONObject(i);
                            
                            VentaDetalle d = new VentaDetalle();
                            d.setId_venta(idVenta);
                            d.setId_producto(detalle.getInt("id_producto"));
                            d.setCantidad(detalle.getInt("cantidad"));
                            d.setPrecio_unitario(detalle.getDouble("precio"));
                            d.setSubtotal(detalle.getDouble("subtotal"));
                            
                            // Verificar si ya existe el producto en la venta
                            if (d.existe(idVenta, d.getId_producto())) {
                                d.actualizarCantidad(idVenta, d.getId_producto(), d.getCantidad());
                            } else {
                                d.agregar();
                            }
                    }
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Error en sr_venta: " + e.getMessage());
        }

        response.sendRedirect("views/ventas.jsp");
    }



    private int obtenerUltimoIdVenta() {
        String sql = "SELECT MAX(id_venta) FROM ventas";
        try (Connection con = new utils.ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("❌ Error al obtener ID venta: " + e.getMessage());
        }
        return 0;
    }
}
