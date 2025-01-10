# Función para listar todos los grupos disponibles
function Listar-Grupos {
    Write-Host "Cargando grupos disponibles..." -ForegroundColor Cyan
    $grupos = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
    for ($i = 0; $i -lt $grupos.Count; $i++) {
        Write-Host "$($i + 1). $($grupos[$i])"
    }
    return $grupos
}

# Función para listar todos los usuarios disponibles
function Listar-Usuarios {
    Write-Host "Cargando usuarios disponibles..." -ForegroundColor Cyan
    $usuarios = Get-ADUser -Filter * | Select-Object Name, SamAccountName
    for ($i = 0; $i -lt $usuarios.Count; $i++) {
        Write-Host "$($i + 1). $($usuarios[$i].Name) [$($usuarios[$i].SamAccountName)]"
    }
    return $usuarios
}

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

# Función para obtener los grupos de un usuario
function Obtener-GruposUsuario {
    param (
        [Parameter(Mandatory=$true)][string]$SamAccountName
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

# Función para alta de usuario con selección de OU y opción de volver atrás
function Alta-Usuario {
    Write-Host "=== Crear un nuevo usuario ===" -ForegroundColor Cyan

    # Selección de OU
    do {
        Write-Host "Selecciona la carpeta organizativa (OU) para el nuevo usuario:"
        $resultado = Listar-OU
        $ous = $resultado[0]  # Lista completa de objetos OU (incluye DistinguishedName)
        $ouNombres = $resultado[1]  # Solo los nombres limpios de las OUs
        Write-Host "0. Volver atrás"
        $opcionOU = Read-Host "Elige una OU para el usuario (número o 0 para volver atrás)"
        if ($opcionOU -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        }
        if ($opcionOU -match '^\d+$' -and $opcionOU -le $ouNombres.Count) {
            $ouSeleccionada = $ous[$opcionOU - 1].DistinguishedName
            Write-Host "OU seleccionada: $($ouNombres[$opcionOU - 1])" -ForegroundColor Green
            break
        } else {
            Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
        }
    } while ($true)

    # Copiar permisos de usuario
    do {
        Write-Host "¿Deseas copiar permisos de un usuario existente? (s/n)"
        Write-Host "0. Volver atrás"
        $copiarPermisos = Read-Host "Elige una opción"
        if ($copiarPermisos -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        } elseif ($copiarPermisos -eq "s") {
            $usuarios = Listar-Usuarios
            Write-Host "0. Volver atrás"
            $opcionUsuario = Read-Host "Elige un usuario para copiar permisos (número o 0 para volver atrás)"
            if ($opcionUsuario -eq "0") {
                Write-Host "Volviendo atrás..." -ForegroundColor Yellow
                return
            }
            if ($opcionUsuario -match '^\d+$' -and $opcionUsuario -le $usuarios.Count) {
                $usuarioSeleccionado = $usuarios[$opcionUsuario - 1]
                Write-Host "Has seleccionado a $($usuarioSeleccionado.Name)." -ForegroundColor Green
                $gruposACopiar = Obtener-GruposUsuario -SamAccountName $usuarioSeleccionado.SamAccountName
                break
            } else {
                Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
            }
        } elseif ($copiarPermisos -eq "n") {
            $gruposACopiar = @()
            Write-Host "No se copiarán permisos." -ForegroundColor Yellow
            break
        } else {
            Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
        }
    } while ($true)

    # Datos del nuevo usuario
    do {
        $nombre = Read-Host "Ingresa el nombre del usuario (o 0 para volver atrás)"
        if ($nombre -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        }
        $apellido = Read-Host "Ingresa el apellido del usuario (o 0 para volver atrás)"
        if ($apellido -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        }
        $usuario = Read-Host "Ingresa el nombre de usuario para servidores (formato: dominio\\usuario, o 0 para volver atrás)"
        if ($usuario -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        }
        $correo = Read-Host "Ingresa el correo electrónico del usuario (o 0 para volver atrás)"
        if ($correo -eq "0") {
            Write-Host "Volviendo atrás..." -ForegroundColor Yellow
            return
        }
        break
    } while ($true)

    # Confirmación
    Write-Host "Datos ingresados:"
    Write-Host "Nombre: $nombre $apellido"
    Write-Host "Correo: $correo"
    Write-Host "Usuario: $usuario"
    Write-Host "OU: $ouSeleccionada"
    if ($gruposACopiar.Count -gt 0) {
        Write-Host "Grupos a los que será asignado:"
        $gruposACopiar | ForEach-Object { Write-Host "- $_" }
    } else {
        Write-Host "El usuario no será asignado a ningún grupo inicialmente." -ForegroundColor Yellow
    }
    $confirmar = Read-Host "¿Deseas continuar con la creación? (s/n o 0 para volver atrás)"
    if ($confirmar -eq "0") {
        Write-Host "Volviendo atrás..." -ForegroundColor Yellow
        return
    }
    if ($confirmar -ne "s") {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }

    # Crear usuario
    $password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
    New-ADUser -Name "$nombre $apellido" `
               -GivenName $nombre `
               -Surname $apellido `
               -SamAccountName $usuario.Split("\")[-1] `
               -UserPrincipalName $correo `
               -AccountPassword $password `
               -Path $ouSeleccionada `
               -Enabled $true `
               -ChangePasswordAtLogon $true

    # Asignar grupos
    foreach ($grupo in $gruposACopiar) {
        Add-ADGroupMember -Identity $grupo -Members $usuario.Split("\")[-1]
    }

    Write-Host "Usuario creado exitosamente." -ForegroundColor Green
}

# Función para baja de usuario
function Baja-Usuario {
    Write-Host "=== Dar de baja un usuario ===" -ForegroundColor Cyan

    # Listar usuarios y elegir uno
    $usuarios = Listar-Usuarios
    Write-Host "0. Volver atrás"
    $opcionUsuario = Read-Host "Elige un usuario para dar de baja (número o 0 para volver atrás)"
    if ($opcionUsuario -eq "0") {
        Write-Host "Volviendo atrás..." -ForegroundColor Yellow
        return
    }
    if ($opcionUsuario -match '^\d+$' -and $opcionUsuario -le $usuarios.Count) {
        $usuarioSeleccionado = $usuarios[$opcionUsuario - 1]
    } else {
        Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
        return
    }

    # Confirmar y deshabilitar usuario
    $confirmar = Read-Host "¿Deseas deshabilitar a $($usuarioSeleccionado.Name)? (s/n)"
    if ($confirmar -ne "s") {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }

    Disable-ADAccount -Identity $usuarioSeleccionado.SamAccountName
    Write-Host "Usuario $($usuarioSeleccionado.Name) deshabilitado." -ForegroundColor Green
}

# Función para modificar usuario
function Modificar-Usuario {
    Write-Host "=== Modificar un usuario ===" -ForegroundColor Cyan

    # Listar usuarios y elegir uno
    $usuarios = Listar-Usuarios
    Write-Host "0. Volver atrás"
    $opcionUsuario = Read-Host "Elige un usuario para modificar (número o 0 para volver atrás)"
    if ($opcionUsuario -eq "0") {
        Write-Host "Volviendo atrás..." -ForegroundColor Yellow
        return
    }
    if ($opcionUsuario -match '^\d+$' -and $opcionUsuario -le $usuarios.Count) {
        $usuarioSeleccionado = $usuarios[$opcionUsuario - 1]
    } else {
        Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
        return
    }

    # Opciones de modificación
    Write-Host "¿Qué deseas modificar?"
    Write-Host "1. Resetear contraseña"
    Write-Host "2. Cambiar grupo"
    Write-Host "0. Volver atrás"
    $opcion = Read-Host "Elige una opción (1-2 o 0 para volver atrás)"
    if ($opcion -eq "0") {
        Write-Host "Volviendo atrás..." -ForegroundColor Yellow
        return
    }
    switch ($opcion) {
        1 {
            $password = Read-Host "Ingresa la nueva contraseña para $($usuarioSeleccionado.Name)"
            $passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
            Set-ADAccountPassword -Identity $usuarioSeleccionado.SamAccountName -NewPassword $passwordSecure -Reset
            Write-Host "Contraseña reseteada correctamente." -ForegroundColor Green
        }
        2 {
            Write-Host "Selecciona el nuevo grupo:"
            $grupos = Listar-Grupos
            Write-Host "0. Volver atrás"
            $opcionGrupo = Read-Host "Elige un grupo (número o 0 para volver atrás)"
            if ($opcionGrupo -eq "0") {
                Write-Host "Volviendo atrás..." -ForegroundColor Yellow
                return
            }
            if ($opcionGrupo -match '^\d+$' -and $opcionGrupo -le $grupos.Count) {
                $grupoSeleccionado = $grupos[$opcionGrupo - 1]
                Add-ADGroupMember -Identity $grupoSeleccionado -Members $usuarioSeleccionado.SamAccountName
                Write-Host "Usuario asignado al grupo $grupoSeleccionado." -ForegroundColor Green
            } else {
                Write-Host "Opción no válida. Intenta de nuevo." -ForegroundColor Red
            }
        }
    }
}

# Menú principal
function Menu-Principal {
    do {
        Write-Host "=== Gestión de Active Directory ===" -ForegroundColor Cyan
        Write-Host "1. Alta de usuario"
        Write-Host "2. Baja de usuario"
        Write-Host "3. Modificar usuario"
        Write-Host "4. Salir"

        $opcion = Read-Host "Elige una opción (1-4)"
        switch ($opcion) {
            1 { Alta-Usuario }
            2 { Baja-Usuario }
            3 { Modificar-Usuario }
            4 { Write-Host "Saliendo..." -ForegroundColor Yellow; break }
            Default { Write-Host "Opción no válida." -ForegroundColor Red }
        }
    } while ($true)
}

# Ejecutar el menú principal
Menu-Principal
