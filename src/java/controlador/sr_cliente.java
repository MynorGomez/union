package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import modelo.Cliente;

@WebServlet(name = "sr_cliente", urlPatterns = {"/sr_cliente"})
public class sr_cliente extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String btn = request.getParameter("btn");
        Cliente cli = new Cliente();

        try {
<<<<<<< HEAD
            // ===============================
            // Campos comunes
            // ===============================
            cli.setNit(request.getParameter("txt_nit"));
            cli.setNombres(request.getParameter("txt_nombres"));
            cli.setApellidos(request.getParameter("txt_apellidos"));
            cli.setDireccion(request.getParameter("txt_direccion"));
            cli.setTelefono(request.getParameter("txt_telefono"));
            cli.setFecha_nacimiento(request.getParameter("txt_fn"));

            // ===============================
            // Nuevos campos agregados a la base
            // ===============================
            cli.setCorreo_electronico(request.getParameter("txt_correo"));
            cli.setGenero(Boolean.parseBoolean(request.getParameter("txt_genero")));

            // ⚠️ Si viene desde el formulario o una actualización manual
            String fechaIngresoParam = request.getParameter("txt_fechaingreso");
            if (fechaIngresoParam != null && !fechaIngresoParam.isEmpty()) {
                cli.setFechaingreso(fechaIngresoParam);
            }

            // ===============================
            // CRUD
            // ===============================
            switch (btn) {
                case "Agregar":
                    cli.agregar();  // fechaingreso se autollenará con NOW() en MySQL
=======
            switch (btn) {
                case "Agregar":
                    cli.setNit(request.getParameter("txt_nit"));
                    cli.setNombres(request.getParameter("txt_nombres"));
                    cli.setApellidos(request.getParameter("txt_apellidos"));
                    cli.setDireccion(request.getParameter("txt_direccion"));
                    cli.setTelefono(request.getParameter("txt_telefono"));
                    cli.setFecha_nacimiento(request.getParameter("txt_fn"));
                    cli.agregar();
>>>>>>> fusion
                    break;

                case "Actualizar":
                    cli.setId_cliente(Integer.parseInt(request.getParameter("id_cliente")));
<<<<<<< HEAD
=======
                    cli.setNit(request.getParameter("txt_nit"));
                    cli.setNombres(request.getParameter("txt_nombres"));
                    cli.setApellidos(request.getParameter("txt_apellidos"));
                    cli.setDireccion(request.getParameter("txt_direccion"));
                    cli.setTelefono(request.getParameter("txt_telefono"));
                    cli.setFecha_nacimiento(request.getParameter("txt_fn"));
>>>>>>> fusion
                    cli.actualizar();
                    break;

                case "Eliminar":
                    cli.setId_cliente(Integer.parseInt(request.getParameter("id_cliente")));
                    cli.eliminar();
                    break;
            }
<<<<<<< HEAD

=======
>>>>>>> fusion
        } catch (Exception e) {
            System.out.println("❌ Error en sr_cliente: " + e.getMessage());
        }

<<<<<<< HEAD
        // Redirige siempre al JSP principal
=======
>>>>>>> fusion
        response.sendRedirect("views/clientes.jsp");
    }
}
