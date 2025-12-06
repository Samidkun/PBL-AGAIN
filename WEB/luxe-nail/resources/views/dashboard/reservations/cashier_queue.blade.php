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
                            <th class="ps-4">Queue No</th>
                            <th>Customer</th>
                            <th>Treatment</th>
                            <th>Total Bill</th>
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
                            <td>{{ $r->updated_at->format('H:i') }}</td>
                            <td class="text-end pe-4">
                                <a href="{{ route('dashboard.cashier', $r->id) }}" class="btn btn-success btn-sm text-white">
                                    <i class="fas fa-money-bill-wave me-1"></i> Process Payment
                                </a>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
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

@push('scripts')
<script>
    // Auto-refresh every 5 seconds
    setInterval(function() {
        location.reload();
    }, 5000);
</script>
@endpush
@endsection
