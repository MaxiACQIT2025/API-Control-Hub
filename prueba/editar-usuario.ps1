param (
    [string]$JsonInput
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Intentar deserializar el JSON recibido
try {
    $datos = $JsonInput | ConvertFrom-Json
} catch {
    Write-Host "Error al deserializar el JSON: $_"
    exit 1
}

# Verificar que el campo 'sAMAccountName' exista (es clave para identificar al usuario)
if (-not $datos.sAMAccountName) {
    Write-Host "Error: No se proporcionó 'sAMAccountName' en el JSON."
    exit 1
}

# Obtener el usuario por sAMAccountName
$usuario = Get-ADUser -Filter { SamAccountName -eq $datos.sAMAccountName } -SearchBase "OU=OU_TEST,DC=ACQ,DC=IT"

if (-not $usuario) {
    Write-Host "Error: No se encontró el usuario con sAMAccountName $($datos.sAMAccountName)."
    exit 1
}

# Crear un hash table con los campos a actualizar
$updates = @{}

if ($datos.cn) { $updates['Name'] = $datos.cn }
if ($datos.userPrincipalName) { $updates['UserPrincipalName'] = $datos.userPrincipalName }
if ($datos.givenName) { $updates['GivenName'] = $datos.givenName }
if ($datos.sn) { $updates['Surname'] = $datos.sn }
if ($datos.displayName) { $updates['DisplayName'] = $datos.displayName }
if ($datos.mail) { $updates['EmailAddress'] = $datos.mail }
if ($datos.department) { $updates['Department'] = $datos.department }
if ($datos.title) { $updates['Title'] = $datos.title }

# Actualizar el usuario si hay campos en el hash table
if ($updates.Count -gt 0) {
    try {
        Set-ADUser -Identity $usuario.DistinguishedName -Replace $updates
        Write-Host "Usuario actualizado exitosamente."

        $resultado = [pscustomobject]@{
            Status  = "Success"
            Message = "Usuario actualizado exitosamente."
            Data    = $updates
        }
    }
    catch {
        Write-Host "Error al actualizar el usuario: $_"
        $resultado = [pscustomobject]@{
            Status  = "Error"
            Message = "Error al actualizar el usuario: $_"
            Data    = $updates
        }
    }
} else {
    Write-Host "No hay campos para actualizar."
    $resultado = [pscustomobject]@{
        Status  = "Warning"
        Message = "No se proporcionaron campos válidos para actualizar."
        Data    = @()
    }
}

# Convertir el resultado a JSON y devolverlo
$resultado | ConvertTo-Json -Depth 3 -Compress
