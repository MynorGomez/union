package controlador;

import java.io.IOException;
<<<<<<< HEAD
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import modelo.Marca;

@WebServlet(name = "sr_marca", urlPatterns = {"/sr_marca"})
public class sr_marca extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtenemos la acción (Agregar, Actualizar o Eliminar)
        String accion = request.getParameter("accion");
        Marca marca = new Marca();

        try {
            switch (accion) {
                case "Agregar":
                    marca.setMarca(request.getParameter("txt_marca"));
                    marca.agregar();
                    break;

                case "Actualizar":
                    marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                    marca.setMarca(request.getParameter("txt_marca"));
                    marca.actualizar();
                    break;

                case "Eliminar":
                    marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                    marca.eliminar();
                    break;
            }

            // Respuesta vacía para AJAX (status 200 OK)
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            System.err.println("❌ Error en sr_marca: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
=======
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.Marca;
import java.util.HashMap;

public class sr_marca extends HttpServlet {

    Marca marca;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Marcas</title>");
            out.println("</head>");
            out.println("<body>");
            
            marca = new Marca();
            
            // Recibir datos del formulario
            String accion = request.getParameter("btn");
            
            if(accion != null) {
                if(request.getParameter("txt_marca") != null) {
                    marca.setMarca(request.getParameter("txt_marca"));
                }
                
                HashMap<String, String> resultado = new HashMap<>();
                
                switch(accion) {
                    case "Agregar":
                        resultado = marca.insertar();
                        break;
                    case "Actualizar":
                        if(request.getParameter("id_marca") != null) {
                            marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                            resultado = marca.actualizar();
                        }
                        break;
                    case "Eliminar":
                        if(request.getParameter("id_marca") != null) {
                            marca.setId_marca(Integer.parseInt(request.getParameter("id_marca")));
                            resultado = marca.eliminar();
                        }
                        break;
                }
                
                response.sendRedirect("views/marcas.jsp");
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
        return "Servlet para el manejo de marcas";
    }
}
>>>>>>> fusion
