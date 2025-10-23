<%@ page import="modelo.Producto,modelo.Marca,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Mantenimiento de Productos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style> 
        tr:hover { background-color: #e8f4ff; cursor: pointer; }
        #formProductos { transition: all 0.3s ease; }
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
        .product-img {
            max-width: 100px;
            max-height: 100px;
            object-fit: cover;
        }
        .product-img-preview {
            max-width: 200px;
            max-height: 200px;
            object-fit: cover;
            margin-top: 10px;
        }
    </style>
</head>

<body class="bg-light">
<%@ include file="../includes/menu.jsp" %>
<div class="main-content">
    <div class="container-fluid">
        <h2 class="mb-4 text-center text-primary">Mantenimiento de Productos</h2>

        <!-- 🔘 BOTÓN PARA MOSTRAR/OCULTAR FORMULARIO -->
        <div class="text-end mb-3">
            <button id="btnMostrarForm" class="btn btn-success">
                ➕ Nuevo Producto
            </button>
        </div>

        <!-- 🧾 FORMULARIO (OCULTO POR DEFECTO) -->
        <form action="../sr_producto" method="post" class="card p-4 shadow-sm d-none" id="formProductos">
            <input type="hidden" name="id_producto" id="id_producto">

            <div class="row g-3">
                <div class="col-md-6">
                    <label for="txt_producto" class="form-label">Nombre del Producto</label>
                    <input type="text" name="txt_producto" id="txt_producto" class="form-control" required>
                </div>
                
                <div class="col-md-6">
                    <label for="drop_marca" class="form-label">Marca</label>
                    <select name="drop_marca" id="drop_marca" class="form-select" required>
                        <option value="">Seleccione una marca</option>
                        <%
                            Marca m = new Marca();
                            List<Marca> marcas = m.leer();
                            for (Marca marca : marcas) {
                        %>
                            <option value="<%= marca.getId_marca() %>"><%= marca.getMarca() %></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="col-md-12">
                    <label for="txt_descripcion" class="form-label">Descripción</label>
                    <textarea name="txt_descripcion" id="txt_descripcion" class="form-control" rows="3"></textarea>
                </div>
                
                <div class="col-md-6">
                    <label for="txt_imagen" class="form-label">URL de la Imagen</label>
                    <input type="url" name="txt_imagen" id="txt_imagen" class="form-control">
                    <img id="imgPreview" class="product-img-preview d-none">
                </div>
                
                <div class="col-md-2">
                    <label for="txt_costo" class="form-label">Precio Costo</label>
                    <input type="number" name="txt_costo" id="txt_costo" class="form-control" step="0.01" min="0" required>
                </div>
                
                <div class="col-md-2">
                    <label for="txt_venta" class="form-label">Precio Venta</label>
                    <input type="number" name="txt_venta" id="txt_venta" class="form-control" step="0.01" min="0" required>
                </div>
                
                <div class="col-md-2">
                    <label for="txt_existencia" class="form-label">Existencia</label>
                    <input type="number" name="txt_existencia" id="txt_existencia" class="form-control" min="0" required>
                </div>
                
                <div class="col-12 d-flex gap-2">
                    <button name="btn" id="btnAccion" value="Agregar" class="btn btn-success">Agregar</button>
                    <button name="btn" value="Eliminar" id="btnEliminar" class="btn btn-danger d-none" onclick="return confirm('¿Eliminar este producto?')">Eliminar</button>
                    <button type="button" id="btnCancelar" class="btn btn-secondary">Cancelar</button>
                </div>
            </div>
        </form>

        <!-- 📋 TABLA -->
        <div class="card mt-3 shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped align-middle" id="tablaProductos">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Imagen</th>
                                <th>Producto</th>
                                <th>Marca</th>
                                <th>Descripción</th>
                                <th>Precio Costo</th>
                                <th>Precio Venta</th>
                                <th>Existencia</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Producto p = new Producto();
                                List<Producto> lista = p.leer();
                                for (Producto producto : lista) {
                            %>
                            <tr onclick="seleccionarProducto(this)"
                                data-id="<%= producto.getId_producto() %>"
                                data-producto="<%= producto.getProducto() %>"
                                data-marca="<%= producto.getId_marca() %>"
                                data-descripcion="<%= producto.getDescripcion() %>"
                                data-imagen="<%= producto.getImagen_url() %>"
                                data-costo="<%= producto.getPrecio_costo() %>"
                                data-venta="<%= producto.getPrecio_venta() %>"
                                data-existencia="<%= producto.getExistencia() %>">
                                <td><%= producto.getId_producto() %></td>
                                <td>
                                    <% if(producto.getImagen_url() != null && !producto.getImagen_url().isEmpty()) { %>
                                        <img src="<%= producto.getImagen_url() %>" class="product-img" alt="<%= producto.getProducto() %>">
                                    <% } else { %>
                                        <span class="text-muted">Sin imagen</span>
                                    <% } %>
                                </td>
                                <td><%= producto.getProducto() %></td>
                                <td><%= producto.getMarca() %></td>
                                <td><%= producto.getDescripcion() %></td>
                                <td>Q<%= String.format("%.2f", producto.getPrecio_costo()) %></td>
                                <td>Q<%= String.format("%.2f", producto.getPrecio_venta()) %></td>
                                <td><%= producto.getExistencia() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JS -->
<script>
$(document).ready(function(){
    // Mostrar / ocultar formulario
    $("#btnMostrarForm").click(function(e){
        e.preventDefault();
        $("#formProductos").toggleClass("d-none");
        $(this).text($("#formProductos").hasClass("d-none") ? "➕ Nuevo Producto" : "❌ Ocultar formulario");
        limpiarFormulario();
    });
    
    // Vista previa de imagen
    $("#txt_imagen").on("input", function(){
        const url = $(this).val();
        const imgPreview = $("#imgPreview");
        if(url) {
            imgPreview.attr("src", url).removeClass("d-none");
        } else {
            imgPreview.addClass("d-none");
        }
    });
    
    // Botón cancelar
    $("#btnCancelar").click(function(){
        limpiarFormulario();
    });
});

function seleccionarProducto(fila) {
    // Llenar formulario con datos
    $("#id_producto").val(fila.dataset.id);
    $("#txt_producto").val(fila.dataset.producto);
    $("#drop_marca").val(fila.dataset.marca);
    $("#txt_descripcion").val(fila.dataset.descripcion);
    $("#txt_imagen").val(fila.dataset.imagen);
    $("#txt_costo").val(fila.dataset.costo);
    $("#txt_venta").val(fila.dataset.venta);
    $("#txt_existencia").val(fila.dataset.existencia);
    
    // Mostrar vista previa de imagen
    const imgUrl = fila.dataset.imagen;
    if(imgUrl) {
        $("#imgPreview").attr("src", imgUrl).removeClass("d-none");
    }
    
    // Cambiar botones
    $("#btnAccion").val("Actualizar").text("Actualizar").removeClass("btn-success").addClass("btn-warning");
    $("#btnEliminar").removeClass("d-none");
    
    // Mostrar formulario
    $("#formProductos").removeClass("d-none");
    $("#btnMostrarForm").text("❌ Ocultar formulario");
}

function limpiarFormulario() {
    $("#formProductos")[0].reset();
    $("#id_producto").val("");
    $("#imgPreview").addClass("d-none");
    $("#btnAccion").val("Agregar").text("Agregar").removeClass("btn-warning").addClass("btn-success");
    $("#btnEliminar").addClass("d-none");
}
</script>

</body>
</html>