<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reservation;
use Barryvdh\DomPDF\Facade\Pdf;

class PaymentController extends Controller
{
    // =================================================
    // SHOW PAYMENT PAGE
    // =================================================
    public function show($id)
    {
        $reservation = Reservation::findOrFail($id);
        return view('payment.show', compact('reservation'));
    }

    // =================================================
    // USER: MARK AS PAID (WAITING VALIDATION)
    // =================================================
    public function markPaid(Request $request, $id)
    {
        $reservation = Reservation::findOrFail($id);

        $reservation->is_paid = 1;
        $reservation->payment_method = "bank_transfer";
        $reservation->status = "waiting_validation";
        $reservation->save();

        return response()->json([
            'success' => true,
            'invoice_url' => route('payment.invoice', $reservation->queue_number),
        ]);
    }

    // =================================================
    // ADMIN CONFIRM PAYMENT
    // =================================================
    public function adminConfirm($id)
    {
        $reservation = Reservation::findOrFail($id);

        if ($reservation->status !== 'waiting_validation') {
            return response()->json([
                'success' => false,
                'message' => 'This reservation has no pending payment.'
            ], 400);
        }

        $reservation->status = "confirmed";
        $reservation->save();

        return response()->json([
            'success' => true,
            'message' => 'Payment verified successfully.'
        ]);
    }

    // =================================================
    // DOWNLOAD INVOICE PDF
    // =================================================
    public function downloadInvoice($queue)
    {
        $reservation = Reservation::where('queue_number', $queue)->firstOrFail();

        $pdf = Pdf::loadView('reservations.pdf', compact('reservation'))
            ->setPaper('a5', 'portrait');

        return $pdf->download("Invoice_{$reservation->queue_number}.pdf");
    }
}
