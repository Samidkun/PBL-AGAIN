<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reservation;
use App\Models\Income;

class BackfillIncomeRecords extends Command
{
    protected $signature = 'income:backfill';
    protected $description = 'Backfill Income records from existing paid reservations';

    public function handle()
    {
        $this->info('Starting Income backfill...');

        // Get all confirmed/completed reservations that are paid but have no income record
        $reservations = Reservation::whereIn('status', ['confirmed', 'completed'])
            ->where('is_paid', 1)
            ->whereDoesntHave('income')
            ->get();

        if ($reservations->isEmpty()) {
            $this->info('No reservations found that need backfilling.');
            return 0;
        }

        $this->info("Found {$reservations->count()} reservations to backfill.");

        $bar = $this->output->createProgressBar($reservations->count());
        $bar->start();

        $created = 0;
        foreach ($reservations as $reservation) {
            try {
                Income::create([
                    'reservation_id' => $reservation->id,
                    'customer_name' => $reservation->name,
                    'customer_phone' => $reservation->phone,
                    'treatment_type' => $reservation->treatment_type,
                    'shape' => null,
                    'color' => null,
                    'finish' => null,
                    'accessory' => null,
                    'price_shape' => 0,
                    'price_color' => 0,
                    'price_finish' => 0,
                    'price_accessory' => 0,
                    'total_price' => $reservation->total_price ?? 0,
                    'ai_image_url' => null,
                    'payment_status' => 'paid',
                    'payment_method' => $reservation->payment_method ?? 'bank_transfer',
                    'reservation_date' => $reservation->reservation_date,
                ]);
                $created++;
            } catch (\Exception $e) {
                $this->error("Failed to create income for reservation {$reservation->id}: {$e->getMessage()}");
            }

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();
        $this->info("Successfully created {$created} income records!");

        return 0;
    }
}
