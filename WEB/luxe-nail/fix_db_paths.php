<?php

use App\Models\Category;
use Illuminate\Support\Facades\DB;

// 1. Fix SHAPE (ai_shape -> nail_shape)
DB::statement("UPDATE categories SET image = REPLACE(image, 'ai_shape', 'nail_shape') WHERE image LIKE '%ai_shape%'");

// 2. Fix COLOR (ai_color -> nail_color)
DB::statement("UPDATE categories SET image = REPLACE(image, 'ai_color', 'nail_color') WHERE image LIKE '%ai_color%'");

// 3. Fix FINISH (ai_finish -> nail_type)
DB::statement("UPDATE categories SET image = REPLACE(image, 'ai_finish', 'nail_type') WHERE image LIKE '%ai_finish%'");

// 4. Fix ACCESSORY (ai_accessories -> nail_accessoris)
// Note: spelling difference 'accessories' vs 'accessoris'
DB::statement("UPDATE categories SET image = REPLACE(image, 'ai_accessories', 'nail_accessoris') WHERE image LIKE '%ai_accessories%'");

echo "Database paths updated.\n";

// Verify
$counts = [
    'nail_shape' => Category::where('image', 'like', '%nail_shape%')->count(),
    'nail_color' => Category::where('image', 'like', '%nail_color%')->count(),
    'nail_type' => Category::where('image', 'like', '%nail_type%')->count(),
    'nail_accessoris' => Category::where('image', 'like', '%nail_accessoris%')->count(),
    'ai_shape' => Category::where('image', 'like', '%ai_shape%')->count(),
];

dump($counts);
