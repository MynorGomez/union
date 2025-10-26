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
        <%= msg %><button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    <% } else if (error != null) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <%= error %><button type="button" class="btn-close" data-bs-dismiss="alert"></button>
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
            if (ventas == null) ventas = new Venta().listar();
            if (ventas != null && !ventas.isEmpty()) {
              for (Venta v : ventas) {
          %>
            <tr class="fila-venta" data-id="<%= v.getId_venta() %>">
              <td><%= v.getId_venta() %></td>
              <td><%= v.getNo_factura() %></td>
              <td><%= v.getSerie() %></td>
              <td><%= v.getFecha_venta() %></td>
              <td><%= v.getCliente() %></td>
              <td><%= v.getEmpleado() %></td>
              <td class="text-end"><%= String.format("%.2f", v.getTotal()) %></td>
              <td>
                <button type="button" class="btn btn-outline-warning btn-sm ver-detalle"
                        data-id="<%= v.getId_venta() %>">
                  <i class="bi bi-eye"></i> Ver Detalle
                </button>
                <form action="../sr_venta" method="post" class="d-inline">
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

<%
StringBuilder opcionesProductos = new StringBuilder();
opcionesProductos.append("<option value=''>-- Seleccione un producto --</option>");
try (Connection con = new ConexionDB().getConexion();
     PreparedStatement ps = con.prepareStatement("SELECT id_producto, producto, precio_venta FROM productos ORDER BY producto");
     ResultSet rs = ps.executeQuery()) {
  while (rs.next()) {
    opcionesProductos.append("<option value='")
      .append(rs.getInt("id_producto"))
      .append("' data-precio='")
      .append(rs.getDouble("precio_venta"))
      .append("'>")
      .append(rs.getString("producto").replace("\"","&quot;"))
      .append(" (Q")
      .append(String.format("%.2f", rs.getDouble("precio_venta")))
      .append(")</option>");
  }
} catch (Exception e) {
  opcionesProductos.append("<option disabled>Error al cargar productos</option>");
}
%>

<div class="modal fade" id="modalVenta" tabindex="-1">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <form action="../sr_venta" method="post">
        <input type="hidden" name="accion" value="agregar">
        <div class="modal-header bg-success text-white">
          <h5 class="modal-title">Nueva Venta</h5>
          <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
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

          <div class="card">
            <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
              <span>Detalle de Productos</span>
              <div>
                <button type="button" class="btn btn-light btn-sm" id="btnAddRow"><i class="bi bi-plus"></i> Agregar</button>
                <button type="button" class="btn btn-danger btn-sm" id="btnVaciar"><i class="bi bi-trash"></i> Vaciar</button>
              </div>
            </div>
            <div class="card-body">
              <table class="table">
                <thead class="table-success">
                  <tr><th>Producto</th><th>Cantidad</th><th>Precio Unitario (Q)</th><th>Subtotal</th><th></th></tr>
                </thead>
                <tbody id="detalleVenta">
                  <tr>
                    <td><select name="id_producto[]" class="form-select"><%= opcionesProductos.toString() %></select></td>
                    <td><input type="number" name="cantidad[]" value="1" class="form-control text-end" min="1"></td>
                    <td><input type="number" name="precio_unitario[]" class="form-control text-end" step="0.01" readonly></td>
                    <td class="subtotal text-end">0.00</td>
                    <td><button type="button" class="btn btn-danger btn-sm btnDelRow">X</button></td>
                  </tr>
                </tbody>
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

<div class="modal fade" id="modalDetalleVenta" tabindex="-1" data-bs-backdrop="static">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header bg-warning text-white">
        <h5 class="modal-title"><i class="bi bi-receipt"></i> Detalle de Venta</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="contenidoDetalleVenta">
        <div class="text-center text-muted my-3"><i class="bi bi-hourglass-split"></i> Cargando detalles...</div>
      </div>
    </div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script>
$(function(){

  // Inicializar DataTable
  $('#tablaVentas').DataTable();

  // Buscar cliente por NIT
  $('#btnBuscarCliente').click(async()=>{
    const nit=$('#nit').val().trim();
    if(!nit) return alert('Ingrese un NIT.');
    const r=await fetch('code/buscarCliente.jsp?nit='+encodeURIComponent(nit));
    const t=await r.text();
    if(!t) return alert('Cliente no encontrado.');
    const [idc,n,a,d,te]=t.split('|');
    $('#nombres').val(n); $('#apellidos').val(a); $('#direccion').val(d); $('#telefono').val(te);
    let h=$('[name="id_cliente"]');
    if(!h.length) $('<input>').attr({type:'hidden',name:'id_cliente'}).val(idc).appendTo('#modalVenta form');
    else h.val(idc);
  });

  // Agregar nueva fila al detalle
  $(document).on('click','#btnAddRow',()=>{
    let f=$('#detalleVenta tr:first').clone();
    f.find('select').val('');
    f.find('[name="cantidad[]"]').val(1);
    f.find('[name="precio_unitario[]"]').val('');
    f.find('.subtotal').text('0.00');
    $('#detalleVenta').append(f);
  });

  // Vaciar detalle
  $('#btnVaciar').click(()=>{
    if(confirm('¿Seguro que desea vaciar?')){
      $('#detalleVenta').html($('#detalleVenta tr:first').prop('outerHTML'));
      $('#detalleVenta tr:first select').val('');
      $('#detalleVenta tr:first [name="cantidad[]"]').val(1);
      $('#detalleVenta tr:first [name="precio_unitario[]"]').val('');
      $('#detalleVenta tr:first .subtotal').text('0.00');
      rTotal();
    }
  });

  // Eliminar fila del detalle
  $(document).on('click','.btnDelRow',function(){
    $(this).closest('tr').remove();
    rTotal();
  });

  // Calcular subtotales y evitar duplicados
  $(document).on('change input','[name="id_producto[]"], [name="cantidad[]"]',function(){
    const fila=$(this).closest('tr');
    const s=fila.find('select');
    const id=s.val();

    // Evitar productos duplicados
    if(id){
      let rep=false;
      $('[name="id_producto[]"]').not(s).each(function(){
        if($(this).val()===id) rep=true;
      });
      if(rep){
        alert('⚠️ Este producto ya fue agregado.');
        s.val('');
        fila.find('[name="precio_unitario[]"]').val('');
        fila.find('.subtotal').text('0.00');
        rTotal();
        return;
      }
    }

    const p=parseFloat(s.find('option:selected').data('precio'))||0;
    const c=parseInt(fila.find('[name="cantidad[]"]').val())||0;
    fila.find('[name="precio_unitario[]"]').val(p.toFixed(2));
    fila.find('.subtotal').text((p*c).toFixed(2));
    rTotal();
  });

  // Recalcular total
  function rTotal(){
    let t=0;
    $('#detalleVenta .subtotal').each(function(){
      t+=parseFloat($(this).text())||0;
    });
    $('#total').val(t.toFixed(2));
  }

  // Ver detalle de venta (solo lectura)
  $(document).on('click','.ver-detalle',function(){
    const id=$(this).data('id');
    const m=new bootstrap.Modal(document.getElementById('modalDetalleVenta'));
    $('#contenidoDetalleVenta').html("<div class='text-center text-muted my-3'><i class='bi bi-hourglass-split'></i> Cargando...</div>");
    $.get('detalleVenta.jsp',{id_venta:id},html=>{
      $('#contenidoDetalleVenta').html(html);
      m.show();
    });
  });

  // EDITAR venta (click en fila)
  $(document).on('click','.fila-venta',function(e){
    if($(e.target).closest('button,a,form').length) return; // evita botones
    const id=$(this).data('id');
    if(!id) return;
    const m=new bootstrap.Modal(document.getElementById('modalVenta'));
    $('#modalVenta .modal-title').text('Editar Venta #'+id);
    $("input[name='accion']").val('actualizar');
    $("input[name='id_venta']").remove();
    $("<input>").attr({type:'hidden',name:'id_venta',value:id}).appendTo('#modalVenta form');
    $("#modalVenta button[type='submit']").text('Actualizar Venta').removeClass('btn-success').addClass('btn-warning');

    $('#detalleVenta').html("<tr><td colspan='5' class='text-center text-muted'>Cargando datos...</td></tr>");

    $.getJSON('code/getVentaInfo.jsp',{id_venta:id},d=>{
      if(d && d.id_cliente){
        $('#nit').val(d.nit); $('#nombres').val(d.nombres); $('#apellidos').val(d.apellidos);
        $('#telefono').val(d.telefono); $('#direccion').val(d.direccion);
        $("input[name='no_factura']").val(d.no_factura);
        $("input[name='serie']").val(d.serie);
        $("select[name='id_empleado']").val(d.id_empleado);
        let h=$('[name="id_cliente"]');
        if(!h.length) $('<input>').attr({type:'hidden',name:'id_cliente'}).val(d.id_cliente).appendTo('#modalVenta form');
        else h.val(d.id_cliente);
      }
    });

    $.get('code/detalleVentaEditable.jsp',{id_venta:id},html=>{
      const t=$(html).find('#tablaDetalleVenta').html();
      if(t){
        $('#detalleVenta').html(t);
        rTotal();
        m.show();
      } else {
        alert('No se encontró el detalle.');
      }
    });
  });

  // NUEVA VENTA: limpiar modal
  $(document).on("click", "[data-bs-target='#modalVenta']", function() {
    $("#modalVenta .modal-title").text("Nueva Venta");
    $("input[name='accion']").val("agregar");
    $("input[name='id_venta']").remove();
    const btnGuardar=$("#modalVenta button[type='submit']");
    btnGuardar.text("Guardar Venta").removeClass("btn-warning").addClass("btn-success");
    $("#nit,#nombres,#apellidos,#direccion,#telefono").val("");
    $("[name='id_cliente']").remove();
    $("select[name='id_empleado']").val("");
    $("#detalleVenta").html(`
        <tr>
            <td><select name="id_producto[]" class="form-select"><%= opcionesProductos.toString() %></select></td>
            <td><input type="number" name="cantidad[]" value="1" class="form-control text-end" min="1"></td>
            <td><input type="number" name="precio_unitario[]" class="form-control text-end" step="0.01" readonly></td>
            <td class="subtotal text-end">0.00</td>
            <td><button type="button" class="btn btn-danger btn-sm btnDelRow">X</button></td>
        </tr>
    `);
    $("#total").val("0.00");
  });

  // ✅ Guardar o actualizar sin recargar la página completa
  $(document).off('submit','#modalVenta form').on('submit','#modalVenta form',function(e){
    e.preventDefault();
    if($(document.activeElement).attr("type")!=="submit") return; // no guardar al cerrar modal
    const f=$(this), acc=f.find("input[name='accion']").val();
    const modal=bootstrap.Modal.getInstance(document.getElementById('modalVenta'));

    $.post(f.attr('action'), f.serialize(), r=>{
      alert('Venta '+(acc==='agregar'?'guardada':'actualizada')+' correctamente.');
      modal.hide();

      // 🔄 Actualiza la tabla principal sin recargar todo
      $("#tablaVentas tbody").html("<tr><td colspan='6' class='text-center text-muted'>Actualizando ventas...</td></tr>");
      $.get('code/getVentasTable.jsp', html=>{
        const rows=$(html).find('tbody').html();
        if(rows) $('#tablaVentas tbody').html(rows);
      });

    }).fail(()=>alert('Error al procesar.'));
  });

  // Limpiar modal al cerrarlo manualmente
  $('#modalVenta').on('hidden.bs.modal', function(){
    $("#modalVenta .modal-title").text("Nueva Venta");
    $("input[name='accion']").val("agregar");
    $("input[name='id_venta']").remove();
    $("#modalVenta button[type='submit']").text("Guardar Venta").removeClass("btn-warning").addClass("btn-success");
  });

});
</script>

</body>
</html>
