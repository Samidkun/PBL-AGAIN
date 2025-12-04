@extends('layouts.app')

@section('title', 'Check Invoice')

@section('content')
<section class="py-5" style="min-height: 80vh; display: flex; align-items: center;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow-lg border-0 rounded-4">
                    <div class="card-body p-5">
                        <div class="text-center mb-4">
                            <h3 class="fw-bold mb-2">Check Booking Status</h3>
                            <p class="text-muted">Enter your Queue Number to check your payment status.</p>
                        </div>

                        <form action="{{ route('payment.check_invoice') }}" method="POST">
                            @csrf
                            <div class="mb-4">
                                <label class="form-label fw-bold">Queue Number</label>
                                <input type="text" name="queue_number" class="form-control form-control-lg" placeholder="e.g. LX2025..." required>
                                @error('queue_number')
                                    <div class="text-danger mt-1 small">{{ $message }}</div>
                                @enderror
                            </div>

                            <button type="submit" class="btn w-100 py-3 fw-bold text-white" style="background: #d889a6; border-radius: 10px;">
                                Check Status
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection
