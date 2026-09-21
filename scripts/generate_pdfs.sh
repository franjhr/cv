#!/usr/bin/env bash
# Regenerates cv_es.pdf and cv_en.pdf from index.html using headless Chrome.
# Run this after editing the CV content in index.html.
set -euo pipefail

CV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT=8799
CHROME="$(command -v google-chrome || command -v google-chrome-stable || command -v chromium || command -v chromium-browser)"

if [ -z "$CHROME" ]; then
  echo "No se ha encontrado Chrome/Chromium instalado." >&2
  exit 1
fi

cd "$CV_DIR"
python3 -m http.server "$PORT" >/tmp/cv_pdf_gen.log 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null || true' EXIT

# Wait for the server to be ready
for i in $(seq 1 20); do
  if curl -s -o /dev/null "http://127.0.0.1:$PORT/index.html"; then
    break
  fi
  sleep 0.2
done

echo "Generando cv_es.pdf..."
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$CV_DIR/cv_es.pdf" \
  "http://127.0.0.1:$PORT/index.html?lang=es"

echo "Generando cv_en.pdf..."
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$CV_DIR/cv_en.pdf" \
  "http://127.0.0.1:$PORT/index.html?lang=en"

echo "Listo: $CV_DIR/cv_es.pdf y $CV_DIR/cv_en.pdf"
