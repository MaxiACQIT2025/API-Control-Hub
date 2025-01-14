# Definir el parámetro que se recibirá desde Laravel
param (
    [Parameter(Mandatory=$true)][string]$SamAccountName
)

# Función para obtener los grupos de un usuario
function Obtener-GruposUsuario {
    param (
        [string]$SamAccountName
    )
    Write-Host "Obteniendo grupos para $SamAccountName..." -ForegroundColor Cyan
    $grupos = Get-ADUser -Identity $SamAccountName -Property MemberOf | Select-Object -ExpandProperty MemberOf
    if ($null -eq $grupos) {
        Write-Host "El usuario no pertenece a ningún grupo." -ForegroundColor Yellow
        return @()
    }
    $grupoNombres = @()
    foreach ($grupo in $grupos) {
        $grupoNombres += (Get-ADGroup -Identity $grupo).Name
    }
    return $grupoNombres
}

# Llamar a la función y convertir el resultado a JSON
Obtener-GruposUsuario -SamAccountName $SamAccountName | ConvertTo-Json -Depth 2