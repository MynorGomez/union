<%@ page import="modelo.Compra,modelo.Proveedor,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro de Compras</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f7f9fc;
            font-family: 'Poppins', sans-serif;
        }
        .card {
            border-radius: 20px;
        }
        tr:hover {
            background-color: #e8f4ff;
            cursor: pointer;
        }
        .table td, .table th {
            vertical-align: middle;
        }
    </style>
</head>
<body class="bg-light">

<div class="container mt-5">
    <h2 class="mb-4 text-center text-primary fw-bold">Registro de Compras</h2>

    <!-- FORMULARIO MAESTRO -->
    <form action="../sr_compra" method="post" id="formCompra" class="card p-4 shadow-sm">
        <div class="row g-3">
            <div class="col-md-3">
                <label class="form-label fw-semibold">No. Orden</label>
                <input type="number" name="no_orden" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label fw-semibold">Proveedor</label>
                <select name="drop_proveedor" class="form-select" required>
                    <option value="">Seleccione...</option>
                    <%
                        Proveedor prov = new Proveedor();
                        List<Proveedor> proveedores = prov.leer();
                        for (Proveedor p : proveedores) {
                    %>
                    <option value="<%= p.getId_proveedor() %>"><%= p.getProveedor() %></option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold">Fecha de emisión</label>
                <input type="date" name="fecha_gridem" class="form-control" required>
            </div>

            <div class="col-md-2 text-end d-flex align-items-end">
                <button type="submit" class="btn btn-success w-100 rounded-pill">💾 Guardar Compra</button>
            </div>
        </div>

        <!-- TABLA DETALLE -->
        <div class="mt-4">
            <h5 class="fw-bold text-secondary mb-3">Detalle de Compra</h5>
            <table class="table table-bordered text-center align-middle" id="tablaDetalle">
                <thead class="table-secondary">
                    <tr>
                        <th style="width: 40%">ID Producto</th>
                        <th style="width: 20%">Cantidad</th>
                        <th style="width: 20%">Precio Unitario</th>
                        <th style="width: 15%">Subtotal</th>
                        <th style="width: 5%">Acción</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>

            <div class="d-flex justify-content-between align-items-center">
                <button type="button" class="btn btn-outline-primary rounded-pill" onclick="agregarFila()">➕ Agregar producto</button>
                <h5>Total: Q <span id="total" class="text-success fw-bold">0.00</span></h5>
            </div>
        </div>
    </form>

    <!-- TABLA DE COMPRAS REGISTRADAS -->
    <div class="card mt-5 shadow-sm">
        <div class="card-body">
            <h5 class="mb-3 text-secondary fw-bold">Historial de Compras</h5>
            <table class="table table-striped text-center align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>No. Orden</th>
                        <th>Proveedor</th>
                        <th>Fecha Emisión</th>
                        <th>Fecha Ingreso</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Compra c = new Compra();
                        List<Compra> compras = c.leer();
                        for (Compra comp : compras) {
                    %>
                    <tr>
                        <td><%= comp.getId_compra() %></td>
                        <td><%= comp.getNegorden_compra() %></td>
                        <td><%= comp.getProveedor() %></td>
                        <td><%= comp.getFecha_gridem() %></td>
                        <td><%= comp.getFecha_ingreso() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ======================== JS DETALLE ======================== -->
<script>
let total = 0;

function agregarFila() {
    const tbody = document.querySelector("#tablaDetalle tbody");
    const fila = document.createElement("tr");

    fila.innerHTML = `
        <td><input type="number" name="id_producto" class="form-control" placeholder="ID Producto" required></td>
        <td><input type="number" name="cantidad" class="form-control" min="1" value="1" required onchange="calcularSubtotal(this)"></td>
        <td><input type="number" name="precio" class="form-control" min="0" step="0.01" value="0" required onchange="calcularSubtotal(this)"></td>
        <td class="subtotal">0.00</td>
        <td><button type="button" class="btn btn-danger btn-sm" onclick="eliminarFila(this)">🗑</button></td>
    `;
    tbody.appendChild(fila);
}

function calcularSubtotal(input) {
    const fila = input.closest("tr");
    const cantidad = parseFloat(fila.querySelector('input[name="cantidad"]').value) || 0;
    const precio = parseFloat(fila.querySelector('input[name="precio"]').value) || 0;
    const subtotal = cantidad * precio;
    fila.querySelector(".subtotal").textContent = subtotal.toFixed(2);
    calcularTotal();
}

function calcularTotal() {
    let totalTemp = 0;
    document.querySelectorAll(".subtotal").forEach(td => {
        totalTemp += parseFloat(td.textContent) || 0;
    });
    total = totalTemp;
    document.getElementById("total").textContent = total.toFixed(2);
}

function eliminarFila(btn) {
    btn.closest("tr").remove();
    calcularTotal();
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
