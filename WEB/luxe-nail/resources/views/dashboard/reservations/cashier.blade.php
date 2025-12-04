@extends('layouts.dashboard')

@section('title', 'Cashier - POS')

@section('content')
<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-lg border-0 rounded-lg">
                <div class="card-header bg-primary text-white text-center py-4">
                    <h3 class="mb-0"><i class="fas fa-cash-register me-2"></i> Cashier / POS</h3>
                    <p class="mb-0 opacity-75">Queue: <strong>{{ $reservation->queue_number }}</strong></p>
                </div>
                <div class="card-body p-5">

                    <div class="row mb-4">
                        <div class="col-md-6">
                            <h5 class="text-muted mb-3">Customer Details</h5>
                            <table class="table table-borderless">
                                <tr>
                                    <td class="ps-0 text-muted">Name:</td>
                                    <td class="fw-bold">{{ $reservation->name }}</td>
                                </tr>
                                <tr>
                                    <td class="ps-0 text-muted">Phone:</td>
                                    <td>{{ $reservation->phone }}</td>
                                </tr>
                                <tr>
                                    <td class="ps-0 text-muted">Treatment:</td>
                                    <td>{{ $reservation->treatment_type }}</td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6 text-end">
                            <h5 class="text-muted mb-3">Total Bill</h5>
                            <div class="display-4 fw-bold text-primary mb-2">
                                Rp {{ number_format($reservation->total_price, 0, ',', '.') }}
                            </div>
                            <span class="badge bg-{{ $reservation->status == 'waiting_payment' ? 'warning' : 'secondary' }} fs-6">
                                {{ strtoupper(str_replace('_', ' ', $reservation->status)) }}
                            </span>
                        </div>
                    </div>

                    <hr class="my-4">

                    <form action="{{ route('dashboard.cashier.process', $reservation->id) }}" method="POST" id="paymentForm">
                        @csrf
                        
                        <div class="mb-4">
                            <label for="cash_received" class="form-label fs-5 fw-bold">Cash Received (Rp)</label>
                            <div class="input-group input-group-lg">
                                <span class="input-group-text">Rp</span>
                                <input type="number" 
                                       class="form-control fw-bold" 
                                       id="cash_received" 
                                       name="cash_received" 
                                       placeholder="Enter amount..." 
                                       required
                                       min="{{ $reservation->total_price }}">
                            </div>
                            @error('cash_received')
                                <div class="text-danger mt-1">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="alert alert-success d-none" id="changeAlert">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fs-5">Change (Kembalian):</span>
                                <span class="fs-3 fw-bold" id="changeAmount">Rp 0</span>
                            </div>
                        </div>

                        <div class="d-grid gap-2 mt-5">
                            <button type="submit" class="btn btn-success btn-lg py-3 text-uppercase fw-bold">
                                <i class="fas fa-check-circle me-2"></i> Process Payment & Finish
                            </button>
                            <a href="{{ route('dashboard.reservations') }}" class="btn btn-outline-secondary btn-lg">
                                Cancel
                            </a>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const totalPrice = {{ $reservation->total_price }};
        const cashInput = document.getElementById('cash_received');
        const changeAlert = document.getElementById('changeAlert');
        const changeAmount = document.getElementById('changeAmount');

        cashInput.addEventListener('input', function() {
            const cash = parseFloat(this.value) || 0;
            const change = cash - totalPrice;

            if (change >= 0) {
                changeAlert.classList.remove('d-none');
                changeAmount.textContent = 'Rp ' + new Intl.NumberFormat('id-ID').format(change);
            } else {
                changeAlert.classList.add('d-none');
            }
        });
    });
</script>
@endsection
