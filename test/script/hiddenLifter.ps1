# --- Rutas Log ---
$rutaTimestampLog  = Join-Path $PSScriptRoot "..\log\$(Get-Date -Format 'yyyy-MM-ddTHH-mm-ss').log"
$rutaLatestLog     = Join-Path $PSScriptRoot "..\log\latest.log"
$rutaLatestTmp     = Join-Path $PSScriptRoot "..\log\latest.tmp"

# --- Transcribe la terminal y crea .tmp ---
Start-Transcript -Path $rutaLatestTmp -Force | Out-Null

    # --- Carga las funciones del modulo envTools ---
    Import-Module "$PSScriptRoot\envTools.psm1"

    # --- Asigna envVars en un hashTable ---
    $env = Read-DotEnv "$PSScriptRoot\..\.env"

    # --- EnvVars de WSL ---
    $env["USER"]    = wsl -d Debian bash -lc 'id -un'
    $env["UID"]     = wsl -d Debian bash -lc "id -u"
    $env["GID"]     = wsl -d Debian bash -lc "id -g"

    # --- Rutas Template ---
    $rutaTemplate           = Join-Path $PSScriptRoot "..\template"
    $rutaTemplateResuelto   = Join-Path $PSScriptRoot "..\log\debug_template"

    # --- Rutas WSL/Linux ---
    $rutaWSL    = "\\wsl$\Debian\home\$($env['USER'])\compose\$($env['COMPOSE_NAME'])"
    $rutaLinux  = "/home/$($env['USER'])/compose/$($env['COMPOSE_NAME'])"

    # --- Resuelve envVars de las plantillas ---
    Invoke-TemplateResolve `
        -Source $rutaTemplate `
        -Destination $rutaTemplateResuelto `
        -Variable $env

    # --- Sincroniza la carpeta TemplateResuelto → WSL ---
    robocopy "$rutaTemplateResuelto" "$rutaWSL" /E /NJH /NJS /NDL /NFL /NP /NS /NC

# --- Cierra la transcripcion ---
Stop-Transcript | Out-Null

    # --- Abre una nueva terminal y ejecuta un script en el entorno WSL ---
    Start-Process powershell -Wait -ArgumentList @(
        "-ExecutionPolicy Bypass",
        "-File", "`"$PSScriptRoot\visibleLifter.ps1`""
        "-rutaLinux", "`"$rutaLinux`"",
        "-rutaLatestTmp", "`"$rutaLatestTmp`""
    )

# --- Transcribe terminal con append ---
Start-Transcript -Path $rutaLatestTmp -Append | Out-Null

    # --- Ejecuta un script en el entorno WSL ---
    wsl -d Debian bash -lc "cd '$rutaLinux' && chmod u+x 02_script.sh && ./02_script.sh"

# --- Cierra la transcripcion ---
Stop-Transcript | Out-Null

# --- Transforma mediante regex el .tmp y lo renombra a .log ---
[System.IO.File]::WriteAllText(
    $rutaLatestTmp, ((Get-Content $rutaLatestTmp -Raw) `
        -replace '(?s)\*{10,}.*?\*{10,}', '' `
        -replace '(?m)^\s*\r?\n',         '' `
        -replace '\s+$',                  '' `
        ).Replace("`r`n", "`n"), 
    (New-Object System.Text.UTF8Encoding($false))
); Move-Item $rutaLatestTmp $rutaLatestLog -Force

# --- Crea timestamp.log ---
Copy-Item -Path $rutaLatestLog -Destination $rutaTimestampLog -Force