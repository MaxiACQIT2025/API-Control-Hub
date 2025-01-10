param (
    [string]$Identity  # Puede ser el sAMAccountName
)

# Establecer la codificación de salida en UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

try {
    # Buscar al usuario por sAMAccountName
    $usuario = Get-ADUser -Filter {SamAccountName -eq $Identity} -SearchBase "OU=OU_TEST,DC=ACQ,DC=IT"

    if ($usuario -eq $null) {
        throw "No se encontró ningún usuario con SamAccountName '$Identity' en OU=OU_TEST,DC=ACQ,DC=IT."
    }

    # Deshabilitar el usuario usando su Distinguished Name
    Disable-ADAccount -Identity $usuario.DistinguishedName

    Write-Host "Usuario deshabilitado exitosamente." -ForegroundColor Green

    $resultado = [pscustomobject]@{
        Status  = "Success"
        Message = "Usuario deshabilitado exitosamente."
    }
    return $resultado
}
catch {
    Write-Host "Error al deshabilitar el usuario: $_" -ForegroundColor Red

    $resultado = [pscustomobject]@{
        Status  = "Error"
        Message = "Error al deshabilitar el usuario: $_"
    }
    return $resultado
}

