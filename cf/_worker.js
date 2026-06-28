// Porteiro do site (Cloudflare Pages, modo avançado).
// Pede usuário+senha (HTTP Basic Auth) antes de servir qualquer coisa.
// Configurar no projeto do Pages (Settings → Environment variables, Production):
//   SITE_PASSWORD  → a senha (marque como "Encrypt"/secret)
//   SITE_USER      → opcional; se vazio, usa "notes"
//
// Sem isto definido, o site fica fechado (fail-closed), nunca aberto por engano.

export default {
  async fetch(request, env) {
    const USER = env.SITE_USER || "notes";
    const PASS = env.SITE_PASSWORD;

    // Sem senha configurada → não serve nada (evita expor por esquecimento).
    if (!PASS) {
      return new Response(
        "Site fechado: defina a variável SITE_PASSWORD no projeto do Cloudflare Pages.",
        { status: 503 },
      );
    }

    const expected = "Basic " + btoa(`${USER}:${PASS}`);
    const got = request.headers.get("Authorization") || "";

    if (got !== expected) {
      return new Response("Acesso restrito 🔒", {
        status: 401,
        headers: {
          "WWW-Authenticate": 'Basic realm="segundo cerebro", charset="UTF-8"',
        },
      });
    }

    // Autenticado → serve os arquivos estáticos gerados pelo Quartz.
    return env.ASSETS.fetch(request);
  },
};
