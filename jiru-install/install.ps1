<#
 ==============================================================================
  JiruHub Installer — Windows (PowerShell)
  Uso: irm https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.ps1 | iex
 ==============================================================================
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ─── Configuración ─────────────────────────────────────────────────────────
$RepoOwner = "jephersonRD"
$RepoName = "JiruHub"
$ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
$InstallDir = "$env:LOCALAPPDATA\JiruHub"
$LogDir = "$env:LOCALAPPDATA\JiruHub\logs"
$LogFile = "$LogDir\installer-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$VersionFile = "$InstallDir\version"
$StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$Lang = "es"

# ─── Colores ANSI ──────────────────────────────────────────────────────────
$Cyan = "`e[1;36m"
$Green = "`e[1;32m"
$Yellow = "`e[1;33m"
$Red = "`e[1;31m"
$Blue = "`e[0;34m"
$White = "`e[1;37m"
$Dim = "`e[2m"
$Bold = "`e[1m"
$Reset = "`e[0m"

# ─── Traducciones ───────────────────────────────────────────────────────────
$I18N_ES = @{
    welcome="Bienvenido al Instalador de JiruHub"
    menu_lang="Selecciona tu idioma"
    opt_spanish="Español"; opt_english="English"; opt_exit="Salir"
    menu_main="Menú Principal"
    opt_install="Instalar"; opt_update="Actualizar"; opt_uninstall="Desinstalar"
    detecting_os="Detectando sistema operativo..."
    detecting_arch="Detectando arquitectura..."
    fetching_release="Buscando última versión en GitHub..."
    downloading="Descargando JiruHub..."
    installing="Instalando JiruHub..."
    success_install="JiruHub se instaló correctamente."
    success_update="JiruHub se actualizó correctamente."
    success_uninstall="JiruHub se desinstaló correctamente."
    installed_version="Versión instalada"
    install_path="Ruta de instalación"
    latest_version="Última versión disponible"
    already_latest="Ya tienes la última versión."
    no_internet="No se detectó conexión a internet."
    choose_option="Elige una opción"
    invalid_option="Opción inválida."
    press_enter="Presiona Enter para salir..."
    cancelled="Operación cancelada."
    log_path="Log guardado en"
    running="ejecuta: jiruhub"
}

$I18N_EN = @{
    welcome="Welcome to JiruHub Installer"
    menu_lang="Select your language"
    opt_spanish="Spanish"; opt_english="English"; opt_exit="Exit"
    menu_main="Main Menu"
    opt_install="Install"; opt_update="Update"; opt_uninstall="Uninstall"
    detecting_os="Detecting operating system..."
    detecting_arch="Detecting architecture..."
    fetching_release="Fetching latest release from GitHub..."
    downloading="Downloading JiruHub..."
    installing="Installing JiruHub..."
    success_install="JiruHub installed successfully."
    success_update="JiruHub updated successfully."
    success_uninstall="JiruHub uninstalled successfully."
    installed_version="Installed version"
    install_path="Installation path"
    latest_version="Latest version available"
    already_latest="You already have the latest version."
    no_internet="No internet connection detected."
    choose_option="Choose an option"
    invalid_option="Invalid option."
    press_enter="Press Enter to exit..."
    cancelled="Operation cancelled."
    log_path="Log saved at"
    running="run: jiruhub"
}

function T($key) {
    $d = if ($Lang -eq "en") { $I18N_EN } else { $I18N_ES }
    return $d[$key]
}

# ─── Utilidades ────────────────────────────────────────────────────────────
function Write-Log($msg) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" | Out-File $LogFile -Append -Encoding UTF8
}

function Info($m)  { Write-Host "  ${Blue}ℹ${Reset}  $m"; Write-Log "INFO: $m" }
function Ok($m)    { Write-Host "  ${Green}✔${Reset}  $m"; Write-Log "OK: $m" }
function Warn($m)  { Write-Host "  ${Yellow}⚠${Reset}  $m"; Write-Log "WARN: $m" }
function Err($m)   { Write-Host "  ${Red}✖${Reset}  $m"; Write-Log "ERR: $m" }
function Die($m)   { Err $m; Read-Host "  $(T press_enter)"; exit 1 }

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

function Show-Spinner($msg, $sb) {
    $spin = "⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"
    $job = Start-Job -ScriptBlock $sb
    $i = 0
    while ($job.State -eq "Running") {
        Write-Host "`r  $($spin[$i%10])  $msg" -NoNewline -ForegroundColor Cyan
        $i++
        Start-Sleep -Milliseconds 100
    }
    Write-Host "`r$(' ' * 60)`r" -NoNewline
    $r = Receive-Job $job
    Remove-Job $job
    return $r
}

function Show-ProgressBar($pct) {
    $w = 40
    $f = [math]::Floor($pct * $w / 100)
    $e = $w - $f
    $bar = "█" * $f + "░" * $e
    Write-Host "`r  [${Cyan}${bar}${Reset}] ${Bold}$pct%${Reset}" -NoNewline
    if ($pct -eq 100) { Write-Host "" }
}

# ─── UI ─────────────────────────────────────────────────────────────────────
function Select-Language {
    Write-Host ""
    Write-Host "  [1] Español"
    Write-Host "  [2] English"
    Write-Host "  [3] $(T('opt_exit'))"
    Write-Host ""
    $c = Read-Host "  $(T('choose_option'))"
    switch ($c) { "1" { $script:Lang = "es" } "2" { $script:Lang = "en" } "3" { exit 0 } }
}

function Show-MainMenu {
    while ($true) {
        Show-Banner
        Write-Host "  ${Bold}${Cyan}◆ $(T('menu_main')) ◆${Reset}`n"
        Write-Host "  [1] $(T('opt_install'))"
        Write-Host "  [2] $(T('opt_update'))"
        Write-Host "  [3] $(T('opt_uninstall'))"
        Write-Host "  [4] ${Red}$(T('opt_exit'))${Reset}"
        Write-Host ""
        $c = Read-Host "  $(T('choose_option'))"
        switch ($c) {
            "1" { Invoke-Install; break }
            "2" { Invoke-Update; break }
            "3" { Invoke-Uninstall; break }
            "4" { exit 0 }
            default { Warn $(T('invalid_option')) }
        }
    }
}

# ─── Detección ─────────────────────────────────────────────────────────────
function Get-OS { return "windows" }

function Get-Arch {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64" { return "x64" }
        "ARM64" { return "arm64" }
        default { return $env:PROCESSOR_ARCHITECTURE }
    }
}

function Test-Internet {
    try { Invoke-WebRequest -Uri "https://api.github.com" -Method Head -TimeoutSec 5 | Out-Null }
    catch { Die $(T('no_internet')) }
}

function Get-LatestRelease {
    $h = @{ Accept = "application/vnd.github.v3+json" }
    return Invoke-RestMethod -Uri $ApiUrl -Headers $h
}

function Find-Asset($os, $arch, $assets) {
    $patterns = switch ($arch) {
        "x64"   { @("JiruHub-*-windows-x64.zip", "JiruHub-*-windows.zip", "JiruHub-*-windows-setup.exe") }
        "arm64" { @("JiruHub-*-windows-arm64.zip") }
        default { @("JiruHub-*-windows.zip", "JiruHub-*-windows-setup.exe") }
    }
    foreach ($p in $patterns) {
        $pat = "^" + [regex]::Escape($p).Replace("\*", ".*") + "$"
        foreach ($a in $assets) {
            if ($a.name -match $pat) { return $a }
        }
    }
    return $null
}

# ─── Descarga ──────────────────────────────────────────────────────────────
function Download-File($url, $outPath) {
    Info $(T('downloading'))
    $req = [System.Net.HttpWebRequest]::Create($url)
    $resp = $req.GetResponse()
    $total = $resp.ContentLength
    $stream = $resp.GetResponseStream()
    $fs = [System.IO.File]::Create($outPath)
    $buf = New-Object byte[] 8192
    $read = 0
    $dl = 0
    $last = -1
    while (($read = $stream.Read($buf, 0, $buf.Length)) -gt 0) {
        $fs.Write($buf, 0, $read)
        $dl += $read
        if ($total -gt 0) {
            $pct = [math]::Floor($dl * 100 / $total)
            if ($pct -ne $last) { Show-ProgressBar $pct; $last = $pct }
        }
    }
    $fs.Close(); $stream.Close()
    Show-ProgressBar 100
    Ok "$((Get-Item $outPath).Name) descargado."
}

function Download-WithRetry($url, $outPath, $retries=3) {
    for ($i=1; $i -le $retries; $i++) {
        try { Download-File $url $outPath; return }
        catch {
            Warn "Intento $i falló. Reintentando..."
            Start-Sleep -Seconds ($i * 2)
        }
    }
    Die "Descarga falló después de $retries intentos."
}

function New-Shortcut($target, $shortcutPath) {
    $wshell = New-Object -ComObject WScript.Shell
    $s = $wshell.CreateShortcut($shortcutPath)
    $s.TargetPath = $target
    $s.WorkingDirectory = (Get-Item $target).DirectoryName
    $s.Save()
}

# ─── Instalar ────────────────────────────────────────────────────────────────
function Invoke-Install {
    Show-Banner
    Test-Internet

    Write-Host "`n  ${Dim}┌─ $(T('detecting_os')) ────────────────────────────────────┐${Reset}"
    $os = Get-OS
    Info "OS: $os"
    Start-Sleep -Milliseconds 300

    $arch = Get-Arch
    Info "Arch: $arch"
    Start-Sleep -Milliseconds 300

    Write-Host "`n  ${Dim}┌─ $(T('fetching_release')) ──────────────────────────────┐${Reset}"
    $release = Show-Spinner $(T('fetching_release')) { Get-LatestRelease }
    $tag = $release.tag_name
    Info "$(T('latest_version')): ${Bold}${Green}$tag${Reset}"

    $asset = Find-Asset $os $arch $release.assets
    if (-not $asset) { Die "No se encontró asset para $os ($arch). Revisa GitHub Releases." }
    Info "Asset: $($asset.name)"

    $tmp = "$env:TEMP\jiruhub_install"
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $zipPath = "$tmp\$($asset.name)"

    Download-WithRetry $asset.browser_download_url $zipPath

    Write-Host "`n  ${Dim}┌─ $(T('installing')) ───────────────────────────────────┐${Reset}"
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    Expand-Archive -Path $zipPath -DestinationPath $tmp -Force

    $bundleDir = $tmp
    Get-ChildItem $tmp -Directory | ForEach-Object {
        if ((Test-Path "$($_.FullName)\jiruhub.exe" -PathType Leaf) -or
            (Test-Path "$($_.FullName)\JiruHub.exe" -PathType Leaf) -or
            (Test-Path "$($_.FullName)\miru.exe" -PathType Leaf)) {
            $bundleDir = $_.FullName
        }
    }

    Remove-Item "$InstallDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$bundleDir\*" $InstallDir -Recurse -Force

    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

    $exe = Get-ChildItem $InstallDir -Filter "*.exe" | Select-Object -First 1
    if (-not $exe) { Die "No se encontró el ejecutable después de extraer." }

    $shortcut = "$StartMenuDir\JiruHub.lnk"
    New-Shortcut $exe.FullName $shortcut
    Info "Acceso directo creado."

    $tag | Out-File $VersionFile -Encoding UTF8

    Write-Host ""
    Write-Host "${Green}${Bold}  ╔══════════════════════════════════════════════════╗${Reset}"
    Write-Host "${Green}${Bold}  ║                                                  ║${Reset}"
    Write-Host "${Green}${Bold}  ║     $(T('success_install'))              ║${Reset}"
    Write-Host "${Green}${Bold}  ║                                                  ║${Reset}"
    Write-Host "${Green}${Bold}  ╚══════════════════════════════════════════════════╝${Reset}"
    Write-Host ""
    Write-Host "  ${Bold}$(T('installed_version')):${Reset}  ${Cyan}$tag${Reset}"
    Write-Host "  ${Bold}$(T('install_path')):${Reset}       ${Cyan}$InstallDir${Reset}"
    Write-Host "  ${Bold}$(T('log_path')):${Reset}         ${Cyan}$LogFile${Reset}"
    Write-Host ""
    Read-Host "  $(T('press_enter'))"
}

# ─── Actualizar ──────────────────────────────────────────────────────────────
function Invoke-Update {
    if (-not (Test-Path $VersionFile)) {
        Warn "JiruHub no está instalado. Ejecuta 'Instalar' primero."
        Start-Sleep -Seconds 2; return
    }
    $current = Get-Content $VersionFile
    Show-Banner
    Test-Internet
    Info "Versión actual: $current"
    $release = Get-LatestRelease
    $latest = $release.tag_name
    if ($current -eq $latest) {
        Ok "$(T('already_latest')) ($current)"
        Read-Host "  $(T('press_enter'))"; return
    }
    Info "Nueva versión: $latest"
    Invoke-Install
    Ok $(T('success_update'))
}

# ─── Desinstalar ─────────────────────────────────────────────────────────────
function Invoke-Uninstall {
    Show-Banner
    Write-Host "`n  ${Yellow}${Bold}  ⚠  Se eliminarán todos los archivos de JiruHub.${Reset}"
    $c = Read-Host "  ¿Continuar? [s/N]"
    if ($c -notmatch "^[Ss]$") { Info $(T('cancelled')); return }
    Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$StartMenuDir\JiruHub.lnk" -Force -ErrorAction SilentlyContinue
    Remove-Item $LogDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\JiruHub" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "${env:ProgramFiles(x86)}\JiruHub" -Recurse -Force -ErrorAction SilentlyContinue
    Ok $(T('success_uninstall'))
    Read-Host "  $(T('press_enter'))"
}

# ─── Entry Point ───────────────────────────────────────────────────────────
try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Log "=== JiruHub Installer started ==="
    Show-Banner
    Select-Language
    Show-MainMenu
    Write-Log "=== JiruHub Installer finished ==="
} catch {
    Err "Error: $_"
    Write-Log "FATAL: $_"
    Read-Host "  $(T('press_enter'))"
}
