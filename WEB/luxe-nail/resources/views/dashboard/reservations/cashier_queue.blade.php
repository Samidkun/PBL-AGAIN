@extends('layouts.dashboard')

@section('title', 'Cashier Queue')

@section('content')
<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="text-primary fw-bold"><i class="fas fa-cash-register me-2"></i> Cashier Queue</h2>
        <span class="badge bg-warning text-dark fs-6">{{ count($reservations) }} Waiting Payment</span>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="ps-4">Invoice No</th>
                            <th>Customer</th>
                            <th>Treatment</th>
                            <th>Total Bill</th>
                            <th>Time Start</th>
                            <th>Time Finished</th>
                            <th class="text-end pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($reservations as $r)
                            <tr>
                                <td class="ps-4 fw-bold">{{ $r->queue_number }}</td>
                                <td>
                                    <div class="fw-bold">{{ $r->name }}</div>
                                    <small class="text-muted">{{ $r->phone }}</small>
                                </td>
                                <td>{{ $r->treatment_type }}</td>
                                <td class="fw-bold text-primary">Rp {{ number_format($r->total_price, 0, ',', '.') }}</td>
                                <td>
                                    @if(isset($r->start_time) && $r->start_time)
                                        {{ \Carbon\Carbon::parse($r->start_time)->format('H:i') }}
                                    @else
                                        {{ \Carbon\Carbon::parse($r->reservation_time)->format('H:i') }}
                                    @endif
                                </td>
                                <td>
                                    @if(isset($r->end_time) && $r->end_time)
                                        {{ \Carbon\Carbon::parse($r->end_time)->format('H:i') }}
                                    @else
                                        -
                                    @endif
                                </td>
                                <td class="text-end pe-4">
                                    <a href="{{ route('dashboard.cashier', $r->id) }}"
                                        class="btn btn-success btn-sm text-white">
                                        <i class="fas fa-money-bill-wave me-1"></i> Process Payment
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fas fa-check-circle fa-3x mb-3 text-success opacity-50"></i>
                                    <p class="mb-0">No pending payments.</p>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

{{-- Payment Success Modal --}}
<div class="modal fade" id="paymentSuccessModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="fas fa-check-circle me-2"></i>Payment Successful!</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-4">
                <i class="fas fa-check-circle text-success" style="font-size: 4rem;"></i>
                <h4 class="mt-3">Payment Processed</h4>
                <p class="text-muted mb-0">Invoice: <strong id="modalQueueNumber"></strong></p>
                <p class="text-muted">Change: <strong id="modalChange"></strong></p>
            </div>
            <div class="modal-footer justify-content-center">
                <a href="#" id="printReceiptBtn" class="btn btn-primary" target="_blank">
                    <i class="fas fa-print me-2"></i>Print Receipt
                </a>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

{{-- Auto Refresh Every 20 seconds --}}
<script>
    @if(session('payment_success'))
        // Show payment success modal
        const modal = new bootstrap.Modal(document.getElementById('paymentSuccessModal'));
        document.getElementById('modalQueueNumber').textContent = '{{ session("queue_number") }}';
        document.getElementById('modalChange').textContent = 'Rp {{ number_format(session("change", 0), 0, ",", ".") }}';
        document.getElementById('printReceiptBtn').href = '/payment/invoice/{{ session("reservation_id") }}';
        modal.show();
        
        // Auto refresh after modal is closed
        document.getElementById('paymentSuccessModal').addEventListener('hidden.bs.modal', function () {
            location.reload();
        });
    @else
        // Normal auto refresh
        setTimeout(function() {
            location.reload();
        }, 20000);
    @endif
</script>
@endsection