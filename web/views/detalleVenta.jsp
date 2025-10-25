<%@ page import="java.sql.*, utils.ConexionDB" %>
<%
    String idVenta = request.getParameter("id_venta");
    String modo = request.getParameter("modo"); // "edicion" o "vista"

    if (idVenta == null || idVenta.isEmpty()) {
        out.print("<div class='alert alert-danger'>? ID de venta no especificado.</div>");
        return;
    }

    ConexionDB cn = new ConexionDB();
    Connection con = cn.getConexion();

    // ? Obtener encabezado de la venta
    String sqlVenta = 
        "SELECT v.no_factura, v.serie, v.fecha_venta, " +
        "CONCAT(c.nombres, ' ', c.apellidos) AS cliente, " +
        "e.nombres AS empleado, v.total " +
        "FROM ventas v " +
        "INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
        "INNER JOIN empleados e ON v.id_empleado = e.id_empleado " +
        "WHERE v.id_venta = ?";

    PreparedStatement psVenta = con.prepareStatement(sqlVenta);
    psVenta.setString(1, idVenta);
    ResultSet rsVenta = psVenta.executeQuery();

    if (rsVenta.next()) {
%>
<div class="card mb-3 shadow-sm">
    <div class="card-body">
        <h5 class="card-title text-primary">
            <i class="bi bi-file-text"></i> Detalle de Venta
        </h5>
        <div class="row">
            <div class="col-md-6">
                <p><strong>No. Factura:</strong> <%= rsVenta.getString("no_factura") %></p>
                <p><strong>Serie:</strong> <%= rsVenta.getString("serie") %></p>
                <p><strong>Fecha:</strong> <%= rsVenta.getString("fecha_venta") %></p>
            </div>
            <div class="col-md-6">
                <p><strong>Cliente:</strong> <%= rsVenta.getString("cliente") %></p>
                <p><strong>Empleado:</strong> <%= rsVenta.getString("empleado") %></p>
                <p><strong>Total:</strong> Q <%= String.format("%.2f", rsVenta.getDouble("total")) %></p>
            </div>
        </div>
    </div>
</div>

<h6 class="text-secondary mt-4">Detalle de Productos</h6>
<table class="table table-bordered align-middle text-center">
    <thead class="table-success">
        <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Precio Unitario</th>
            <th>Subtotal</th>
            <% if ("edicion".equalsIgnoreCase(modo)) { %>
                <th>Acción</th>
            <% } %>
        </tr>
    </thead>
    <tbody>
<%
    }

    // ? Obtener detalle de productos
    String sqlDetalle =
        "SELECT d.id_producto, p.producto, d.cantidad, d.precio_unitario, " +
        "(d.cantidad * d.precio_unitario) AS subtotal " +
        "FROM ventas_detalle d " +
        "INNER JOIN productos p ON d.id_producto = p.id_producto " +
        "WHERE d.id_venta = ?";

    PreparedStatement psDetalle = con.prepareStatement(sqlDetalle);
    psDetalle.setString(1, idVenta);
    ResultSet rs = psDetalle.executeQuery();

    if ("edicion".equalsIgnoreCase(modo)) {
        // ? Modo edición (permitir cambiar cantidad)
        while (rs.next()) {
%>
        <tr>
            <td>
                <select name="id_producto[]" class="form-select producto" disabled>
                    <option value="<%= rs.getInt("id_producto") %>"><%= rs.getString("producto") %></option>
                </select>
            </td>
            <td><input type="number" name="cantidad[]" class="form-control cantidad" min="1" value="<%= rs.getInt("cantidad") %>"></td>
            <td><input type="text" name="precio[]" class="form-control precio" value="<%= rs.getDouble("precio_unitario") %>" readonly></td>
            <td><input type="text" name="subtotal[]" class="form-control subtotal" value="<%= rs.getDouble("subtotal") %>" readonly></td>
            <td class="text-center"><button type="button" class="btn btn-danger btn-sm eliminar">??</button></td>
        </tr>
<%
        }
    } else {
        // ?? Solo vista
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getString("producto") %></td>
            <td><%= rs.getInt("cantidad") %></td>
            <td>Q <%= String.format("%.2f", rs.getDouble("precio_unitario")) %></td>
            <td>Q <%= String.format("%.2f", rs.getDouble("subtotal")) %></td>
        </tr>
<%
        }
    }
%>
    </tbody>
</table>
<%
    con.close();
%>
