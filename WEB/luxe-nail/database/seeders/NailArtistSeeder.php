<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\NailArtist;

class NailArtistSeeder extends Seeder
{
    public function run()
    {
        $artists = [
            ['name' => 'Nail Artist A', 'username' => 'artist1'],
            ['name' => 'Nail Artist B', 'username' => 'artist2'],
            ['name' => 'Nail Artist C', 'username' => 'artist3'],
            ['name' => 'Nail Artist D', 'username' => 'artist4'],
        ];

        foreach ($artists as $data) {
            // 1. Create User
            $user = \App\Models\User::create([
                'name'     => $data['name'],
                'username' => $data['username'],
                'email'    => $data['username'] . '@luxenail.com',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role'     => 'nail_artist',
            ]);

            // 2. Create Nail Artist linked to User
            NailArtist::create([
                'user_id'         => $user->id,
                'name'            => $data['name'],
                'status'          => 'available',
                'customers_today' => 0
            ]);
        }
    }
}
