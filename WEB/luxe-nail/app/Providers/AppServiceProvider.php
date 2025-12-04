<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Validator; // Added this line for clarity, though not strictly required due to FQCN

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Illuminate\Support\Facades\Validator::extend('captcha', function ($attribute, $value, $parameters, $validator) {
            return session('captcha_code') && strtolower($value) === strtolower(session('captcha_code'));
        }, 'Incorrect captcha code.');
        Route::prefix('api')
            ->middleware('api')
            ->group(base_path('routes/api.php'));
    }
}
