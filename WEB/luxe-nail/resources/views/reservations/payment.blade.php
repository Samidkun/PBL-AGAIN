@extends('layouts.app')

@section('title', 'Payment')

@section('content')
<div class="container py-5">

    <div class="text-center mb-5">
        <h2 class="fw-bold" style="font-family: 'Playfair Display', serif;">
            Complete Your Payment
        </h2>
        <p class="text-muted">Please finish your payment to confirm your booking.</p>
    </div>

    <div class="row justify-content-center">
        <div class="col-lg-6">

            <!-- Card -->
            <div class="card shadow-lg border-0 p-4"
                 style="border-radius: 20px; background: #fff5f7;">

                {{-- SUMMARY --}}
                <h4 class="fw-bold mb-3" style="font-family: 'Playfair Display', serif;">
                    Booking Summary
                </h4>

                <div class="mb-3">
                    <strong>Name:</strong> {{ $reservation->name }} <br>
                    <strong>Treatment:</strong> {{ ucfirst(str_replace('_',' ',$reservation->treatment_type)) }} <br>
                    <strong>Date:</strong> {{ $reservation->reservation_date }} <br>
                    <strong>Time:</strong> {{ $reservation->reservation_time }} <br>
                    <strong>Queue:</strong> {{ $reservation->queue_number }}
                </div>

                <hr>

                {{-- PAYMENT STATUS --}}
                <h5 class="fw-bold mb-2">Payment Status</h5>

                @if($reservation->is_paid == 0)
                    <div class="alert alert-warning p-2">
                        <strong>Pending:</strong> You haven't submitted your payment.
                    </div>
                @elseif($reservation->status === 'waiting_validation')
                    <div class="alert alert-info p-2">
                        <strong>Waiting Validation:</strong> Admin will verify your payment shortly.
                    </div>
                @elseif($reservation->status === 'confirmed')
                    <div class="alert alert-success p-2">
                        <strong>Confirmed:</strong> Your payment is approved & booking is confirmed!
                    </div>
                @endif

                <hr>

                {{-- PAYMENT METHOD --}}
                <h5 class="fw-bold mb-3">Payment Method</h5>
                <div class="p-3 bg-white rounded shadow-sm mb-3"
                     style="border-left: 4px solid #d889a6;">
                    <strong>Bank Transfer</strong> <br>
                    <span class="text-muted">Transfer to the account below:</span>

                    <div class="mt-3">
                        <div class="small text-muted">Account Number</div>
                        <div class="fw-bold fs-5">1234 5678 9101</div>

                        <div class="small text-muted mt-2">Account Name</div>
                        <div class="fw-bold">LUXE NAIL STUDIO</div>

                        <div class="small text-muted mt-2">Bank</div>
                        <div class="fw-bold">BCA</div>
                    </div>
                </div>

                <hr>

                {{-- TOTAL --}}
                <h5 class="fw-bold mb-2">Price Details</h5>

                <div class="d-flex justify-content-between small mb-1">
                    <span>Booking Fee</span>
                    <span>Rp {{ number_format($reservation->booking_fee ?? 25000, 0, ',', '.') }}</span>
                </div>

                <div class="d-flex justify-content-between small mb-1">
                    <span>Service Price</span>
                    <span>Rp {{ number_format($reservation->total_price, 0, ',', '.') }}</span>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-3">
                    <h4 class="fw-bold m-0" style="color:#d889a6;">
                        Total: Rp {{ number_format(($reservation->total_price + ($reservation->booking_fee ?? 25000)), 0, ',', '.') }}
                    </h4>
                </div>

                {{-- BUTTON --}}
                @if($reservation->status === 'pending')
                    <button id="payBtn" class="btn w-100 py-3 fw-bold mt-4"
                        style="background:#d889a6; color:white; border-radius:10px;">
                        I Have Transferred
                    </button>

                    <p class="text-center text-muted mt-3 small">
                        After submitting, you MUST download your invoice.
                    </p>

                @else
                    <p class="text-center mt-4 fw-bold text-success">
                        Payment already submitted.
                    </p>
                @endif

            </div>
        </div>
    </div>
</div>

{{-- AJAX Script --}}
<script>
document.getElementById("payBtn")?.addEventListener("click", async () => {

    const response = await fetch("{{ route('payment.paid', $reservation->id) }}", {
        method: "POST",
        headers: {
            "X-CSRF-TOKEN": "{{ csrf_token() }}"
        }
    });

    const data = await response.json();

    if (!data.success) {
        alert("Error submitting payment.");
        return;
    }

    // 1. Paksa download PDF
    const a = document.createElement("a");
    a.href = data.invoice_url;
    a.download = "";
    document.body.appendChild(a);
    a.click();
    a.remove();

    // 2. Redirect setelah download
    setTimeout(() => {
        window.location.href = data.thank_you_url;
    }, 2000);
});
</script>

@endsection
