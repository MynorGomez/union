<%@ page contentType="application/json;charset=UTF-8" %>
<%@ page import="java.sql.*,utils.ConexionDB" %>
<%
    String idVenta = request.getParameter("id_venta");
    if (idVenta == null) {
        out.print("{}\n");
        return;
    }
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = new ConexionDB().getConexion();
        String sql = "SELECT v.no_factura, v.serie, v.id_empleado, c.nit, c.nombres, c.apellidos, c.direccion, c.telefono FROM ventas v JOIN clientes c ON v.id_cliente = c.id_cliente WHERE v.id_venta = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(idVenta));
        rs = ps.executeQuery();
        String no_factura = "", serie = "", nit = "", nombres = "", apellidos = "", direccion = "", telefono = "";
        int id_empleado = 0;
        if (rs.next()) {
            no_factura = rs.getString("no_factura");
            serie = rs.getString("serie");
            id_empleado = rs.getInt("id_empleado");
            nit = rs.getString("nit");
            nombres = rs.getString("nombres");
            apellidos = rs.getString("apellidos");
            direccion = rs.getString("direccion");
            telefono = rs.getString("telefono");
        }
        out.print("{\"no_factura\":\"" + no_factura + "\",\"serie\":\"" + serie + "\",\"id_empleado\":" + id_empleado + ",\"nit\":\"" + nit + "\",\"nombres\":\"" + nombres + "\",\"apellidos\":\"" + apellidos + "\",\"direccion\":\"" + direccion + "\",\"telefono\":\"" + telefono + "\"}");
    } catch (Exception e) {
        out.print("{}\n");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (con != null) con.close(); } catch (Exception ex) {}
    }
%>
