package controlador;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ConexionDB;

@WebServlet(name = "sr_conexion", urlPatterns = {"/sr_conexion"})
public class sr_conexion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            ConexionDB cn = new ConexionDB();
            if (cn.getConexion() != null) {
                out.println("<h2 style='color:green;'>✅ Conexión exitosa a la base de datos</h2>");
            } else {
                out.println("<h2 style='color:red;'>❌ Error de conexión</h2>");
            }
        }
    }
}
