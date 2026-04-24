param(
    [Parameter(Mandatory)]
    [string]$pathInit,
    [string]$hasInstalledExtensions = $null
)

# --- Obtencion rutas  ---
$pathHiddenLifter   = Join-Path $PSScriptRoot   "hiddenLifter.ps1"
$pathCompose        = Join-Path $pathInit       "compose"
$pathExtension      = Join-Path $pathInit       "extension"

# --- Rutas Log (relativas a la carpeta compose seleccionada) ---
$pathLatestLog     = Join-Path $pathInit "extension\log\latest.log"
$pathLatestTmp     = Join-Path $pathInit "extension\log\latest.tmp"



function Invoke-RestartShell {
    Clear-Host
    & $PSCommandPath -pathInit "$pathInit"
    exit
}

function Invoke-HiddenLifter {
    $pathSelectedCompose = Join-Path $pathCompose $folderName[$num - 1]

    # --- Lanza hiddenLifter de forma oculta ---
    Start-Process powershell -ArgumentList @(
        "-executionPolicy bypass",
        "-file", "`"$pathHiddenLifter`"",
        "-pathSelectedCompose", "`"$pathSelectedCompose`"",
        "-pathInit","`"$pathInit`""
    ) -WindowStyle Hidden

}

function Invoke-InstaladorExtensiones {
    $pathTimestampLog  = Join-Path $pathExtension "log\$(Get-Date -Format 'yyyy-MM-ddTHH-mm-ss').log"

    $json = Get-Content (Join-Path $pathExtension "vscode-extension.json") -Raw | ConvertFrom-Json

    Start-Transcript -Path $pathLatestTmp -Force | Out-Null
        
        wsl -d Debian bash -lc "code --install-extension $($json.extensions -join " --install-extension ") --force" | Select-Object -Skip 1
    
    Stop-Transcript | Out-Null

    # --- Crea timestamp.log ---
    Copy-Item -Path $pathLatestLog -Destination $pathTimestampLog -Force

    1..3 | ForEach-Object { Write-Host "." -NoNewline; Start-Sleep 1 }

    [System.IO.File]::WriteAllText(
        $pathLatestTmp, ((Get-Content $pathLatestTmp -Raw) `
            -replace '(?s)\*{10,}.*?\*{10,}', '' `
            -replace '(?m)^\s*\r?\n',         '' `
            -replace '\s+$',                  '' `
            ).Replace("`r`n", "`n"), 
        (New-Object System.Text.UTF8Encoding($false))
    ); Move-Item $pathLatestTmp $pathLatestLog -Force

    Clear-Host
    & $PSCommandPath -pathInit "$pathInit" -hasInstalledExtensions "$true"

    exit
}

# --- Printea banner ASCII ---
Write-Host (
@"
        CCCCCCCCCCCCCCCC    LLLLLLLLLLLLL               IIIIIIIIIIIIIIIIIIIIIIII            CCCCCCCCCCCCCCCC
     CCC:::::::::::::::C    L:::::::::::L               I::::::::::::::::::::::I         CCC:::::::::::::::C
   CC::::::::::::::::::C    L:::::::::::L               I::::::::::::::::::::::I       CC::::::::::::::::::C
  C:::::::CCCCCCC::::::C    LL:::::::LLLL               IIIIIIII::::::::IIIIIIII      C:::::::CCCCCCC::::::C
 C:::::::C      CCCCCCCC     L::::::L                         III::::::III           C:::::::C      CCCCCCCC
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
C:::::::C                    L::::::L                           I::::::I            C:::::::C               
 C:::::::C      CCCCCCCC     L::::::L         LLLLLL          III::::::III           C:::::::C      CCCCCCCC
  C:::::::CCCCCCC::::::C    LL:::::::LLLLLLLLL:::::L    IIIIIIII::::::::IIIIIIII      C:::::::CCCCCCC::::::C
   CC::::::::::::::::::C    L::::::::::::::::::::::L    I::::::::::::::::::::::I       CC::::::::::::::::::C
     CCC:::::::::::::::C    L::::::::::::::::::::::L    I::::::::::::::::::::::I         CCC:::::::::::::::C
        CCCCCCCCCCCCCCCC    LLLLLLLLLLLLLLLLLLLLLLLL    IIIIIIIIIIIIIIIIIIIIIIII            CCCCCCCCCCCCCCCC

CLIC is a Launching Interface for Containers; Developed by Netti;

"@
) -ForegroundColor Magenta

# --- Formateamos el selector ---
#==========================================================================================================================
Write-Host "[i]"    -NoNewline -ForegroundColor Cyan;   Write-Host " install addons "   -NoNewline  -ForegroundColor White
Write-Host "[r]"    -NoNewline -ForegroundColor Cyan;   Write-Host " reload interface " -NoNewline  -ForegroundColor White
Write-Host "[q]"    -NoNewline -ForegroundColor Red;    Write-Host " quit "                         -ForegroundColor White
#==========================================================================================================================

Write-Host;

# --- Mostramos las carpetas por indice ---
#==========================================================================================================================
$folderName = Get-ChildItem $pathCompose -Directory | ForEach-Object Name

$i = 0; foreach ($name in $folderName) {
    Write-Host ("[{0,2}]" -f $i++) -NoNewline   -ForegroundColor White 
    Write-Host " $name"                         -ForegroundColor Yellow
}

if ($hasInstalledExtensions) {
    Write-Host; Write-Host "Instalacion exitosa" -ForegroundColor DarkGreen
} 

#==========================================================================================================================

Write-Host;

# --- Validamos la seleccion del usuario ---
#==========================================================================================================================
while ($response -ne "Q") {

    Write-Host "> " -NoNewline -ForegroundColor Yellow; $response = (Read-Host).ToUpper();

    $resultado = ($num = (($response -as [int]) -in (1..$nombresCarpetas.Count)))

    switch ($response) {
        "R"             { Invoke-RestartShell }
        "I"             { Invoke-InstaladorExtensiones }
        {$resultado}    { Invoke-HiddenLifter }
        default         { Write-Host "Respuesta invalida" -ForegroundColor Red }
    }

}
#==========================================================================================================================