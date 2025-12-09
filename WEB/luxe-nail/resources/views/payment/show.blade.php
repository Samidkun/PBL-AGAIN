@extends('layouts.app')

@section('title', 'Payment')

@section('content')
    <section class="payment-page">
        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-lg-7 col-md-9">

                    {{-- SEMUA MASUK KE 1 CARD PUTIH --}}
                    <div class="payment-card">

                        {{-- HEADER DI DALAM CARD (biar ga misah strip pink) --}}
                        <div class="payment-header text-center">
                            <h2 class="payment-header-title">
                                Complete Your Payment
                            </h2>
                            <p class="payment-header-subtitle">
                                Please finish your payment to confirm your booking.
                            </p>
                        </div>

                        {{-- SUMMARY --}}
                        <div class="payment-section">
                            <div class="payment-title">Booking Summary</div>

                            <div class="summary-grid">
                                <div class="summary-item">
                                    <span class="label">Name</span>
                                    <span class="value">{{ $reservation->name }}</span>
                                </div>

                                <div class="summary-item">
                                    <span class="label">Treatment</span>
                                    <span class="value">
                                        {{ ucfirst(str_replace('_', ' ', $reservation->treatment_type)) }}
                                    </span>
                                </div>

                                <div class="summary-item">
                                    <span class="label">Date</span>
                                    <span class="value">{{ $reservation->reservation_date }}</span>
                                </div>

                                <div class="summary-item">
                                    <span class="label">Time</span>
                                    <span class="value">{{ $reservation->reservation_time }}</span>
                                </div>

                                <div class="summary-item" style="grid-column: 1 / -1;">
                                    <span class="label">Invoice Number</span>
                                    <span class="value"
                                        style="font-size: 1.5rem; color: #d889a6;">{{ $reservation->queue_number }}</span>
                                    <small class="d-block text-danger mt-1" style="font-size: 0.8rem;">
                                        <i class="fas fa-exclamation-circle"></i> SAVE THIS NUMBER! You can use it to check
                                        your booking status if you leave this page.
                                    </small>
                                </div>
                            </div>
                        </div>

                        {{-- STATUS --}}
                        <div class="payment-section">
                            <div class="payment-title">Payment Status</div>

                            @if($reservation->is_paid == 0)
                                <div class="status-badge pending">
                                    <div>
                                        <div class="status-title">Pending</div>
                                        <div class="status-desc">You haven't submitted your payment.</div>
                                    </div>
                                </div>
                            @elseif($reservation->status === 'waiting_validation')
                                <div class="status-badge waiting">
                                    <div>
                                        <div class="status-title">Waiting Validation</div>
                                        <div class="status-desc">Admin will verify your payment shortly.</div>
                                    </div>
                                </div>
                            @elseif($reservation->status === 'confirmed')
                                <div class="status-badge confirmed">
                                    <div>
                                        <div class="status-title">Confirmed</div>
                                        <div class="status-desc">Your payment is approved & booking is confirmed!</div>
                                    </div>
                                </div>
                            @endif
                        </div>

                        {{-- PAYMENT METHOD --}}
                        <div class="payment-section">
                            <div class="payment-title">Payment Method</div>

                            <div class="bank-card">
                                <div class="bank-header">
                                    <div class="bank-icon">
                                        <i class="fas fa-university"></i>
                                    </div>
                                    <div>
                                        <div class="bank-title">Bank Transfer</div>
                                        <div class="bank-desc">Transfer to the account below:</div>
                                    </div>
                                </div>

                                <div class="bank-info">
                                    <div class="bank-row">
                                        <span class="bank-label">Account Number</span>
                                        <span class="bank-value">1234 5678 9101</span>
                                    </div>
                                    <div class="bank-row">
                                        <span class="bank-label">Account Name</span>
                                        <span class="bank-value">LUXE NAIL STUDIO</span>
                                    </div>
                                    <div class="bank-row">
                                        <span class="bank-label">Bank</span>
                                        <span class="bank-value">BCA</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- PRICE --}}
                        <div class="payment-section">
                            <div class="payment-title">Price Details</div>

                            <div class="price-row">
                                <span>Booking Fee</span>
                                <span>Rp {{ number_format($reservation->booking_fee ?? 25000, 0, ',', '.') }}</span>
                            </div>

                            <div class="price-row">
                                <span>Service Price</span>
                                <span>Rp {{ number_format($reservation->total_price, 0, ',', '.') }}</span>
                            </div>

                            <div class="price-total">
                                Total: Rp
                                {{ number_format(($reservation->total_price + ($reservation->booking_fee ?? 25000)), 0, ',', '.') }}
                            </div>
                        </div>

                        {{-- BUTTON --}}
                        @if($reservation->status === 'pending')
                            <form id="paymentForm" enctype="multipart/form-data">
                                <div class="mb-3">
                                    <label class="fw-bold">Upload Payment Proof</label>
                                    <input type="file" name="payment_proof" class="form-control" required accept="image/*">
                                    <small class="text-muted">Max 2MB (JPG, PNG)</small>
                                </div>

                                <button type="submit" class="btn w-100 py-3 fw-bold mt-4"
                                    style="background:#d889a6; color:white; border-radius:10px;">
                                    Confirm Payment
                                </button>
                            </form>

                            <p class="text-center text-muted mt-3 small">
                                After submitting, you MUST download your invoice.
                            </p>
                        @else
                            <div class="payment-done">
                                Payment already submitted.
                            </div>
                        @endif

                    </div>
                </div>
            </div>
    </section>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        document.getElementById("paymentForm")?.addEventListener("submit", async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);

            // Show loading
            Swal.fire({
                title: 'Processing Payment...',
                html: 'Please wait while we verify your proof.',
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });

            try {
                const response = await fetch("{{ route('payment.paid', $reservation->id) }}", {
                    method: "POST",
                    headers: { "X-CSRF-TOKEN": "{{ csrf_token() }}" },
                    body: formData
                });

                const data = await response.json();

                if (!data.success) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Payment Failed',
                        text: 'Error submitting payment. Please try again.',
                        confirmButtonColor: '#d889a6'
                    });
                    return;
                }

                // Show success
                Swal.fire({
                    icon: 'success',
                    title: 'Payment Submitted!',
                    text: 'Downloading your invoice...',
                    timer: 2000,
                    showConfirmButton: false
                });

                // download invoice
                const a = document.createElement("a");
                a.href = data.invoice_url;
                a.download = "";
                document.body.appendChild(a);
                a.click();
                a.remove();

                setTimeout(() => {
                    window.location.href = data.thank_you_url;
                }, 2000);

            } catch (error) {
                Swal.fire({
                    icon: 'error',
                    title: 'System Error',
                    text: 'Something went wrong. Please check your connection.',
                    confirmButtonColor: '#d889a6'
                });
            }
        });
    </script>
@endsection