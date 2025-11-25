<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ReservationController extends Controller
{
    // ========================= LIST (Admin + Nail Artist Mobile) =========================
    public function index(Request $request)
    {
        $query = Reservation::query();

        // === MOBILE FILTERING ===
        if (!$request->has('status')) {

            $date = $request->date ?? today()->format('Y-m-d');

            $query->where('status', 'confirmed')
                ->whereDate('reservation_date', $date);
        } else {
            // === FOR ADMIN PANEL ===
            $query->where('status', $request->status);
        }

        $reservations = $query
            ->orderBy('reservation_time', 'asc')
            ->get()
            ->map(function ($r) {
                return [
                    'id' => $r->id,
                    'name' => $r->name,
                    'phone' => $r->phone,
                    'treatment_type' => $r->treatment_type,
                    'reservation_date' => date('Y-m-d', strtotime($r->reservation_date)),
                    'reservation_time' => $r->reservation_time,
                    'queue_number' => $r->queue_number,
                    'status' => $r->status,

                    // NEW → BIAR MOBILE TAU BERAPA KALI AI UDAH DIPAKAI
                    'generate_count' => $r->generate_count ?? 0,

                    // Disiapkan untuk step pembayaran
                    'total_price' => $r->total_price ?? 0,
                    'is_paid'      => $r->is_paid ?? 0,
                ];
            });

        return response()->json([
            'success' => true,
            'count' => $reservations->count(),
            'data' => $reservations
        ]);
    }


    // ========================= STORE (Customer Booking) =========================
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string|max:500',
            'phone' => 'required|string|max:20',
            'treatment_type' => 'required|in:nail_extension,nail_art',
            'reservation_date' => 'required|date|after:today',
            'reservation_time' => 'required|date_format:H:i'
        ]);

        $queueNumber = 'LX' . date('Ymd') . strtoupper(Str::random(4));

        $reservation = Reservation::create([
            'name' => $validated['name'],
            'address' => $validated['address'],
            'phone' => $validated['phone'],
            'treatment_type' => $validated['treatment_type'],
            'reservation_date' => $validated['reservation_date'],
            'reservation_time' => $validated['reservation_time'],
            'queue_number' => $queueNumber,
            'status' => 'pending',
            'generate_count' => 0,
            'total_price' => 0,
            'is_paid' => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Reservation created successfully',
            'data' => $reservation
        ], 201);
    }


    // ========================= SHOW (Optional) =========================
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
            'data' => $reservation
        ]);
    }


    // ========================= UPDATE =========================
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
            'name' => 'sometimes|string|max:255',
            'address' => 'sometimes|string|max:500',
            'phone' => 'sometimes|string|max:20',
            'treatment_type' => 'sometimes|in:nail_extension,nail_art',
            'reservation_date' => 'sometimes|date|after:today',
            'reservation_time' => 'sometimes|date_format:H:i',
            'status' => 'sometimes|in:pending,confirmed,in_progress,completed,cancelled',

            // NEW - Harga dari AIResultScreen
            'total_price' => 'sometimes|numeric|min:0',

            // NEW - Payment state
            'is_paid' => 'sometimes|boolean',
        ]);

        $reservation->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Reservation updated successfully',
            'data' => $reservation
        ]);
    }


    // ========================= DELETE =========================
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


    // ========================= AI GENERATE LIMIT (Max 3x) =========================
    public function incrementGenerate(Request $request)
{
    $request->validate([
        'reservation_id' => 'required|integer',
    ]);

    $r = Reservation::find($request->reservation_id);

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

}
