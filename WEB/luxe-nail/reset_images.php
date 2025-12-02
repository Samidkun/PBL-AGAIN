<?php

use App\Models\Category;

// Map filenames to Category Names (or partial names)
// These are the files CONFIRMED to exist on disk
$map = [
    // SHAPE
    'img/kategori/nail_shape/1763469805_NS-square.jpg' => 'Square',
    'img/kategori/nail_shape/1763637865_NS-coffin.jpg' => 'Coffin',
    'img/kategori/nail_shape/1763638147_NS-almond.jpeg' => 'Almond',
    'img/kategori/nail_shape/1763638346_NS-stiletto.jpg' => 'Stiletto',
    'img/kategori/nail_shape/1763470986_NS-square.jpg' => 'Russian Almond',

    // COLOR
    'img/kategori/nail_color/1763639320_CL-merah.png' => 'Burgundy', 
    'img/kategori/nail_color/1763639377_CL-hijau.png' => 'Emerald', 
    'img/kategori/nail_color/1763639413_CL-biru.jpg' => 'Royal Gold', 
    'img/kategori/nail_color/1763639576_CL-pink.png' => 'Platinum', 
    
    // ACCESSORIES
    'img/kategori/nail_accessoris/1763639446_AC-bunga.jpg' => 'Flower', 
    'img/kategori/nail_accessoris/1763639471_AC-pearl.jpeg' => 'Pearl', 
    'img/kategori/nail_accessoris/1763639525_AC-pita.jpeg' => 'Ribbon', 

    // FINISH (nail_type folder)
    'img/kategori/nail_type/1763639135_NT-matte.jpeg' => 'Matte',
    'img/kategori/nail_type/1763639194_NT-glossy.jpeg' => 'Glossy',
    'img/kategori/nail_type/1763639264_NT-cateye.jpeg' => 'Cat Eye',
];

foreach ($map as $path => $keyword) {
    // Update ANY category that matches the keyword, overwriting whatever broken path is there
    $categories = Category::where('name', 'LIKE', "%$keyword%")->get();
    foreach ($categories as $category) {
        $category->image = $path;
        $category->save();
        echo "Reset: {$category->name} -> $path\n";
    }
}
