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
        Schema::table('nail_artists', function (Blueprint $table) {
            $table->time('jam_kerja_start')->default('08:00:00');
            $table->time('jam_kerja_end')->default('16:00:00');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('nail_artists', function (Blueprint $table) {
            $table->dropColumn('jam_kerja_start');
            $table->dropColumn('jam_kerja_end');
        });
    }
};
