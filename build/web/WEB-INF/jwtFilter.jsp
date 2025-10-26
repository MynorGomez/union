<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("jwt") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
