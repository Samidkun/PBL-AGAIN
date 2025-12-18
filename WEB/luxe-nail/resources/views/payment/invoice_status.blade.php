@extends('layouts.app')

@section('title', 'Invoice Status')

@section('content')
    <section class="py-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-lg border-0 rounded-4 overflow-hidden">
                        <div class="card-header bg-white p-4 border-bottom text-center">
                            <h4 class="fw-bold mb-0">Invoice Details</h4>
                            <p class="text-muted mb-0">Invoice Number: <span
                                    class="fw-bold text-dark">{{ $reservation->queue_number }}</span></p>
                        </div>
                        <div class="card-body p-5">

                            {{-- STATUS BADGE --}}
                            <div class="text-center mb-5">
                                @if($reservation->status === 'cancelled')
                                    <div class="badge bg-danger fs-5 px-4 py-2 rounded-pill">EXPIRED / CANCELLED</div>
                                    <p class="text-danger mt-2">This reservation has expired because payment was not completed
                                        within 1 hour.</p>
                                @elseif($reservation->is_paid == 0)
                                    <div class="badge bg-warning text-dark fs-5 px-4 py-2 rounded-pill">PENDING PAYMENT</div>
                                    <p class="text-muted mt-2">Please complete your payment to confirm the booking.</p>
                                @elseif($reservation->status === 'waiting_validation')
                                    <div class="badge bg-info text-white fs-5 px-4 py-2 rounded-pill">WAITING VALIDATION</div>
                                    <p class="text-muted mt-2">Admin is verifying your payment.</p>
                                @elseif($reservation->status === 'confirmed')
                                    <div class="badge bg-success fs-5 px-4 py-2 rounded-pill">CONFIRMED</div>
                                    <p class="text-success mt-2">Your booking is confirmed!</p>
                                @endif
                            </div>

                            {{-- DETAILS --}}
                            <div class="row g-4 mb-5">
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted small fw-bold">Customer Details</h6>
                                    <p class="mb-0 fw-bold">{{ $reservation->name }}</p>
                                    <p class="mb-0 text-muted">{{ $reservation->phone }}</p>
                                </div>
                                <div class="col-md-6 text-md-end">
                                    <h6 class="text-uppercase text-muted small fw-bold">Booking Info</h6>
                                    <p class="mb-0 fw-bold">
                                        {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('d M Y') }}</p>
                                    <p class="mb-0 text-muted">
                                        {{ \Carbon\Carbon::parse($reservation->reservation_time)->format('H:i') }}</p>
                                    <p class="mb-0 text-primary">
                                        {{ ucfirst(str_replace('_', ' ', $reservation->treatment_type)) }}</p>
                                </div>
                            </div>

                            {{-- ACTION BUTTONS --}}
                            <div class="d-grid gap-2">
                                @if($reservation->status === 'pending')
                                    <a href="{{ route('payment.show', $reservation->id) }}" class="btn btn-primary py-3 fw-bold"
                                        style="background: #d889a6; border:none;">
                                        Pay Now
                                    </a>
                                @elseif($reservation->status === 'cancelled')
                                    <a href="{{ route('reservations.create') }}" class="btn btn-outline-dark py-3 fw-bold">
                                        Make New Booking
                                    </a>
                                @else
                                    <a href="{{ route('payment.invoice', $reservation->queue_number) }}"
                                        class="btn btn-outline-primary py-3 fw-bold">
                                        Download Invoice
                                    </a>
                                @endif

                                <a href="{{ route('home') }}" class="btn btn-link text-muted mt-2">Back to Home</a>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
@endsection