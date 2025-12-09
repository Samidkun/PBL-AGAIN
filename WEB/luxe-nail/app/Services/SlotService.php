<?php

namespace App\Services;

use App\Models\Reservation;
use App\Models\NailArtist;
use Carbon\Carbon;

class SlotService
{
    public static function generateForDate($date, $durationMinutes = 60)
    {
        $artists = NailArtist::all();

        $start = Carbon::createFromTime(8, 0);
        $end = Carbon::createFromTime(20, 0); // Buka sampai jam 8 malam

        $slots = [];

        // Interval antar slot (misal user bisa booking tiap 30 menit atau 60 menit)
        // Kita set 30 menit biar lebih fleksibel
        $interval = 30;

        while ($start->lt($end)) {

            $timeStr = $start->format("H:i");
            $slotStart = $start->copy();
            $slotEnd = $start->copy()->addMinutes($durationMinutes);

            // BREAK RULES
            // - 12:00-13:00 (lunch break)
            // - 15:00-16:00 (afternoon break)  
            // - 17:30-18:30 (Maghrib prayer break)
            if (in_array($timeStr, ["12:00", "12:30", "15:00", "15:30", "17:30", "18:00"])) {
                $start->addMinutes($interval);
                continue;
            }

            // PAST TIME CHECK
            // If date is today, skip slots that have already passed
            if (Carbon::parse($date)->isToday()) {
                if ($start->lt(Carbon::now())) {
                    $start->addMinutes($interval);
                    continue;
                }
            }

            $availableArtists = [];

            foreach ($artists as $artist) {
                if (!self::artistIsWorkingAt($artist, $timeStr))
                    continue;

                // Cek Overlap
                // Logic: (StartA < EndB) && (EndA > StartB)
                $isOverlap = Reservation::where("nail_artist_id", $artist->id)
                    ->where("reservation_date", $date)
                    ->where(function ($query) use ($slotStart, $slotEnd) {
                        $query->where(function ($q) use ($slotStart, $slotEnd) {
                            $q->where('reservation_time', '<', $slotEnd->format('H:i:s'))
                                ->where('end_time', '>', $slotStart->format('H:i:s'));
                        });
                    })
                    ->exists();

                if (!$isOverlap) {
                    $availableArtists[] = $artist->id;
                }
            }

            $slots[] = [
                "time" => $timeStr,
                "artists_available" => $availableArtists,
                "available" => count($availableArtists) > 0
            ];

            $start->addMinutes($interval);
        }

        return $slots;
    }

    private static function artistIsWorkingAt($artist, $time)
    {
        // Pastikan jam kerja valid
        $startWork = substr($artist->jam_kerja_start ?? '08:00', 0, 5);
        $endWork = substr($artist->jam_kerja_end ?? '20:00', 0, 5);

        return $time >= $startWork && $time < $endWork;
    }
}
