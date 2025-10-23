<%@ include file="../includes/menu.jsp" %>
<div class="main-content">
<%@ page import="modelo.Proveedor,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mantenimiento de Proveedores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style> 
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
        #formProveedores { transition: all 0.3s ease; }
    </style>
</head>
<body class="bg-light">

<div class="container mt-5">
    <h2 class="mb-4 text-center text-primary">Mantenimiento de Proveedores</h2>

    <!-- 🔘 BOTÓN PARA MOSTRAR/OCULTAR FORMULARIO -->
    <div class="text-end mb-3">
        <button id="btnMostrarForm" class="btn btn-success">
            ➕ Nuevo Proveedor
        </button>
    </div>

    <!-- Formulario -->
    <form action="../sr_proveedor" method="post" class="card p-4 shadow-sm d-none" id="formProveedores">
        <input type="hidden" name="id_proveedor" id="id_proveedor">

        <div class="row g-3">
            <div class="col-md-3"><input type="text" name="txt_proveedor" id="txt_proveedor" class="form-control" placeholder="Proveedor" required></div>
            <div class="col-md-3"><input type="text" name="txt_nit" id="txt_nit" class="form-control" placeholder="NIT" required></div>
            <div class="col-md-3"><input type="text" name="txt_direccion" id="txt_direccion" class="form-control" placeholder="Dirección" required></div>
            <div class="col-md-3"><input type="text" name="txt_telefono" id="txt_telefono" class="form-control" placeholder="Teléfono" required></div>

            <div class="col-md-3 d-flex gap-2">
                <button name="btn" id="btnAccion" value="Agregar" class="btn btn-success w-100">Agregar</button>
                <button name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger w-100 d-none" onclick="return confirm('¿Eliminar este proveedor?')">Eliminar</button>
            </div>
        </div>
    </form>

    <!-- Tabla -->
    <div class="card mt-4 shadow-sm">
        <div class="card-body">
            <table class="table table-striped align-middle text-center" id="tablaProveedores">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th><th>Proveedor</th><th>NIT</th><th>Dirección</th><th>Teléfono</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Proveedor pr = new Proveedor();
                        List<Proveedor> lista = pr.leer();
                        for (Proveedor p : lista) {
                    %>
                    <tr onclick="seleccionarProveedor(this)"
                        data-id="<%= p.getId_proveedor() %>"
                        data-proveedor="<%= p.getProveedor() %>"
                        data-nit="<%= p.getNit() %>"
                        data-direccion="<%= p.getDireccion() %>"
                        data-telefono="<%= p.getTelefono() %>">
                        <td><%= p.getId_proveedor() %></td>
                        <td><%= p.getProveedor() %></td>
                        <td><%= p.getNit() %></td>
                        <td><%= p.getDireccion() %></td>
                        <td><%= p.getTelefono() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function seleccionarProveedor(fila) {
    document.getElementById("id_proveedor").value = fila.dataset.id;
    document.getElementById("txt_proveedor").value = fila.dataset.proveedor;
    document.getElementById("txt_nit").value = fila.dataset.nit;
    document.getElementById("txt_direccion").value = fila.dataset.direccion;
    document.getElementById("txt_telefono").value = fila.dataset.telefono;

    document.getElementById("btnAccion").value = "Actualizar";
    document.getElementById("btnAccion").textContent = "Actualizar";
    document.getElementById("btnAccion").classList.replace("btn-success", "btn-warning");
    document.getElementById("btnEliminar").classList.remove("d-none");
    
    // Mostrar el formulario si está oculto
    $("#formProveedores").removeClass("d-none");
    $("#btnMostrarForm").text("❌ Ocultar formulario");
}

// Mostrar / ocultar formulario
$(document).ready(function(){
    $("#btnMostrarForm").on("click", function(e){
        e.preventDefault();
        $("#formProveedores").toggleClass("d-none");
        $(this).text($("#formProveedores").hasClass("d-none") ? "➕ Nuevo Proveedor" : "❌ Ocultar formulario");
    });
});
</script>
</div>
</body>
</html>
