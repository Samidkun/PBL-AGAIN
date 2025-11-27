<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('reservations', function (Blueprint $table) {

            // payment
            $table->decimal('total_price', 12, 2)->default(0)->after('status');
            $table->boolean('is_paid')->default(0)->after('total_price');

            // booking fee (kalau dipakai nanti)
            $table->decimal('booking_fee', 12, 2)->default(25000)->after('is_paid');

            // payment method (optional)
            $table->string('payment_method')->nullable()->after('booking_fee');

            // payment proof (optional, kalau mau upload)
            $table->string('payment_proof')->nullable()->after('payment_method');

            // receipt
            $table->boolean('has_downloaded_receipt')->default(0)->after('payment_proof');
        });
    }

    public function down()
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->dropColumn([
                'total_price',
                'is_paid',
                'booking_fee',
                'payment_method',
                'payment_proof',
                'has_downloaded_receipt',
            ]);
        });
    }
};
