package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Puesto;

@WebServlet(name = "sr_puesto", urlPatterns = {"/sr_puesto"})
public class sr_puesto extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String btn = request.getParameter("btn");
        Puesto puesto = new Puesto();

        try {
            switch (btn) {
                case "Agregar":
                    puesto.setPuesto(request.getParameter("txt_puesto"));
                    puesto.agregar();
                    break;

                case "Actualizar":
                    puesto.setId_puesto(Integer.parseInt(request.getParameter("id_puesto")));
                    puesto.setPuesto(request.getParameter("txt_puesto"));
                    puesto.actualizar();
                    break;

                case "Eliminar":
                    puesto.setId_puesto(Integer.parseInt(request.getParameter("id_puesto")));
                    puesto.eliminar();
                    break;
            }
        } catch (Exception e) {
            System.out.println("❌ Error en sr_puesto: " + e.getMessage());
        }

        response.sendRedirect("views/puestos.jsp");
    }
}
