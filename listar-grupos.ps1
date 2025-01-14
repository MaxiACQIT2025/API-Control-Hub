# Función para listar todos los grupos disponibles
function Listar-Grupos {
    Write-Host "Cargando grupos disponibles..." -ForegroundColor Cyan
    $grupos = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
    for ($i = 0; $i -lt $grupos.Count; $i++) {
        Write-Host "$($i + 1). $($grupos[$i])"
    }
    return $grupos
}

# Llamar a la función y convertir el resultado a JSON
Listar-Grupos | ConvertTo-Json -Depth 2