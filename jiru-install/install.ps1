<#
 ==============================================================================
  JiruHub Installer — Windows (PowerShell 5.1+)
  Uso: irm https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.ps1 | iex
  O:  Invoke-RestMethod https://... | Invoke-Expression
 ==============================================================================
#>

#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$ProgressPreference     = "SilentlyContinue"

# ─── Habilitar ANSI en Windows 10/11 (consola clásica y Windows Terminal) ───
if ($PSVersionTable.PSVersion.Major -lt 6) {
    # Intenta activar el modo ANSI del kernel para consolas Win32
    try {
        $kernel32 = Add-Type -PassThru -Name 'Kernel32' -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
'@
        $h = $kernel32::GetStdHandle(-11); $m = 0
        $kernel32::GetConsoleMode($h, [ref]$m) | Out-Null
        $kernel32::SetConsoleMode($h, $m -bor 4) | Out-Null   # ENABLE_VIRTUAL_TERMINAL_PROCESSING
    } catch { <# ignorar si falla #> }
}

# ─── Configuración ─────────────────────────────────────────────────────────
$RepoOwner    = "jephersonRD"
$RepoName     = "JiruHub"
$ApiUrl       = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
$InstallDir   = "$env:LOCALAPPDATA\JiruHub"
$LogDir       = "$env:LOCALAPPDATA\JiruHub\logs"
$LogFile      = "$LogDir\installer-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$VersionFile  = "$InstallDir\version"
$StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$DesktopDir   = [Environment]::GetFolderPath('Desktop')
$Lang         = "es"

# ─── Colores ANSI (compatibles PS 5.1+) ───────────────────────────────────
$ESC    = [char]27
$Cyan   = "$ESC[1;36m"
$Green  = "$ESC[1;32m"
$Yellow = "$ESC[1;33m"
$Red    = "$ESC[1;31m"
$Blue   = "$ESC[0;34m"
$White  = "$ESC[1;37m"
$Dim    = "$ESC[2m"
$Bold   = "$ESC[1m"
$Reset  = "$ESC[0m"

# ─── Traducciones ──────────────────────────────────────────────────────────
$I18N_ES = @{
    welcome           = "Bienvenido al Instalador de JiruHub"
    menu_lang         = "Selecciona tu idioma"
    opt_spanish       = "Español"; opt_english = "English"; opt_exit = "Salir"
    menu_main         = "Menú Principal"
    opt_install       = "Instalar"
    opt_update        = "Actualizar"
    opt_uninstall     = "Desinstalar"
    detecting_os      = "Detectando sistema operativo..."
    fetching_release  = "Buscando última versión en GitHub..."
    downloading       = "Descargando JiruHub..."
    installing        = "Instalando JiruHub..."
    success_install   = "JiruHub se instaló correctamente."
    success_update    = "JiruHub se actualizó correctamente."
    success_uninstall = "JiruHub se desinstaló correctamente."
    installed_version = "Versión instalada"
    install_path      = "Ruta de instalación"
    latest_version    = "Última versión disponible"
    already_latest    = "Ya tienes la última versión."
    no_internet       = "No se detectó conexión a internet."
    choose_option     = "Elige una opción"
    invalid_option    = "Opción inválida. Ingresa 1, 2, 3 o 4."
    press_enter       = "Presiona Enter para salir..."
    cancelled         = "Operación cancelada."
    log_path          = "Log guardado en"
    running           = "Ejecuta: jiruhub"
    shortcut_created  = "Acceso directo creado en el Escritorio y Menú Inicio."
    path_added        = "JiruHub agregado al PATH del sistema."
    no_asset          = "No se encontró el archivo de descarga para tu sistema."
    extract_fail      = "No se encontró el ejecutable tras la extracción."
    download_fail     = "La descarga falló tras varios intentos."
}

$I18N_EN = @{
    welcome           = "Welcome to the JiruHub Installer"
    menu_lang         = "Select your language"
    opt_spanish       = "Spanish"; opt_english = "English"; opt_exit = "Exit"
    menu_main         = "Main Menu"
    opt_install       = "Install"
    opt_update        = "Update"
    opt_uninstall     = "Uninstall"
    detecting_os      = "Detecting operating system..."
    fetching_release  = "Fetching latest release from GitHub..."
    downloading       = "Downloading JiruHub..."
    installing        = "Installing JiruHub..."
    success_install   = "JiruHub installed successfully."
    success_update    = "JiruHub updated successfully."
    success_uninstall = "JiruHub uninstalled successfully."
    installed_version = "Installed version"
    install_path      = "Installation path"
    latest_version    = "Latest version available"
    already_latest    = "You already have the latest version."
    no_internet       = "No internet connection detected."
    choose_option     = "Choose an option"
    invalid_option    = "Invalid option. Enter 1, 2, 3 or 4."
    press_enter       = "Press Enter to exit..."
    cancelled         = "Operation cancelled."
    log_path          = "Log saved at"
    running           = "Run: jiruhub"
    shortcut_created  = "Shortcut created on Desktop and Start Menu."
    path_added        = "JiruHub added to system PATH."
    no_asset          = "No download asset found for your system."
    extract_fail      = "Executable not found after extraction."
    download_fail     = "Download failed after several attempts."
}

function T($key) {
    $d = if ($Lang -eq "en") { $I18N_EN } else { $I18N_ES }
    if ($d.ContainsKey($key)) { return $d[$key] }
    return $key
}

# ─── Utilidades ────────────────────────────────────────────────────────────
function Write-Log($msg) {
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" | Out-File $LogFile -Append -Encoding UTF8
}

function Info($m)  { Write-Host "  ${Blue}i${Reset}  $m"; Write-Log "INFO: $m" }
function Ok($m)    { Write-Host "  ${Green}OK${Reset} $m"; Write-Log "OK: $m" }
function Warn($m)  { Write-Host "  ${Yellow}!!${Reset} $m"; Write-Log "WARN: $m" }
function Err($m)   { Write-Host "  ${Red}ERR${Reset} $m"; Write-Log "ERR: $m" }
function Die($m)   { Err $m; Read-Host "`n  $(T 'press_enter')"; exit 1 }

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "${Cyan}     ██╗██╗██████╗ ██╗   ██╗██╗  ██╗██╗   ██╗██████╗ ${Reset}"
    Write-Host "${Cyan}     ██║██║██╔══██╗██║   ██║██║  ██║██║   ██║██╔══██╗${Reset}"
    Write-Host "${Cyan}     ██║██║██████╔╝██║   ██║███████║██║   ██║██████╔╝${Reset}"
    Write-Host "${Cyan}██   ██║██║██╔══██╗██║   ██║██╔══██║██║   ██║██╔══██╗${Reset}"
    Write-Host "${Cyan}╚█████╔╝██║██║  ██║╚██████╔╝██║  ██║╚██████╔╝██████╔╝${Reset}"
    Write-Host "${Cyan} ╚════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ${Reset}"
    Write-Host "${Dim}        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
    Write-Host ""
}

function Show-ProgressBar($pct) {
    $w   = 40
    $f   = [math]::Floor($pct * $w / 100)
    $e   = $w - $f
    $bar = ("█" * $f) + ("░" * $e)
    Write-Host "`r  [${Cyan}${bar}${Reset}] ${Bold}${pct}%${Reset}   " -NoNewline
    if ($pct -eq 100) { Write-Host "" }
}

# ─── UI ─────────────────────────────────────────────────────────────────────
function Select-Language {
    Write-Host ""
    Write-Host "  ${Bold}[1]${Reset} Español"
    Write-Host "  ${Bold}[2]${Reset} English"
    Write-Host "  ${Bold}[3]${Reset} Salir / Exit"
    Write-Host ""
    $c = Read-Host "  Selecciona / Choose [1-3]"
    switch ($c) {
        "1" { $script:Lang = "es" }
        "2" { $script:Lang = "en" }
        "3" { exit 0 }
        default { $script:Lang = "es" }
    }
}

function Show-MainMenu {
    while ($true) {
        Show-Banner
        Write-Host "  ${Bold}${Cyan}◆ $(T 'menu_main') ◆${Reset}`n"
        Write-Host "  ${Bold}[1]${Reset} $(T 'opt_install')"
        Write-Host "  ${Bold}[2]${Reset} $(T 'opt_update')"
        Write-Host "  ${Bold}[3]${Reset} $(T 'opt_uninstall')"
        Write-Host "  ${Bold}[4]${Reset} ${Red}$(T 'opt_exit')${Reset}"
        Write-Host ""
        $c = Read-Host "  $(T 'choose_option') [1-4]"
        switch ($c) {
            "1" { Invoke-Install }
            "2" { Invoke-Update }
            "3" { Invoke-Uninstall }
            "4" { exit 0 }
            default { Warn (T 'invalid_option'); Start-Sleep -Seconds 1 }
        }
    }
}

# ─── Detección ─────────────────────────────────────────────────────────────
function Get-WindowsVersion {
    $v = [System.Environment]::OSVersion.Version
    $build = $v.Build
    if ($build -ge 22000) { return "Windows 11" }
    elseif ($build -ge 10240) { return "Windows 10" }
    else { return "Windows $($v.Major).$($v.Minor) (build $build)" }
}

function Get-Arch {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64" { return "x64" }
        "ARM64" { return "arm64" }
        "x86"   {
            # Verifica si es un proceso de 32-bit corriendo en un SO de 64-bit (WoW64)
            if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") { return "x64" }
            return "x86"
        }
        default { return $env:PROCESSOR_ARCHITECTURE }
    }
}

function Test-Internet {
    try {
        Invoke-WebRequest -Uri "https://api.github.com" -Method Head -TimeoutSec 8 -UseBasicParsing | Out-Null
    } catch {
        Die (T 'no_internet')
    }
}

# ─── CORRECCIÓN PRINCIPAL: Get-LatestRelease usa Invoke-RestMethod directamente
#     (NO dentro de Start-Job, porque los jobs no heredan las funciones del scope padre)
function Get-LatestRelease {
    $headers = @{
        Accept     = "application/vnd.github.v3+json"
        UserAgent  = "JiruHub-Installer/1.0"
    }
    try {
        return Invoke-RestMethod -Uri $ApiUrl -Headers $headers -UseBasicParsing
    } catch {
        Die "No se pudo obtener la última versión de GitHub. Detalles: $_"
    }
}

function Find-Asset($arch, $assets) {
    # Patrones de búsqueda por prioridad según arquitectura
    $patterns = switch ($arch) {
        "x64"   { @("JiruHub-*-windows-x64.zip", "JiruHub-*-windows.zip", "*windows*x64*.zip", "*windows*.zip") }
        "arm64" { @("JiruHub-*-windows-arm64.zip", "JiruHub-*-windows-arm.zip", "*windows*arm*.zip") }
        "x86"   { @("JiruHub-*-windows-x86.zip", "JiruHub-*-windows.zip", "*windows*.zip") }
        default { @("JiruHub-*-windows.zip", "*windows*.zip") }
    }
    foreach ($pattern in $patterns) {
        $regex = "^" + [regex]::Escape($pattern).Replace("\*", ".*") + "$"
        foreach ($asset in $assets) {
            if ($asset.name -match $regex) { return $asset }
        }
    }
    return $null
}

# ─── Descarga con barra de progreso ─────────────────────────────────────────
function Download-File($url, $outPath) {
    try {
        $req                  = [System.Net.HttpWebRequest]::Create($url)
        $req.UserAgent        = "JiruHub-Installer/1.0"
        $req.Timeout          = 120000
        $resp                 = $req.GetResponse()
        $total                = $resp.ContentLength
        $stream               = $resp.GetResponseStream()
        $fs                   = [System.IO.File]::Create($outPath)
        $buf                  = New-Object byte[] 32768
        $downloaded           = 0
        $lastPct              = -1

        while (($read = $stream.Read($buf, 0, $buf.Length)) -gt 0) {
            $fs.Write($buf, 0, $read)
            $downloaded += $read
            if ($total -gt 0) {
                $pct = [math]::Floor($downloaded * 100 / $total)
                if ($pct -ne $lastPct) { Show-ProgressBar $pct; $lastPct = $pct }
            }
        }
        $fs.Close(); $stream.Close(); $resp.Close()
        Show-ProgressBar 100
        Ok "$((Get-Item $outPath).Name) descargado correctamente."
    } catch {
        if ($fs)  { try { $fs.Close() }  catch {} }
        if ($resp){ try { $resp.Close() } catch {} }
        throw $_
    }
}

function Download-WithRetry($url, $outPath, $retries = 3) {
    for ($i = 1; $i -le $retries; $i++) {
        try {
            Download-File $url $outPath
            return
        } catch {
            if ($i -lt $retries) {
                Warn "Intento $i de $retries falló. Reintentando en $($i * 3)s..."
                Start-Sleep -Seconds ($i * 3)
            }
        }
    }
    Die (T 'download_fail')
}

# ─── Acceso directo ─────────────────────────────────────────────────────────
function New-JiruHubShortcut($exePath, $shortcutPath) {
    try {
        $wshell   = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath       = $exePath
        $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($exePath)
        $shortcut.Description      = "JiruHub - Anime, manga y películas"
        $shortcut.Save()
    } catch {
        Warn "No se pudo crear el acceso directo en: $shortcutPath"
    }
}

# ─── Agregar al PATH ─────────────────────────────────────────────────────────
function Add-ToUserPath($dir) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$dir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$dir", "User")
        # También actualiza la sesión actual
        $env:PATH += ";$dir"
        Ok (T 'path_added')
    }
}

# ─── Instalar ────────────────────────────────────────────────────────────────
function Invoke-Install {
    Show-Banner

    # 1. Verificar internet
    Write-Host "  ${Dim}┌─ Verificando conexión a internet... ─────────────────────────┐${Reset}"
    Test-Internet
    Ok "Conexión a internet OK."

    # 2. Detectar sistema
    Write-Host "`n  ${Dim}┌─ $(T 'detecting_os') ────────────────────────────────────┐${Reset}"
    $winVer = Get-WindowsVersion
    $arch   = Get-Arch
    Info "Sistema:       ${Bold}$winVer${Reset}"
    Info "Arquitectura:  ${Bold}$arch${Reset}"
    Info "PowerShell:    ${Bold}$($PSVersionTable.PSVersion)${Reset}"

    # 3. Obtener última versión
    Write-Host "`n  ${Dim}┌─ $(T 'fetching_release') ──────────────────────────────────┐${Reset}"
    Write-Host "  Consultando GitHub API..." -NoNewline
    $release = Get-LatestRelease
    Write-Host " ${Green}OK${Reset}"

    $tag = $release.tag_name
    Info "$(T 'latest_version'): ${Bold}${Green}$tag${Reset}"

    # 4. Buscar asset correcto
    $asset = Find-Asset $arch $release.assets
    if (-not $asset) {
        Err (T 'no_asset')
        Write-Host ""
        Write-Host "  Assets disponibles en la release ${Bold}$tag${Reset}:"
        foreach ($a in $release.assets) { Write-Host "    - $($a.name)" }
        Read-Host "`n  $(T 'press_enter')"
        return
    }
    Info "Archivo:  ${Bold}$($asset.name)${Reset}  ($([math]::Round($asset.size/1MB, 1)) MB)"

    # 5. Descargar
    Write-Host "`n  ${Dim}┌─ $(T 'downloading') ─────────────────────────────────────────┐${Reset}"
    $tmp     = Join-Path $env:TEMP "jiruhub_install_$(Get-Random)"
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $zipPath = Join-Path $tmp $asset.name

    Download-WithRetry $asset.browser_download_url $zipPath

    # 6. Extraer e instalar
    Write-Host "`n  ${Dim}┌─ $(T 'installing') ──────────────────────────────────────────┐${Reset}"
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    $extractDir = Join-Path $tmp "extracted"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    Write-Host "  Extrayendo archivos..." -NoNewline
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
    Write-Host " ${Green}OK${Reset}"

    # Buscar la carpeta que contiene el .exe (puede estar en subfolder o en raíz)
    $sourceDir = $extractDir
    $exeFiles  = Get-ChildItem $extractDir -Recurse -Filter "*.exe" | Where-Object {
        $_.Name -match "(jiruhub|miru)\.exe" -and $_.Name -notmatch "unins"
    }
    if ($exeFiles) {
        $sourceDir = $exeFiles[0].DirectoryName
    } else {
        # Buscar cualquier .exe si no hay match exacto
        $anyExe = Get-ChildItem $extractDir -Recurse -Filter "*.exe" | Where-Object {
            $_.Name -notmatch "unins"
        } | Select-Object -First 1
        if ($anyExe) { $sourceDir = $anyExe.DirectoryName }
    }

    # Limpiar instalación previa y copiar
    Write-Host "  Copiando archivos a $InstallDir..." -NoNewline
    Remove-Item "$InstallDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$sourceDir\*" $InstallDir -Recurse -Force
    Write-Host " ${Green}OK${Reset}"

    # Limpiar temporales
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

    # 7. Verificar ejecutable
    $exe = Get-ChildItem $InstallDir -Filter "*.exe" | Where-Object {
        $_.Name -match "(jiruhub|miru)\.exe" -and $_.Name -notmatch "unins"
    } | Select-Object -First 1

    if (-not $exe) {
        $exe = Get-ChildItem $InstallDir -Filter "*.exe" | Where-Object {
            $_.Name -notmatch "unins"
        } | Select-Object -First 1
    }

    if (-not $exe) { Die (T 'extract_fail') }

    # 8. Crear accesos directos
    $menuShortcut    = Join-Path $StartMenuDir "JiruHub.lnk"
    $desktopShortcut = Join-Path $DesktopDir "JiruHub.lnk"
    New-JiruHubShortcut $exe.FullName $menuShortcut
    New-JiruHubShortcut $exe.FullName $desktopShortcut
    Ok (T 'shortcut_created')

    # 9. Agregar al PATH del usuario
    Add-ToUserPath $InstallDir

    # 10. Guardar versión instalada
    $tag | Out-File $VersionFile -Encoding UTF8 -NoNewline

    # 11. Resultado
    Write-Host ""
    Write-Host "  ${Green}${Bold}╔══════════════════════════════════════════════════════╗${Reset}"
    Write-Host "  ${Green}${Bold}║                                                      ║${Reset}"
    Write-Host "  ${Green}${Bold}║   [OK]  $(T 'success_install')               ║${Reset}"
    Write-Host "  ${Green}${Bold}║                                                      ║${Reset}"
    Write-Host "  ${Green}${Bold}╚══════════════════════════════════════════════════════╝${Reset}"
    Write-Host ""
    Write-Host "  ${Bold}$(T 'installed_version'):${Reset}  ${Cyan}$tag${Reset}"
    Write-Host "  ${Bold}$(T 'install_path'):${Reset}       ${Cyan}$InstallDir${Reset}"
    Write-Host "  ${Bold}$(T 'log_path'):${Reset}           ${Cyan}$LogFile${Reset}"
    Write-Host ""
    Write-Host "  ${Dim}Puedes abrir JiruHub desde el Escritorio o el Menú Inicio.${Reset}"
    Write-Host ""
    Read-Host "  $(T 'press_enter')"
}

# ─── Actualizar ───────────────────────────────────────────────────────────────
function Invoke-Update {
    Show-Banner
    if (-not (Test-Path $VersionFile)) {
        Warn "JiruHub no está instalado en este equipo."
        Warn "Selecciona la opción 'Instalar' primero."
        Start-Sleep -Seconds 3
        return
    }

    $current = (Get-Content $VersionFile -Raw).Trim()
    Test-Internet
    Info "Versión instalada: ${Bold}$current${Reset}"

    Write-Host "  Consultando GitHub API..." -NoNewline
    $release = Get-LatestRelease
    Write-Host " ${Green}OK${Reset}"

    $latest = $release.tag_name
    Info "$(T 'latest_version'):   ${Bold}${Green}$latest${Reset}"

    if ($current -eq $latest) {
        Write-Host ""
        Ok "$(T 'already_latest') ($current)"
        Read-Host "`n  $(T 'press_enter')"
        return
    }

    Write-Host ""
    Write-Host "  ${Yellow}${Bold}Nueva versión disponible:${Reset} ${Green}${Bold}$latest${Reset}"
    Write-Host ""
    Invoke-Install
    Ok (T 'success_update')
}

# ─── Desinstalar ──────────────────────────────────────────────────────────────
function Invoke-Uninstall {
    Show-Banner
    Write-Host ""
    Write-Host "  ${Yellow}${Bold}  [!]  Se eliminarán todos los archivos de JiruHub.${Reset}"
    Write-Host "  ${Dim}Ruta: $InstallDir${Reset}"
    Write-Host ""
    $c = Read-Host "  ¿Continuar? [s/N]"
    if ($c -notmatch "^[Ss]$") {
        Info (T 'cancelled')
        Start-Sleep -Seconds 1
        return
    }

    Write-Host "  Eliminando archivos..." -NoNewline
    Remove-Item $InstallDir     -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$StartMenuDir\JiruHub.lnk" -Force -ErrorAction SilentlyContinue
    Remove-Item "$DesktopDir\JiruHub.lnk"   -Force -ErrorAction SilentlyContinue
    Remove-Item $LogDir         -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " ${Green}OK${Reset}"

    # Remover del PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = ($currentPath -split ";" | Where-Object { $_ -ne $InstallDir }) -join ";"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

    Write-Host ""
    Ok (T 'success_uninstall')
    Read-Host "`n  $(T 'press_enter')"
}

# ─── Entry Point ─────────────────────────────────────────────────────────────
try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Log "=== JiruHub Installer v2.0 started (PS $($PSVersionTable.PSVersion)) ==="
    Write-Log "Windows: $(Get-WindowsVersion) | Arch: $(Get-Arch)"

    Show-Banner
    Select-Language
    Show-MainMenu

    Write-Log "=== JiruHub Installer finished ==="
} catch {
    $msg = $_.ToString()
    Err "Error inesperado: $msg"
    Write-Log "FATAL: $msg"
    Write-Host ""
    Read-Host "  $(T 'press_enter')"
    exit 1
}

