#!/usr/bin/env bash
# =============================================================================
#  JiruHub Installer — Linux/macOS
#  Uso: curl -fsSL https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.sh | bash
# =============================================================================

set -euo pipefail

# ─── Configuración ─────────────────────────────────────────────────────────
REPO_OWNER="jephersonRD"
REPO_NAME="JiruHub"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
INSTALL_DIR="${HOME}/.local/share/JiruHub"
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"
LOG_DIR="${HOME}/.local/share/JiruHub/logs"
LOG_FILE="${LOG_DIR}/installer-$(date +%Y%m%d-%H%M%S).log"
VERSION_FILE="${INSTALL_DIR}/version"
DEPS_FILE="${INSTALL_DIR}/.deps-instaladas"

# ─── Colores ANSI ──────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
    C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'; C_CYAN='\033[0;36m'; C_WHITE='\033[1;37m'
else
    C_RESET=''; C_BOLD=''; C_DIM=''; C_RED=''; C_GREEN=''; C_YELLOW=''
    C_BLUE=''; C_CYAN=''; C_WHITE=''
fi

# ─── Utilidades ────────────────────────────────────────────────────────────
log() { mkdir -p "$LOG_DIR"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }
print() { echo -e "$*"; }
info() { print "${C_BLUE}[i]${C_RESET}  $*"; log "INFO: $*"; }
success() { print "${C_GREEN}[OK]${C_RESET}  $*"; log "SUCCESS: $*"; }
warn() { print "${C_YELLOW}[!]${C_RESET}  $*"; log "WARN: $*"; }
error() { print "${C_RED}[X]${C_RESET}  $*"; log "ERROR: $*"; }
die() { error "$*"; exit 1; }

# ─── Banner ──────────────────────────────────────────────────────────────────
show_banner() {
    clear 2>/dev/null || true
    print ""
    print "${C_CYAN}${C_BOLD}     ██╗██╗██████╗ ██╗   ██╗██╗  ██╗██╗   ██╗██████╗ ${C_RESET}"
    print "${C_CYAN}${C_BOLD}     ██║██║██╔══██╗██║   ██║██║  ██║██║   ██║██╔══██╗${C_RESET}"
    print "${C_CYAN}${C_BOLD}     ██║██║██████╔╝██║   ██║███████║██║   ██║██████╔╝${C_RESET}"
    print "${C_CYAN}${C_BOLD}██   ██║██║██╔══██╗██║   ██║██╔══██║██║   ██║██╔══██╗${C_RESET}"
    print "${C_CYAN}${C_BOLD}╚█████╔╝██║██║  ██║╚██████╔╝██║  ██║╚██████╔╝██████╔╝${C_RESET}"
    print "${C_CYAN}${C_BOLD} ╚════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ${C_RESET}"
    print "${C_DIM}        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    print ""
}

# ─── Spinner ─────────────────────────────────────────────────────────────────
spinner() {
    local pid=$1 msg="$2" delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i
    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 9); do
            printf "\r${C_CYAN}%s${C_RESET}  %s" "${spin:$i:1}" "$msg"
            sleep $delay
        done
    done
    printf "\r%-60s\r" ""
}

# ─── Barra de Progreso ───────────────────────────────────────────────────────
progress_bar() {
    local percent=$1 width=40
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "\r${C_CYAN}[%s]${C_RESET} ${C_BOLD}%3d%%${C_RESET}" "$bar" "$percent"
    [[ $percent -eq 100 ]] && echo ""
}

# ─── Traducciones ────────────────────────────────────────────────────────────
declare -A I18N_ES=(
    [welcome]="Bienvenido al Instalador de JiruHub"
    [menu_lang]="Selecciona tu idioma"
    [opt_spanish]="Español"
    [opt_english]="English"
    [opt_exit]="Salir"
    [menu_main]="Menú Principal"
    [opt_install]="Instalar"
    [opt_update]="Actualizar"
    [opt_uninstall]="Desinstalar"
    [detecting_os]="Detectando sistema operativo..."
    [detecting_arch]="Detectando arquitectura..."
    [fetching_release]="Buscando última versión en GitHub..."
    [downloading]="Descargando JiruHub..."
    [installing]="Instalando JiruHub..."
    [success_install]="JiruHub se instaló correctamente."
    [success_update]="JiruHub se actualizó correctamente."
    [success_uninstall]="JiruHub se desinstaló correctamente."
    [installed_version]="Versión instalada"
    [install_path]="Ruta de instalación"
    [latest_version]="Última versión disponible"
    [already_latest]="Ya tienes la última versión."
    [no_internet]="No se detectó conexión a internet."
    [choose_option]="Elige una opción"
    [invalid_option]="Opción inválida."
    [press_enter]="Presiona Enter para salir..."
    [cancelled]="Operación cancelada."
    [log_path]="Log guardado en"
    [running]="ejecuta: jiruhub"
    [dep_title]="Dependencias del Sistema"
    [dep_installed]="ya instalado"
    [dep_required]="Se requiere:"
    [dep_installing]="Instalando"
    [dep_ok]="instalado correctamente"
    [dep_fail]="Error instalando"
    [dep_distro_unknown]="No se pudo detectar tu distribución automáticamente."
    [dep_manual_list]="Asegúrate de tener instalado:"
    [dep_sudo]="Verificando acceso sudo..."
    [dep_sudo_fail]="Se requiere sudo para instalar dependencias."
    [dep_refreshing]="Actualizando indices de paquetes..."
    [dep_optional]="opcional"
    [dep_plan]="Se ejecutaran estos comandos como root:"
    [dep_confirm]="Continuar?"
    [dep_noninteractive]="Sin terminal interactiva: se continua sin pedir confirmacion."
    [uninst_deps]="El instalador habia puesto estas dependencias:"
    [uninst_deps_ask]="Eliminarlas tambien?"
    [uninst_deps_kept]="Se conservan las dependencias."
    [uninst_deps_fail]="No se pudieron eliminar; hacelo a mano si hace falta."
    [dep_declined]="Instalacion cancelada. JiruHub necesita estas librerias para arrancar:"
    [dep_optional_why]="solo para el reproductor externo"
    [dep_declined_hint]="Instalalas cuando quieras y volve a ejecutar el instalador:"
    [dep_retry]="Reintentando con los nombres de paquete antiguos..."
    [dep_optional_fail]="no se pudo instalar; se continua sin el reproductor externo."
    [dep_nixos]="NixOS detectado. Instala las dependencias de forma declarativa:"
    [dep_pm_unknown]="No se reconocio el gestor de paquetes. Instala a mano:"
    [dep_refresh_fail]="No se pudieron actualizar los indices; se intenta instalar igual."
    [dep_skip]="Continuar de todas formas"
    [dep_continue]="Continuar"
)

declare -A I18N_EN=(
    [welcome]="Welcome to JiruHub Installer"
    [menu_lang]="Select your language"
    [opt_spanish]="Spanish"
    [opt_english]="English"
    [opt_exit]="Exit"
    [menu_main]="Main Menu"
    [opt_install]="Install"
    [opt_update]="Update"
    [opt_uninstall]="Uninstall"
    [detecting_os]="Detecting operating system..."
    [detecting_arch]="Detecting architecture..."
    [fetching_release]="Fetching latest release from GitHub..."
    [downloading]="Downloading JiruHub..."
    [installing]="Installing JiruHub..."
    [success_install]="JiruHub installed successfully."
    [success_update]="JiruHub updated successfully."
    [success_uninstall]="JiruHub uninstalled successfully."
    [installed_version]="Installed version"
    [install_path]="Installation path"
    [latest_version]="Latest version available"
    [already_latest]="You already have the latest version."
    [no_internet]="No internet connection detected."
    [choose_option]="Choose an option"
    [invalid_option]="Invalid option."
    [press_enter]="Press Enter to exit..."
    [cancelled]="Operation cancelled."
    [log_path]="Log saved at"
    [running]="run: jiruhub"
    [dep_title]="System Dependencies"
    [dep_installed]="already installed"
    [dep_required]="Required:"
    [dep_installing]="Installing"
    [dep_ok]="installed successfully"
    [dep_fail]="Error installing"
    [dep_distro_unknown]="Could not detect your distribution automatically."
    [dep_manual_list]="Make sure you have installed:"
    [dep_sudo]="Verifying sudo access..."
    [dep_sudo_fail]="sudo is required to install dependencies."
    [dep_refreshing]="Refreshing package indexes..."
    [dep_optional]="optional"
    [dep_plan]="These commands will run as root:"
    [dep_confirm]="Continue?"
    [dep_noninteractive]="No interactive terminal: continuing without asking."
    [uninst_deps]="The installer had added these dependencies:"
    [uninst_deps_ask]="Remove them too?"
    [uninst_deps_kept]="Keeping the dependencies."
    [uninst_deps_fail]="Could not remove them; do it manually if needed."
    [dep_declined]="Installation cancelled. JiruHub needs these libraries to start:"
    [dep_optional_why]="only for the external player"
    [dep_declined_hint]="Install them whenever you want and run the installer again:"
    [dep_retry]="Retrying with the older package names..."
    [dep_optional_fail]="could not be installed; continuing without the external player."
    [dep_nixos]="NixOS detected. Install the dependencies declaratively:"
    [dep_pm_unknown]="Could not recognise the package manager. Install manually:"
    [dep_refresh_fail]="Could not refresh indexes; trying to install anyway."
    [dep_skip]="Continue anyway"
    [dep_continue]="Continue"
)

LANG_CODE="es"
t() { local key="$1"; [[ "$LANG_CODE" == "en" ]] && printf "%s" "${I18N_EN[$key]:-$key}" || printf "%s" "${I18N_ES[$key]:-$key}"; }

select_language() {
    print ""
    print "  ${C_BOLD}${C_WHITE}[1]${C_RESET} Español"
    print "  ${C_BOLD}${C_WHITE}[2]${C_RESET} English"
    print "  ${C_BOLD}${C_WHITE}[3]${C_RESET} ${C_RED}$(t opt_exit)${C_RESET}"
    print ""
    read -rp "  $(t choose_option): " choice </dev/tty || true
    case "$choice" in 1) LANG_CODE="es" ;; 2) LANG_CODE="en" ;; 3) exit 0 ;; esac
}

# ─── Menú Principal ─────────────────────────────────────────────────────────
main_menu() {
    while true; do
        show_banner
        print "  ${C_BOLD}${C_CYAN}◆ $(t menu_main) ◆${C_RESET}\n"
        print "  ${C_BOLD}${C_WHITE}[1]${C_RESET} $(t opt_install)"
        print "  ${C_BOLD}${C_WHITE}[2]${C_RESET} $(t opt_update)"
        print "  ${C_BOLD}${C_WHITE}[3]${C_RESET} $(t opt_uninstall)"
        print "  ${C_BOLD}${C_WHITE}[4]${C_RESET} ${C_RED}$(t opt_exit)${C_RESET}"
        print ""
        read -rp "  $(t choose_option): " choice </dev/tty || true
        case "$choice" in
            1) do_install; break ;;
            2) do_update; break ;;
            3) do_uninstall; break ;;
            4) exit 0 ;;
            *) warn "$(t invalid_option)" ;;
        esac
    done
}

# ─── Detección ─────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       die "Sistema operativo no soportado: $(uname -s)" ;;
    esac
}

detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)   echo "x64" ;;
        aarch64|arm64)  echo "arm64" ;;
        armv7l|armv6l)  echo "arm" ;;
        i386|i486|i586|i686)
            error "Arquitectura de 32 bits ($arch) no está soportada por JiruHub."
            error "JiruHub requiere un sistema de 64 bits (x86_64 o aarch64)."
            die   "Por favor usa un sistema operativo de 64 bits."
            ;;
        *) die "Arquitectura no soportada: $arch" ;;
    esac
}

# ─── Detección de Distribución ───────────────────────────────────────────────
detect_pkg_manager() {
    local m
    for m in pacman xbps-install apk eopkg emerge zypper dnf yum apt-get nix-env; do
        if command -v "$m" >/dev/null 2>&1; then
            echo "$m"
            return 0
        fi
    done
    echo "unknown"
}

has_lib() {
    local so="$1" d
    if ldconfig -p 2>/dev/null | grep "$so" >/dev/null; then
        return 0
    fi
    for d in /usr/lib64 /usr/lib /lib64 /lib /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu; do
        [[ -e "$d/$so" ]] && return 0
    done
    return 1
}

# ─── Gestión de Dependencias ──────────────────────────────────────────────
check_dependencies() {
    local pm="$1"

    print "\n${C_DIM}┌─ $(t dep_title) ──────────────────────────────────────────────────┐${C_RESET}"

    local req="" opt="" cmd="" refresh="" fallback="" uncmd=""
    case "$pm" in
        pacman)       req="gtk3 mpv libx11";                         opt="mpv"; cmd="sudo pacman -S --noconfirm";  refresh="sudo pacman -Sy --noconfirm"; uncmd="sudo pacman -Rs --noconfirm" ;;
        apt-get)      req="libgtk-3-0 libmpv2 libx11-6";             opt="mpv"; cmd="sudo apt-get install -y";     refresh="sudo apt-get update"; fallback="libgtk-3-0 libmpv1 libx11-6"; uncmd="sudo apt-get remove -y" ;;
        dnf|yum)      req="gtk3 mpv-libs libX11";                    opt="mpv"; cmd="sudo $pm install -y"; uncmd="sudo $pm remove -y" ;;
        zypper)       req="libgtk-3-0 libmpv2 libX11-6";             opt="mpv"; cmd="sudo zypper install -y";      refresh="sudo zypper --non-interactive refresh"; uncmd="sudo zypper --non-interactive remove" ;;
        apk)          req="gtk+3.0 mpv-libs libx11";                 opt="mpv"; cmd="sudo apk add --no-cache";     refresh="sudo apk update"; uncmd="sudo apk del" ;;
        xbps-install) req="gtk+3 libmpv libX11";                     opt="mpv"; cmd="sudo xbps-install -Sy"; uncmd="sudo xbps-remove -Ry" ;;
        emerge)       req="x11-libs/gtk+ media-video/mpv x11-libs/libX11"; opt=""; cmd="sudo emerge --verbose"; uncmd="sudo emerge --unmerge" ;;
        eopkg)        req="libgtk-3 mpv libx11";                     opt="mpv"; cmd="sudo eopkg install -y";       refresh="sudo eopkg update-repo"; uncmd="sudo eopkg remove -y" ;;
        nix-env)
            print ""
            warn "$(t dep_nixos)"
            info "  environment.systemPackages = [ pkgs.gtk3 pkgs.mpv pkgs.xorg.libX11 ];"
            print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
            return 0
            ;;
        *)
            print ""
            warn "$(t dep_pm_unknown)"
            info "  libgtk-3, libmpv (libmpv.so.2), libX11${opt:+, mpv}"
            print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
            return 0
            ;;
    esac

    local libs_ok=0
    has_lib libgtk-3.so.0 && has_lib libmpv.so.2 && has_lib libX11.so.6 && libs_ok=1

    local mpv_ok=0
    command -v mpv >/dev/null 2>&1 && mpv_ok=1

    if [[ $libs_ok -eq 1 && $mpv_ok -eq 1 ]]; then
        print ""
        success "libgtk-3, libmpv, libX11, mpv  $(t dep_installed)"
        print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
        return 0
    fi

    print ""
    [[ $libs_ok -eq 0 ]] && warn "$(t dep_required) libgtk-3, libmpv, libX11"
    [[ $mpv_ok -eq 0 ]]  && warn "$(t dep_required) mpv ($(t dep_optional))"

    print ""
    info "$(t dep_plan)"
    [[ -n "$refresh" ]] && print "  ${C_DIM}\$ ${refresh}${C_RESET}"
    [[ $libs_ok -eq 0 ]] && print "  ${C_DIM}\$ ${cmd} ${req}${C_RESET}"
    [[ $mpv_ok -eq 0 && -n "$opt" ]] && print "  ${C_DIM}\$ ${cmd} ${opt}${C_RESET}"

    print ""
    local reply=""
    if { : </dev/tty; } 2>/dev/null; then
        read -rp "  $(t dep_confirm) [S/n]: " reply </dev/tty || reply=""
    else
        print ""
        warn "$(t dep_noninteractive)"
    fi
    if [[ "$reply" =~ ^[NnKk] ]]; then
        print ""
        warn "$(t dep_declined)"
        info "  libgtk-3   ->  libgtk-3.so.0"
        info "  libmpv     ->  libmpv.so.2"
        info "  libX11     ->  libX11.so.6"
        [[ -n "$opt" ]] && info "  mpv        ->  $(t dep_optional), $(t dep_optional_why)"
        print ""
        info "$(t dep_declined_hint)"
        print "  ${C_DIM}\$ ${cmd} ${req}${C_RESET}"
        print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
        return 1
    fi

    info "$(t dep_sudo)"
    if ! sudo -v 2>/dev/null; then
        error "$(t dep_sudo_fail)"
        print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
        return 1
    fi

    if [[ -n "$refresh" ]]; then
        print ""
        info "$(t dep_refreshing)"
        log "refresh: $refresh"
        eval "$refresh" || warn "$(t dep_refresh_fail)"
    fi

    if [[ $libs_ok -eq 0 ]]; then
        print ""
        info "$(t dep_installing) libgtk-3, libmpv, libX11"
        log "install: $cmd $req"
        if ! eval "$cmd $req" && [[ -n "$fallback" ]]; then
            print ""
            warn "$(t dep_retry)"
            log "install fallback: $cmd $fallback"
            eval "$cmd $fallback" || true
        fi
    fi

    if [[ $mpv_ok -eq 0 && -n "$opt" ]]; then
        print ""
        info "$(t dep_installing) mpv ($(t dep_optional))"
        log "install optional: $cmd $opt"
        eval "$cmd $opt" || warn "$(t dep_optional_fail)"
    fi

    local puestos=""
    [[ $libs_ok -eq 0 ]] && puestos=" $req"
    [[ $mpv_ok -eq 0 && -n "$opt" ]] && puestos="$puestos $opt"
    if [[ -n "$puestos" && -n "$uncmd" ]]; then
        mkdir -p "$INSTALL_DIR"
        echo "$uncmd$puestos" > "$DEPS_FILE"
    fi

    print ""
    local missing=""
    has_lib libgtk-3.so.0 || missing="$missing libgtk-3"
    has_lib libmpv.so.2   || missing="$missing libmpv"
    has_lib libX11.so.6   || missing="$missing libX11"

    if [[ -n "$missing" ]]; then
        error "$(t dep_fail):$missing"
        print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
        return 1
    fi

    success "libgtk-3, libmpv, libX11  $(t dep_ok)"
    command -v mpv >/dev/null 2>&1 || warn "mpv ($(t dep_optional)) $(t dep_optional_fail)"
    print "\n${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}"
    return 0
}

check_internet() {
    if ! curl -fsSL --max-time 5 https://api.github.com > /dev/null 2>&1; then
        die "$(t no_internet)"
    fi
}

get_latest_release() {
    local tmpfile
    tmpfile=$(mktemp)
    curl -fsSL -H "Accept: application/vnd.github.v3+json" "$API_URL" > "$tmpfile" 2>/dev/null || {
        rm -f "$tmpfile"
        die "Error al conectar con GitHub API."
    }
    cat "$tmpfile"
    rm -f "$tmpfile"
}

detect_asset() {
    local os="$1" arch="$2" release_json="$3"
    local patterns=()

    case "$os" in
        linux)
            case "$arch" in
                x64)   patterns=("JiruHub-*-linux-x64.tar.gz" "JiruHub-*-linux.tar.gz") ;;
                arm64) patterns=("JiruHub-*-linux-arm64.tar.gz") ;;
                arm)   patterns=("JiruHub-*-linux-arm.tar.gz") ;;
            esac
            ;;
        macos)
            case "$arch" in
                x64)   patterns=("JiruHub-*-mac-x64.tar.gz" "JiruHub-*-macos-x64.tar.gz" "JiruHub-*-mac.tar.gz") ;;
                arm64) patterns=("JiruHub-*-mac-arm64.tar.gz" "JiruHub-*-macos-arm64.tar.gz") ;;
            esac
            ;;
    esac

    for pattern in "${patterns[@]}"; do
        local url
        url=$(echo "$release_json" | grep -o '"browser_download_url": "[^"]*JiruHub-[^"]*\.tar\.gz"' | sed 's/"browser_download_url": "//;s/"$//' | grep -m1 "${pattern/\*/.*}")
        if [[ -n "$url" ]]; then
            echo "$url"
            return 0
        fi
    done
    return 1
}

download_file() {
    local url="$1" output="$2"
    info "$(t downloading)"
    log "Downloading: $url -> $output"

    local total_size
    total_size=$(curl -fsSL -I "$url" 2>/dev/null | grep -i content-length | awk '{print $2}' | tr -d '\r')
    [[ -z "$total_size" || "$total_size" == "0" ]] && total_size=1

    mkdir -p "$(dirname "$output")"

    if command -v wget >/dev/null 2>&1; then
        wget -q --show-progress "$url" -O "$output" 2>&1 | while IFS= read -r line; do
            if [[ "$line" =~ ([0-9]+)% ]]; then
                progress_bar "${BASH_REMATCH[1]}"
            fi
        done
    else
        (
            curl -fsSL "$url" -o "$output" >/dev/null 2>&1
        ) &
        local pid=$!
        local sim=0
        while kill -0 $pid 2>/dev/null; do
            if [[ $sim -lt 95 ]]; then
                sim=$((sim + RANDOM % 5 + 1))
                [[ $sim -gt 95 ]] && sim=95
            fi
            progress_bar "$sim"
            sleep 0.3
        done
        wait $pid
        progress_bar 100
    fi

    [[ -f "$output" ]] || die "Descarga fallida."
    success "$(basename "$output") descargado."
}

download_with_retry() {
    local url="$1" output="$2" retries=3 delay=2
    for ((i=1; i<=retries; i++)); do
        if download_file "$url" "$output"; then return 0; fi
        warn "Intento $i falló. Reintentando en ${delay}s..."
        sleep $delay
        delay=$((delay * 2))
    done
    die "Descarga falló después de $retries intentos."
}

create_desktop_entry() {
    local binary_path="$1" icon_path="$2"
    mkdir -p "$APP_DIR"
    cat > "${APP_DIR}/jiruhub.desktop" <<EOF
[Desktop Entry]
Name=JiruHub
Comment=Anime, manga and multimedia player
Exec=${binary_path}
Icon=${icon_path}
Terminal=false
Type=Application
Categories=AudioVideo;Player;Network;
StartupWMClass=jiruhub
EOF
    chmod +x "${APP_DIR}/jiruhub.desktop"
}

# ─── Instalar ────────────────────────────────────────────────────────────────
do_install() {
    show_banner
    check_internet

    local os arch pkg_manager release_json asset_url tag_name tmpdir

    print "\n${C_DIM}┌─ $(t detecting_os) ────────────────────────────────────┐${C_RESET}"
    os=$(detect_os)
    info "OS: $os"
    sleep 0.3

    arch=$(detect_arch)
    info "Arch: $arch"
    sleep 0.3

    if [[ "$os" == "linux" ]]; then
        pkg_manager=$(detect_pkg_manager)
        info "Gestor de paquetes: $pkg_manager"
        check_dependencies "$pkg_manager" || exit 1
    fi

    print "\n${C_DIM}┌─ $(t fetching_release) ──────────────────────────────┐${C_RESET}"
    local _tmp
    _tmp=$(mktemp)
    get_latest_release > "$_tmp" &
    spinner $! "$(t fetching_release)"
    wait $!
    release_json=$(cat "$_tmp")
    rm -f "$_tmp"

    tag_name=$(echo "$release_json" | grep '"tag_name":' | head -n1 | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
    info "$(t latest_version): ${C_BOLD}${C_GREEN}$tag_name${C_RESET}"

    asset_url=$(detect_asset "$os" "$arch" "$release_json") || \
        die "No se encontró asset para $os ($arch). Revisa GitHub Releases."

    info "Asset: $(basename "$asset_url")"

    tmpdir=$(mktemp -d)
    local filepath="${tmpdir}/$(basename "$asset_url")"

    download_with_retry "$asset_url" "$filepath"

    print "\n${C_DIM}┌─ $(t installing) ───────────────────────────────────┐${C_RESET}"
    mkdir -p "$INSTALL_DIR" "$BIN_DIR"

    tar -xzf "$filepath" -C "$tmpdir"

    local bundle_src=""
    for candidate in "$tmpdir"/*/; do
        if [[ -f "${candidate}jiruhub" ]] || [[ -f "${candidate}JiruHub" ]] || [[ -f "${candidate}miru" ]]; then
            bundle_src="$candidate"
            break
        fi
    done
    if [[ -z "$bundle_src" ]]; then
        # Fallback: el contenido está extraído directamente
        bundle_src="$tmpdir/"
    fi

    cp -r "${bundle_src}"* "$INSTALL_DIR/"
    rm -rf "$tmpdir"

    local binary=""
    for name in jiruhub JiruHub miru; do
        [[ -f "${INSTALL_DIR}/${name}" ]] && binary="${INSTALL_DIR}/${name}" && chmod +x "$binary" && break
    done

    if [[ -z "$binary" ]]; then
        die "No se encontró el binario después de extraer."
    fi

    ln -sf "$binary" "${BIN_DIR}/jiruhub"
    info "Symlink: ${BIN_DIR}/jiruhub → $binary"

    create_desktop_entry "$binary" "${INSTALL_DIR}/icon.png"
    info "Acceso directo creado."

    echo "$tag_name" > "$VERSION_FILE"

    print "\n${C_GREEN}${C_BOLD}  ╔══════════════════════════════════════════════════╗${C_RESET}"
    print "${C_GREEN}${C_BOLD}  ║                                                  ║${C_RESET}"
    print "${C_GREEN}${C_BOLD}  ║     $(t success_install)              ║${C_RESET}"
    print "${C_GREEN}${C_BOLD}  ║                                                  ║${C_RESET}"
    print "${C_GREEN}${C_BOLD}  ╚══════════════════════════════════════════════════╝${C_RESET}"
    print ""
    print "  ${C_BOLD}$(t installed_version):${C_RESET}  ${C_CYAN}$tag_name${C_RESET}"
    print "  ${C_BOLD}$(t install_path):${C_RESET}       ${C_CYAN}$INSTALL_DIR${C_RESET}"
    print "  ${C_BOLD}$(t running):${C_RESET}             ${C_CYAN}jiruhub${C_RESET}"
    print "  ${C_BOLD}$(t log_path):${C_RESET}         ${C_CYAN}$LOG_FILE${C_RESET}"
    print ""
    read -rp "  $(t press_enter) " </dev/tty || true
}

# ─── Actualizar ──────────────────────────────────────────────────────────────
do_update() {
    if [[ ! -f "$VERSION_FILE" ]]; then
        warn "JiruHub no está instalado. Ejecuta 'Instalar' primero."
        sleep 2
        return
    fi
    local current
    current=$(cat "$VERSION_FILE")
    show_banner
    check_internet
    info "Versión actual: $current"
    local release_json latest
    release_json=$(get_latest_release)
    latest=$(echo "$release_json" | grep '"tag_name":' | head -n1 | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
    if [[ "$current" == "$latest" ]]; then
        success "$(t already_latest) ($current)"
        read -rp "  $(t press_enter) " </dev/tty || true
        return
    fi
    info "Nueva versión: $latest"
    do_install
    success "$(t success_update)"
}

# ─── Desinstalar ─────────────────────────────────────────────────────────────
do_uninstall() {
    show_banner
    print "\n${C_YELLOW}${C_BOLD}  [!]  Se eliminarán todos los archivos de JiruHub.${C_RESET}"
    read -rp "  ¿Continuar? [s/N]: " confirm </dev/tty || true
    [[ "$confirm" =~ ^[Ss]$ ]] || { info "$(t cancelled)"; return; }
    if [[ -s "$DEPS_FILE" ]]; then
        local uncmd_saved
        uncmd_saved=$(cat "$DEPS_FILE")
        print ""
        info "$(t uninst_deps)"
        print "  ${C_DIM}\$ ${uncmd_saved}${C_RESET}"
        print ""
        local rmdeps=""
        if { : </dev/tty; } 2>/dev/null; then
            read -rp "  $(t uninst_deps_ask) [s/N]: " rmdeps </dev/tty || rmdeps=""
        fi
        if [[ "$rmdeps" =~ ^[Ss] ]]; then
            eval "$uncmd_saved" || warn "$(t uninst_deps_fail)"
        else
            info "$(t uninst_deps_kept)"
        fi
    fi
    rm -rf "$INSTALL_DIR"
    rm -f "${BIN_DIR}/jiruhub"
    rm -f "${APP_DIR}/jiruhub.desktop"
    rm -rf "${LOG_DIR}"
    success "$(t success_uninstall)"
    read -rp "  $(t press_enter) " </dev/tty || true
}

# ─── Entry Point ─────────────────────────────────────────────────────────────
trap 'error "Instalación interrumpida."; exit 130' INT TERM
mkdir -p "$LOG_DIR"
log "=== JiruHub Installer started ==="
show_banner
select_language
main_menu
log "=== JiruHub Installer finished ==="
