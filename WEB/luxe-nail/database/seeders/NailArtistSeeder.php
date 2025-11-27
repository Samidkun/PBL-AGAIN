<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\NailArtist;

class NailArtistSeeder extends Seeder
{
    public function run()
    {
        $artists = [
            'Nail Artist A',
            'Nail Artist B',
            'Nail Artist C',
            'Nail Artist D',
        ];

        foreach ($artists as $name) {
            NailArtist::create([
                'name' => $name,
                'status' => 'available',
                'customers_today' => 0
            ]);
        }
    }
}
