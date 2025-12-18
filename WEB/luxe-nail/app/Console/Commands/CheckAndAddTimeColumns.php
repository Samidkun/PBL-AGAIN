<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class CheckAndAddTimeColumns extends Command
{
    protected $signature = 'reservations:add-time-columns';
    protected $description = 'Check and add start_time and end_time columns if they do not exist';

    public function handle()
    {
        $this->info('Checking reservations table for time columns...');

        $hasStartTime = Schema::hasColumn('reservations', 'start_time');
        $hasEndTime = Schema::hasColumn('reservations', 'end_time');

        $this->info("start_time exists: " . ($hasStartTime ? 'YES' : 'NO'));
        $this->info("end_time exists: " . ($hasEndTime ? 'YES' : 'NO'));

        if (!$hasStartTime) {
            $this->info('Adding start_time column...');
            DB::statement('ALTER TABLE reservations ADD COLUMN start_time TIMESTAMP NULL AFTER reservation_time');
            $this->info('✅ start_time column added successfully!');
        } else {
            $this->info('start_time column already exists, skipping.');
        }

        if (!$hasEndTime) {
            $this->info('Adding end_time column...');
            DB::statement('ALTER TABLE reservations ADD COLUMN end_time TIMESTAMP NULL AFTER start_time');
            $this->info('✅ end_time column added successfully!');
        } else {
            $this->info('end_time column already exists, skipping.');
        }

        $this->info("\n✅ All done! Columns are ready.");

        return 0;
    }
}
