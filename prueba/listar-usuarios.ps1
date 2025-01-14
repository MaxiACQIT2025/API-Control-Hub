# Función para listar usuarios y sus grupos
function Listar-Usuarios-Con-Grupos {
    $searchBase = "OU=OU_TEST,DC=ACQ,DC=IT"
    
    try {
        # Obtener los usuarios de la OU específica
        $usuarios = Get-ADUser -Filter * -SearchBase $searchBase -Properties MemberOf | Select-Object Name, SamAccountName, MemberOf

        # Crear un objeto de resultado con la información de usuarios y grupos
        $usuariosConGrupos = @()
        foreach ($usuario in $usuarios) {
            $grupos = @()

            # Si el usuario pertenece a grupos, convertir los DN a nombres de grupos legibles
            if ($usuario.MemberOf) {
                foreach ($dn in $usuario.MemberOf) {
                    $nombreGrupo = (Get-ADGroup -Identity $dn).Name
                    $grupos += $nombreGrupo
                }
            }

            # Agregar el usuario y sus grupos al resultado
            $usuariosConGrupos += [pscustomobject]@{
                Name           = $usuario.Name
                SamAccountName = $usuario.SamAccountName
                Groups         = $grupos
            }
        }

        # Crear el objeto final de resultado
        $resultado = [pscustomobject]@{
            Status  = "Success"
            Message = "Usuarios y grupos cargados exitosamente."
            Data    = $usuariosConGrupos
        }
    }
    catch {
        # Manejar errores y devolver un objeto con el mensaje de error
        $resultado = [pscustomobject]@{
            Status  = "Error"
            Message = "Error al listar usuarios y grupos: $_"
            Data    = @()
        }
    }

    # Convertir el resultado a JSON sin saltos de línea ni espacios adicionales
    $resultado | ConvertTo-Json -Depth 3 -Compress
}

# Llamar a la función
Listar-Usuarios-Con-Grupos


