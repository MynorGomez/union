package controlador;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.Producto;
import java.util.HashMap;

public class sr_producto extends HttpServlet {

    Producto producto;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Productos</title>");
            out.println("</head>");
            out.println("<body>");
            
            producto = new Producto();
            
            // Recibir datos del formulario
            String accion = request.getParameter("btn");
            
            if(accion != null) {
                if(request.getParameter("txt_producto") != null) {
                    producto.setProducto(request.getParameter("txt_producto"));
                }
                if(request.getParameter("drop_marca") != null) {
                    producto.setId_marca(Integer.parseInt(request.getParameter("drop_marca")));
                }
                if(request.getParameter("txt_descripcion") != null) {
                    producto.setDescripcion(request.getParameter("txt_descripcion"));
                }
                if(request.getParameter("txt_imagen") != null) {
                    producto.setImagen_url(request.getParameter("txt_imagen"));
                }
                if(request.getParameter("txt_costo") != null) {
                    producto.setPrecio_costo(Double.parseDouble(request.getParameter("txt_costo")));
                }
                if(request.getParameter("txt_venta") != null) {
                    producto.setPrecio_venta(Double.parseDouble(request.getParameter("txt_venta")));
                }
                if(request.getParameter("txt_existencia") != null) {
                    producto.setExistencia(Integer.parseInt(request.getParameter("txt_existencia")));
                }
                
                HashMap<String, String> resultado = new HashMap<>();
                
                switch(accion) {
                    case "Agregar":
                        resultado = producto.insertar();
                        break;
                    case "Actualizar":
                        if(request.getParameter("id_producto") != null) {
                            producto.setId_producto(Integer.parseInt(request.getParameter("id_producto")));
                            resultado = producto.actualizar();
                        }
                        break;
                    case "Eliminar":
                        if(request.getParameter("id_producto") != null) {
                            producto.setId_producto(Integer.parseInt(request.getParameter("id_producto")));
                            resultado = producto.eliminar();
                        }
                        break;
                }
                
                response.sendRedirect("views/productos.jsp");
            }
            
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para el manejo de productos";
    }
}