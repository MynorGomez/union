package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import modelo.*;

@WebServlet(name = "sr_venta", urlPatterns = {"/sr_venta"})
public class sr_venta extends HttpServlet {

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
                int idVenta = obtenerUltimoIdVenta();

                // Insertar los detalles
                String[] productos = request.getParameterValues("id_producto");
                String[] cantidades = request.getParameterValues("cantidad");
                String[] precios = request.getParameterValues("precio");

                if (productos != null) {
                    for (int i = 0; i < productos.length; i++) {
                        VentaDetalle d = new VentaDetalle();
                        d.setId_venta(idVenta);
                        d.setId_producto(Integer.parseInt(productos[i]));
                        d.setCantidad(Integer.parseInt(cantidades[i]));
                        double precio = Double.parseDouble(precios[i]);
                        d.setPrecio_unitario(precio);
                        d.setSubtotal(precio * d.getCantidad());
                        d.agregar();
                    }
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Error en sr_venta: " + e.getMessage());
        }

        response.sendRedirect("views/ventas.jsp");
    }

    private int obtenerIdCliente(String nit) {
        String sql = "SELECT id_cliente FROM clientes WHERE nit=?";
        try (Connection con = new utils.ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nit);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id_cliente");
        } catch (Exception e) {
            System.out.println("❌ Error al buscar cliente: " + e.getMessage());
        }
        return 0;
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
