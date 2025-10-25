<%@ page import="java.util.*, java.sql.*, modelo.Venta, utils.ConexionDB" %>
<%@ include file="../includes/menu.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="main-content">
    <div class="container my-4">
        <h3 class="text-primary mb-4">Gestión de Ventas</h3>

        <%
            String msg = request.getParameter("msg");
            String error = request.getParameter("error");
            if (msg != null) {
        %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } else if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="d-flex justify-content-between mb-3">
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalVenta">
                <i class="bi bi-plus-circle"></i> Nueva Venta
            </button>
            <div>
                <a href="clientes.jsp" class="btn btn-outline-secondary btn-sm">Ir a Clientes</a>
                <a href="empleados.jsp" class="btn btn-outline-secondary btn-sm">Ir a Empleados</a>
            </div>
        </div>

        <!-- Tabla de Ventas -->
        <div class="card shadow-sm">
            <div class="card-body">
                <table id="tablaVentas" class="table table-striped table-hover align-middle">
                    <thead class="table-primary">
                    <tr>
                        <th>ID</th><th>No. Factura</th><th>Serie</th><th>Fecha</th>
                        <th>Cliente</th><th>Empleado</th><th>Total (Q)</th><th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        List<Venta> ventas = (List<Venta>) request.getAttribute("ventas");
                        if (ventas != null && !ventas.isEmpty()) {
                            for (Venta v : ventas) {
                    %>
                    <tr>
                        <td><%= v.getId_venta() %></td>
                        <td><%= v.getNo_factura() %></td>
                        <td><%= v.getSerie() %></td>
                        <td><%= v.getFecha_venta() %></td>
                        <td><%= v.getCliente() %></td>
                        <td><%= v.getEmpleado() %></td>
                        <td class="text-end"><%= String.format("%.2f", v.getTotal()) %></td>
                        <td>
                            <form action="sr_venta" method="post" class="d-inline">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="id_venta" value="<%= v.getId_venta() %>">
                                <button type="submit" class="btn btn-danger btn-sm"
                                        onclick="return confirm('¿Eliminar venta?')">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="8" class="text-center text-muted">No hay ventas registradas</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal Nueva Venta -->
<div class="modal fade" id="modalVenta" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <form action="sr_venta" method="post">
                <input type="hidden" name="accion" value="agregar">

                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">Nueva Venta</h5>
                    <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <!-- Datos del Cliente -->
                    <div class="row mb-3 align-items-end">
                        <div class="col-md-3">
                            <label>NIT</label>
                            <div class="input-group">
                                <input type="text" id="nit" name="nit" class="form-control" placeholder="CF o NIT">
                                <button type="button" id="btnBuscarCliente" class="btn btn-outline-secondary">
                                    <i class="bi bi-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-3"><label>Nombres</label><input type="text" id="nombres" class="form-control" readonly></div>
                        <div class="col-md-3"><label>Apellidos</label><input type="text" id="apellidos" class="form-control" readonly></div>
                        <div class="col-md-3"><label>Teléfono</label><input type="text" id="telefono" class="form-control" readonly></div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6"><label>Dirección</label><input type="text" id="direccion" class="form-control" readonly></div>
                        <div class="col-md-3">
                            <label>No. Factura</label>
                            <%
                                String noFactura = "0001";
                                try (Connection con = new ConexionDB().getConexion();
                                     PreparedStatement ps = con.prepareStatement("SELECT LPAD(COALESCE(MAX(id_venta)+1,1),4,'0') nf FROM ventas");
                                     ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) noFactura = rs.getString("nf");
                                } catch (Exception e) {}
                            %>
                            <input type="text" name="no_factura" class="form-control" readonly value="<%= noFactura %>">
                        </div>
                        <div class="col-md-3"><label>Serie</label><input type="text" name="serie" class="form-control" readonly value="A"></div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label>Empleado</label>
                            <select name="id_empleado" class="form-select" required>
                                <option value="">-- Seleccione --</option>
                                <%
                                    try (Connection con = new ConexionDB().getConexion();
                                         PreparedStatement ps = con.prepareStatement("SELECT id_empleado, CONCAT(nombres,' ',apellidos) nom FROM empleados");
                                         ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                                %>
                                <option value="<%= rs.getInt("id_empleado") %>"><%= rs.getString("nom") %></option>
                                <% } } catch (Exception e) { %><option>Error</option><% } %>
                            </select>
                        </div>
                    </div>

                    <!-- Detalle de Productos -->
                    <div class="card">
                        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                            <span>Detalle de Productos</span>
                            <button type="button" class="btn btn-light btn-sm" id="btnAddRow">
                                <i class="bi bi-plus"></i> Agregar producto
                            </button>
                        </div>
                        <div class="card-body">
                            <table class="table">
                                <thead class="table-success">
                                <tr><th>Producto</th><th>Cantidad</th><th>Precio (Q)</th><th>Subtotal</th><th></th></tr>
                                </thead>
                                <tbody id="detalleVenta"></tbody>
                            </table>
                            <div class="text-end">
                                <strong>Total:</strong>
                                <input type="text" name="total" id="total" class="form-control d-inline-block text-end" style="width:150px;" readonly value="0.00">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-success">Guardar Venta</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>
$(document).ready(function() {
    $('#tablaVentas').DataTable();

    // Buscar cliente
    $('#btnBuscarCliente').click(async () => {
        const nit = $('#nit').val().trim();
        if (!nit) { alert('Ingrese un NIT.'); return; }
        const resp = await fetch(`ajax/buscarCliente.jsp?nit=${nit}`);
        const data = await resp.text();
        if (data && data !== "") {
            const [nombres, apellidos, direccion, telefono] = data.split("|");
            if (nombres) {
                $('#nombres').val(nombres);
                $('#apellidos').val(apellidos);
                $('#direccion').val(direccion);
                $('#telefono').val(telefono);
                $('<input>').attr({type:'hidden',name:'id_cliente',value:1}).appendTo('form'); // puedes cambiar para buscar por id_cliente real
            } else {
                alert('Cliente no encontrado.');
            }
        } else {
            alert('Cliente no encontrado.');
        }
    });

    // Cargar opciones de productos
    const opcionesProductos = `
        <% try (Connection con = new ConexionDB().getConexion();
               PreparedStatement ps = con.prepareStatement("SELECT id_producto, producto, precio_venta FROM productos ORDER BY producto");
               ResultSet rs = ps.executeQuery()) {
            while (rs.next()) { %>
                <option value="<%=rs.getInt("id_producto")%>" data-precio="<%=rs.getDouble("precio_venta")%>">
                    <%=rs.getString("producto")%> (Q<%=rs.getDouble("precio_venta")%>)
                </option>
        <% } } catch (Exception e) { %><option>Error</option><% } %>`;

    // Agregar fila producto
    $('#btnAddRow').click(() => {
        $('#detalleVenta').append(`
            <tr>
                <td><select name="id_producto[]" class="form-select">${opcionesProductos}</select></td>
                <td><input type="number" name="cantidad[]" value="1" class="form-control text-end" min="1"></td>
                <td><input type="number" name="precio[]" class="form-control text-end" step="0.01" readonly></td>
                <td class="subtotal text-end">0.00</td>
                <td><button type="button" class="btn btn-danger btn-sm btnDelRow">X</button></td>
            </tr>`);
    });

    // Eliminar fila
    $(document).on('click', '.btnDelRow', function() {
        $(this).closest('tr').remove(); recalcularTotal();
    });

    // Calcular subtotal
    $(document).on('change input', '[name="id_producto[]"], [name="cantidad[]"]', function() {
        const fila = $(this).closest('tr');
        const precio = parseFloat(fila.find('select option:selected').data('precio')) || 0;
        const cantidad = parseInt(fila.find('[name="cantidad[]"]').val()) || 0;
        const subtotal = precio * cantidad;
        fila.find('[name="precio[]"]').val(precio.toFixed(2));
        fila.find('.subtotal').text(subtotal.toFixed(2));
        recalcularTotal();
    });

    // Calcular total
    function recalcularTotal() {
        let total = 0;
        $('#detalleVenta .subtotal').each(function() {
            total += parseFloat($(this).text()) || 0;
        });
        $('#total').val(total.toFixed(2));
    }
});
</script>

</body>
</html>
