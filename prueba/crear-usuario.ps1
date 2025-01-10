param (
    [string]$JsonInput
)

# Establecer la codificación de salida en UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Deserializar el JSON recibido
$datos = $JsonInput | ConvertFrom-Json

Write-Host "Contenido deserializado del JSON:"
Write-Host ($datos | ConvertTo-Json -Depth 2)

# Validar y asignar valores con valores por defecto si son nulos
$cn = if ($datos.cn) { $datos.cn } else { "Holi" }
$sAMAccountName = if ($datos.sAMAccountName) { $datos.sAMAccountName } else { "Holi" }
$userPrincipalName = if ($datos.userPrincipalName) { $datos.userPrincipalName } else { "$sAMAccountName@acq.it" }
$password = if ($datos.password) { $datos.password } else { "Password123!" }
$distinguishedName = if ($datos.distinguishedName) { $datos.distinguishedName } else { "OU=OU_TEST,DC=ACQ,DC=IT" }
$mail = if ($datos.mail) { $datos.mail } else { "sincorreo@acq.it" }
$department = if ($datos.department) { $datos.department } else { "Sin Departamento" }
$title = if ($datos.title) { $datos.title } else { "Sin Título" }
$userAccountControl = if ($datos.userAccountControl) { $datos.userAccountControl } else { 512 }

Write-Host "Datos ingresados:"
Write-Host "Nombre completo (cn): $cn"
Write-Host "sAMAccountName: $sAMAccountName"
Write-Host "Correo (userPrincipalName): $userPrincipalName"
Write-Host "Distinguished Name: $distinguishedName"
Write-Host "Departamento: $department"
Write-Host "Título: $title"

# Convertir la contraseña en un objeto seguro
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Crear el usuario en Active Directory
try {
    New-ADUser -Name $cn `
               -SamAccountName $sAMAccountName `
               -UserPrincipalName $userPrincipalName `
               -GivenName $givenName `
               -Surname $sn `
               -DisplayName $displayName `
               -AccountPassword $securePassword `
               -Path $distinguishedName `
               -Enabled $true `
               -ChangePasswordAtLogon $true `
               -EmailAddress $mail `
               -Department $department `
               -Title $title

    # Establecer UserAccountControl después de crear el usuario
    Set-ADUser -Identity $sAMAccountName -Replace @{userAccountControl = $userAccountControl}

    Write-Host "Usuario creado exitosamente." -ForegroundColor Green

    $resultado = [pscustomobject]@{
        Status  = "Success"
        Message = "Usuario creado exitosamente."
        Data    = $datos
    }
    return $resultado
}
catch {
    Write-Host "Error al crear el usuario: $_" -ForegroundColor Red

    $resultado = [pscustomobject]@{
        Status  = "Error"
        Message = "Error al crear el usuario: $_"
        Data    = $datos
    }
    return $resultado
}



