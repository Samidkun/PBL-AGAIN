<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use App\Models\NailArtist;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ReservationController extends Controller
{
    // =========================================================================
    //  LIST RESERVATIONS  (Admin + Nail Artist Mobile)
    // =========================================================================
    public function index(Request $request)
    {
        $query = Reservation::query();

        // === Filter by Nail Artist (My Appointments) ===
        $user = $request->user();
        if ($user && $user->role === 'nail_artist') {
            if ($user->nailArtist) {
                $query->where('nail_artist_id', $user->nailArtist->id);
            }
        }

        // === Mobile default: tampilkan confirmed hari ini ===
        if (!$request->has('status')) {

            $date = $request->date ?? today()->format('Y-m-d');

            $query->where('status', 'confirmed')
                  ->whereDate('reservation_date', $date);

        } else {
            // === Admin bisa filter status ===
            $query->where('status', $request->status);
        }

        $reservations = $query
            ->orderBy('reservation_time', 'asc')
            ->get()
            ->map(function ($r) {
                return [
                    'id'              => $r->id,
                    'name'            => $r->name,
                    'phone'           => $r->phone,
                    'address'         => $r->address,
                    'treatment_type'  => $r->treatment_type,
                    'reservation_date'=> date('Y-m-d', strtotime($r->reservation_date)),
                    'reservation_time'=> $r->reservation_time,
                    'queue_number'    => $r->queue_number,
                    'status'          => $r->status,
                    'generate_count'  => $r->generate_count ?? 0,
                    'total_price'     => $r->total_price ?? 0,
                    'is_paid'         => $r->is_paid ?? 0,
                ];
            });

        return response()->json([
            'success' => true,
            'count'   => $reservations->count(),
            'data'    => $reservations
        ]);
    }





    // =========================================================================
    //  CREATE RESERVATION  (Customer Booking)
    // =========================================================================
    public function store(Request $request)
    {
        // === VALIDATION ===
        $validated = $request->validate([
            'name'             => 'required|string|max:255',
            'address'          => 'required|string|max:500',
            'phone'            => 'required|string|max:20',
            'treatment_type'   => 'required|in:nail_extension,nail_art',
            'reservation_date' => 'required|date',
            'reservation_time' => 'required|date_format:H:i',
        ]);

        // =========================================================================
        //  AUTO PICK ARTIST DENGAN BEBAN TERENDAH
        // =========================================================================

        $artists = NailArtist::all();

        $bestArtist = null;
        $minLoad = PHP_INT_MAX;

        foreach ($artists as $artist) {

            $count = Reservation::where('nail_artist_id', $artist->id)
                ->where('reservation_date', $validated['reservation_date'])
                ->where('reservation_time', $validated['reservation_time'])
                ->count();

            if ($count < $minLoad) {
                $minLoad = $count;
                $bestArtist = $artist;
            }
        }

        // Jika tidak ada artist sama sekali
        if (!$bestArtist) {
            return response()->json([
                'success' => false,
                'message' => 'No available nail artist.'
            ], 400);
        }

        // =========================================================================
        //  CREATE RESERVATION
        // =========================================================================
        $reservation = Reservation::create([
            'name'              => $validated['name'],
            'address'           => $validated['address'],
            'phone'             => $validated['phone'],
            'treatment_type'    => $validated['treatment_type'],
            'reservation_date'  => $validated['reservation_date'],
            'reservation_time'  => $validated['reservation_time'],
            'queue_number'      => 'LX' . date('Ymd') . strtoupper(Str::random(4)),
            'nail_artist_id'    => $bestArtist->id,
            'status'            => 'pending',
            'is_paid'           => 0,
            'total_price'       => 0,
        ]);

        // Redirect ke halaman payment
        return redirect()->route('payment.show', $reservation->id);
    }





    // =========================================================================
    //  SHOW BY QUEUE NUMBER
    // =========================================================================
    public function show($queueNumber)
    {
        $reservation = Reservation::where('queue_number', $queueNumber)->first();

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $reservation
        ]);
    }





    // =========================================================================
    //  UPDATE (Admin / Nail Artist)
    // =========================================================================
    public function update(Request $request, $id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        $validated = $request->validate([
            'name'             => 'sometimes|string|max:255',
            'address'          => 'sometimes|string|max:500',
            'phone'            => 'sometimes|string|max:20',
            'treatment_type'   => 'sometimes|in:nail_extension,nail_art',
            'reservation_date' => 'sometimes|date',
            'reservation_time' => 'sometimes|date_format:H:i',
            'status'           => 'sometimes|in:pending,confirmed,in_progress,completed,cancelled',
            'total_price'      => 'sometimes|numeric|min:0',
            'is_paid'          => 'sometimes|boolean',
        ]);

        $reservation->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Reservation updated successfully',
            'data'    => $reservation
        ]);
    }





    // =========================================================================
    //  DELETE
    // =========================================================================
    public function destroy($id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        $reservation->delete();

        return response()->json([
            'success' => true,
            'message' => 'Reservation deleted successfully'
        ]);
    }





    // =========================================================================
    //  AI GENERATION FLAG (Limit 3x)
    // =========================================================================
    public function incrementGenerate($id)
    {
        $r = Reservation::find($id);

        if (!$r) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        if ($r->generate_count >= 3) {
            return response()->json([
                'success' => false,
                'message' => 'Limit reached (3/3)',
                'generate_count' => $r->generate_count
            ], 403);
        }

        $r->generate_count += 1;
        $r->save();

        return response()->json([
            'success' => true,
            'message' => 'Increment success',
            'generate_count' => $r->generate_count,
        ]);
    }
    // =========================================================================
    //  FINISH JOB (Mobile Staff)
    // =========================================================================
    public function finish($id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        $reservation->status = 'waiting_payment';
        $reservation->save();

        return response()->json([
            'success' => true,
            'message' => 'Job finished. Waiting for payment.',
            'data'    => $reservation
        ]);
    }
}
