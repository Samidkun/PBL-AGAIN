<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AIController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CalendarController;
use App\Http\Controllers\IncomeController;


/*
|--------------------------------------------------------------------------
| PUBLIC ROUTEs
|--------------------------------------------------------------------------
*/

// LOGIN
Route::post('/login', [AuthController::class, 'login'])->name('api.login');

// Create reservation (customer, no token)
Route::prefix('v1')->group(function () {
    Route::post('/reservations', [ReservationController::class, 'store']);
});

// Categories (public)
Route::prefix('v1')->group(function () {
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/type/{type}', [CategoryController::class, 'getByType']);
    Route::get('/categories/{id}', [CategoryController::class, 'show']);
});

// ⛔ FIX: Slot harus public (web booking butuh ini)
Route::get('/v1/calendar/slots', [CalendarController::class, 'getSlots']);

// ⛔ OPTIONAL: Artists public (kalau mau dipakai web)
Route::get('/v1/available-artists', [CalendarController::class, 'getArtists']);


/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (AUTH SANCTUM)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Reservations
    Route::get('/reservations', [ReservationController::class, 'index']);
    Route::put('/reservations/{id}', [ReservationController::class, 'update']);
    Route::delete('/reservations/{id}', [ReservationController::class, 'destroy']);

    // Pricing
    Route::post('/reservations/{id}/set-price', [ReservationController::class, 'setPrice']);
    Route::post('/reservations/{id}/increment-generate', [ReservationController::class, 'incrementGenerate']);

    // User
    Route::get('/user', [ProfileController::class, 'index']);

    // AI Generate
    Route::post('/ai/generate', [AIController::class, 'generate']);

    // Income
    Route::post('/income/store', [IncomeController::class, 'store']);

    // Staff Actions
    Route::post('/reservations/{id}/finish', [ReservationController::class, 'finish']);
    Route::post('/artist/toggle-break', [App\Http\Controllers\Api\StaffController::class, 'toggleBreak']);
});

Route::get('/debug/categories', function () {

    try {
        return \App\Models\Category::limit(5)->get();
    } catch (\Exception $e) {
        return response()->json([
            'error' => $e->getMessage(),
            'trace' => $e->getTrace()[0] ?? null,
        ], 500);
    }
});

Route::get('/debug/categories-full', function () {
    try {
        $categories = \App\Models\Category::where('is_active', 1)
            ->orderBy('order')
            ->get();

        return $categories;
    } catch (\Exception $e) {
        return response()->json([
            'error' => $e->getMessage(),
            'trace' => $e->getTrace()[0] ?? null,
        ], 500);
    }
});

