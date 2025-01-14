<?php

namespace App\Ldap;

use LdapRecord\Models\ActiveDirectory\User as LdapUser;

class User extends LdapUser
{
    /**
     * Indica si el modelo utiliza timestamps.
     */
    public $timestamps = false;
}
