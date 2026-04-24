# --- Parametros recibidos desde init.vbs ---
param(
    [Parameter(Mandatory)]
    [string]$pathSelectedCompose,
    [string]$pathInit
)

# --- Rutas Log (relativas a la carpeta compose seleccionada) ---
$pathTimestampLog  = Join-Path $pathSelectedCompose "log\$(Get-Date -Format 'yyyy-MM-ddTHH-mm-ss').log"
$pathLatestLog     = Join-Path $pathSelectedCompose "log\latest.log"
$pathLatestTmp     = Join-Path $pathSelectedCompose "log\latest.tmp"

# --- Transcribe la terminal y crea .tmp ---
Start-Transcript -Path $pathLatestTmp -Force | Out-Null

    # --- Carga las funciones del modulo envTools ---
    Import-Module "$PSScriptRoot\envTools.psm1"

    # --- Asigna envVars en un hashTable ---
    $env = Read-DotEnv "$pathSelectedCompose\.env"

    # --- EnvVars de WSL ---
    $env["USER"]    = wsl -d Debian bash -lc 'id -un'
    $env["UID"]     = wsl -d Debian bash -lc "id -u"
    $env["GID"]     = wsl -d Debian bash -lc "id -g"

    # --- Rutas Template (relativas a la carpeta compose seleccionada) ---
    $pathTemplate           = Join-Path $pathSelectedCompose    "template"
    $pathTemplateResuelto   = Join-Path $pathSelectedCompose    "log\debug_template"
    $pathBash               = Join-Path $pathInit               "script\bash"

    # --- Rutas WSL/Linux ---
    $pathWSL    = "\\wsl$\Debian\home\$($env['USER'])\compose\$($env['COMPOSE_NAME'])"
    $pathLinux  = "/home/$($env['USER'])/compose/$($env['COMPOSE_NAME'])"

    # --- Resuelve envVars de las plantillas ---
    Invoke-TemplateResolve `
        -Source $pathTemplate `
        -Destination $pathTemplateResuelto `
        -Variable $env

    Invoke-TemplateResolve `
        -Source $pathBash `
        -Destination $pathTemplateResuelto `
        -Variable $env

    # --- Sincroniza la carpeta TemplateResuelto → WSL ---
    robocopy "$pathTemplateResuelto" "$pathWSL" /E /NJH /NJS /NDL /NFL /NP /NS /NC

# --- Cierra la transcripcion ---
Stop-Transcript | Out-Null

    # --- Abre una nueva terminal y ejecuta un script en el entorno WSL ---
    Start-Process powershell -Wait -ArgumentList @(
        "-ExecutionPolicy Bypass",
        "-File", "`"$PSScriptRoot\visibleLifter.ps1`""
        "-pathLinux", "`"$pathLinux`"",
        "-pathLatestTmp", "`"$pathLatestTmp`""
    )

# --- Transcribe terminal con append ---
Start-Transcript -Path $pathLatestTmp -Append | Out-Null

    # --- Ejecuta un script en el entorno WSL ---
    wsl -d Debian bash -lc "cd '$pathLinux' && chmod u+x 02_script.sh && ./02_script.sh"

# --- Cierra la transcripcion ---
Stop-Transcript | Out-Null

# --- Transforma mediante regex el .tmp y lo renombra a .log ---
[System.IO.File]::WriteAllText(
    $pathLatestTmp, ((Get-Content $pathLatestTmp -Raw) `
        -replace '(?s)\*{10,}.*?\*{10,}', '' `
        -replace '(?m)^\s*\r?\n',         '' `
        -replace '\s+$',                  '' `
        ).Replace("`r`n", "`n"), 
    (New-Object System.Text.UTF8Encoding($false))
); Move-Item $pathLatestTmp $pathLatestLog -Force

# --- Crea timestamp.log ---
Copy-Item -Path $pathLatestLog -Destination $pathTimestampLog -Force
