<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Venta,java.util.List,java.sql.*,utils.ConexionDB" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .main-content { margin-left: 250px; padding: 20px; position: relative; z-index: 1; }
        .modal { z-index: 2000 !important; }
        .modal-backdrop { z-index: 1050 !important; }
        .sidebar { z-index: 100 !important; }
        .border-success { border: 2px solid #28a745 !important; }
        .border-danger { border: 2px solid #dc3545 !important; }
    </style>
</head>
<body>

<%@ include file="../includes/menu.jsp" %>

<div class="main-content">
    <div class="card shadow-lg">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0"><i class="bi bi-cash-stack"></i> Ventas</h4>
            <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#modalNuevaVenta">
                <i class="bi bi-plus-circle"></i> Nueva Venta
            </button>
        </div>

        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover table-striped align-middle">
                    <thead class="table-dark text-center">
                        <tr>
                            <th>No. Factura</th>
                            <th>Serie</th>
                            <th>Fecha</th>
                            <th>Cliente</th>
                            <th>Empleado</th>
                            <th>Total</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Venta venta = new Venta();
                            List<Venta> ventas = venta.listar();
                            for (Venta v : ventas) {
                        %>
                        <tr class="text-center">
                            <td><%= v.getNo_factura() %></td>
                            <td><%= v.getSerie() %></td>
                            <td><%= v.getFecha_venta() %></td>
                            <td><%= v.getCliente() %></td>
                            <td><%= v.getEmpleado() %></td>
                            <td>Q <%= String.format("%.2f", v.getTotal()) %></td>
                            <td>
                                <button type="button" class="btn btn-info btn-sm" onclick="verDetalle(<%= v.getId_venta() %>)">
                                    <i class="bi bi-eye"></i> Ver Detalle
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 🧾 Modal NUEVA VENTA -->
<div class="modal fade" id="modalNuevaVenta" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="bi bi-receipt"></i> Nueva Venta</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="ventaForm" action="../sr_venta" method="post">
                    <h6 class="text-secondary mb-3">Datos del Cliente</h6>
                    <div id="mensajeCliente" class="alert d-none"></div>

                    <div class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label">NIT</label>
                            <div class="input-group">
                                <input type="text" id="nit" name="nit" class="form-control" required>
                                <button type="button" id="btnBuscarCliente" class="btn btn-outline-primary">🔍</button>
                                <span id="estadoCliente" class="badge bg-secondary ms-2 d-none">Esperando...</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Nombres</label>
                            <input type="text" id="nombres" name="nombres" class="form-control">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Apellidos</label>
                            <input type="text" id="apellidos" name="apellidos" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Dirección</label>
                            <input type="text" id="direccion" name="direccion" class="form-control">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Teléfono</label>
                            <input type="text" id="telefono" name="telefono" class="form-control">
                        </div>
                    </div>

                    <hr>

                    <h6 class="text-secondary mb-3">Datos de la Venta</h6>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label">No. Factura</label>
                            <%
                                ConexionDB cn = new ConexionDB();
                                Connection con = cn.getConexion();
                                PreparedStatement ps = con.prepareStatement("SELECT IFNULL(MAX(no_factura), 0) + 1 AS siguiente FROM ventas");
                                ResultSet rs = ps.executeQuery();
                                int siguienteFactura = 1;
                                if (rs.next()) siguienteFactura = rs.getInt("siguiente");
                                con.close();
                            %>
                            <input type="text" name="no_factura" class="form-control" value="<%= siguienteFactura %>" readonly>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Serie</label>
                            <input type="text" name="serie" class="form-control" value="A" readonly>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Empleado</label>
                            <select name="id_empleado" class="form-select" required>
                                <%
                                    cn = new ConexionDB();
                                    con = cn.getConexion();
                                    ps = con.prepareStatement("SELECT id_empleado, nombres FROM empleados");
                                    rs = ps.executeQuery();
                                    while (rs.next()) {
                                %>
                                    <option value="<%=rs.getInt("id_empleado")%>"><%=rs.getString("nombres")%></option>
                                <% } con.close(); %>
                            </select>
                        </div>
                    </div>

                    <hr>

                    <h6 class="text-secondary mb-3">Detalle de Productos</h6>
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
                        <tbody>
                            <tr>
                                <td>
                                    <select name="id_producto[]" class="form-select producto">
                                        <%
                                            cn = new ConexionDB();
                                            con = cn.getConexion();
                                            ps = con.prepareStatement("SELECT id_producto, producto, precio_venta FROM productos");
                                            rs = ps.executeQuery();
                                            while (rs.next()) {
                                        %>
                                            <option value="<%=rs.getInt("id_producto")%>" data-precio="<%=rs.getDouble("precio_venta")%>">
                                                <%=rs.getString("producto")%>
                                            </option>
                                        <% } con.close(); %>
                                    </select>
                                </td>
                                <td><input type="number" name="cantidad[]" class="form-control cantidad" value="1" min="1"></td>
                                <td><input type="text" name="precio[]" class="form-control precio" readonly></td>
                                <td><input type="text" name="subtotal[]" class="form-control subtotal" readonly></td>
                                <td class="text-center"><button type="button" class="btn btn-danger btn-sm eliminar">🗑️</button></td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="d-flex justify-content-between align-items-center">
                        <button type="button" id="agregar" class="btn btn-success">➕ Agregar producto</button>
                        <div>
                            <label class="form-label me-2 fw-bold">Total:</label>
                            <input type="text" id="total" name="total" class="form-control d-inline-block" style="width:150px" readonly>
                        </div>
                    </div>

                    <div class="text-center mt-4">
                        <button type="submit" class="btn btn-primary px-5">💾 Guardar venta</button>
                    </div>

                </form>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Modal Detalle -->
<div class="modal fade" id="modalDetalle" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-secondary text-white">
                <h5 class="modal-title">Detalle de Venta</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="detalleVenta"></div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// ✅ Buscar cliente funcional
$(document).on("click", "#btnBuscarCliente", function() {
    const nit = $("#nit").val().trim();
    const badge = $("#estadoCliente");
    const mensaje = $("#mensajeCliente");

    if (nit === "") {
        mensaje.removeClass().addClass("alert alert-warning").text("⚠️ Ingresa un NIT antes de buscar.").show();
        return;
    }

    badge.removeClass().addClass("badge bg-info text-dark").text("Buscando...").show();

    $.ajax({
        url: "../buscarCliente.jsp", // asegúrate de tener este JSP en /Sistema/buscarCliente.jsp
        method: "GET",
        data: { nit: nit },
        success: function(data) {
            data = data.trim();
            if (data !== "" && !data.startsWith("ERROR")) {
                const partes = data.split("|");
                $("#nombres").val(partes[0]).prop("readonly", true);
                $("#apellidos").val(partes[1]).prop("readonly", true);
                $("#direccion").val(partes[2]).prop("readonly", true);
                $("#telefono").val(partes[3]).prop("readonly", true);
                badge.removeClass().addClass("badge bg-success").text("Cliente encontrado ✅");
                mensaje.removeClass().addClass("alert alert-success").text("✅ Cliente encontrado.").show();
            } else {
                $("#nombres, #apellidos, #direccion, #telefono").val("").prop("readonly", false);
                badge.removeClass().addClass("badge bg-warning text-dark").text("Nuevo cliente ⚠️");
                mensaje.removeClass().addClass("alert alert-warning").text("⚠️ Cliente no encontrado, ingresa los datos.").show();
            }
        },
        error: function() {
            badge.removeClass().addClass("badge bg-danger").text("Error ❌");
            mensaje.removeClass().addClass("alert alert-danger").text("❌ Error al conectar con buscarCliente.jsp").show();
        }
    });
});

// ✅ Calcular precios/subtotales
function setPrecioYSubtotal($row) {
    const $sel = $row.find('.producto');
    const precio = parseFloat($sel.find(':selected').data('precio')) || 0;
    const cant = parseInt($row.find('.cantidad').val()) || 0;
    const sub = precio * cant;
    $row.find('.precio').val(precio.toFixed(2));
    $row.find('.subtotal').val(sub.toFixed(2));
}

function recalcular() {
    let total = 0;
    $("#tablaProductos tbody tr").each(function() {
        const $row = $(this);
        setPrecioYSubtotal($row);
        total += parseFloat($row.find(".subtotal").val()) || 0;
    });
    $("#total").val(total.toFixed(2));
}

$(document).on('change', '.producto', function() {
    setPrecioYSubtotal($(this).closest('tr'));
    recalcular();
});

$(document).on('input', '.cantidad', function() {
    setPrecioYSubtotal($(this).closest('tr'));
    recalcular();
});

$("#agregar").click(function() {
    let $row = $("#tablaProductos tbody tr:first").clone();
    $row.find('input').val('');
    $row.find('select').prop('selectedIndex', 0);
    $row.find('.cantidad').val('1');
    setPrecioYSubtotal($row);
    $("#tablaProductos tbody").append($row);
    recalcular();
});
function verDetalle(idVenta) {
    $.ajax({
        url: "../views/detalleVenta.jsp",
        type: "GET",
        data: { id_venta: idVenta },
        success: function(resp) {
            $("#detalleVenta").html(resp);
            new bootstrap.Modal('#modalDetalle').show();
        },
        error: function() {
            alert('Error al cargar detalle');
        }
    });
}


</script>

</body>
</html>
