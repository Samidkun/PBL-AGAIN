<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if columns don't exist before adding
        if (!Schema::hasColumn('reservations', 'start_time')) {
            Schema::table('reservations', function (Blueprint $table) {
                $table->timestamp('start_time')->nullable()->after('reservation_time');
            });
        }

        if (!Schema::hasColumn('reservations', 'end_time')) {
            Schema::table('reservations', function (Blueprint $table) {
                $table->timestamp('end_time')->nullable()->after('start_time');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('reservations', function (Blueprint $table) {
            if (Schema::hasColumn('reservations', 'start_time')) {
                $table->dropColumn('start_time');
            }
            if (Schema::hasColumn('reservations', 'end_time')) {
                $table->dropColumn('end_time');
            }
        });
    }
};
