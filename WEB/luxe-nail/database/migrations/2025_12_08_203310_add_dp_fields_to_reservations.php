<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->decimal('dp_amount', 10, 2)->default(25000)->after('total_price');
            $table->string('dp_payment_method')->nullable()->after('dp_amount');
            $table->boolean('dp_paid')->default(false)->after('dp_payment_method');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->dropColumn(['dp_amount', 'dp_payment_method', 'dp_paid']);
        });
    }
};
