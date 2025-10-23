    <%@ page import="modelo.Cliente,java.util.List" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ include file="../includes/menu.jsp" %>

    <!DOCTYPE html>
    <html lang="es">
    <head meta name="viewport" content="width=device-width, initial-scale=1.0">
    > 
        <meta charset="UTF-8">
        <title>Mantenimiento de Clientes</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <style> 
            tr:hover { background-color: #e8f4ff; cursor: pointer; }
            #formClientes { transition: all 0.3s ease; }
        </style>
    </head>

    <body class="bg-light">
    <div class="container mt-5">
        <h2 class="mb-4 text-center text-primary">Clientes</h2>

        <!-- 🔘 BOTÓN PARA MOSTRAR/OCULTAR FORMULARIO -->
        <div class="text-end mb-3">
            <button id="btnMostrarForm" class="btn btn-success">
                ➕ Nuevo Cliente
            </button>
        </div>

        <!-- 🧾 FORMULARIO (OCULTO POR DEFECTO) -->
        <form action="../sr_cliente" method="post" class="card p-4 shadow-sm d-none" id="formClientes">
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
                    <button type="button" id="btnCancelar" class="btn btn-secondary w-100">Cancelar</button>
                </div>
            </div>
        </form>

        <!-- 📋 TABLA -->
        <div class="card mt-3 shadow-sm">
      <div class="card-body">
        <!-- El div con la clase .table-responsive es la clave -->
        <div class="table-responsive">
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

    <!-- JS -->
    <script>
    $(document).ready(function(){
        // Mostrar / ocultar formulario
        $("#btnMostrarForm").click(function(){
            $("#formClientes").toggleClass("d-none");
            $(this).text($("#formClientes").hasClass("d-none") ? "➕ Nuevo Cliente" : "❌ Ocultar formulario");
            if ($("#formClientes").hasClass("d-none")) limpiarFormulario();
        });

        $("#btnCancelar").click(function(){
            limpiarFormulario();
            $("#formClientes").addClass("d-none");
            $("#btnMostrarForm").text("➕ Nuevo Cliente");
        });
    });

    function limpiarFormulario(){
        $("#formClientes")[0].reset();
        $("#id_cliente").val("");
        $("#btnAccion").val("Agregar").text("Agregar").removeClass("btn-warning").addClass("btn-success");
        $("#btnEliminar").addClass("d-none");
    }

    function seleccionarCliente(fila) {
        $("#formClientes").removeClass("d-none");
        $("#btnMostrarForm").text("❌ Ocultar formulario");

        $("#id_cliente").val(fila.dataset.id);
        $("#txt_nit").val(fila.dataset.nit);
        $("#txt_nombres").val(fila.dataset.nombres);
        $("#txt_apellidos").val(fila.dataset.apellidos);
        $("#txt_direccion").val(fila.dataset.direccion);
        $("#txt_telefono").val(fila.dataset.telefono);
        $("#txt_fn").val(fila.dataset.fn);

        $("#btnAccion").val("Actualizar").text("Actualizar").removeClass("btn-success").addClass("btn-warning");
        $("#btnEliminar").removeClass("d-none");
    }
    </script>

    </body>
    </html>
