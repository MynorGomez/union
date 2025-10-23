<%@ page import="modelo.Puesto,modelo.Empleado,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Mantenimiento de Empleados</title>
    <style>
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
    </style>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
        #formEmpleados { transition: all 0.3s ease; }
    </style>
</head>
<body class="bg-light">
<%@ include file="../includes/menu.jsp" %>
<div class="main-content">
    <div class="container-fluid">
    <h2 class="mb-4 text-center text-primary">Mantenimiento de Empleados</h2>

    <!-- 🔘 BOTÓN PARA MOSTRAR/OCULTAR FORMULARIO -->
    <div class="text-end mb-3">
        <button id="btnMostrarForm" class="btn btn-success">
            ➕ Nuevo Empleado
        </button>
    </div>

    <!-- FORMULARIO -->
    <form action="../sr_empleado" method="post" class="card p-4 shadow-sm d-none" id="formEmpleados">
        <input type="hidden" name="id_empleado" id="id_empleado">

        <div class="row g-3">
            <div class="col-md-3"><input type="text" name="txt_codigo" id="txt_codigo" class="form-control" placeholder="Código" required></div>
            <div class="col-md-3"><input type="text" name="txt_nombres" id="txt_nombres" class="form-control" placeholder="Nombres" required></div>
            <div class="col-md-3"><input type="text" name="txt_apellidos" id="txt_apellidos" class="form-control" placeholder="Apellidos" required></div>
            <div class="col-md-3"><input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required></div>
            <div class="col-md-3"><input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required></div>
            <div class="col-md-3"><input type="date" name="txt_fn" id="txt_fn" class="form-control" required></div>
            <div class="col-md-3">
                <select name="drop_puesto" id="drop_puesto" class="form-select" required>
                    <option value="">Seleccione un puesto</option>
                    <%
                        Puesto p = new Puesto();
                        List<Puesto> puestos = p.leer();
                        for (Puesto item : puestos) {
                    %>
                        <option value="<%= item.getId_puesto() %>"><%= item.getPuesto() %></option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-3 d-flex gap-2">
                <button name="btn" id="btnAccion" value="Agregar" class="btn btn-success w-100">Agregar</button>
                <button name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger w-100 d-none" onclick="return confirm('¿Eliminar este empleado?')">Eliminar</button>
            </div>
        </div>
    </form>

    <!-- TABLA -->
    <div class="card mt-4 shadow-sm">
        <div class="card-body">
            <table class="table table-striped align-middle text-center" id="tablaEmpleados">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Código</th>
                        <th>Nombres</th>
                        <th>Apellidos</th>
                        <th>Dirección</th>
                        <th>Teléfono</th>
                        <th>Fecha Nac.</th>
                        <th>Puesto</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Empleado e = new Empleado();
                        List<Empleado> lista = e.leer();
                        for (Empleado emp : lista) {
                    %>
                    <tr onclick="seleccionarEmpleado(this)"
                        data-id="<%= emp.getId_empleado() %>"
                        data-codigo="<%= emp.getCodigo() %>"
                        data-nombres="<%= emp.getNombres() %>"
                        data-apellidos="<%= emp.getApellidos() %>"
                        data-direccion="<%= emp.getDireccion() %>"
                        data-telefono="<%= emp.getTelefono() %>"
                        data-fn="<%= emp.getFecha_nacimiento() %>"
                        data-puesto="<%= emp.getId_puesto() %>">
                        <td><%= emp.getId_empleado() %></td>
                        <td><%= emp.getCodigo() %></td>
                        <td><%= emp.getNombres() %></td>
                        <td><%= emp.getApellidos() %></td>
                        <td><%= emp.getDireccion() %></td>
                        <td><%= emp.getTelefono() %></td>
                        <td><%= emp.getFecha_nacimiento() %></td>
                        <td><%= emp.getPuesto() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function seleccionarEmpleado(fila) {
    document.getElementById("id_empleado").value = fila.dataset.id;
    document.getElementById("txt_codigo").value = fila.dataset.codigo;
    document.getElementById("txt_nombres").value = fila.dataset.nombres;
    document.getElementById("txt_apellidos").value = fila.dataset.apellidos;
    document.getElementById("txt_direccion").value = fila.dataset.direccion;
    document.getElementById("txt_telefono").value = fila.dataset.telefono;
    document.getElementById("txt_fn").value = fila.dataset.fn;
    document.getElementById("drop_puesto").value = fila.dataset.puesto;

    // Cambiar botones
    document.getElementById("btnAccion").value = "Actualizar";
    document.getElementById("btnAccion").textContent = "Actualizar";
    document.getElementById("btnAccion").classList.replace("btn-success", "btn-warning");
    document.getElementById("btnEliminar").classList.remove("d-none");
    
    // Mostrar el formulario si está oculto
    $("#formEmpleados").removeClass("d-none");
    $("#btnMostrarForm").text("❌ Ocultar formulario");
}

// Mostrar / ocultar formulario
$(document).ready(function(){
    $("#btnMostrarForm").on("click", function(e){
        e.preventDefault();
        $("#formEmpleados").toggleClass("d-none");
        $(this).text($("#formEmpleados").hasClass("d-none") ? "➕ Nuevo Empleado" : "❌ Ocultar formulario");
    });
});
</script>
</div>
</body>
</html>
