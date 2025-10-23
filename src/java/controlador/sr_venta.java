package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDateTime;
import modelo.*;

@WebServlet(name = "sr_venta", urlPatterns = {"/sr_venta"})
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
        
        response.setContentType("text/html;charset=UTF-8");
        Connection con = null;
        
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
                try (Connection conexion = new utils.ConexionDB().getConexion();
                     PreparedStatement ps = conexion.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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

            con = new utils.ConexionDB().getConexion();
            // Iniciar transacción
            con.setAutoCommit(false);

                if (v.agregar()) {
                    int idVenta = v.getUltimoId();
                    if (idVenta == 0) {
                        throw new SQLException("No se pudo obtener el ID de la venta");
                    }

                    String[] productos = request.getParameterValues("id_producto[]");
                    String[] cantidades = request.getParameterValues("cantidad[]");
                    String[] precios = request.getParameterValues("precio[]");

                    if (productos != null) {
                        for (int i = 0; i < productos.length; i++) {
                            VentaDetalle d = new VentaDetalle();
                            d.setId_venta(idVenta);
                            d.setId_producto(Integer.parseInt(productos[i]));
                            d.setCantidad(Integer.parseInt(cantidades[i]));
                            d.setPrecio_unitario(Double.parseDouble(precios[i]));
                            
                            // Calcular el subtotal después de establecer cantidad y precio
                            if (!d.agregar()) {
                                throw new SQLException("Error al agregar el detalle de la venta");
                            }
                        }
                    }

                    // Si todo está bien, confirmar la transacción
                    con.commit();
                    
                    response.setContentType("text/html;charset=UTF-8");
                    try (PrintWriter out = response.getWriter()) {
                        out.println("<html><body>");
                        out.println("<script type='text/javascript'>");
                        out.println("alert('Venta registrada exitosamente');");
                        out.println("window.location='views/lista_ventas.jsp';");
                        out.println("</script>");
                        out.println("</body></html>");
                    }
            } else {
                throw new SQLException("Error al crear la venta");
            }

        } catch (Exception e) {
            // Si hay error, hacer rollback
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    System.out.println("❌ Error al hacer rollback: " + ex.getMessage());
                }
            }
            
            System.out.println("❌ Error en sr_venta: " + e.getMessage());
            response.setContentType("text/html;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<html><body>");
                out.println("<script type='text/javascript'>");
                out.println("alert('Error al registrar la venta: " + e.getMessage().replace("'", "\\'") + "');");
                out.println("window.history.back();");
                out.println("</script>");
                out.println("</body></html>");
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ex) {
                    System.out.println("❌ Error al cerrar conexión: " + ex.getMessage());
                }
            }
        }
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
