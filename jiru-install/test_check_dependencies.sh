#!/usr/bin/env bash
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"
sed '/^# ─── Entry Point/,$d' "$here/install.sh" > "$tmp/lib.sh"

fail=0
check() {
    if [ "$2" = "$3" ]; then
        echo "ok   $1"
    else
        echo "FALLA $1: esperaba '$3', obtuve '$2'"
        fail=1
    fi
}

check "install.sh no usa grep -q" \
      "$(grep -c 'grep -q' "$here/install.sh")" "0"

real_lib=$(ldconfig -p 2>/dev/null | sed -n 's/^\s*\(libc\.so\.6\).*/\1/p' | head -1)
out=$(bash -c ". '$tmp/lib.sh'; has_lib '${real_lib:-libc.so.6}' && echo si || echo no")
check "has_lib encuentra una libreria que existe" "$out" "si"
out=$(bash -c ". '$tmp/lib.sh'; has_lib libnoexiste.so.99 && echo si || echo no")
check "has_lib no inventa una que no existe" "$out" "no"

out=$(bash -c ". '$tmp/lib.sh'; i=SENTINELA; (sleep 0.2) & spinner \$! x >/dev/null 2>&1; echo \$i")
check "spinner conserva \$i del llamador" "$out" "SENTINELA"

printf '#!/bin/sh\nexit 0\n' > "$tmp/bin/pacman"
printf '#!/bin/sh\nexit 0\n' > "$tmp/bin/apt-get"
chmod +x "$tmp/bin/pacman" "$tmp/bin/apt-get"
out=$(PATH="$tmp/bin:$PATH" bash -c ". '$tmp/lib.sh'; detect_pkg_manager")
check "detect_pkg_manager respeta la precedencia" "$out" "pacman"
rm -f "$tmp/bin/pacman" "$tmp/bin/apt-get"
out=$(bash -c ". '$tmp/lib.sh'; PATH='$tmp/bin'; detect_pkg_manager")
check "sin ningun gestor devuelve unknown" "$out" "unknown"

printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\necho "$*" >> "$SUDOLOG"\nexit 0\n' > "$tmp/bin/sudo"
chmod +x "$tmp/bin/sudo"
export PATH="$tmp/bin:$PATH"

while IFS='|' read -r pm want; do
    [ -n "$pm" ] || continue
    export SUDOLOG="$tmp/sudo-$pm.log"; : > "$SUDOLOG"
    HOME="$tmp/home" bash -c ". '$tmp/lib.sh'; has_lib() { return 1; }; check_dependencies $pm" >/dev/null 2>&1
    got=$(grep -xF -- "$want" "$SUDOLOG" | head -1)
    check "$pm instala el conjunto requerido" "$got" "$want"
done <<'MATRIX'
pacman|pacman -S --noconfirm gtk3 mpv libx11
apt-get|apt-get install -y libgtk-3-0 libmpv2 libx11-6
dnf|dnf install -y gtk3 mpv-libs libX11
zypper|zypper install -y libgtk-3-0 libmpv2 libX11-6
apk|apk add --no-cache gtk+3.0 mpv-libs libx11
xbps-install|xbps-install -Sy gtk+3 libmpv libX11
emerge|emerge --verbose x11-libs/gtk+ media-video/mpv x11-libs/libX11
eopkg|eopkg install -y libgtk-3 mpv libx11
MATRIX

export SUDOLOG="$tmp/sudo-unknown.log"; : > "$SUDOLOG"
rc=0
HOME="$tmp/home" bash -c ". '$tmp/lib.sh'; check_dependencies pepito" >/dev/null 2>&1 || rc=$?
check "un gestor desconocido no aborta la instalacion" "$rc" "0"
check "un gestor desconocido no ejecuta nada como root" \
      "$(wc -c < "$SUDOLOG" | tr -d ' ')" "0"

printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\nexit 1\n' > "$tmp/bin/sudo"
chmod +x "$tmp/bin/sudo"

rc=0
HOME="$tmp/home" bash -c "
    . '$tmp/lib.sh'
    has_lib() { return 0; }
    command() { [ \"\${2:-}\" = mpv ] && return 1; builtin command \"\$@\"; }
    check_dependencies dnf" >/dev/null 2>&1 || rc=$?
check "si solo falla la opcional, devuelve 0" "$rc" "0"

rc=0
HOME="$tmp/home" bash -c ". '$tmp/lib.sh'; has_lib() { return 1; }; check_dependencies dnf" >/dev/null 2>&1 || rc=$?
check "si falta una requerida, devuelve 1" "$rc" "1"

export SUDOLOG="$tmp/sudo-manifiesto.log"; : > "$SUDOLOG"
printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\necho "$*" >> "$SUDOLOG"\nexit 0\n' > "$tmp/bin/sudo"
chmod +x "$tmp/bin/sudo"
rm -rf "$tmp/home"; mkdir -p "$tmp/home"
HOME="$tmp/home" bash -c "
    . '$tmp/lib.sh'
    has_lib() { return 1; }
    command() { [ \"\${2:-}\" = mpv ] && return 1; builtin command \"\$@\"; }
    check_dependencies dnf" >/dev/null 2>&1
check "anota en el manifiesto lo que instalo" \
      "$(cat "$tmp/home/.local/share/JiruHub/.deps-instaladas" 2>/dev/null)" \
      "sudo dnf remove -y gtk3 mpv-libs libX11 mpv"

rm -rf "$tmp/home"; mkdir -p "$tmp/home"
HOME="$tmp/home" bash -c ". '$tmp/lib.sh'; has_lib() { return 0; }; check_dependencies dnf" >/dev/null 2>&1
check "sin instalar nada, no deja manifiesto" \
      "$(test -e "$tmp/home/.local/share/JiruHub/.deps-instaladas" && echo si || echo no)" "no"

exit $fail
