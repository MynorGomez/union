<%@ page import="java.sql.*, utils.ConexionDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Editar Detalle de Venta</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <style>
    body { background-color: #f8fafc; font-family: 'Poppins', sans-serif; }
    .card { border-radius: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
    .table th { background-color: #e7f6e7; }
    .table tfoot { background-color: #212529; color: #fff; font-weight: bold; }
  </style>
</head>

<body>
<%
  String idVenta = request.getParameter("id_venta");
  ConexionDB cn = new ConexionDB();
  Connection con = cn.getConexion();

  PreparedStatement ps = con.prepareStatement(
      "SELECT v.no_factura, v.serie, v.fecha_venta, c.nombres AS cliente_nombre, c.apellidos AS cliente_apellido, c.nit, " +
      "e.nombres AS empleado_nombre, e.apellidos AS empleado_apellido " +
      "FROM ventas v " +
      "INNER JOIN clientes c ON v.id_cliente = c.id_cliente " +
      "INNER JOIN empleados e ON v.id_empleado = e.id_empleado " +
      "WHERE v.id_venta = ?");
  ps.setInt(1, Integer.parseInt(idVenta));
  ResultSet rs = ps.executeQuery();
%>

<div class="container py-3">
  <form id="formEditarVenta">
    <input type="hidden" name="accion" value="actualizar_detalle">
    <input type="hidden" name="id_venta" value="<%= idVenta %>">

    <div class="card p-3 mb-4">
      <h5 class="text-primary"><i class="bi bi-info-circle"></i> Datos de la Venta</h5>
      <hr>
      <% if (rs.next()) { %>
      <div class="row">
        <div class="col-md-3"><strong>No. Factura:</strong> <%= rs.getString("no_factura") %></div>
        <div class="col-md-3"><strong>Serie:</strong> <%= rs.getString("serie") %></div>
        <div class="col-md-3"><strong>Cliente:</strong> <%= rs.getString("cliente_nombre") %> <%= rs.getString("cliente_apellido") %></div>
        <div class="col-md-3"><strong>NIT:</strong> <%= rs.getString("nit") %></div>
      </div>
      <div class="row mt-2">
        <div class="col-md-4"><strong>Empleado:</strong> <%= rs.getString("empleado_nombre") %> <%= rs.getString("empleado_apellido") %></div>
        <div class="col-md-4"><strong>Fecha:</strong> <%= rs.getTimestamp("fecha_venta") %></div>
      </div>
      <% } %>
    </div>

    <div class="card p-3">
      <h5 class="text-success"><i class="bi bi-pencil-square"></i> Editar Productos Vendidos</h5>
      <hr>
      <div class="table-responsive" id="tablaDetalleVenta">
        <table class="table table-bordered align-middle text-center">
          <thead>
            <tr>
              <th>Producto</th>
              <th>Cantidad</th>
              <th>Precio Unitario (Q)</th>
              <th>Subtotal (Q)</th>
              <th></th>
            </tr>
          </thead>
          <tbody id="detalleBody">
            <%
              ps = con.prepareStatement(
                "SELECT d.id_producto, p.producto, p.precio_venta, d.cantidad, d.precio_unitario, d.subtotal " +
                "FROM ventas_detalle d " +
                "INNER JOIN productos p ON d.id_producto = p.id_producto " +
                "WHERE d.id_venta = ?");
              ps.setInt(1, Integer.parseInt(idVenta));
              rs = ps.executeQuery();
              boolean hay = false;
              while (rs.next()) {
                hay = true;
            %>
            <tr>
              <td>
                <select name="id_producto[]" class="form-select producto">
                  <%
                    PreparedStatement psProd = con.prepareStatement("SELECT id_producto, producto, precio_venta FROM productos ORDER BY producto");
                    ResultSet rsP = psProd.executeQuery();
                    while (rsP.next()) {
                      boolean selected = (rsP.getInt("id_producto") == rs.getInt("id_producto"));
                  %>
                    <option value="<%= rsP.getInt("id_producto") %>" data-precio="<%= rsP.getDouble("precio_venta") %>" <%= selected ? "selected" : "" %>>
                      <%= rsP.getString("producto") %>
                    </option>
                  <% } rsP.close(); psProd.close(); %>
                </select>
              </td>
              <td><input type="number" name="cantidad[]" class="form-control text-end cantidad" min="1" value="<%= rs.getInt("cantidad") %>"></td>
              <td><input type="number" name="precio_unitario[]" class="form-control text-end precio" step="0.01" value="<%= rs.getDouble("precio_unitario") %>"></td>
              <td class="subtotal text-end"><%= String.format("%.2f", rs.getDouble("subtotal")) %></td>
              <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
            </tr>
            <% } if (!hay) { %>
              <tr><td colspan="5" class="text-center text-muted">Sin productos</td></tr>
            <% } %>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="3" class="text-end fw-bold">Total:</td>
              <td id="totalVenta" class="text-end fw-bold">0.00</td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div class="mt-2">
        <button type="button" id="btnAgregarProducto" class="btn btn-success btn-sm">
          <i class="bi bi-plus-lg"></i> Agregar Producto
        </button>
      </div>

      <div class="text-end mt-4">
        <button type="button" id="btnGuardarCambios" class="btn btn-primary">
          <i class="bi bi-save"></i> Guardar Cambios
        </button>
      </div>
    </div>
  </form>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
$(function(){
  function recalcular() {
    let total = 0;
    $("#detalleBody tr").each(function(){
      const c = parseFloat($(this).find(".cantidad").val()) || 0;
      const p = parseFloat($(this).find(".precio").val()) || 0;
      const s = c * p;
      $(this).find(".subtotal").text(s.toFixed(2));
      total += s;
    });
    $("#totalVenta").text(total.toFixed(2));
  }

  // Recalcular al escribir cantidad o precio
  $(document).on("input change", ".cantidad, .precio", recalcular);

  // Actualizar precio al cambiar producto
  $(document).on("change", ".producto", function(){
    const fila = $(this).closest("tr");
    const precio = parseFloat($(this).find("option:selected").data("precio")) || 0;
    fila.find(".precio").val(precio.toFixed(2));
    recalcular();
  });

  recalcular();

  // Eliminar fila
  $(document).on("click", ".eliminarFila", function(){
    $(this).closest("tr").remove();
    recalcular();
  });

  // Agregar fila nueva
  $(document).on("click", "#btnAgregarProducto", function(){
    let fila = `
      <tr>
        <td>
          <select name="id_producto[]" class="form-select producto">
            <% 
              PreparedStatement ps2 = con.prepareStatement("SELECT id_producto, producto, precio_venta FROM productos ORDER BY producto");
              ResultSet rs2 = ps2.executeQuery();
              while (rs2.next()) {
            %>
              <option value="<%= rs2.getInt("id_producto") %>" data-precio="<%= rs2.getDouble("precio_venta") %>">
                <%= rs2.getString("producto") %>
              </option>
            <% } rs2.close(); ps2.close(); %>
          </select>
        </td>
        <td><input type="number" name="cantidad[]" class="form-control text-end cantidad" min="1" value="1"></td>
        <td><input type="number" name="precio_unitario[]" class="form-control text-end precio" step="0.01" value="0.00"></td>
        <td class="subtotal text-end">0.00</td>
        <td><button type="button" class="btn btn-danger btn-sm eliminarFila"><i class="bi bi-trash"></i></button></td>
      </tr>`;
    $("#detalleBody").append(fila);
  });

 // Guardar cambios vía AJAX (sin recargar toda la página)
$("#btnGuardarCambios").click(function(){
  const form = $("#formEditarVenta");
  const data = form.serialize();

  $.post("../sr_venta", data, function(resp){
    // ✅ Confirmación visual
    alert("✅ Cambios guardados correctamente.");

    // 🔒 Cerrar el modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('modalDetalleVenta'));
    if (modal) modal.hide();

    // 🔄 Actualizar solo la tabla principal de ventas
    $.get("code/getVentasTable.jsp", function(html){
      const filas = $(html).find("tbody").html();
      if (filas) $("#tablaVentas tbody").html(filas);
    });

    // 🔁 (Opcional) actualizar el total general si lo tienes fuera de la tabla
    // $("#totalGlobal").load("code/getTotalVentas.jsp");

  }).fail(function(){
    alert("❌ Error al guardar los cambios.");
  });
});


</script>
</body>
</html>
