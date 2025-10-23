<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Venta,modelo.VentaDetalle,java.util.List"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <%@ include file="../includes/menu.jsp" %>
    
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Listado de Ventas</h4>
                        <a href="nueva_venta.jsp" class="btn btn-success">
                            <i class="bi bi-plus-circle"></i> Nueva Venta
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead>
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
                                        for(Venta v : ventas) {
                                    %>
                                    <tr>
                                        <td><%= v.getNo_factura() %></td>
                                        <td><%= v.getSerie() %></td>
                                        <td><%= v.getFecha_venta() %></td>
                                        <td><%= v.getCliente() %></td>
                                        <td><%= v.getEmpleado() %></td>
                                        <td>Q <%= String.format("%.2f", v.getTotal()) %></td>
                                        <td>
                                            <button type="button" class="btn btn-info btn-sm" 
                                                    onclick="verDetalle(<%= v.getId_venta() %>)">
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
        </div>
    </div>

    <!-- Modal para mostrar detalles -->
    <div class="modal fade" id="modalDetalle" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Detalle de Venta</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="detalleVenta"></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function verDetalle(idVenta) {
            $.ajax({
                url: '../sr_venta',
                type: 'GET',
                data: {
                    accion: 'verDetalle',
                    id_venta: idVenta
                },
                success: function(response) {
                    $('#detalleVenta').html(response);
                    $('#modalDetalle').modal('show');
                },
                error: function() {
                    alert('Error al cargar los detalles de la venta');
                }
            });
        }
        
        // Mostrar mensajes de éxito o error
        $(document).ready(function() {
            const urlParams = new URLSearchParams(window.location.search);
            if(urlParams.get('exito') === 'true') {
                alert('Venta registrada exitosamente');
            } else if(urlParams.get('error') === 'true') {
                alert('Error al registrar la venta');
            }
        });
    </script>
</body>
</html>