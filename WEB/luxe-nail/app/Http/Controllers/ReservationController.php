<?php

namespace App\Http\Controllers;

use App\Models\Reservation;
use App\Models\NailArtist;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Carbon\Carbon;

class ReservationController extends Controller
{
    // ======================================================
    // CUSTOMER — CREATE FORM
    // ======================================================
    public function create()
    {
        return view('reservations.create');
    }

    // ======================================================
    // CUSTOMER — BOOKING STORE
    // ======================================================
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'             => 'required|string|max:255',
            'address'          => 'required|string|max:500',
            'phone'            => 'required|string|max:20',
            'treatment_type'   => 'required|in:nail_extension,nail_art',
            'reservation_date' => 'required|date',
            'reservation_time' => 'required|date_format:H:i',
        ]);

        $artists = NailArtist::all();

        if ($artists->count() == 0) {
            return response()->json([
                'success' => false,
                'message' => 'No nail artist available.'
            ]);
        }

        $bestArtist = null;
        $minLoad = PHP_INT_MAX;

        foreach ($artists as $artist) {
            $busy = Reservation::where('nail_artist_id', $artist->id)
                ->where('reservation_date', $validated['reservation_date'])
                ->where('reservation_time', $validated['reservation_time'])
                ->count();

            if ($busy < $minLoad) {
                $minLoad = $busy;
                $bestArtist = $artist;
            }
        }

        if (!$bestArtist) {
            return response()->json([
                'success' => false,
                'message' => 'All artists are busy for this slot.'
            ]);
        }

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
            'booking_fee'       => 25000,
            'total_price'       => 25000,
        ]);

        return response()->json([
            'success'      => true,
            'redirect_url' => route('payment.show', $reservation->id)
        ]);
    }



    // ======================================================
    // CUSTOMER — THANK YOU PAGE
    // ======================================================
    public function thankYou(Request $request)
    {
        $queueNumber = $request->query('queue_number');

        $reservation = Reservation::where('queue_number', $queueNumber)->firstOrFail();

        return view('reservations.thank-you', compact('reservation'));
    }



    // ======================================================
    // ADMIN PANEL — SHOW DASHBOARD PAGE
    // ======================================================
    public function dashboard()
    {
        return view('dashboard.reservations.dashboard_reservations');
        // atau view('dashboard.reservations.dashboard') → sesuaikan folder lo
    }



    // ======================================================
    // ADMIN PANEL — GET RESERVATIONS BY DATE
    // ======================================================
    public function getByDate($date)
    {
        $reservations = Reservation::where('reservation_date', $date)
            ->orderBy('reservation_time', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'reservations' => $reservations
        ]);
    }



    // ======================================================
    // ADMIN PANEL — GET SINGLE RESERVATION FOR EDIT MODAL
    // ======================================================
    public function getSingle($id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found.'
            ], 404);
        }

        return response()->json($reservation);
    }



    // ======================================================
    // ADMIN PANEL — UPDATE STATUS (CONFIRM / CANCEL)
    // ======================================================
    public function updateStatus(Request $request, $id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        $reservation->status = $request->status;

        if ($request->status === 'confirmed') {
            $reservation->is_paid = 1;
        }

        $reservation->save();

        return response()->json([
            'success' => true
        ]);
    }

public function calendar()
{
    return view('calendar.index'); // atau view lain yg lo pakai
}


    // ======================================================
    // ADMIN PANEL — UPDATE RESERVATION
    // ======================================================
    public function updateReservation(Request $request, $id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        $reservation->update([
            'name'           => $request->name,
            'phone'          => $request->phone,
            'address'        => $request->address,
            'treatment_type' => $request->treatment_type,
            'reservation_time' => $request->reservation_time,
        ]);

        return response()->json([
            'success' => true
        ]);

    }

public function getReservationsByDate($date)
{
    try {
        $reservations = Reservation::whereDate('reservation_date', $date)
            ->orderBy('reservation_time', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'reservations' => $reservations
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
}





}


