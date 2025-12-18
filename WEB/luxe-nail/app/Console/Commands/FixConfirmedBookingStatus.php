<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reservation;

class FixConfirmedBookingStatus extends Command
{
    protected $signature = 'booking:fix-confirmed';
    protected $description = 'Fix confirmed bookings that have is_paid = 0';

    public function handle()
    {
        $this->info('Checking confirmed bookings...');

        // Find all confirmed bookings with is_paid = 0
        $bookings = Reservation::where('status', 'confirmed')
            ->where('is_paid', 0)
            ->get();

        if ($bookings->isEmpty()) {
            $this->info('No bookings need fixing. All confirmed bookings have is_paid = 1.');
            return 0;
        }

        $this->info("Found {$bookings->count()} bookings to fix:");

        foreach ($bookings as $booking) {
            $this->line("- {$booking->queue_number} ({$booking->name}) - Setting is_paid = 1");
            $booking->is_paid = 1;
            $booking->save();
        }

        $this->info("\n✅ Successfully fixed {$bookings->count()} bookings!");

        return 0;
    }
}
