<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Services\SlotService;
use App\Models\Reservation;
use App\Models\NailArtist;

class CalendarController extends Controller
{
    public function getArtists(Request $request)
    {
        $date = $request->date;

        $artists = NailArtist::all()->map(function($a) use ($date) {

            $count = Reservation::where('nail_artist_id', $a->id)
                ->where('reservation_date', $date)
                ->count();

            return [
                'id' => $a->id,
                'name' => $a->name,
                'remaining_slots' => max(0, 12 - $count)
            ];
        });

        return response()->json([
            "success" => true,
            "data" => $artists
        ]);
    }

    public function getSlots(Request $request)
    {
        $date = $request->date ?? Carbon::today()->format("Y-m-d");
        $treatmentType = $request->treatment_type; // e.g. "nail_extension"

        $duration = 60; // Default

        if ($treatmentType) {
            $type = \App\Models\TreatmentType::where('name', $treatmentType)->first();
            if ($type) {
                $duration = $type->duration;
            }
        }

        return response()->json([
            "success" => true,
            "date"    => $date,
            "duration_used" => $duration,
            "data"    => SlotService::generateForDate($date, $duration)
        ]);
    }

}
