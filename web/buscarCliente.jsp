<%@ page import="java.sql.*, utils.ConexionDB" %>
<%
    String nit = request.getParameter("nit");
    String respuesta = "";

    if (nit != null && !nit.isEmpty()) {
        ConexionDB cn = new ConexionDB();
        Connection con = cn.getConexion();
        String sql = "SELECT nombres, apellidos, direccion, telefono FROM clientes WHERE nit=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, nit);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            respuesta = rs.getString("nombres") + "|" +
                        rs.getString("apellidos") + "|" +
                        rs.getString("direccion") + "|" +
                        rs.getString("telefono");
        }
        con.close();
    }

    out.print(respuesta);
%>
