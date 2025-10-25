<%@ page import="java.sql.*, utils.ConexionDB" %>
<%
    String idVenta = request.getParameter("id_venta");
    if (idVenta == null || idVenta.trim().isEmpty()) idVenta = "0";

    ConexionDB cn = new ConexionDB();
    Connection con = cn.getConexion();

    String query = "SELECT d.id_producto, p.producto, d.cantidad, d.precio_unitario, (d.cantidad * d.precio_unitario) AS subtotal " +
                   "FROM ventas_detalle d INNER JOIN productos p ON d.id_producto = p.id_producto " +
                   "WHERE d.id_venta = ?";
    PreparedStatement ps = con.prepareStatement(query);
    ps.setInt(1, Integer.parseInt(idVenta));
    ResultSet rs = ps.executeQuery();
%>
<div class="table-responsive">
    <table class="table table-bordered text-center align-middle" id="tablaDetalleVentaEditable">
        <thead class="table-success">
            <tr>
                <th style="width: 35%">Producto</th>
                <th style="width: 15%">Cantidad</th>
                <th style="width: 20%">Precio Unitario</th>
                <th style="width: 20%">Subtotal</th>
                <th style="width: 10%">Acción</th>
            </tr>
        </thead>
        <tbody id="detalleBodyVenta">
            <%
                boolean tieneRegistros = false;
                while (rs.next()) {
                    tieneRegistros = true;
            %>
            <tr>
                <td>
                    <select name="id_producto[]" class="form-select producto" disabled>
                        <option value="<%= rs.getInt("id_producto") %>" selected><%= rs.getString("producto") %></option>
                    </select>
                </td>
                <td><input type="number" name="cantidad[]" class="form-control cantidad" min="1" value="<%= rs.getInt("cantidad") %>" required></td>
                <td><input type="number" name="precio[]" class="form-control precio" value="<%= rs.getDouble("precio_unitario") %>" readonly></td>
                <td><input type="text" class="form-control subtotal" value="<%= rs.getDouble("subtotal") %>" readonly></td>
                <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
            </tr>
            <%
                }
                if (!tieneRegistros) {
            %>
            <tr><td colspan="5" class="text-center">No hay productos en esta venta.</td></tr>
            <%
                }
                rs.close();
                ps.close();
                con.close();
            %>
        </tbody>
    </table>
</div>
