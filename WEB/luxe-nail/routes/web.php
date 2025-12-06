<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\IncomeController;
use App\Http\Controllers\StaffController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TreatmentTypeController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PaymentController;

/*
|--------------------------------------------------------------------------
| WEB ROUTES
|--------------------------------------------------------------------------
*/

// ======================
// AUTH & LOGIN
// ======================
Route::view('/login-page', 'auth.login')->name('login');
Route::post('/login-page', [AuthController::class, 'login'])->name('login.page.submit');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// ======================
// DASHBOARD
// ======================
Route::get('/dashboard', [DashboardController::class, 'index'])
    ->middleware('auth')
    ->name('dashboard');

// ======================
// LANDING PAGES
// ======================
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');
Route::get('/gallery', [HomeController::class, 'gallery'])->name('gallery');
Route::get('/contact', [HomeController::class, 'contact'])->name('contact');

Route::get('/calendar', [ReservationController::class, 'calendar'])
    ->name('calendar');

// ======================
// BOOKING (USER)
// ======================
Route::get('/reservations', [ReservationController::class, 'create'])->name('reservations.create');
Route::post('/reservations', [ReservationController::class, 'store'])->name('reservations.store');
Route::get('/reservations/thank-you', [ReservationController::class, 'thankYou'])->name('reservations.thank-you');

Route::get('/reservations/{queue_number}/download', [ReservationController::class, 'downloadPdf'])
    ->name('reservations.download');

// ======================
// PAYMENT ROUTES
// ======================
Route::get('/reservations/{id}/payment', [PaymentController::class, 'show'])->name('payment.show');
Route::post('/reservations/{id}/paid', [PaymentController::class, 'markPaid'])->name('payment.paid');
Route::get('/invoice/{queue}', [PaymentController::class, 'downloadInvoice'])->name('payment.invoice');

// CHECK INVOICE
Route::get('/check-invoice', [PaymentController::class, 'checkInvoiceForm'])->name('payment.check_invoice_form');
Route::post('/check-invoice', [PaymentController::class, 'checkInvoice'])->name('payment.check_invoice');
Route::get('/invoice-status/{queue}', [PaymentController::class, 'invoiceStatus'])->name('payment.invoice.status');

// ADMIN CONFIRM PAYMENT
Route::post('/admin/payment/{id}/confirm', [PaymentController::class, 'adminConfirm'])
    ->middleware('auth')
    ->name('payment.admin.confirm');



Route::get('/captcha/image', [App\Http\Controllers\CaptchaController::class, 'generate'])->name('captcha.image');

// ======================
// PROFILE
// ======================
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile.index');
    Route::post('/profile/update', [ProfileController::class, 'update'])->name('profile.update');
    Route::post('/profile/change-password', [ProfileController::class, 'updatePassword'])->name('profile.password');
});

// ======================
// STAFF
// ======================
Route::middleware('auth')->group(function () {
    Route::resource('staff', StaffController::class);
});


// ======================
// CATEGORY MANAGEMENT
// ======================
Route::middleware('auth')->group(function () {
    // AJAX Routes for Category
    Route::get('/kategori/get-create-form', [CategoryController::class, 'getCreateForm'])->name('kategori.get-create-form');
    Route::post('/kategori/ajax-store', [CategoryController::class, 'ajaxStore'])->name('kategori.ajax-store');
    Route::get('/kategori/{category}/ajax-edit', [CategoryController::class, 'ajaxEdit'])->name('kategori.ajax-edit');
    Route::put('/kategori/{category}/ajax-update', [CategoryController::class, 'ajaxUpdate'])->name('kategori.ajax-update');
    Route::delete('/kategori/{category}/ajax-delete', [CategoryController::class, 'ajaxDestroy'])->name('kategori.ajax-delete');

    Route::resource('kategori', CategoryController::class);
});


// ======================
// ADMIN DASHBOARD (RESERVATIONS)
// ======================
Route::prefix('dashboard')
    ->middleware('auth')
    ->group(function () {

        Route::get('/reservations', [ReservationController::class, 'dashboard'])
            ->name('dashboard.reservations');

        Route::get('/reservations/date/{date}', [ReservationController::class, 'getReservationsByDate']);
        Route::get('/reservations/{id}', [ReservationController::class, 'getReservation']);
        Route::put('/reservations/{id}/status', [ReservationController::class, 'updateStatus']);
        Route::put('/reservations/{id}', [ReservationController::class, 'updateReservation']);

        Route::get('/income', [IncomeController::class, 'index'])
            ->name('dashboard.income');

        // CASHIER / POS
        Route::get('/cashier/{id}', [ReservationController::class, 'cashier'])
            ->name('dashboard.cashier');
        Route::post('/cashier/{id}/process', [ReservationController::class, 'processPayment'])
            ->name('dashboard.cashier.process');

        Route::get('/cashier-queue', [ReservationController::class, 'cashierQueue'])
            ->name('dashboard.cashier.queue');
    });

// ======================
// IMAGE SERVING (CORS FIX)
// ======================
Route::get('/served-image/{path}', function ($path) {
    $filePath = public_path($path);
    if (!file_exists($filePath)) {
        abort(404);
    }
    return response()->file($filePath, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
    ]);
})->where('path', '.*');
