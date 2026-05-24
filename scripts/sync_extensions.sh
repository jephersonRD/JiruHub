#!/usr/bin/env bash
set -e

REPO_DIR="/home/jeph/Documents/miru-app/_jiruhub_fix"
EXT_DIR="$REPO_DIR/extensions"
SOURCE_BASE="https://miru-repo.0n0.dev"
RAW_BASE="https://raw.githubusercontent.com/jephersonRD/JiruHub/main"

echo "📥 Descargando index.json de miru-repo..."
curl -s "$SOURCE_BASE/index.json" -o /tmp/miru_index.json
TOTAL=$(python3 -c "import json; data=json.load(open('/tmp/miru_index.json')); print(len(data))")
echo "📦 Total de extensiones: $TOTAL"

echo ""
echo "📥 Descargando todos los archivos .js..."
mkdir -p "$EXT_DIR"

python3 - <<'PYEOF'
import json, urllib.request, os, time

SOURCE_BASE = "https://miru-repo.0n0.dev"
EXT_DIR = "/home/jeph/Documents/miru-app/_jiruhub_fix/extensions"

with open('/tmp/miru_index.json') as f:
    extensions = json.load(f)

ok = 0
fail = 0
for ext in extensions:
    js_filename = ext.get('url', '')
    if not js_filename or not js_filename.endswith('.js'):
        continue
    
    url = f"{SOURCE_BASE}/{js_filename}"
    dest = os.path.join(EXT_DIR, js_filename)
    
    try:
        urllib.request.urlretrieve(url, dest)
        # Rename ==MiruExtension== to ==JiruHubExtension== for branding
        with open(dest, 'r', errors='replace') as f:
            content = f.read()
        content = content.replace('==MiruExtension==', '==JiruHubExtension==')
        content = content.replace('==/MiruExtension==', '==/JiruHubExtension==')
        with open(dest, 'w') as f:
            f.write(content)
        ok += 1
        print(f"  ✅ {js_filename}")
    except Exception as e:
        fail += 1
        print(f"  ❌ {js_filename}: {e}")

print(f"\n✅ Descargados: {ok}  ❌ Fallidos: {fail}")
PYEOF

echo ""
echo "📝 Generando nuevo index.json apuntando a JiruHub..."

python3 - <<'PYEOF'
import json

RAW_BASE = "https://raw.githubusercontent.com/jephersonRD/JiruHub/main"

with open('/tmp/miru_index.json') as f:
    extensions = json.load(f)

new_index = []
for ext in extensions:
    js_filename = ext.get('url', '')
    if not js_filename.endswith('.js'):
        continue
    
    new_ext = dict(ext)
    # Point URL to JiruHub raw GitHub
    new_ext['url'] = f"{RAW_BASE}/extensions/{js_filename}"
    # Keep external icons as-is (no need to host them)
    new_index.append(new_ext)

with open('/home/jeph/Documents/miru-app/_jiruhub_fix/index.json', 'w', encoding='utf-8') as f:
    json.dump(new_index, f, ensure_ascii=False, indent=2)

print(f"✅ index.json generado con {len(new_index)} extensiones")
PYEOF

echo ""
echo "📤 Haciendo commit y push..."
cd "$REPO_DIR"
git add extensions/ index.json
git commit -m "feat: add all $(git diff --cached --name-only | grep extensions/ | wc -l) extensions from miru-repo.0n0.dev, rehosted in JiruHub"
git push origin main

echo ""
echo "🎉 ¡Listo! Todas las extensiones están en JiruHub."
echo "   URL del repo: https://jephersonrd.github.io/JiruHub"
