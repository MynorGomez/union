package controlador;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import modelo.*;
import utils.ConexionDB;

public class sr_venta extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "listar":
                listarVentas(request, response);
                break;
            case "buscarCliente":
                buscarCliente(request, response);
                break;
            default:
                listarVentas(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "";

        switch (accion) {
            case "agregar":
                agregarVenta(request, response);
                break;
            case "eliminar":
                eliminarVenta(request, response);
                break;
            default:
                listarVentas(request, response);
                break;
        }
    }

    // 🔹 Listar todas las ventas
    private void listarVentas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Venta> lista = new Venta().listar();
        request.setAttribute("ventas", lista);
        request.getRequestDispatcher("views/ventas.jsp").forward(request, response);
    }

    // 🔹 Buscar cliente por NIT (responde JSON)
    private void buscarCliente(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String nit = request.getParameter("nit");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try (Connection con = new ConexionDB().getConexion()) {
            String sql = "SELECT id_cliente, nombres, apellidos, direccion, telefono FROM clientes WHERE nit = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, nit);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    out.print("{");
                    out.print("\"id_cliente\":" + rs.getInt("id_cliente") + ",");
                    out.print("\"nombres\":\"" + rs.getString("nombres") + "\",");
                    out.print("\"apellidos\":\"" + rs.getString("apellidos") + "\",");
                    out.print("\"direccion\":\"" + rs.getString("direccion") + "\",");
                    out.print("\"telefono\":\"" + rs.getString("telefono") + "\"");
                    out.print("}");
                } else {
                    out.print("{}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.print("{}");
        }
    }

    // 🔹 Agregar venta con detalles (Transacción)
    private void agregarVenta(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Connection con = null;
        try {
            con = new ConexionDB().getConexion();
            con.setAutoCommit(false);

            // Datos de venta
            String no_factura = request.getParameter("no_factura");
            String serie = request.getParameter("serie");
            int id_cliente = Integer.parseInt(request.getParameter("id_cliente"));
            int id_empleado = Integer.parseInt(request.getParameter("id_empleado"));
            double total = Double.parseDouble(request.getParameter("total"));

            Venta venta = new Venta();
            venta.setNo_factura(no_factura);
            venta.setSerie(serie);
            venta.setId_cliente(id_cliente);
            venta.setId_empleado(id_empleado);
            venta.setFecha_venta(new Timestamp(System.currentTimeMillis()));
            venta.setTotal(total);

            if (!venta.agregar(con)) {
                throw new SQLException("No se pudo guardar la venta");
            }
            int idVenta = venta.getUltimoId();

            // Detalles
            String[] id_producto = request.getParameterValues("id_producto[]");
            String[] cantidad = request.getParameterValues("cantidad[]");
            String[] precio = request.getParameterValues("precio[]");

            for (int i = 0; i < id_producto.length; i++) {
                int idProd = Integer.parseInt(id_producto[i]);
                int cant = Integer.parseInt(cantidad[i]);
                double prec = Double.parseDouble(precio[i]);

                VentaDetalle det = new VentaDetalle();
                det.setId_venta(idVenta);
                det.setId_producto(idProd);
                det.setCantidad(cant);
                det.setPrecio_unitario(prec);

                det.agregar(con);

                // 🔹 Actualizar existencia
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE productos SET existencia = existencia - ? WHERE id_producto = ?")) {
                    ps.setInt(1, cant);
                    ps.setInt(2, idProd);
                    ps.executeUpdate();
                }
            }

            con.commit();
            response.sendRedirect("sr_venta?msg=Venta registrada exitosamente");
        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect("sr_venta?error=Error al registrar la venta");
        } finally {
            try {
                if (con != null) con.setAutoCommit(true);
                if (con != null) con.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    // 🔹 Eliminar venta (con detalles en cascada)
    private void eliminarVenta(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id_venta"));
        try (Connection con = new ConexionDB().getConexion();
             PreparedStatement ps = con.prepareStatement("DELETE FROM ventas WHERE id_venta=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
            response.sendRedirect("sr_venta?msg=Venta eliminada exitosamente");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("sr_venta?error=Error al eliminar venta");
        }
    }
}
