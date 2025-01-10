# Función para listar todos los usuarios disponibles en la OU específica
function Listar-Usuarios {
    Write-Host "Cargando usuarios disponibles en OU=OU_TEST,DC=ACQ,DC=IT..." -ForegroundColor Cyan
    $searchBase = "OU=OU_TEST,DC=ACQ,DC=IT"
    
    # Obtener los usuarios de la OU específica
    $usuarios = Get-ADUser -Filter * -SearchBase $searchBase | Select-Object Name, SamAccountName

    # Mostrar los usuarios en la consola
    for ($i = 0; $i -lt $usuarios.Count; $i++) {
        Write-Host "$($i + 1). $($usuarios[$i].Name) [$($usuarios[$i].SamAccountName)]"
    }

    # Devolver los usuarios como resultado de la función
    return $usuarios
}

# Llamar a la función y convertir el resultado a JSON
Listar-Usuarios | ConvertTo-Json -Depth 2
