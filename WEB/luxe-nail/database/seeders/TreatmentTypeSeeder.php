<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\TreatmentType;

class TreatmentTypeSeeder extends Seeder
{
    public function run()
    {
        TreatmentType::updateOrCreate(
            ['name' => 'nail_extension'],
            [
                'description' => 'Full set nail extension',
                'duration' => 120, // 2 Jam
                'is_active' => true
            ]
        );

        TreatmentType::updateOrCreate(
            ['name' => 'nail_art'],
            [
                'description' => 'Custom nail art design',
                'duration' => 90, // 1.5 Jam
                'is_active' => true
            ]
        );
    }
}