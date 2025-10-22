<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, modelo.*, utils.ConexionDB, java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #f8fafc; font-family: 'Poppins', sans-serif; }
        .container { margin-top: 40px; }
        .card { border-radius: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .btn-agregar { border-radius: 30px; }
        input[readonly] { background-color: #f5f5f5; }
        #mensajeCliente {
            transition: all 0.3s ease-in-out;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <div class="card-header bg-success text-white text-center">
            <h4>Registro de Ventas</h4>
        </div>
        <div class="card-body">

            <form action="../sr_venta" method="post">

                <!-- DATOS DEL CLIENTE -->
                <h5 class="text-secondary">Datos del cliente</h5>
                <div id="mensajeCliente" class="alert d-none mt-2" role="alert"></div>

                <div class="row mb-3 align-items-end">
                    <div class="col-md-4">
                        <label for="nit" class="form-label">NIT:</label>
                        <div class="input-group">
    <input type="text" id="nit" name="nit" class="form-control" placeholder="Ingrese NIT" required>
    <button type="button" id="btnBuscarCliente" class="btn btn-outline-primary">🔍 Buscar</button>
    <!-- 🔹 Badge dinámico -->
    <span id="estadoCliente" class="badge bg-secondary ms-2 align-self-center d-none">Esperando búsqueda...</span>
</div>

                    <div class="col-md-4">
                        <label for="nombres" class="form-label">Nombres:</label>
                        <input type="text" id="nombres" name="nombres" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label for="apellidos" class="form-label">Apellidos:</label>
                        <input type="text" id="apellidos" name="apellidos" class="form-control">
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="direccion" class="form-label">Dirección:</label>
                        <input type="text" id="direccion" name="direccion" class="form-control">
                    </div>
                    <div class="col-md-3">
                        <label for="telefono" class="form-label">Teléfono:</label>
                        <input type="text" id="telefono" name="telefono" class="form-control">
                    </div>
                </div>

                <hr>

                <!-- DATOS DE LA VENTA -->
                <h5 class="text-secondary">Datos de la venta</h5>
                <div class="row mb-3">
                    <div class="col-md-3">
                        <label class="form-label">No. Factura</label>
                        <input type="text" name="no_factura" class="form-control" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Serie</label>
                        <input type="text" name="serie" class="form-control" value="A">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Empleado</label>
                        <select name="id_empleado" class="form-select" required>
                            <%
                                ConexionDB cn = new ConexionDB();
                                Connection con = cn.getConexion();
                                PreparedStatement ps = con.prepareStatement("SELECT id_empleado, nombres FROM empleados");
                                ResultSet rs = ps.executeQuery();
                                while (rs.next()) {
                            %>
                                <option value="<%=rs.getInt("id_empleado")%>"><%=rs.getString("nombres")%></option>
                            <% } con.close(); %>
                        </select>
                    </div>
                </div>

                <hr>

                <!-- DETALLE DE PRODUCTOS -->
                <h5 class="text-secondary">Detalle de productos</h5>
                <table class="table table-bordered" id="tablaProductos">
                    <thead class="table-success text-center">
                        <tr>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Precio</th>
                            <th>Subtotal</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody id="detalle">
                        <tr>
                            <td>
                                <select name="id_producto" class="form-select producto">
                                    <%
                                        cn = new ConexionDB();
                                        con = cn.getConexion();
                                        ps = con.prepareStatement("SELECT id_producto, producto, precio_costo FROM productos");
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                    %>
                                        <option value="<%=rs.getInt("id_producto")%>" data-precio="<%=rs.getDouble("precio_costo")%>">
                                            <%=rs.getString("producto")%>
                                        </option>
                                    <% } con.close(); %>
                                </select>
                            </td>
                            <td><input type="number" name="cantidad" class="form-control cantidad" value="1" min="1"></td>
                            <td><input type="text" name="precio" class="form-control precio" readonly></td>
                            <td><input type="text" name="subtotal" class="form-control subtotal" readonly></td>
                            <td class="text-center"><button type="button" class="btn btn-danger btn-sm eliminar">🗑️</button></td>
                        </tr>
                    </tbody>
                </table>

                <div class="d-flex justify-content-between align-items-center">
                    <button type="button" id="agregar" class="btn btn-success btn-agregar">➕ Agregar producto</button>
                    <div>
                        <label class="form-label me-2 fw-bold">Total:</label>
                        <input type="text" id="total" name="total" class="form-control d-inline-block" style="width:150px" readonly>
                    </div>
                </div>

                <div class="mt-4 text-center">
                    <button type="submit" class="btn btn-primary px-5">💾 Guardar venta</button>
                    <a href="../index.jsp" class="btn btn-secondary px-5">🔙 Volver</a>
                </div>

            </form>
        </div>
    </div>
</div>

<!-- ========== JAVASCRIPT ========== -->
<script>
    // Calcular subtotales y total
    function calcularTotales() {
        let total = 0;
        $("#tablaProductos tbody tr").each(function() {
            let cantidad = parseFloat($(this).find(".cantidad").val()) || 0;
            let precio = parseFloat($(this).find(".precio").val()) || 0;
            let subtotal = cantidad * precio;
            $(this).find(".subtotal").val(subtotal.toFixed(2));
            total += subtotal;
        });
        $("#total").val(total.toFixed(2));
    }

    // Al cambiar producto, mostrar precio
    $(document).on("change", ".producto", function() {
        let precio = $(this).find(":selected").data("precio");
        $(this).closest("tr").find(".precio").val(precio);
        calcularTotales();
    });

    // Al cambiar cantidad, recalcular
    $(document).on("input", ".cantidad", function() {
        calcularTotales();
    });

    // Agregar nueva fila
    $("#agregar").click(function() {
        let fila = $("#detalle tr:first").clone();
        fila.find("input").val("");
        $("#tablaProductos tbody").append(fila);
    });

    // Eliminar fila
    $(document).on("click", ".eliminar", function() {
        if ($("#tablaProductos tbody tr").length > 1) {
            $(this).closest("tr").remove();
            calcularTotales();
        }
    });

// 🔍 Buscar cliente por NIT al hacer clic en el botón
$("#btnBuscarCliente").click(function() {
    const nit = $("#nit").val().trim();
    const badge = $("#estadoCliente");

    if (nit === "") {
        mostrarMensaje("⚠️ Por favor ingrese un NIT antes de buscar.", "warning");
        badge.removeClass().addClass("badge bg-warning ms-2 align-self-center").text("NIT vacío");
        return;
    }

    // Mostrar estado de búsqueda
    badge.removeClass().addClass("badge bg-info text-dark ms-2 align-self-center").text("Buscando...");

    $.ajax({
        url: "../buscarCliente.jsp",
        method: "GET",
        data: { nit: nit },
        success: function(data) {
            if (data.trim() !== "") {
                // Cliente encontrado ✅
                const partes = data.split("|");
                $("#nombres").val(partes[0]).prop("readonly", true);
                $("#apellidos").val(partes[1]).prop("readonly", true);
                $("#direccion").val(partes[2]).prop("readonly", true);
                $("#telefono").val(partes[3]).prop("readonly", true);

                badge.removeClass().addClass("badge bg-success ms-2 align-self-center").text("Cliente existente ✅");
                mostrarMensaje("✅ Cliente encontrado correctamente.", "success");
            } else {
                // Cliente no encontrado ⚠️
                $("#nombres, #apellidos, #direccion, #telefono")
                    .val("")
                    .prop("readonly", false);

                badge.removeClass().addClass("badge bg-warning text-dark ms-2 align-self-center").text("Nuevo cliente ⚠️");
                mostrarMensaje("⚠️ Cliente no encontrado. Complete los datos para registrarlo automáticamente.", "warning");
            }
        },
        error: function() {
            badge.removeClass().addClass("badge bg-danger ms-2 align-self-center").text("Error ❌");
            mostrarMensaje("❌ Error al buscar el cliente. Verifique conexión o archivo buscarCliente.jsp.", "danger");
        }
    });
});

// 🧩 Función para mostrar mensajes visuales
function mostrarMensaje(texto, tipo) {
    const mensajeDiv = $("#mensajeCliente");
    mensajeDiv
        .removeClass("d-none alert-success alert-warning alert-danger")
        .addClass(`alert-${tipo}`)
        .html(texto);
    setTimeout(() => mensajeDiv.addClass("d-none"), 5000);
}

</script>

</body>
</html>
