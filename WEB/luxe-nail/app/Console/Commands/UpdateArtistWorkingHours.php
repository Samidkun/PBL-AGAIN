<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\NailArtist;

class UpdateArtistWorkingHours extends Command
{
    protected $signature = 'artists:update-hours';
    protected $description = 'Update all nail artists working hours to 08:00-20:00';

    public function handle()
    {
        $this->info('Updating nail artists working hours...');

        $updated = NailArtist::query()->update([
            'jam_kerja_start' => '08:00:00',
            'jam_kerja_end' => '20:00:00',
        ]);

        $this->info("Successfully updated {$updated} nail artists!");
        $this->info('Working hours: 08:00 - 20:00');

        return 0;
    }
}
