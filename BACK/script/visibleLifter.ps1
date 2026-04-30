# --- Parametros de la terminal anterior ---
param(
    [string]$rutaLinux,
    [string]$rutaLatestTmp
)

# --- Transcribe terminal con append ---
Start-Transcript -Path $rutaLatestTmp -Append | Out-Null

    # --- Ejecuta un script en el entorno WSL ---
    wsl -d Debian bash -lc "cd '$rutaLinux' && chmod u+x 01_script.sh && ./01_script.sh"

# --- Cierra la transcripcion ---
Stop-Transcript | Out-Null

# --- Animacion visual para mas elegancia ---
1..3 | % { Write-Host "." -NoNewline; Start-Sleep 1 }