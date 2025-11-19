<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\IncomeController;
use App\Http\Controllers\StaffController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TreatmentTypeController;
use App\Http\Controllers\DashboardController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// ====== LOGIN PAGE (Web) ======
Route::view('/login-page', 'auth.login')->name('login.page');
Route::post('/login-page', [AuthController::class, 'login'])->name('login.page.submit');

// ====== LOGOUT ======
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// ====== DASHBOARD ======
// Route::get('/dashboard', fn() => view('dashboard.index'))->name('dashboard');
Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard')->middleware('auth');

// ====== HALAMAN UTAMA ======
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');
Route::get('/gallery', [HomeController::class, 'gallery'])->name('gallery');
Route::get('/contact', [HomeController::class, 'contact'])->name('contact');

// ====== RESERVATION ======
Route::get('/reservations', [ReservationController::class, 'create'])->name('reservations.create');
Route::post('/reservations', [ReservationController::class, 'store'])->name('reservations.store');
Route::get('/reservations/thank-you', [ReservationController::class, 'thankYou'])->name('reservations.thank-you');
Route::get('/reservations/{queue_number}/download', [ReservationController::class, 'downloadPdf'])
    ->name('reservations.download');

// ====== KALENDER ======
Route::get('/calendar', [ReservationController::class, 'calendar'])->name('calendar');
Route::get('/schedule-data', [ReservationController::class, 'getScheduleData'])->name('schedule.data');
Route::get('/date-details/{date}', [ReservationController::class, 'getDateDetails'])->name('date.details');
Route::get('/check-availability', [ReservationController::class, 'checkAvailability']);

// ====== PROFILE ======
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile.index');
    Route::post('/profile/update', [ProfileController::class, 'update'])->name('profile.update');
    Route::post('/profile/change-password', [ProfileController::class, 'updatePassword'])->name('profile.password');
});

// ====== INCOME ======
Route::view('/dashboard/income', 'dashboard.income.dashboard_income')->name('dashboard.income');

// ====== STAFF MANAGEMENT ======
Route::middleware('auth')->group(function () {
    Route::resource('staff', StaffController::class);
});

// ====== OWNER DASHBOARD ======
//Route::get('/dashboard/reservations', [OwnerReservationController::class, 'index'])
   // ->name('dashboard.reservations');
   Route::prefix('dashboard')->middleware(['auth'])->group(function () {
    Route::get('/reservations', [ReservationController::class, 'dashboard'])->name('dashboard.reservations');
    Route::get('/reservations/date/{date}', [ReservationController::class, 'getReservationsByDate']);
    Route::put('/reservations/{id}/status', [ReservationController::class, 'updateStatus']);
    Route::get('/reservations/{id}', [ReservationController::class, 'getReservation']);
    Route::put('/reservations/{id}', [ReservationController::class, 'updateReservation']);
});

// ====== CATEGORY MANAGEMENT ======
Route::get('/kategori', [CategoryController::class, 'index'])->name('kategori.index');
Route::get('/kategori/create', [CategoryController::class, 'create'])->name('kategori.create');
Route::post('/kategori', [CategoryController::class, 'store'])->name('kategori.store');
Route::get('/kategori/{category}/edit', [CategoryController::class, 'edit'])->name('kategori.edit');
Route::put('/kategori/{category}', [CategoryController::class, 'update'])->name('kategori.update');
Route::delete('/kategori/{category}', [CategoryController::class, 'destroy'])->name('kategori.destroy');
Route::get('/kategori/{category}/ajax-edit', [CategoryController::class, 'ajaxEdit'])->name('kategori.ajax-edit');
Route::post('/kategori/ajax-store', [CategoryController::class, 'ajaxStore'])->name('kategori.ajax-store');
Route::put('/kategori/{category}/ajax-update', [CategoryController::class, 'ajaxUpdate'])->name('kategori.ajax-update');
Route::get('/kategori/get-create-form', [CategoryController::class, 'getCreateForm'])->name('kategori.get-create-form');
Route::delete('/kategori/{category}/ajax-delete', [CategoryController::class, 'ajaxDestroy'])->name('kategori.ajax-destroy');

// TREATMENT TYPES
Route::resource('treatment-types', TreatmentTypeController::class);