<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="modelo.ProductoReporte" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Productos</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="p-4">

<!-- 🔹 Navegación -->
<div class="d-flex justify-content-between mb-4">
    <!-- Volver al menú principal -->
    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-secondary">
       ️ Volver al Menú Principal
    </a>

    <!-- Exportar PDF -->
    <a href="<%= request.getContextPath() %>/ReporteProductosPDF?tipo=<%= request.getParameter("tipo") != null ? request.getParameter("tipo") : "venta" %>"
       target="_blank" class="btn btn-danger">
        📄 Exportar a PDF
    </a>
</div>

<!-- 🔹 Título -->
<h2 class="mb-4 text-center">📦 <%= request.getAttribute("titulo") %></h2>

<%
    List<ProductoReporte> productos = (List<ProductoReporte>) request.getAttribute("productos");
%>

<!-- 🔹 Tabla de productos -->
<table class="table table-bordered table-striped shadow-sm">
    <thead class="table-dark text-center">
        <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Total (Q)</th>
        </tr>
    </thead>
    <tbody>
    <% if (productos != null && !productos.isEmpty()) {
           for (ProductoReporte p : productos) { %>
        <tr>
            <td><%= p.getNombre() %></td>
            <td class="text-center"><%= p.getCantidad() %></td>
            <td class="text-end"><%= String.format("%.2f", p.getTotal()) %></td>
        </tr>
    <% } } else { %>
        <tr><td colspan="3" class="text-center text-muted">No hay datos disponibles</td></tr>
    <% } %>
    </tbody>
</table>

<!-- 🔹 Gráfico de productos -->
<div class="mt-5">
    <canvas id="graficoProductos" width="900" height="400"></canvas>
</div>

<script>
    const ctx = document.getElementById('graficoProductos').getContext('2d');

    const datos = [
        <% if (productos != null) {
               for (ProductoReporte p : productos) { %>
                   { nombre: "<%= p.getNombre() %>", cantidad: <%= p.getCantidad() %> },
        <%     }
           } %>
    ];

    const nombres = datos.map(d => d.nombre);
    const cantidades = datos.map(d => d.cantidad);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: nombres,
            datasets: [{
                label: 'Cantidad',
                data: cantidades,
                backgroundColor: 'rgba(54, 162, 235, 0.8)',
                borderRadius: 6,
                barThickness: 25
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                title: { 
                    display: true, 
                    text: '<%= request.getAttribute("titulo") %>', 
                    font: { size: 18 } 
                }
            },
            scales: {
                x: { ticks: { autoSkip: false, maxRotation: 45, font: { size: 11 } } },
                y: { beginAtZero: true }
            }
        }
    });
</script>

</body>
</html>
