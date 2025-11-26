<?php

namespace App\Services;

use App\Models\Reservation;
use App\Models\NailArtist;
use Carbon\Carbon;

class ArtistQueue
{
    /**
     * Pick artist untuk slot tertentu (rotasi kuyStudio)
     */
    public static function pickArtist($availableArtistIds, $date)
    {
        if (empty($availableArtistIds)) return null;

        $artists = NailArtist::whereIn("id", $availableArtistIds)->get();

        // Hitung jumlah job per-artist hari ini
        $jobCount = [];
        foreach ($artists as $artist) {
            $jobCount[$artist->id] = Reservation::where("nail_artist_id", $artist->id)
                ->where("reservation_date", $date)
                ->count();
        }

        // Ambil nilai job paling sedikit
        $minJobs = min($jobCount);

        // Ambil semua artist yang jobnya sama
        $candidates = collect($artists)->filter(function($a) use ($jobCount, $minJobs) {
            return $jobCount[$a->id] == $minJobs;
        });

        // Rotasi KuyStudio: pilih artist dengan ID terkecil di kandidat
        // (anti condong, anti random, fair rotation)
        return $candidates->sortBy("id")->first();
    }
}
