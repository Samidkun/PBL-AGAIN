<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class CaptchaController extends Controller
{
    public function generate()
    {
        try {
            // 1. Generate Random Code
            $code = strtoupper(Str::random(5));
            
            // 2. Store in Session
            session(['captcha_code' => $code]);

            // 3. Create Image Manager (Intervention v3)
            if (!class_exists(\Intervention\Image\Drivers\Gd\Driver::class)) {
                throw new \Exception("Driver class not found: " . \Intervention\Image\Drivers\Gd\Driver::class);
            }
            $manager = new \Intervention\Image\ImageManager(new \Intervention\Image\Drivers\Gd\Driver());

            // 4. Create Canvas
            $image = $manager->create(160, 50);

            // 5. Add Background (Light Gray)
            $image->fill('#f0f0f0');

            // 6. Add Text
            $image->text($code, 80, 25, function ($font) {
                $font->file('C:\Windows\Fonts\arial.ttf'); 
                $font->size(32);
                $font->color('#333333');
                $font->align('center');
                $font->valign('middle');
            });
            
            // 7. Add some noise (lines)
            for ($i = 0; $i < 5; $i++) {
                $image->drawLine(function ($line) {
                    $line->from(rand(0, 160), rand(0, 50));
                    $line->to(rand(0, 160), rand(0, 50));
                    $line->color('#cccccc');
                    $line->width(2);
                });
            }

            // 8. Return Response
            return response((string) $image->encodeByMediaType('image/png', 90))
                ->header('Content-Type', 'image/png')
                ->header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
        } catch (\Throwable $e) {
            return response($e->getMessage() . "\n" . $e->getTraceAsString(), 500);
        }
    }
}
