<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::table('reservations', function (Blueprint $table) {
        $table->integer('booking_fee')->default(25000);
        $table->string('payment_method', 50)->nullable();
        $table->string('payment_proof')->nullable();
    });
}

public function down(): void
{
    Schema::table('reservations', function (Blueprint $table) {
        $table->dropColumn(['booking_fee','payment_method','payment_proof']);
    });
}

};
