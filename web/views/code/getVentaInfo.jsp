<%@ page import="java.sql.*, org.json.JSONObject, utils.ConexionDB" %>
<%@ page contentType="application/json;charset=UTF-8" %>

<%
    String idVenta = request.getParameter("id_venta");
    JSONObject json = new JSONObject();

    if (idVenta != null) {
        try (Connection con = new ConexionDB().getConexion()) {
            String query = """
                SELECT v.id_venta, v.no_factura, v.serie,
                       c.id_cliente, c.nit, c.nombres, c.apellidos, c.telefono, c.direccion,
                       e.id_empleado
                FROM ventas v
                INNER JOIN clientes c ON v.id_cliente = c.id_cliente
                INNER JOIN empleados e ON v.id_empleado = e.id_empleado
                WHERE v.id_venta = ?
            """;
            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, Integer.parseInt(idVenta));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                json.put("id_venta", rs.getInt("id_venta"));
                json.put("no_factura", rs.getString("no_factura"));
                json.put("serie", rs.getString("serie"));
                json.put("id_cliente", rs.getInt("id_cliente"));
                json.put("nit", rs.getString("nit"));
                json.put("nombres", rs.getString("nombres"));
                json.put("apellidos", rs.getString("apellidos"));
                json.put("telefono", rs.getString("telefono"));
                json.put("direccion", rs.getString("direccion"));
                json.put("id_empleado", rs.getInt("id_empleado"));
            }
        } catch (Exception e) {
            json.put("error", e.getMessage());
        }
    }

    out.print(json.toString());
%>
