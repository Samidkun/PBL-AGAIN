<?php
require __DIR__ . '/vendor/autoload.php';

use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

try {
    if (!class_exists(Driver::class)) {
        echo "Driver class not found\n";
        exit(1);
    }
    echo "Driver class found\n";

    $manager = new ImageManager(new Driver());
    echo "Manager instantiated\n";

    $image = $manager->create(100, 100);
    echo "Image created\n";

    $image->fill('red');
    
    $image->text('TEST', 10, 50, function ($font) {
        $font->file('C:\Windows\Fonts\arial.ttf');
        $font->size(20);
        $font->color('#ffffff');
    });
    echo "Text added\n";

    $encoded = $image->encodeByMediaType('image/png', 90);
    echo "Image encoded: " . strlen((string)$encoded) . " bytes\n";

    echo "Success\n";
} catch (\Throwable $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}
