<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up()
{
    Schema::table('reservations', function (Blueprint $table) {
        $table->integer('total_price')->nullable()->after('status');
        $table->boolean('is_paid')->default(false)->after('total_price');
        $table->timestamp('paid_at')->nullable()->after('is_paid');
    });
}

public function down()
{
    Schema::table('reservations', function (Blueprint $table) {
        $table->dropColumn(['total_price', 'is_paid', 'paid_at']);
    });
}

};
