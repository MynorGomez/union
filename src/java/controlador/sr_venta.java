package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import modelo.*;
import utils.ConexionDB;

@WebServlet(name = "sr_venta", urlPatterns = {"/sr_venta"})
public class sr_venta extends HttpServlet {

    // ============================================================
    // 🔹 OBTENER o CREAR CLIENTE (por NIT)
    // ============================================================
    private int obtenerIdCliente(String nit, String nombres, String apellidos, String direccion, String telefono, Connection con) throws SQLException {
        int id_cliente = 0;
        String sqlBuscar = "SELECT id_cliente FROM clientes WHERE nit = ?";
        try (PreparedStatement psBuscar = con.prepareStatement(sqlBuscar)) {
            psBuscar.setString(1, nit);
            ResultSet rs = psBuscar.executeQuery();
            if (rs.next()) {
                return rs.getInt("id_cliente");
            }
        }

        String sqlInsert = "INSERT INTO clientes (nit, nombres, apellidos, direccion, telefono) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement psInsert = con.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            psInsert.setString(1, nit);
            psInsert.setString(2, nombres);
            psInsert.setString(3, apellidos);
            psInsert.setString(4, direccion);
            psInsert.setString(5, telefono);
            psInsert.executeUpdate();
            ResultSet rs = psInsert.getGeneratedKeys();
            if (rs.next()) id_cliente = rs.getInt(1);
        }
        return id_cliente;
    }

    // ============================================================
    // 🧾 POST PRINCIPAL
    // ============================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "agregar";

        response.setContentType("application/json;charset=UTF-8");

        try (Connection con = new ConexionDB().getConexion()) {
            con.setAutoCommit(false);

            // 🗑️ ELIMINAR
            if ("eliminar".equalsIgnoreCase(accion)) {
                int idVenta = Integer.parseInt(request.getParameter("id_venta"));
                PreparedStatement psDetalles = con.prepareStatement("SELECT id_producto, cantidad FROM ventas_detalle WHERE id_venta = ?");
                psDetalles.setInt(1, idVenta);
                ResultSet rs = psDetalles.executeQuery();
                while (rs.next()) {
                    int idProd = rs.getInt("id_producto");
                    int cant = rs.getInt("cantidad");
                    PreparedStatement psUpd = con.prepareStatement("UPDATE productos SET existencia = existencia + ? WHERE id_producto = ?");
                    psUpd.setInt(1, cant);
                    psUpd.setInt(2, idProd);
                    psUpd.executeUpdate();
                }
                con.prepareStatement("DELETE FROM ventas_detalle WHERE id_venta = " + idVenta).executeUpdate();
                con.prepareStatement("DELETE FROM ventas WHERE id_venta = " + idVenta).executeUpdate();
                con.commit();
                response.sendRedirect("views/ventas.jsp");
                return;
            }

            // ✅ 🔧 NUEVO BLOQUE: ACTUALIZAR DETALLE (solo productos)
            if ("actualizar_detalle".equalsIgnoreCase(accion)) {
                int idVenta = Integer.parseInt(request.getParameter("id_venta"));
                String[] idsProd = request.getParameterValues("id_producto[]");
                String[] cantidades = request.getParameterValues("cantidad[]");
                String[] precios = request.getParameterValues("precio_unitario[]");

                if (idsProd == null || idsProd.length == 0) {
                    response.getWriter().write("{\"status\":\"error\",\"msg\":\"No hay productos.\"}");
                    return;
                }

                // Borrar los detalles anteriores
                PreparedStatement del = con.prepareStatement("DELETE FROM ventas_detalle WHERE id_venta=?");
                del.setInt(1, idVenta);
                del.executeUpdate();

                // Insertar nuevos detalles
                PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO ventas_detalle (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES (?,?,?,?,?)");

                double total = 0;
                for (int i = 0; i < idsProd.length; i++) {
                    int idProd = Integer.parseInt(idsProd[i]);
                    double cantidad = Double.parseDouble(cantidades[i]);
                    double precio = Double.parseDouble(precios[i]);
                    double subtotal = cantidad * precio;
                    total += subtotal;

                    ins.setInt(1, idVenta);
                    ins.setInt(2, idProd);
                    ins.setDouble(3, cantidad);
                    ins.setDouble(4, precio);
                    ins.setDouble(5, subtotal);
                    ins.executeUpdate();
                }

                // Actualizar el total de la venta
                PreparedStatement upd = con.prepareStatement("UPDATE ventas SET total=? WHERE id_venta=?");
                upd.setDouble(1, total);
                upd.setInt(2, idVenta);
                upd.executeUpdate();

                con.commit();
                response.getWriter().write("{\"status\":\"ok\"}");
                return;
            }

            // 🧍 CLIENTE
            String nit = request.getParameter("nit");
            String nombres = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String direccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");
            int id_cliente = obtenerIdCliente(nit, nombres, apellidos, direccion, telefono, con);

            // 🧾 ENCABEZADO
            Venta v = new Venta();
            v.setNo_factura(request.getParameter("no_factura"));
            v.setSerie(request.getParameter("serie"));
            v.setFecha_venta(new java.sql.Timestamp(System.currentTimeMillis()));
            v.setId_cliente(id_cliente);
            v.setId_empleado(Integer.parseInt(request.getParameter("id_empleado")));
            v.setTotal(Double.parseDouble(request.getParameter("total")));

            int idVenta;

            // ✏️ ACTUALIZAR VENTA COMPLETA
            if ("actualizar".equalsIgnoreCase(accion)) {
                idVenta = Integer.parseInt(request.getParameter("id_venta"));
                PreparedStatement psUpVenta = con.prepareStatement(
                        "UPDATE ventas SET no_factura=?, serie=?, id_cliente=?, id_empleado=?, total=? WHERE id_venta=?");
                psUpVenta.setString(1, v.getNo_factura());
                psUpVenta.setString(2, v.getSerie());
                psUpVenta.setInt(3, v.getId_cliente());
                psUpVenta.setInt(4, v.getId_empleado());
                psUpVenta.setDouble(5, v.getTotal());
                psUpVenta.setInt(6, idVenta);
                psUpVenta.executeUpdate();

                // Revertir existencias previas
                PreparedStatement psDetAnt = con.prepareStatement("SELECT id_producto, cantidad FROM ventas_detalle WHERE id_venta = ?");
                psDetAnt.setInt(1, idVenta);
                ResultSet rsAnt = psDetAnt.executeQuery();
                while (rsAnt.next()) {
                    int idProd = rsAnt.getInt("id_producto");
                    int cant = rsAnt.getInt("cantidad");
                    PreparedStatement psUpd = con.prepareStatement("UPDATE productos SET existencia = existencia + ? WHERE id_producto = ?");
                    psUpd.setInt(1, cant);
                    psUpd.setInt(2, idProd);
                    psUpd.executeUpdate();
                }

                con.prepareStatement("DELETE FROM ventas_detalle WHERE id_venta = " + idVenta).executeUpdate();
            } else {
                // ➕ AGREGAR NUEVA VENTA
                if (!v.agregar(con)) throw new SQLException("Error al insertar la venta");
                idVenta = v.getUltimoId();
                if (idVenta == 0) throw new SQLException("No se pudo obtener el ID de la venta");
            }

            // 📦 DETALLES (para agregar o actualizar venta completa)
            String[] productos = request.getParameterValues("id_producto[]");
            String[] cantidades = request.getParameterValues("cantidad[]");
            String[] precios = request.getParameterValues("precio_unitario[]");

            if (productos == null || productos.length == 0)
                throw new SQLException("No hay productos en la venta");

            for (int i = 0; i < productos.length; i++) {
                int id_producto = Integer.parseInt(productos[i]);
                int cantidad = Integer.parseInt(cantidades[i]);
                double precio = Double.parseDouble(precios[i]);

                VentaDetalle d = new VentaDetalle();
                d.setId_venta(idVenta);
                d.setId_producto(id_producto);
                d.setCantidad(cantidad);
                d.setPrecio_unitario(precio);

                if (!d.agregar(con))
                    throw new SQLException("Error al agregar detalle del producto ID: " + id_producto);

                PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE productos SET existencia = existencia - ? WHERE id_producto = ?");
                psUpdate.setInt(1, cantidad);
                psUpdate.setInt(2, id_producto);
                psUpdate.executeUpdate();
            }

            con.commit();
            response.sendRedirect("views/ventas.jsp");

        } catch (Exception e) {
            System.out.println("❌ Error en sr_venta: " + e.getMessage());
            throw new ServletException(e);
        }
    }
}
