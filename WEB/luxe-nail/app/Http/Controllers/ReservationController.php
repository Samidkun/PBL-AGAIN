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
            'captcha'          => 'required|captcha',
        ]);

        // 1. Hitung End Time berdasarkan durasi treatment
        $duration = 60; // Default
        $type = \App\Models\TreatmentType::where('name', $validated['treatment_type'])->first();
        if ($type) {
            $duration = $type->duration;
        }

        $startTime = Carbon::createFromFormat('H:i', $validated['reservation_time']);
        $endTime   = $startTime->copy()->addMinutes($duration);

        // 2. Cari Artist yang Available (Tidak Overlap)
        // Logic: Artist yang TIDAK punya reservasi yang overlap dengan jam ini
        $bestArtist = NailArtist::whereDoesntHave('reservations', function ($q) use ($validated, $startTime, $endTime) {
            $q->where('reservation_date', $validated['reservation_date'])
              ->where('status', '!=', 'cancelled') // Ignore cancelled reservations
              ->where(function ($query) use ($startTime, $endTime) {
                  $query->where('reservation_time', '<', $endTime->format('H:i:s'))
                        ->where('end_time', '>', $startTime->format('H:i:s'));
              });
        })->first(); // Ambil satu aja yang kosong

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
            'end_time'          => $endTime->format('H:i:s'), // Simpan End Time
            'queue_number'      => 'LX' . date('Ymd') . strtoupper(Str::random(4)),
            'nail_artist_id'    => $bestArtist->id,
            'status'            => 'pending',
            'is_paid'           => 0,
            'booking_fee'       => 25000,
            'total_price'       => 25000, // Harusnya ambil dari TreatmentType->price
        ]);

        // Queue cookie for 60 minutes
        \Illuminate\Support\Facades\Cookie::queue('pending_booking', $reservation->queue_number, 60);

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

        $request->validate([
            'name'             => 'required|string|max:255',
            'phone'            => 'required|string|max:20',
            'address'          => 'required|string',
            'treatment_type'   => 'required',
            'reservation_time' => 'required',
        ]);

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





    // ======================================================
    // ADMIN PANEL — CASHIER PAGE
    // ======================================================
    public function cashier($id)
    {
        $reservation = Reservation::findOrFail($id);
        return view('dashboard.reservations.cashier', compact('reservation'));
    }

    public function cashierQueue()
    {
        $reservations = Reservation::where('status', 'waiting_payment')
            ->orderBy('updated_at', 'desc')
            ->get();

        return view('dashboard.reservations.cashier_queue', compact('reservations'));
    }

    public function processPayment(Request $request, $id)
    {
        $reservation = Reservation::findOrFail($id);

        $request->validate([
            'cash_received' => 'required|numeric|min:' . $reservation->total_price,
        ]);

        // Update Status
        $reservation->status = 'completed';
        $reservation->is_paid = 1;
        $reservation->save();

        // Optional: Record to Income table if you have one
        // Income::create([...]);

        return redirect()->route('dashboard.reservations')
            ->with('success', 'Payment processed successfully! Job Completed.');
    }

}


