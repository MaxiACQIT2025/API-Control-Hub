<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class UsuariosBase extends Controller
{
    public function index()
    {
        try {
            // Obtener todos los usuarios de la tabla 'users'
            $users = User::all();

            return response()->json($users, 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error al obtener los usuarios',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

}
