<?php

use App\Models\Category;
use Illuminate\Support\Facades\File;

// 1. Get all known files
$knownFiles = [
    'nail_accessoris/1763639446_AC-bunga.jpg',
    'nail_accessoris/1763639471_AC-pearl.jpeg',
    'nail_accessoris/1763639525_AC-pita.jpeg',
    'nail_color/1763639320_CL-merah.png',
    'nail_color/1763639377_CL-hijau.png',
    'nail_color/1763639413_CL-biru.jpg',
    'nail_color/1763639576_CL-pink.png',
    'nail_color/1763639590_CL-pink.png',
    'nail_shape/1763469805_NS-square.jpg',
    'nail_shape/1763470287_NS-square.jpg',
    'nail_shape/1763470986_NS-square.jpg',
    'nail_shape/1763637865_NS-coffin.jpg',
    'nail_shape/1763638147_NS-almond.jpeg',
    'nail_shape/1763638346_NS-stiletto.jpg',
    'nail_type/1763639135_NT-matte.jpeg',
    'nail_type/1763639194_NT-glossy.jpeg',
    'nail_type/1763639264_NT-cateye.jpeg',
];

// Helper to find best match
function findBestMatch($categoryName, $knownFiles) {
    foreach ($knownFiles as $file) {
        // Simple check: if filename contains part of category name
        // e.g. "Coffin" in "1763637865_NS-coffin.jpg"
        if (stripos($file, $categoryName) !== false) {
            return 'img/kategori/' . $file;
        }
        
        // Check for specific keywords mapping
        $keywords = [
            'Square' => 'square',
            'Coffin' => 'coffin',
            'Almond' => 'almond',
            'Stiletto' => 'stiletto',
            'Matte' => 'matte',
            'Glossy' => 'glossy',
            'Cat Eye' => 'cateye',
            'Flower' => 'bunga',
            'Pearl' => 'pearl',
            'Ribbon' => 'pita',
            'Burgundy' => 'merah', // Mapping based on previous observation
            'Emerald' => 'hijau',
            'Royal' => 'biru',
            'Platinum' => 'pink', // Maybe?
        ];
        
        foreach ($keywords as $key => $val) {
            if (stripos($categoryName, $key) !== false && stripos($file, $val) !== false) {
                return 'img/kategori/' . $file;
            }
        }
    }
    return null;
}

$categories = Category::all();

foreach ($categories as $category) {
    $currentPath = $category->image;
    $fullPath = public_path($currentPath);
    
    // Check if file exists
    if ($currentPath && file_exists($fullPath)) {
        echo "[OK] {$category->name}: $currentPath\n";
        continue;
    }
    
    // File missing or null. Try to find a match.
    $newPath = findBestMatch($category->name, $knownFiles);
    
    if ($newPath) {
        $category->image = $newPath;
        $category->save();
        echo "[FIXED] {$category->name}: $newPath\n";
    } else {
        // No match found. Set to NULL to show placeholder.
        if ($category->image !== null) {
            $category->image = null;
            $category->save();
            echo "[NULL] {$category->name}: Image not found on disk. Set to NULL.\n";
        } else {
            echo "[SKIP] {$category->name}: Already NULL.\n";
        }
    }
}
