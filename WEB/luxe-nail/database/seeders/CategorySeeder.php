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
            ['name' => 'Natural Round', 'type' => 'shape', 'price' => 0, 'code' => 'SHP-001', 'image' => 'img/kategori/ai_shape/1764524358_Natural Round.jpg'],
            ['name' => 'Soft Square', 'type' => 'shape', 'price' => 0, 'code' => 'SHP-002', 'image' => 'img/kategori/ai_shape/1764524629_Soft Square.jpg'],
            ['name' => 'Oval', 'type' => 'shape', 'price' => 10000, 'code' => 'SHP-003', 'image' => 'img/kategori/ai_shape/1764524575_Oval.jpg'],
            
            // COLOR (Standard)
            ['name' => 'Classic Red', 'type' => 'color', 'price' => 15000, 'code' => 'COL-001', 'image' => 'img/kategori/ai_color/1764524648_1763639320_CL-merah.png'],
            ['name' => 'Nude Pink', 'type' => 'color', 'price' => 15000, 'code' => 'COL-002', 'image' => 'img/kategori/ai_color/1764500701_1763639576_CL-pink.png'],
            ['name' => 'Midnight Blue', 'type' => 'color', 'price' => 15000, 'code' => 'COL-003', 'image' => 'img/kategori/ai_color/1764525140_Midnight Blue.jpg'],
            ['name' => 'Pure Black', 'type' => 'color', 'price' => 15000, 'code' => 'COL-004', 'image' => 'img/kategori/ai_color/1764524897_Pure Black.jpg'],
            ['name' => 'White', 'type' => 'color', 'price' => 15000, 'code' => 'COL-005', 'image' => 'img/kategori/ai_color/1764525025_White.jpg'],

            // FINISH (Basic)
            ['name' => 'Glossy', 'type' => 'finish', 'price' => 10000, 'code' => 'FIN-001', 'image' => 'img/kategori/ai_finish/1764525045_1763639194_NT-glossy.jpeg'],
            ['name' => 'Matte', 'type' => 'finish', 'price' => 15000, 'code' => 'FIN-002', 'image' => 'img/kategori/ai_finish/1764525056_1763639135_NT-matte.jpeg'],

            // ACCESSORY (Simple)
            ['name' => 'Simple Glitter', 'type' => 'accessory', 'price' => 20000, 'code' => 'ACC-001', 'image' => 'img/kategori/ai_accessories/1764525266_Simple Glitter.jpg'],
            ['name' => 'Minimalist Line', 'type' => 'accessory', 'price' => 25000, 'code' => 'ACC-002', 'image' => 'img/kategori/ai_accessories/1764525327_Minimalist Line.jpg'],
            ['name' => 'Small Sticker', 'type' => 'accessory', 'price' => 15000, 'code' => 'ACC-003', 'image' => 'img/kategori/ai_accessories/1764525389_Small Sticker.jpg'],
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
            ['name' => 'Coffin (Ballerina)', 'type' => 'shape', 'price' => 50000, 'code' => 'SHP-EXT-001', 'image' => 'img/kategori/ai_shape/1764510587_1763637865_NS-coffin.jpg'],
            ['name' => 'Stiletto', 'type' => 'shape', 'price' => 60000, 'code' => 'SHP-EXT-002', 'image' => 'img/kategori/ai_shape/1764511981_1763638346_NS-stiletto.jpg'],
            ['name' => 'Almond', 'type' => 'shape', 'price' => 45000, 'code' => 'SHP-EXT-003', 'image' => 'img/kategori/ai_shape/1764512062_1763638147_NS-almond.jpeg'],
            ['name' => 'Russian Almond', 'type' => 'shape', 'price' => 75000, 'code' => 'SHP-EXT-004', 'image' => 'img/kategori/ai_shape/1764522342_Russian_Almond.jpg'],

            // COLOR (Premium / Metallic / Gel)
            ['name' => 'Royal Gold', 'type' => 'color', 'price' => 50000, 'code' => 'COL-EXT-001', 'image' => 'img/kategori/ai_color/1764520504_CL-metallic_gold.png'],
            ['name' => 'Platinum Silver', 'type' => 'color', 'price' => 50000, 'code' => 'COL-EXT-002', 'image' => 'img/kategori/ai_color/1764520775_Platinum_Silver.png'],
            ['name' => 'Deep Emerald', 'type' => 'color', 'price' => 45000, 'code' => 'COL-EXT-003', 'image' => 'img/kategori/ai_color/1764520686_Black_Emerald.png'],
            ['name' => 'Burgundy Wine', 'type' => 'color', 'price' => 45000, 'code' => 'COL-EXT-004', 'image' => 'img/kategori/ai_color/1764521019_burgundy-wine.png'],
            ['name' => 'Rose Gold', 'type' => 'color', 'price' => 55000, 'code' => 'COL-EXT-005', 'image' => 'img/kategori/ai_color/1764520461_CL-rose_gold.png'],

            // FINISH (High-End)
            ['name' => 'Holographic', 'type' => 'finish', 'price' => 60000, 'code' => 'FIN-EXT-001', 'image' => 'img/kategori/ai_finish/1764522453_Holographic.jpg'],
            ['name' => 'Chrome Powder', 'type' => 'finish', 'price' => 65000, 'code' => 'FIN-EXT-002', 'image' => 'img/kategori/ai_finish/1764522513_Chrome Powder.jpg'],
            ['name' => 'Cat Eye 9D', 'type' => 'finish', 'price' => 75000, 'code' => 'FIN-EXT-003', 'image' => 'img/kategori/ai_finish/1764522787_Cat Eye 9D.jpg'],
            ['name' => 'Velvet Touch', 'type' => 'finish', 'price' => 55000, 'code' => 'FIN-EXT-004', 'image' => 'img/kategori/ai_finish/1764523177_Velvet Touch.jpg'],

            // ACCESSORY (Luxury)
            ['name' => 'Swarovski Crystals', 'type' => 'accessory', 'price' => 150000, 'code' => 'ACC-EXT-001', 'image' => 'img/kategori/ai_accessories/1764522173_Swarovski Crystals.jpg'],
            ['name' => '3D Acrylic Flower', 'type' => 'accessory', 'price' => 85000, 'code' => 'ACC-EXT-002', 'image' => 'img/kategori/ai_accessories/1764523436_1763639446_AC-bunga.jpg'],
            ['name' => 'Gold Foil Flakes', 'type' => 'accessory', 'price' => 45000, 'code' => 'ACC-EXT-003', 'image' => 'img/kategori/ai_accessories/1764523590_Gold Foil Flakes.jpg'],
            ['name' => 'Genuine Pearls', 'type' => 'accessory', 'price' => 100000, 'code' => 'ACC-EXT-004', 'image' => 'img/kategori/ai_accessories/1764523745_1763639471_AC-pearl.jpeg'],
            ['name' => 'Encapsulated Art', 'type' => 'accessory', 'price' => 120000, 'code' => 'ACC-EXT-005', 'image' => 'img/kategori/ai_accessories/1764524032_Encapsulated Art.jpg'],
        ];

        foreach ($extCategories as $cat) {
            Category::updateOrCreate(
                ['code' => $cat['code']],
                array_merge($cat, ['treatment_type_id' => $nailExt->id])
            );
        }
    }
}
