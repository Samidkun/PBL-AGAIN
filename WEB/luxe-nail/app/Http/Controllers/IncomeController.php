<?php

namespace App\Http\Controllers;

use App\Models\Income;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Carbon\Carbon; // WAJIB: Import Carbon

class IncomeController extends Controller
{
    /**
     * Store income after nail artist submits payment screen (API LOGIC)
     * (Fungsi ini biarkan sama dengan yang sudah diperbaiki sebelumnya)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'reservation_id'    => 'required|exists:reservations,id',
            'shape'             => 'nullable|string',
            'color'             => 'nullable|string',
            'finish'            => 'nullable|string',
            'accessory'         => 'nullable|string',
            'price_shape'       => 'required|numeric|min:0',
            'price_color'       => 'required|numeric|min:0',
            'price_finish'      => 'required|numeric|min:0',
            'price_accessory'   => 'required|numeric|min:0',
            'total_price'       => 'required|numeric|min:0',
            'ai_image_url'      => 'nullable|string',
            'payment_method'    => 'required|in:cash,transfer,bank_transfer',
        ]);

        $reservation = Reservation::find($validated['reservation_id']);

        if (!$reservation) {
            return response()->json(['success' => false, 'message' => 'Reservation not found'], 404);
        }
        
        // CHECK: If paid, ensure no duplicate income record exists.
        // If is_paid=1 but NO income record, we allow it (case: bank transfer proof uploaded).
        if ($reservation->is_paid == 1 && $reservation->income()->exists()) {
             return response()->json(['success' => false, 'message' => 'Reservation already paid and recorded.'], 400);
        }

        $income = Income::create([
            'reservation_id'    => $reservation->id,
            'customer_name'     => $reservation->name,
            'customer_phone'    => $reservation->phone,
            'treatment_type'    => $reservation->treatment_type,
            'shape'             => $validated['shape'] ?? null,
            'color'             => $validated['color'] ?? null,
            'finish'            => $validated['finish'] ?? null,
            'accessory'         => $validated['accessory'] ?? null,
            'price_shape'       => $validated['price_shape'],
            'price_color'       => $validated['price_color'],
            'price_finish'      => $validated['price_finish'],
            'price_accessory'   => $validated['price_accessory'],
            'total_price'       => $validated['total_price'],
            'ai_image_url'      => $validated['ai_image_url'] ?? null,
            'payment_status'    => 'paid',
            'payment_method'    => $validated['payment_method'],
            'reservation_date'  => $reservation->reservation_date,
        ]);

        $reservation->update([
            'is_paid'       => 1,
            'total_price'   => $validated['total_price'],
            'status'        => 'confirmed',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment recorded and reservation confirmed.',
            'data'    => $income
        ]);
    }



    /**
     * List all income for dashboard (FIXED ALL VARIABLES)
     */
    public function index()
    {
        // 1. Ambil semua data income
        $incomes = Income::orderBy('created_at', 'desc')->get();

        // 2. Hitung total bulanan
        $totalMonthly = $incomes->sum('total_price');

        // 3. Hitung total hari ini
        $totalToday = Income::whereDate('created_at', Carbon::today())->sum('total_price');

        // 4. HITUNG JUMLAH RESERVASI/INCOME (FIXED $totalReservation)
        $totalReservation = $incomes->count();

        // 5. KEMBALIKAN VIEW DENGAN SEMUA VARIABEL
        return view('dashboard.income.dashboard_income', compact('incomes', 'totalMonthly', 'totalToday', 'totalReservation'));
    }
}
