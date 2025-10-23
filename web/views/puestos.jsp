<%@ include file="../includes/menu.jsp" %>
<div class="main-content">

<%@ page import="modelo.Puesto" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Puestos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-5">
    <h2 class="mb-4 text-center text-primary">Mantenimiento de Puestos</h2>

    <!-- Formulario -->
    <form action="../sr_puesto" method="post" class="card p-4 shadow-sm">
        <div class="row g-3 align-items-center">
            <div class="col-md-4">
                <label for="txt_puesto" class="form-label">Nombre del Puesto</label>
                <input type="text" class="form-control" id="txt_puesto" name="txt_puesto" required>
            </div>
            <div class="col-md-8 text-end mt-4">
                <button type="submit" name="btn" value="Agregar" class="btn btn-success">Agregar</button>
                <button type="reset" class="btn btn-secondary">Limpiar</button>
            </div>
        </div>
    </form>

    <!-- Tabla -->
    <div class="card mt-4 shadow-sm">
        <div class="card-body">
            <h5 class="card-title">Lista de Puestos</h5>
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Puesto</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Puesto obj = new Puesto();
                        List<Puesto> lista = obj.leer();
                        for (Puesto p : lista) {
                    %>
                    <tr>
                        <form action="../sr_puesto" method="post">
                            <td><input type="hidden" name="id_puesto" value="<%= p.getId_puesto() %>"><%= p.getId_puesto() %></td>
                            <td><input type="text" name="txt_puesto" value="<%= p.getPuesto() %>" class="form-control"></td>
                            <td>
                                <button name="btn" value="Actualizar" class="btn btn-warning btn-sm">Actualizar</button>
                                <button name="btn" value="Eliminar" class="btn btn-danger btn-sm" onclick="return confirm('¿Eliminar este puesto?')">Eliminar</button>
                            </td>
                        </form>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</div>
</body>
</html>
