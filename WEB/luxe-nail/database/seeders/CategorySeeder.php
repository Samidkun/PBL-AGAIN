<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\TreatmentType;

class CategorySeeder extends Seeder
{
    public function run()
    {
        // 1. Get Treatment Types
        $nailArt = TreatmentType::where('name', 'nail_art')->first();
        $nailExt = TreatmentType::where('name', 'nail_extension')->first();

        if (!$nailArt || !$nailExt) {
            $this->command->error('Treatment Types not found. Please run TreatmentTypeSeeder first.');
            return;
        }

        // ==========================================
        // NAIL ART (STANDARD / CASUAL)
        // ==========================================
        $artCategories = [
            // SHAPE (Basic)
            ['name' => 'Natural Round', 'type' => 'shape', 'price' => 0, 'code' => 'SHP-001'],
            ['name' => 'Soft Square', 'type' => 'shape', 'price' => 0, 'code' => 'SHP-002'],
            ['name' => 'Oval', 'type' => 'shape', 'price' => 10000, 'code' => 'SHP-003'],
            
            // COLOR (Standard)
            ['name' => 'Classic Red', 'type' => 'color', 'price' => 15000, 'code' => 'COL-001'],
            ['name' => 'Nude Pink', 'type' => 'color', 'price' => 15000, 'code' => 'COL-002'],
            ['name' => 'Midnight Blue', 'type' => 'color', 'price' => 15000, 'code' => 'COL-003'],
            ['name' => 'Pure Black', 'type' => 'color', 'price' => 15000, 'code' => 'COL-004'],
            ['name' => 'White', 'type' => 'color', 'price' => 15000, 'code' => 'COL-005'],

            // FINISH (Basic)
            ['name' => 'Glossy', 'type' => 'finish', 'price' => 10000, 'code' => 'FIN-001'],
            ['name' => 'Matte', 'type' => 'finish', 'price' => 15000, 'code' => 'FIN-002'],

            // ACCESSORY (Simple)
            ['name' => 'Simple Glitter', 'type' => 'accessory', 'price' => 20000, 'code' => 'ACC-001'],
            ['name' => 'Minimalist Line', 'type' => 'accessory', 'price' => 25000, 'code' => 'ACC-002'],
            ['name' => 'Small Sticker', 'type' => 'accessory', 'price' => 15000, 'code' => 'ACC-003'],
        ];

        foreach ($artCategories as $cat) {
            Category::updateOrCreate(
                ['code' => $cat['code']],
                array_merge($cat, ['treatment_type_id' => $nailArt->id])
            );
        }

        // ==========================================
        // NAIL EXTENSION (LUXURY / PREMIUM)
        // ==========================================
        $extCategories = [
            // SHAPE (Premium)
            ['name' => 'Coffin (Ballerina)', 'type' => 'shape', 'price' => 50000, 'code' => 'SHP-EXT-001'],
            ['name' => 'Stiletto', 'type' => 'shape', 'price' => 60000, 'code' => 'SHP-EXT-002'],
            ['name' => 'Almond', 'type' => 'shape', 'price' => 45000, 'code' => 'SHP-EXT-003'],
            ['name' => 'Russian Almond', 'type' => 'shape', 'price' => 75000, 'code' => 'SHP-EXT-004'],

            // COLOR (Premium / Metallic / Gel)
            ['name' => 'Royal Gold', 'type' => 'color', 'price' => 50000, 'code' => 'COL-EXT-001'],
            ['name' => 'Platinum Silver', 'type' => 'color', 'price' => 50000, 'code' => 'COL-EXT-002'],
            ['name' => 'Deep Emerald', 'type' => 'color', 'price' => 45000, 'code' => 'COL-EXT-003'],
            ['name' => 'Burgundy Wine', 'type' => 'color', 'price' => 45000, 'code' => 'COL-EXT-004'],
            ['name' => 'Rose Gold', 'type' => 'color', 'price' => 55000, 'code' => 'COL-EXT-005'],

            // FINISH (High-End)
            ['name' => 'Holographic', 'type' => 'finish', 'price' => 60000, 'code' => 'FIN-EXT-001'],
            ['name' => 'Chrome Powder', 'type' => 'finish', 'price' => 65000, 'code' => 'FIN-EXT-002'],
            ['name' => 'Cat Eye 9D', 'type' => 'finish', 'price' => 75000, 'code' => 'FIN-EXT-003'],
            ['name' => 'Velvet Touch', 'type' => 'finish', 'price' => 55000, 'code' => 'FIN-EXT-004'],

            // ACCESSORY (Luxury)
            ['name' => 'Swarovski Crystals', 'type' => 'accessory', 'price' => 150000, 'code' => 'ACC-EXT-001'],
            ['name' => '3D Acrylic Flower', 'type' => 'accessory', 'price' => 85000, 'code' => 'ACC-EXT-002'],
            ['name' => 'Gold Foil Flakes', 'type' => 'accessory', 'price' => 45000, 'code' => 'ACC-EXT-003'],
            ['name' => 'Genuine Pearls', 'type' => 'accessory', 'price' => 100000, 'code' => 'ACC-EXT-004'],
            ['name' => 'Encapsulated Art', 'type' => 'accessory', 'price' => 120000, 'code' => 'ACC-EXT-005'],
        ];

        foreach ($extCategories as $cat) {
            Category::updateOrCreate(
                ['code' => $cat['code']],
                array_merge($cat, ['treatment_type_id' => $nailExt->id])
            );
        }
    }
}
