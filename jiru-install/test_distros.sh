#!/usr/bin/env bash
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
engine=$(command -v podman || command -v docker) || { echo "hace falta podman o docker"; exit 1; }

MATRIX=(
  "docker.io/library/fedora:latest|dnf"
  "docker.io/library/debian:stable-slim|apt-get"
  "docker.io/library/ubuntu:24.04|apt-get"
  "docker.io/library/archlinux:latest|pacman"
  "docker.io/library/alpine:latest|apk"
  "docker.io/opensuse/tumbleweed:latest|zypper"
  "ghcr.io/void-linux/void-glibc:latest|xbps-install"
  "docker.io/gentoo/stage3:latest|emerge|resolve"
)
[[ $# -gt 0 ]] && MATRIX=("$@")

if [[ -n "${REF:-}" ]]; then
    echo "### usando install.sh de $REF"
    git -C "$here" show "$REF:jiru-install/install.sh" > "$here/.src.tmp.sh"
else
    cp "$here/install.sh" "$here/.src.tmp.sh"
fi
sed '/^# ─── Entry Point/,$d' "$here/.src.tmp.sh" > "$here/.lib.tmp.sh"

cat > "$here/.run.tmp.sh" <<'INNER'
#!/bin/sh
: > /sudolog
if [ -n "${RESOLVE:-}" ]; then
    printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\necho "$*" >> /sudolog\nexit 0\n' > /usr/local/bin/sudo
else
    printf '#!/bin/sh\n[ "$1" = "-v" ] && exit 0\necho "$*" >> /sudolog\nexec "$@"\n' > /usr/local/bin/sudo
fi
chmod +x /usr/local/bin/sudo
if ! command -v bash >/dev/null 2>&1; then
    { apk add --no-cache bash || dnf install -y bash || zypper -n install bash \
      || pacman -Sy --noconfirm bash || xbps-install -Sy bash || eopkg install -y bash \
      || { apt-get update && apt-get install -y bash; }; } >/dev/null 2>&1
fi
[ -n "${RESOLVE:-}" ] && [ ! -d /var/db/repos/gentoo/metadata ] && emerge-webrsync >/dev/null 2>&1
exec bash -c '
    set -uo pipefail
    LANG_CODE=en
    . /lib.sh
    if declare -F detect_pkg_manager >/dev/null; then arg=$(detect_pkg_manager); else arg=$(detect_distro); fi
    echo "PM=$arg"
    declare -F has_lib >/dev/null || has_lib() { ldconfig -p 2>/dev/null | grep "$1" >/dev/null; }
    has_lib libmpv.so.2 && echo "ANTES=si" || echo "ANTES=no"
    check_dependencies "$arg" > /salida 2>&1 || true
    echo "RC=$?"
    if [ -n "${RESOLVE:-}" ]; then
        atoms=$(grep -- "--verbose" /sudolog | head -1 | sed "s/^emerge --verbose //")
        echo "ATOMS=$atoms"
        faltan=""
        for a in $atoms; do
            [ -d "/var/db/repos/gentoo/${a%%:*}" ] || faltan="$faltan $a"
        done
        [ -z "$faltan" ] && echo "RESUELVE=si" || echo "RESUELVE=no$faltan"
    fi
    has_lib libmpv.so.2 && echo "DESPUES=si" || echo "DESPUES=no"
    command -v mpv >/dev/null 2>&1 && echo "MPVBIN=si" || echo "MPVBIN=no"
    tail -25 /salida
'
INNER

fail=0
for row in "${MATRIX[@]}"; do
    IFS='|' read -r image want_pm mode <<< "$row"
    echo "=============== $image   (espera gestor: $want_pm)"
    out=$("$engine" run --rm -e RESOLVE="${mode:-}" \
            -v "$here/.lib.tmp.sh:/lib.sh:ro,Z" \
            -v "$here/.run.tmp.sh:/run.sh:ro,Z" \
            "$image" sh /run.sh 2>&1)
    val() { printf '%s' "$out" | sed -n "s/^$1=//p" | tail -1; }
    pm=$(val PM); before=$(val ANTES); after=$(val DESPUES); mpvbin=$(val MPVBIN)

    if [[ "$pm" == "$want_pm" ]]; then echo "  gestor   : $pm  ok"
    else echo "  gestor   : ${pm:-?}  FALLA (esperaba $want_pm)"; fail=1; fi

    if [[ -n "${mode:-}" ]]; then
        resuelve=$(val RESUELVE)
        echo "  atomos   : $(val ATOMS)"
        if [[ "$resuelve" == si ]]; then echo "             ok, los atomos existen en el arbol de portage"
        else echo "             FALLA"; fail=1; fi
    else
        echo "  libmpv   : antes=${before:-?}  despues=${after:-?}"
        if [[ "$after" == si ]]; then echo "             ok, el paquete existe y aporta libmpv.so.2"
        else echo "             FALLA"; fail=1; fi
    fi
    echo "  mpv(opc) : ${mpvbin:-?}"

    if [[ -z "${mode:-}" && "$after" != si ]]; then printf '%s\n' "$out" | tail -20 | sed 's/^/      | /'; fi
done

rm -f "$here/.lib.tmp.sh" "$here/.run.tmp.sh" "$here/.src.tmp.sh"
echo
if [[ $fail -eq 0 ]]; then echo "TODO VERDE"; else echo "HAY FALLOS"; fi
exit $fail
