<?php

namespace Database\Seeders;

use App\Models\TreatmentType;
use App\Models\Category;
use Illuminate\Database\Seeder;

class TreatmentTypeSeeder extends Seeder
{
    public function run()
    {
        // Treatment Types
        $nailExtension = TreatmentType::create([
            'name' => 'Nail Extension', 
            'description' => 'Treatment dengan extension kuku',
            'order' => 1
        ]);

        $nailArt = TreatmentType::create([
            'name' => 'Nail Art', 
            'description' => 'Treatment tanpa extension',
            'order' => 2
        ]);

        // Categories for Nail Extension
        $extensionCategories = [
            // Nail Shapes
            ['name' => 'Coffin', 'type' => 'nail_shape', 'price' => 25000, 'treatment_type_id' => $nailExtension->id, 'order' => 1],
            ['name' => 'Almond', 'type' => 'nail_shape', 'price' => 20000, 'treatment_type_id' => $nailExtension->id, 'order' => 2],
            ['name' => 'Stiletto', 'type' => 'nail_shape', 'price' => 30000, 'treatment_type_id' => $nailExtension->id, 'order' => 3],
            
            // Nail Types
            ['name' => 'Matte', 'type' => 'nail_type', 'price' => 20000, 'treatment_type_id' => $nailExtension->id, 'order' => 1],
            ['name' => 'Glossy', 'type' => 'nail_type', 'price' => 15000, 'treatment_type_id' => $nailExtension->id, 'order' => 2],
            ['name' => 'Cat Eye', 'type' => 'nail_type', 'price' => 35500, 'treatment_type_id' => $nailExtension->id, 'order' => 3],
            
            // Colors
            ['name' => 'Merah', 'type' => 'color', 'price' => 10000, 'treatment_type_id' => $nailExtension->id, 'order' => 1],
            ['name' => 'Pink', 'type' => 'color', 'price' => 10000, 'treatment_type_id' => $nailExtension->id, 'order' => 2],
            
            // Accessories
            ['name' => 'Flower', 'type' => 'accessory', 'price' => 15000, 'treatment_type_id' => $nailExtension->id, 'order' => 1],
            ['name' => 'Pearl', 'type' => 'accessory', 'price' => 10000, 'treatment_type_id' => $nailExtension->id, 'order' => 2],
        ];

        // Categories for Nail Art
        $artCategories = [
            // Nail Types for Nail Art
            ['name' => 'Matte', 'type' => 'nail_type', 'price' => 15000, 'treatment_type_id' => $nailArt->id, 'order' => 1],
            ['name' => 'Glossy', 'type' => 'nail_type', 'price' => 10000, 'treatment_type_id' => $nailArt->id, 'order' => 2],
            
            // Colors for Nail Art
            ['name' => 'Merah', 'type' => 'color', 'price' => 5000, 'treatment_type_id' => $nailArt->id, 'order' => 1],
            ['name' => 'Pink', 'type' => 'color', 'price' => 5000, 'treatment_type_id' => $nailArt->id, 'order' => 2],
            
            // Accessories for Nail Art
            ['name' => 'Flower', 'type' => 'accessory', 'price' => 10000, 'treatment_type_id' => $nailArt->id, 'order' => 1],
        ];

        foreach (array_merge($extensionCategories, $artCategories) as $category) {
            Category::create($category);
        }
    }
}