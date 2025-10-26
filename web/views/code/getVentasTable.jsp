<%@ page import="java.util.*, modelo.Venta" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<tbody>
<%
    List<Venta> ventas = new Venta().listar();
    if (ventas != null && !ventas.isEmpty()) {
        for (Venta v : ventas) {
%>
<tr>
    <td><%= v.getId_venta() %></td>
    <td><%= v.getNo_factura() %></td>
    <td><%= v.getSerie() %></td>
    <td><%= v.getFecha_venta() %></td>
    <td><%= v.getCliente() %></td>
    <td><%= v.getEmpleado() %></td>
    <td class="text-end"><%= String.format("%.2f", v.getTotal()) %></td>
    <td>
        <button type="button" class="btn btn-outline-warning btn-sm ver-detalle"
                data-id="<%= v.getId_venta() %>">
            <i class="bi bi-eye"></i> Ver Detalle
        </button>
        <form action="../sr_venta" method="post" class="d-inline">
            <input type="hidden" name="accion" value="eliminar">
            <input type="hidden" name="id_venta" value="<%= v.getId_venta() %>">
            <button type="submit" class="btn btn-danger btn-sm"
                    onclick="return confirm('¿Eliminar venta?')">
                <i class="bi bi-trash"></i>
            </button>
        </form>
    </td>
</tr>
<%
        }
    } else {
%>
<tr><td colspan="8" class="text-center text-muted">No hay ventas registradas</td></tr>
<%
    }
%>
</tbody>
