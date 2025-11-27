<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->enum('status', [
                'pending',             // Baru booking
                'waiting_validation',  // Sudah bayar, nunggu dicek admin
                'confirmed',           // Admin validasi → booking fix
                'in_progress',         // Lagi dikerjain
                'completed',           // Selesai
                'cancelled'            // Dibatalkan
            ])->default('pending')->change();
        });
    }

    public function down()
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->enum('status', [
                'pending',
                'confirmed',
                'in_progress',
                'completed',
                'cancelled'
            ])->default('pending')->change();
        });
    }
};
