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

        // Check Expiration
        if ($reservation->status === 'pending' && $reservation->created_at->diffInHours(now()) >= 1) {
            $reservation->status = 'cancelled';
            $reservation->save();
        }

        return view('payment.show', compact('reservation'));
    }

    // =================================================
    // USER: MARK AS PAID (WAITING VALIDATION)
    // =================================================
    public function markPaid(Request $request, $id)
    {
        $request->validate([
            'payment_proof' => 'required|image|max:2048' // Max 2MB
        ]);

        $reservation = Reservation::findOrFail($id);

        if ($request->hasFile('payment_proof')) {
            $path = $request->file('payment_proof')->store('payment_proofs', 'public');
            $reservation->payment_proof = $path;
        }

        $reservation->is_paid = 1;
        $reservation->payment_method = "bank_transfer";
        $reservation->status = "waiting_validation";
        $reservation->save();

        return response()->json([
            'success' => true,
            'invoice_url' => route('payment.invoice', $reservation->queue_number),
            'thank_you_url' => route('reservations.thank-you', ['queue_number' => $reservation->queue_number]),
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

    // =================================================
    // CHECK INVOICE FORM
    // =================================================
    public function checkInvoiceForm()
    {
        return view('payment.check_invoice');
    }

    // =================================================
    // HANDLE CHECK INVOICE
    // =================================================
    public function checkInvoice(Request $request)
    {
        $request->validate([
            'queue_number' => 'required|string|exists:reservations,queue_number'
        ]);

        return redirect()->route('payment.invoice.status', $request->queue_number);
    }

    // =================================================
    // SHOW INVOICE STATUS
    // =================================================
    public function invoiceStatus($queue)
    {
        $reservation = Reservation::where('queue_number', $queue)->firstOrFail();

        // Check Expiration
        if ($reservation->status === 'pending' && $reservation->created_at->diffInHours(now()) >= 1) {
            $reservation->status = 'cancelled';
            $reservation->save();
        }

        return view('payment.invoice_status', compact('reservation'));
    }
}
