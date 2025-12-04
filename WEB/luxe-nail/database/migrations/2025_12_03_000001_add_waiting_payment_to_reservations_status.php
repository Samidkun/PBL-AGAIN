<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // For MySQL, we need to redefine the ENUM column
        DB::statement("ALTER TABLE reservations MODIFY COLUMN status ENUM('pending', 'waiting_validation', 'confirmed', 'in_progress', 'waiting_payment', 'completed', 'cancelled') NOT NULL DEFAULT 'pending'");
    }

    public function down()
    {
        // Revert back to original statuses (WARNING: this might fail if there are 'waiting_payment' records)
        DB::statement("ALTER TABLE reservations MODIFY COLUMN status ENUM('pending', 'waiting_validation', 'confirmed', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'pending'");
    }
};
