<?php

namespace App\Services;

use App\Models\Reservation;
use App\Models\NailArtist;
use Carbon\Carbon;

class SlotService
{
    public static function generateForDate($date)
    {
        $artists = NailArtist::all();

        $start = Carbon::createFromTime(8,0);
        $end   = Carbon::createFromTime(21,0); // sampai 21.00

        $slots = [];

        while ($start < $end) {

            $time = $start->format("H:i");

            // BREAK RULES
            if ($time == "12:00") { $start->addHour(); continue; }
            if ($time == "15:00") { $start->addMinutes(30); continue; }
            if ($time == "18:00") { $start->addMinutes(30); continue; }

            $availableArtists = [];

            foreach ($artists as $artist) {

                if (!self::artistIsWorkingAt($artist, $time)) continue;

                // cek overlap (bukan hanya jam =)
                $isOverlap = Reservation::where("nail_artist_id", $artist->id)
                    ->where("reservation_date", $date)
                    ->where("reservation_time", $time)
                    ->exists();

                if (!$isOverlap) {
                    $availableArtists[] = $artist->id;
                }
            }

            $slots[] = [
                "time" => $time,
                "artists_available" => $availableArtists,
                "available" => count($availableArtists) > 0
            ];

            $start->addHour(); // tiap slot 1 jam
        }

        return $slots;
    }

    private static function artistIsWorkingAt($artist, $time)
    {
        return $time >= substr($artist->jam_kerja_start,0,5)
            && $time < substr($artist->jam_kerja_end,0,5);
    }
}
