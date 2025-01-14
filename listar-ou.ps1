# Función para listar las OU disponibles mostrando solo sus nombres
function Listar-OU {
    Write-Host "Cargando unidades organizativas disponibles..." -ForegroundColor Cyan
    $ous = Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName
    $ouNombres = @()

    # Extraer solo el nombre de la OU del DistinguishedName
    foreach ($ou in $ous) {
        $nombreOU = ($ou.DistinguishedName -split ',')[0] -replace '^OU=', ''
        $ouNombres += $nombreOU
    }

    # Mostrar las OUs con sus índices
    for ($i = 0; $i -lt $ouNombres.Count; $i++) {
        Write-Host "$($i + 1). $($ouNombres[$i])"
    }
    return $ous, $ouNombres
}

# Llamar a la función y convertir el resultado a JSON
Listar-OU | ConvertTo-Json -Depth 2