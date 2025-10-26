<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login - Sistema</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <style>
    body {
      background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
      font-family: 'Poppins', sans-serif;
    }
    .login-box {
      max-width: 400px;
      margin: 100px auto;
      background: #fff;
      padding: 2rem;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }
  </style>
</head>
<body>
<div class="login-box">
  <h3 class="text-center mb-4 text-primary">Iniciar Sesión</h3>
  <div id="msg"></div>

  <form id="loginForm">
    <div class="mb-3">
      <label class="form-label">Usuario</label>
      <input type="text" class="form-control" name="usuario" required>
    </div>
    <div class="mb-3">
      <label class="form-label">Contraseña</label>
      <input type="password" class="form-control" name="clave" required>
    </div>
    <button type="submit" class="btn btn-primary w-100">Entrar</button>
  </form>
</div>

<script>
$("#loginForm").submit(async function(e){
  e.preventDefault();
  $("#msg").html("<div class='text-center text-muted'>Verificando credenciales...</div>");
  
  const data = {
    usuario: $("[name='usuario']").val(),
    clave: $("[name='clave']").val()
  };

  try {
    // ⚙️ Llamada al API REST que devuelve el JWT
    const res = await fetch("http://localhost:5119/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    });

    if (!res.ok) throw new Error("Error de autenticación");

    const json = await res.json();
    if (json.token) {
      // Guarda el token en sesión vía servlet
      $.post("sr_login", { token: json.token, usuario: data.usuario }, function(){
        window.location = "views/ventas.jsp"; // Redirige a tu página principal
      });
    } else {
      $("#msg").html("<div class='alert alert-danger mt-3 text-center'>Credenciales incorrectas</div>");
    }
  } catch (error) {
    $("#msg").html("<div class='alert alert-danger mt-3 text-center'>Error al conectar con el servidor</div>");
  }
});
</script>
</body>
</html>
