<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use LdapRecord\Container;

class TestLdapConnection extends Command
{
    protected $signature = 'ldap:test';
    protected $description = 'Prueba la conexión con el servidor LDAP';

    public function __construct()
    {
        parent::__construct();
    }

    public function handle()
    {
        try {
            $connection = Container::getConnection();
            $connection->connect();

            $this->info("Conexión exitosa con Active Directory.");
        } catch (\Exception $e) {
            $this->error("Error en la conexión: " . $e->getMessage());
        }
    }
}
