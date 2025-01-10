<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use LdapRecord\Models\ActiveDirectory\User as LdapUser;

class usuariosAD extends Controller
{   

    /**
     * Ejecuta un script de PowerShell para listar usuarios en Active Directory.
     */
    public function listUsers()
    {
        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\listar-usuarios.ps1';

        // Comando para ejecutar el script de PowerShell
        $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath";

        // Ejecutar el comando y capturar la salida
        $output = shell_exec($command);

        // Verificar si hubo un error
        if (empty($output)) {
            return response()->json(['error' => 'No se pudo listar los usuarios o el script no devolvió resultados'], 500);
        }

        // Convertir la salida en un array (si la salida es JSON desde PowerShell)
        $users = json_decode($output, true);

        // Verificar si la conversión fue exitosa
        if (json_last_error() === JSON_ERROR_NONE) {
            return response()->json(['users' => $users], 200);
        }

        // Si la salida no es JSON, devolverla como texto plano
        return response()->json(['output' => $output], 200);
    }

    /**
     * Ejecuta un script de PowerShell para listar grupos en Active Directory.
     */
    public function listGroups()
    {
        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\listar-grupos.ps1';

        // Comando para ejecutar el script de PowerShell
        $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath";

        // Ejecutar el comando y capturar la salida
        $output = shell_exec($command);

        // Verificar si hubo un error
        if (empty($output)) {
            return response()->json(['error' => 'No se pudo listar los grupos o el script no devolvió resultados'], 500);
        }

        // Convertir la salida en un array (si la salida es JSON desde PowerShell)
        $groups = json_decode($output, true);

        // Verificar si la conversión fue exitosa
        if (json_last_error() === JSON_ERROR_NONE) {
            return response()->json(['groups' => $groups], 200);
        }

        // Si la salida no es JSON, devolverla como texto plano
        return response()->json(['output' => $output], 200);
    }

    /**
     * Ejecuta un script de PowerShell para listar OU en Active Directory.
     */
    public function listOU()
    {
        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\listar-ou.ps1';

        // Comando para ejecutar el script de PowerShell
        $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath";

        // Ejecutar el comando y capturar la salida
        $output = shell_exec($command);

        // Verificar si hubo un error
        if (empty($output)) {
            return response()->json(['error' => 'No se pudo listar los OU o el script no devolvió resultados'], 500);
        }

        // Convertir la salida en un array (si la salida es JSON desde PowerShell)
        $ou = json_decode($output, true);

        // Verificar si la conversión fue exitosa
        if (json_last_error() === JSON_ERROR_NONE) {
            return response()->json(['ou' => $ou], 200);
        }

        // Si la salida no es JSON, devolverla como texto plano
        return response()->json(['output' => $output], 200);
    }

    /**
     * Ejecuta un script de PowerShell para Obtener grupos por usuario.
     */
    public function gruposPorUsuario(Request $request)
    {
        // Validar que se reciba el parámetro necesario
        $request->validate([
            'sam_account_name' => 'required|string'
        ]);

        dd($sam_account_name);

        // Obtener el SamAccountName del request
        $samAccountName = $request->input('sam_account_name');

        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\obtener-grupos-usuario.ps1';

        // Comando para ejecutar el script de PowerShell con el parámetro
        $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -SamAccountName $samAccountName";

        // Ejecutar el comando y capturar la salida y errores
        $output = shell_exec($command . ' 2>&1');

        // Verificar si hubo un error en la ejecución del script
        if (empty($output)) {
            return response()->json(['error' => 'No se pudo obtener los grupos del usuario o el script no devolvió resultados'], 500);
        }

        // Convertir la salida en un array (si es JSON válido)
        $groups = json_decode($output, true);

        // Si la salida no es JSON, devolverla como texto plano para depuración
        return response()->json(['output' => $output], 200);
    }


    /**
     * Ejecuta un script de PowerShell para realizar acciones en Active Directory.
     */
    public function manageUser(Request $request)
    {
        // Validar la entrada
        $request->validate([
            'action' => 'required|string|in:create,update,delete',
            'username' => 'required|string',
            'password' => 'nullable|string', // Solo requerido para 'create'
            'ou' => 'nullable|string', // Requerido para 'create'
        ]);

        // Obtener los parámetros de la solicitud
        $action = $request->input('action');
        $username = $request->input('username');
        $password = $request->input('password', '');
        $ou = $request->input('ou', '');

        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\activedirectory.ps1';

        // Comando para ejecutar el script de PowerShell
        $command = "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Action $action -Username $username";

        // Agregar parámetros opcionales según la acción
        if ($action === 'create') {
            $command .= " -Password $password -OU $ou";
        }

        // Ejecutar el comando y capturar la salida
        $output = shell_exec($command);

        // Verificar si hubo un error
        if (strpos($output, 'successfully') !== false) {
            return response()->json(['message' => $output], 200);
        }

        return response()->json(['error' => 'Error executing PowerShell script', 'output' => $output], 500);
    }

    public function createUser(Request $request)
    {
        // Validar los datos del formulario
        $request->validate([
            'cn' => 'required|string|max:100',
            'sAMAccountName' => 'required|string|max:50',
            'userPrincipalName' => 'required|email|max:100',
            'givenName' => 'required|string|max:50',
            'sn' => 'required|string|max:50',
            'displayName' => 'required|string|max:100',
            'userAccountControl' => 'required|integer',
            'password' => 'required|string|min:8',
            'distinguishedName' => 'required|string|max:255',
            'mail' => 'required|email|max:100',
            'department' => 'nullable|string|max:50',
            'title' => 'nullable|string|max:50',
        ]);

        // Generar el JSON desde el request
        $jsonData = json_encode($request->all(), JSON_UNESCAPED_UNICODE);

        // Escapar el JSON para pasarlo como parámetro en línea de comandos
        $escapedJsonData = escapeshellarg($jsonData);

        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\crear-usuario.ps1';

        // Construir el comando para ejecutar el script de PowerShell con el JSON como parámetro
        $command = "powershell -ExecutionPolicy Bypass -File \"$scriptPath\" -JsonInput $escapedJsonData";

        // Ejecutar el script de PowerShell
        $output = shell_exec($command);

        // Verificar el resultado de la ejecución
        if ($output) {
            return response()->json([
                'message' => 'Usuario creado exitosamente',
                'output' => $output
            ]);
        } else {
            return response()->json([
                'message' => 'Error al crear el usuario',
                'output' => $output
            ], 500);
        }
    }

    public function disableUser(Request $request, $user)
    {
        //$request->validate([
        //    'identity' => 'required|string|max:255'  // Puede ser sAMAccountName, DN o ObjectGUID
        //]);

        $identity = $user;

        // Ruta del script de PowerShell
        $scriptPath = 'C:\Users\maximiliano.gomez\Desktop\prueba-laravel\prueba\deshabilitar-usuario.ps1';

        // Construir el comando para ejecutar el script de PowerShell
        $command = "powershell -ExecutionPolicy Bypass -File \"$scriptPath\" -Identity $identity";

        // Ejecutar el script de PowerShell
        $output = shell_exec($command);

        // Verificar el resultado de la ejecución
        if (strpos($output, 'Usuario deshabilitado exitosamente') !== false) {
            return response()->json([
                'message' => 'Usuario deshabilitado exitosamente',
                'output' => $output
            ]);
        } else {
            return response()->json([
                'message' => 'Error al deshabilitar el usuario',
                'output' => $output
            ], 500);
        }
    }



}
