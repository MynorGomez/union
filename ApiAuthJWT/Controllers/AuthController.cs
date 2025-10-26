using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using MySql.Data.MySqlClient;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace ApiAuthJWT.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;

        public AuthController(IConfiguration config)
        {
            _config = config;
        }

        // ✅ POST: /api/auth/login
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            try
            {
                using var con = new MySqlConnection(_config.GetConnectionString("MySql"));
                con.Open();

                using var cmd = new MySqlCommand(
                    "SELECT id_usuario, usuario, password, nombre, rol FROM usuarios WHERE usuario = @usuario", con);
                cmd.Parameters.AddWithValue("@usuario", request.Usuario);

                using var reader = cmd.ExecuteReader();
                if (!reader.Read())
                {
                    return Unauthorized(new { message = "Usuario no encontrado" });
                }

                string storedPassword = reader.GetString("password");
                string nombre = reader.GetString("nombre");
                string rol = reader.GetString("rol");

                // ⚙️ Comparar contraseñas (sin cifrado para ejemplo)
                if (storedPassword != request.Clave)
                {
                    return Unauthorized(new { message = "Contraseña incorrecta" });
                }

                var token = GenerateJwtToken(request.Usuario, nombre, rol);
                return Ok(new
                {
                    usuario = request.Usuario,
                    nombre,
                    rol,
                    token
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error en servidor", error = ex.Message });
            }
        }

        // 🔑 Genera el JWT
        private string GenerateJwtToken(string usuario, string nombre, string rol)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, usuario),
                new Claim("nombre", nombre),
                new Claim("rol", rol),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class LoginRequest
    {
        public string Usuario { get; set; }
        public string Clave { get; set; }
    }
}
