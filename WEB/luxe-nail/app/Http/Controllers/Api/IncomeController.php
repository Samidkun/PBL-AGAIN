<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AIController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\IncomeController; // IncomeController (non-API namespace)

/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES
|--------------------------------------------------------------------------
*/

// LOGIN
Route::post('/login', [AuthController::class, 'login'])->name('api.login');

// Customer create reservation
Route::prefix('v1')->group(function () {
    Route::post('/reservations', [ReservationController::class, 'store']);
});

// Categories (public)
Route::get('/v1/categories', [CategoryController::class, 'index']);


/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (SANCTUM & V1 PREFIX)
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->prefix('v1')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Reservations
    Route::get('/reservations', [ReservationController::class, 'index']);
    Route::put('/reservations/{id}', [ReservationController::class, 'update']);
    Route::delete('/reservations/{id}', [ReservationController::class, 'destroy']);

    // Set price
    Route::post('/reservations/{id}/set-price', [ReservationController::class, 'setPrice']);

    // Increment AI generate counter
    Route::post('/reservations/{id}/increment-generate', [ReservationController::class, 'incrementGenerate']);

    // Profile
    Route::get('/user', [ProfileController::class, 'index']);

    // AI GENERATE
    Route::post('/ai/generate', [AIController::class, 'generate']);

    // ==============================================================
    // INCOME AND PAYMENT CONFIRMATION (DIPINDAHKAN KE SINI AGAR AMAN & SESUAI PREFIX)
    // ==============================================================
    Route::post('/income/store', [IncomeController::class, 'store']);
    Route::get('/dashboard/income/{income}/edit', [App\Http\Controllers\IncomeController::class, 'edit'])
    ->name('dashboard.income.edit');
});


/*
|--------------------------------------------------------------------------
| INCOME (SECTION LAMA DIHAPUS / DIKOSONGKAN)
|--------------------------------------------------------------------------
*/

// Section ini dikosongkan karena route sudah dipindahkan ke atas.
