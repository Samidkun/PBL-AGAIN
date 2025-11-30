<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('reservations', function (Blueprint $table) {
            if (!Schema::hasColumn('reservations', 'total_price')) {
                $table->decimal('total_price', 12, 2)->default(0)->after('status');
            }
            if (!Schema::hasColumn('reservations', 'is_paid')) {
                $table->boolean('is_paid')->default(0)->after('total_price');
            }
            if (!Schema::hasColumn('reservations', 'booking_fee')) {
                $table->decimal('booking_fee', 12, 2)->default(25000)->after('is_paid');
            }
            if (!Schema::hasColumn('reservations', 'payment_method')) {
                $table->string('payment_method')->nullable()->after('booking_fee');
            }
            if (!Schema::hasColumn('reservations', 'payment_proof')) {
                $table->string('payment_proof')->nullable()->after('payment_method');
            }
            if (!Schema::hasColumn('reservations', 'has_downloaded_receipt')) {
                $table->boolean('has_downloaded_receipt')->default(0)->after('payment_proof');
            }
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
