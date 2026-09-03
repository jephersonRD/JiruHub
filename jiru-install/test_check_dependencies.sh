#!/usr/bin/env bash
# Comprueba la deteccion de dependencias de install.sh sin instalar nada:
# stubea sudo y solo ejecuta check_dependencies. Uso: bash test_check_dependencies.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\nexit ${STUB_FAIL:-0}\n' > "$tmp/bin/sudo"
chmod +x "$tmp/bin/sudo"
# El script corre su menu interactivo al final; nos quedamos solo con las funciones.
sed '/^# ─── Entry Point/,$d' "$here/install.sh" > "$tmp/lib.sh"
export PATH="$tmp/bin:$PATH"

fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FALLA $1: esperaba '$3', obtuve '$2'"; fail=1; fi; }

# 1. 'grep -q' bajo 'set -o pipefail' rompe el chequeo: sale al primer match,
#    el productor recibe SIGPIPE y la tuberia devuelve 141 aunque haya coincidido.
q=$(bash -c "set -o pipefail; seq 1 200000 | grep -q '^7\$'" >/dev/null 2>&1; echo $?)
n=$(bash -c "set -o pipefail; seq 1 200000 | grep '^7\$' >/dev/null" >/dev/null 2>&1; echo $?)
check "grep -q falla bajo pipefail (por eso no se usa)" "$q" "141"
check "sin -q el chequeo devuelve 0"                    "$n" "0"
check "install.sh no usa grep -q en los chequeos" \
      "$(grep -c "grep -q" "$here/install.sh" || true)" "0"

# 2. spinner() no debe pisar la variable del bucle de quien la llama.
out=$(bash -c ". '$tmp/lib.sh'; i=SENTINELA; (sleep 0.2) & spinner \$! x >/dev/null 2>&1; echo \$i")
check "spinner conserva \$i del llamador" "$out" "SENTINELA"

# 3. Una dependencia opcional que no se puede instalar avisa, pero no cuenta como error.
out=$(STUB_FAIL=1 bash -c "
    . '$tmp/lib.sh'
    check_dependencies debian >/dev/null 2>&1 && echo 0 || echo \$?" || true)
check "las opcionales no abortan la instalacion" "$(test "$out" -le 1 && echo ok || echo no)" "ok"

exit $fail
