package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import modelo.Compra;
import modelo.CompraDetalle;


@WebServlet(name = "sr_compra", urlPatterns = {"/sr_compra"})
public class sr_compra extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Compra compra = new Compra();
            compra.setNegorden_compra(Integer.parseInt(request.getParameter("no_orden")));
            compra.setId_proveedor(Integer.parseInt(request.getParameter("drop_proveedor")));
            compra.setFecha_gridem(Date.valueOf(request.getParameter("fecha_gridem")));
            compra.setFecha_ingreso(Timestamp.valueOf(LocalDateTime.now()));

            if (compra.agregar()) {
                // Obtener el id de la compra recién creada
                int idCompra = obtenerUltimoIdCompra();

                // Leer los detalles enviados
                String[] productos = request.getParameterValues("id_producto");
                String[] cantidades = request.getParameterValues("cantidad");
                String[] precios = request.getParameterValues("precio");

                if (productos != null) {
                    for (int i = 0; i < productos.length; i++) {
                        CompraDetalle detalle = new CompraDetalle();
                        detalle.setId_compra(idCompra);
                        detalle.setId_producto(Integer.parseInt(productos[i]));
                        detalle.setCantidad(Integer.parseInt(cantidades[i]));
                        detalle.setPrecio_unitario(Double.parseDouble(precios[i]));
                        detalle.agregar();
                    }
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Error en sr_compra: " + e.getMessage());
        }

        response.sendRedirect("views/compras.jsp");
    }

    private int obtenerUltimoIdCompra() {
        try (var con = new utils.ConexionDB().getConexion();
             var ps = con.prepareStatement("SELECT MAX(id_compra) FROM Compras");
             var rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            System.out.println("❌ Error al obtener último ID: " + e.getMessage());
        }
        return 0;
    }
}
