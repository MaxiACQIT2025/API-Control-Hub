<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\usuariosAD;
use App\Http\Controllers\UsuariosBase;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::get('/usersBase', [UsuariosBase::class, 'index']);

Route::put('/ad/users/{user}', [UsuariosAD::class, 'disableUser']); // deshabilitar usuario

Route::post('/ad/users', [UsuariosAD::class, 'createUser']); // Alta

Route::get('/ad/users', [UsuariosAD::class, 'listUsers']); // listar usuarios


//Route::put('/ad/users/{username}', [UsuariosAD::class, 'update']); // Modificación
//Route::delete('/ad/users/{username}', [UsuariosAD::class, 'destroy']); // Baja

Route::get('/ad/groups', [UsuariosAD::class, 'listGroups']); // listar grupos

Route::get('/ad/ou', [UsuariosAD::class, 'listOU']); // listar OU

Route::get('/ad/user-groups/{sam_account_name}', [UsuariosAD::class, 'gruposPorUsuario']); // Obtener grupos por usuario


