<%@ page import="modelo.Cliente,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Clientes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style> tr:hover { background-color: #e8f4ff; cursor: pointer; } </style>
</head>
<body class="bg-light">
<div class="container mt-5">
    <h2 class="mb-4 text-center text-primary">Mantenimiento de Clientes</h2>

    <!-- Formulario -->
    <form action="../sr_cliente" method="post" class="card p-4 shadow-sm">
        <input type="hidden" name="id_cliente" id="id_cliente">

        <div class="row g-3">
            <div class="col-md-3"><input type="text" name="txt_nit" id="txt_nit" class="form-control" placeholder="NIT" required></div>
            <div class="col-md-3"><input type="text" name="txt_nombres" id="txt_nombres" class="form-control" placeholder="Nombres" required></div>
            <div class="col-md-3"><input type="text" name="txt_apellidos" id="txt_apellidos" class="form-control" placeholder="Apellidos" required></div>
            <div class="col-md-3"><input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required></div>
            <div class="col-md-3"><input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required></div>
            <div class="col-md-3"><input type="date" name="txt_fn" id="txt_fn" class="form-control" required></div>
            <div class="col-md-3 d-flex gap-2">
                <button name="btn" id="btnAccion" value="Agregar" class="btn btn-success w-100">Agregar</button>
                <button name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger w-100 d-none" onclick="return confirm('¿Eliminar este cliente?')">Eliminar</button>
            </div>
        </div>
    </form>

    <!-- Tabla -->
    <div class="card mt-4 shadow-sm">
        <div class="card-body">
            <table class="table table-striped align-middle text-center" id="tablaClientes">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th><th>NIT</th><th>Nombres</th><th>Apellidos</th><th>Dirección</th><th>Teléfono</th><th>Fecha Nac.</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Cliente c = new Cliente();
                        List<Cliente> lista = c.leer();
                        for (Cliente cli : lista) {
                    %>
                    <tr onclick="seleccionarCliente(this)"
                        data-id="<%= cli.getId_cliente() %>"
                        data-nit="<%= cli.getNit() %>"
                        data-nombres="<%= cli.getNombres() %>"
                        data-apellidos="<%= cli.getApellidos() %>"
                        data-direccion="<%= cli.getDireccion() %>"
                        data-telefono="<%= cli.getTelefono() %>"
                        data-fn="<%= cli.getFecha_nacimiento() %>">
                        <td><%= cli.getId_cliente() %></td>
                        <td><%= cli.getNit() %></td>
                        <td><%= cli.getNombres() %></td>
                        <td><%= cli.getApellidos() %></td>
                        <td><%= cli.getDireccion() %></td>
                        <td><%= cli.getTelefono() %></td>
                        <td><%= cli.getFecha_nacimiento() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function seleccionarCliente(fila) {
    document.getElementById("id_cliente").value = fila.dataset.id;
    document.getElementById("txt_nit").value = fila.dataset.nit;
    document.getElementById("txt_nombres").value = fila.dataset.nombres;
    document.getElementById("txt_apellidos").value = fila.dataset.apellidos;
    document.getElementById("txt_direccion").value = fila.dataset.direccion;
    document.getElementById("txt_telefono").value = fila.dataset.telefono;
    document.getElementById("txt_fn").value = fila.dataset.fn;

    document.getElementById("btnAccion").value = "Actualizar";
    document.getElementById("btnAccion").textContent = "Actualizar";
    document.getElementById("btnAccion").classList.replace("btn-success", "btn-warning");
    document.getElementById("btnEliminar").classList.remove("d-none");
}
</script>
</body>
</html>
