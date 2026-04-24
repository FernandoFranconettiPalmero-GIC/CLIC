# --- Lee un dotEnv y crea un hashTable a partir del mismo ---
function Read-DotEnv {

    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "El archivo '$Path' no existe."
    }

    $envTable = @{}

    foreach ($line in Get-Content $Path) {

        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("#")) {
            continue
        }

        if ($line -match "^\s*[^=\s]+\=[^=\s].*$") {

            $parts = $line.Split("=", 2)
            $key   = $parts[0]
            $value = $parts[1]

            $envTable[$key] = $value
        }
        else {
            Write-Warning "Línea inválida (espacios no permitidos): '$line'"
        }
    }

    return $envTable
}

# --- Recoge un hashTable, busca en archivos variables en formato POSIX y las reemplaza ---
function Invoke-TemplateResolve {

    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination,

        [Parameter(Mandatory)]
        [hashtable]$Variable
    )

    if (-not (Test-Path $Source)) {
        New-Item -ItemType Directory -Path $Source -Force | Out-Null
    }

    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    $files = Get-ChildItem -Path $Source -File

    if ($files.Count -eq 0) {
        throw "No se encontraron archivos en el directorio de origen: $Source"
    }

    foreach ($file in $files) {

        $targetFile = Join-Path $Destination $file.Name

        $content = Get-Content $file.FullName -Raw

        foreach ($key in $Variable.Keys) {
            $content = $content -replace "\$\{$key\}", [string]$Variable[$key]
        }

        [System.IO.File]::WriteAllText(
            $targetFile,
            ($content.Replace("`r`n","`n")),
            (New-Object System.Text.UTF8Encoding($false))
        )

    }
}

# --- Exporta las funciones para poder utilizarlas ---
Export-ModuleMember -Function Read-DotEnv, Invoke-TemplateResolve