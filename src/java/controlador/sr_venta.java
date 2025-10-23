package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.LocalDateTime;
import modelo.*;
import utils.ConexionDB;

@WebServlet(name = "sr_venta", urlPatterns = {"/sr_venta"})
public class sr_venta extends HttpServlet {

    private int obtenerIdCliente(String nit, String nombres, String apellidos, String direccion, String telefono, Connection con) throws SQLException {
        int id_cliente = 0;

        // Buscar cliente
        String sqlBuscar = "SELECT id_cliente FROM clientes WHERE nit = ?";
        try (PreparedStatement psBuscar = con.prepareStatement(sqlBuscar)) {
            psBuscar.setString(1, nit);
            ResultSet rs = psBuscar.executeQuery();
            if (rs.next()) {
                return rs.getInt("id_cliente");
            }
        }

        // Si no existe, crear cliente
        String sqlInsert = "INSERT INTO clientes (nit, nombres, apellidos, direccion, telefono) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement psInsert = con.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            psInsert.setString(1, nit);
            psInsert.setString(2, nombres);
            psInsert.setString(3, apellidos);
            psInsert.setString(4, direccion);
            psInsert.setString(5, telefono);
            psInsert.executeUpdate();

            ResultSet rs = psInsert.getGeneratedKeys();
            if (rs.next()) {
                id_cliente = rs.getInt(1);
            }
        }
        return id_cliente;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        try {
            // 🔹 Obtener conexión y comenzar transacción
            con = new ConexionDB().getConexion();
            con.setAutoCommit(false);

            // 🔹 Datos cliente
            String nit = request.getParameter("nit");
            String nombres = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String direccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");

            int id_cliente = obtenerIdCliente(nit, nombres, apellidos, direccion, telefono, con);

            // 🔹 Crear venta
            Venta v = new Venta();
            v.setNo_factura(request.getParameter("no_factura"));
            v.setSerie(request.getParameter("serie"));
            v.setFecha_venta(Timestamp.valueOf(LocalDateTime.now()));
            v.setId_cliente(id_cliente);
            v.setId_empleado(Integer.parseInt(request.getParameter("id_empleado")));
            v.setTotal(Double.parseDouble(request.getParameter("total")));

            if (!v.agregar(con)) {
                throw new SQLException("Error al insertar la venta");
            }

            int idVenta = v.getUltimoId();
            if (idVenta == 0) {
                throw new SQLException("No se pudo obtener el ID de la venta");
            }

            // 🔹 Detalles de venta
            String[] productos = request.getParameterValues("id_producto[]");
            String[] cantidades = request.getParameterValues("cantidad[]");
            String[] precios = request.getParameterValues("precio[]");

            if (productos == null || productos.length == 0) {
                throw new SQLException("No hay productos en la venta");
            }

            for (int i = 0; i < productos.length; i++) {
                int id_producto = Integer.parseInt(productos[i]);
                int cantidad = Integer.parseInt(cantidades[i]);
                double precio = Double.parseDouble(precios[i]);

                // Verificar stock disponible
                PreparedStatement psStock = con.prepareStatement("SELECT existencia FROM productos WHERE id_producto=?");
                psStock.setInt(1, id_producto);
                ResultSet rsStock = psStock.executeQuery();

                if (!rsStock.next()) {
                    throw new SQLException("Producto no encontrado (ID: " + id_producto + ")");
                }

                int existencia = rsStock.getInt("existencia");
                if (existencia < cantidad) {
                    throw new SQLException("Stock insuficiente para el producto ID: " + id_producto + " (existencia: " + existencia + ")");
                }

                // Insertar detalle
                VentaDetalle d = new VentaDetalle();
                d.setId_venta(idVenta);
                d.setId_producto(id_producto);
                d.setCantidad(cantidad);
                d.setPrecio_unitario(precio);

                if (!d.agregar(con)) {
                    throw new SQLException("Error al agregar detalle del producto ID: " + id_producto);
                }

                // Actualizar existencia
                PreparedStatement psUpdate = con.prepareStatement(
                    "UPDATE productos SET existencia = existencia - ? WHERE id_producto = ?");
                psUpdate.setInt(1, cantidad);
                psUpdate.setInt(2, id_producto);
                psUpdate.executeUpdate();
            }

            // ✅ Confirmar transacción
            con.commit();

            // Respuesta exitosa
            try (PrintWriter out = response.getWriter()) {
                out.println("<script>alert('✅ Venta registrada y stock actualizado correctamente');");
                out.println("window.location='views/ventas.jsp';</script>");
            }

        } catch (Exception e) {
            // 🔁 Rollback
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            e.printStackTrace();
            try (PrintWriter out = response.getWriter()) {
                out.println("<script>alert('❌ Error al registrar venta: " + e.getMessage().replace("'", "") + "');");
                out.println("window.history.back();</script>");
            }

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
