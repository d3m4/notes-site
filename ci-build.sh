#!/usr/bin/env bash
#
# Build do site no Cloudflare Pages.
#
# O projeto do Cloudflare observa o repo PRIVADO `notes` (o conteúdo).
# Este script vive no repo PÚBLICO `notes-site` (Quartz + tema) e é clonado
# durante o build. Ele lê as notas e gera o site estático.
#
# Uso (definido no "Build command" do Cloudflare):
#   git clone --depth 1 https://github.com/d3m4/notes-site "$HOME/notes-site" \
#     && CONTENT_DIR="$PWD" bash "$HOME/notes-site/ci-build.sh"
#
# Output directory (no Cloudflare): public
#
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="${CONTENT_DIR:?defina CONTENT_DIR apontando para o checkout do repo notes}"

echo "▸ conteúdo (notas): $CONTENT_DIR"
echo "▸ site (quartz):    $SITE_DIR"

# O Cloudflare faz checkout raso (shallow); o Quartz usa o git log p/ datas
# ("notas recentes"). Tenta buscar o histórico completo; se falhar, cai pra mtime.
git -C "$CONTENT_DIR" fetch --unshallow 2>/dev/null || true

cd "$SITE_DIR"
npm ci
npx quartz plugin install --from-config

# Injeta o nosso componente de "notas recentes" com excerpt (título + 1ªs linhas).
# É um override do dist já buildado; a versão do plugin está fixada em
# quartz.lock.json (commit 3c3d104), então o arquivo casa com o resto.
cp overrides/recent-notes-components-index.js .quartz/plugins/recent-notes/dist/components/index.js
cp overrides/recent-notes-index.js            .quartz/plugins/recent-notes/dist/index.js

npx quartz build -d "$CONTENT_DIR" -o "$CONTENT_DIR/public"
echo "✓ site gerado em $CONTENT_DIR/public"
