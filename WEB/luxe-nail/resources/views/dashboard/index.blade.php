@extends('layouts.dashboard')

@section('title', 'Dashboard - Luxe Nail')
@section('page-title', 'Dashboard Overview')

@section('content')

<!-- === FILTER TANGGAL di dashboard === -->
<form action="{{ route('dashboard') }}" method="GET" class="mb-4">
    <div class="row g-3 align-items-end mt-2"">
        <div class="col-md-3">
            <h5 class="bold" style="color:#ffffff; font-family:'Georgia', serif; margin-bottom:25px;">
                Filter by Date
            </h5>
            <input type="date" name="date" class="form-control" 
                   value="{{ request('date') }}">
        </div>
        <div class="col-md-2">
            <button class="btn w-100 text-light" 
                style="background:#f3b8c2; border-radius:10px;">
                Apply
            </button>
        </div>
        <div class="col-md-2">
            <a href="{{ route('dashboard') }}" 
               class="btn w-100 text-light"
               style="background:#d87a87; border-radius:10px;">
                Reset
            </a>
        </div>
    </div>
</form>

<!-- === DASHBOARD CARDS === -->
<div class="row g-4 mt-2">
    <div class="col-md-3 col-sm-6">
        <div class="card-stat shadow-sm">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6>Total Reservations</h6>
                    <h3>{{ $totalReservations }}</h3>
                </div>
                <i class="bi bi-calendar-check"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="card-stat shadow-sm">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6>Total Nail Art</h6>
                    <h3>{{ $totalNailArt }}</h3>
                </div>
                <i class="bi bi-brush"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="card-stat shadow-sm">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6>Total Nail Extension</h6>
                    <h3>{{ $totalNailExtension }}</h3>
                </div>
                <i class="bi bi-brush-fill"></i>
            </div>
        </div>
    </div>
</div>

<hr class="section-divider">

<!-- === Recent Reservations === -->
<div class="recent-reservations mt-2">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="bold" style="color:#ffffff; font-family:'Georgia', serif;">Recent Reservations</h3>
    </div>

    <div class="card border-0 shadow-sm p-4" 
         style="border-radius:20px; background:linear-gradient(180deg, #fff 0%, #fff5f8 100%);">
        <table class="table align-middle mb-0">
            <thead style="background-color:#ffe6ef;">
                <tr style="color:#451a2b; font-family:'Georgia', serif; font-weight:600;">
                    <th scope="col">Customer</th>
                    <th scope="col">Service</th>
                    <th scope="col" >Date</th>
                    <th scope="col" class="text-center">Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($reservations as $item)
                    <tr class="reservation-row">
                        <td>
                            <i class="bi bi-person-circle me-2 text-pink"></i>
                            {{ $item->name }}
                        </td>
                        <td>
                            {{ $item->treatment_type === 'nail_extension' ? 'Nail Extension' : 'Nail Art' }}
                        </td>
                        <td>
                            {{ \Carbon\Carbon::parse($item->reservation_date)->format('d M Y') }}
                        </td>
                        <td class="text-center">
                            @php
                                $color = match($item->status) {
                                    'completed' => '#46b96a',
                                    'pending'   => '#fcca33',
                                    'confirmed' => '#ff8abb',
                                    'cancelled' => '#ff283d',
                                    default     => '#6c757d'
                                };
                            @endphp
                            <span class="badge rounded-pill px-3 py-2"
                                  style="background-color: {{ $color }}; color:white; font-weight:500;">
                                  {{ ucfirst($item->status) }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="text-center py-3 text-muted">
                            No reservations found for this date.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection