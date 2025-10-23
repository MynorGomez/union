<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, utils.ConexionDB" %>
<%
    String idVentaStr = request.getParameter("id_venta");
    if (idVentaStr == null || idVentaStr.isEmpty()) {
        out.println("<div class='alert alert-danger'>No se especificó la venta.</div>");
        return;
    }

    int id_venta = Integer.parseInt(idVentaStr);

    ConexionDB cn = new ConexionDB();
    Connection con = cn.getConexion();

    PreparedStatement psVenta = null;
    PreparedStatement psDetalle = null;
    ResultSet rsVenta = null;
    ResultSet rsDetalle = null;

    try {
        // 🔹 Consulta de encabezado de la venta
        String sqlVenta = "SELECT v.no_factura, v.serie, v.fecha_venta, " +
                          "CONCAT(c.nombres, ' ', c.apellidos) AS cliente, " +
                          "e.nombres AS empleado, v.total " +
                          "FROM ventas v " +
                          "INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
                          "INNER JOIN empleados e ON v.id_empleado = e.id_empleado " +
                          "WHERE v.id_venta = ?";
        psVenta = con.prepareStatement(sqlVenta);
        psVenta.setInt(1, id_venta);
        rsVenta = psVenta.executeQuery();

        if (rsVenta.next()) {
%>
<div class="container-fluid">
    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <h5 class="card-title text-primary mb-3"><i class="bi bi-receipt"></i> Detalle de Venta</h5>
            <div class="row">
                <div class="col-md-6">
                    <p><strong>No. Factura:</strong> <%= rsVenta.getString("no_factura") %></p>
                    <p><strong>Serie:</strong> <%= rsVenta.getString("serie") %></p>
                    <p><strong>Fecha:</strong> <%= rsVenta.getTimestamp("fecha_venta") %></p>
                </div>
                <div class="col-md-6">
                    <p><strong>Cliente:</strong> <%= rsVenta.getString("cliente") %></p>
                    <p><strong>Empleado:</strong> <%= rsVenta.getString("empleado") %></p>
                    <p><strong>Total:</strong> Q <%= String.format("%.2f", rsVenta.getDouble("total")) %></p>
                </div>
            </div>
        </div>
    </div>

    <!-- 🔹 Detalle de productos -->
    <div class="table-responsive">
        <table class="table table-bordered table-hover align-middle">
            <thead class="table-success text-center">
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio Unitario</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String sqlDetalle = "SELECT p.producto, d.cantidad, d.precio_unitario, " +
                                        "(d.cantidad * d.precio_unitario) AS subtotal " +
                                        "FROM ventas_detalle d " +
                                        "INNER JOIN productos p ON d.id_producto = p.id_producto " +
                                        "WHERE d.id_venta = ?";
                    psDetalle = con.prepareStatement(sqlDetalle);
                    psDetalle.setInt(1, id_venta);
                    rsDetalle = psDetalle.executeQuery();

                    while (rsDetalle.next()) {
                %>
                <tr class="text-center">
                    <td><%= rsDetalle.getString("producto") %></td>
                    <td><%= rsDetalle.getInt("cantidad") %></td>
                    <td>Q <%= String.format("%.2f", rsDetalle.getDouble("precio_unitario")) %></td>
                    <td>Q <%= String.format("%.2f", rsDetalle.getDouble("subtotal")) %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>
<%
        } else {
            out.println("<div class='alert alert-warning'>No se encontró información de esta venta.</div>");
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error al cargar detalle: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) con.close();
    }
%>
