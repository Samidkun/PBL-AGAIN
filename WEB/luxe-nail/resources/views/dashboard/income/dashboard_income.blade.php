@extends('layouts.dashboard')

@section('title', 'Income Dashboard')

@section('content')
<link rel="stylesheet" href="{{ asset('css/income.css') }}">

<div class="income-page">
    <div class="dashboard-header">
        <div class="header-content">
            <h1 class="dashboard-title">
                <i class="fas fa-chart-line me-3"></i>Income Dashboard
            </h1>
            <p class="dashboard-subtitle">Summary of transactions and revenue by reservation.</p>
        </div>
    </div>

    <div class="card-section filter-card mb-6">
        <h2 class="card-title" style="font-family: 'Georgia', serif;">Filters</h2>
        <form method="GET" action="{{ route('dashboard.income') }}">
            <div class="filter-grid-beauty">

                <div class="filter-item">
                    <label class="filter-label-beauty">Tanggal</label>
                    <input type="date"
                       name="date"
                       class="filter-input-beauty"
                       value="{{ request('date') }}">
                </div>

                <div class="filter-item">
                    <label class="filter-label-beauty">Service</label>
                    <select name="treatment" class="filter-input-beauty">
                        <option value="">Semua Service</option>
                        <option value="Nail Art" {{ request('treatment')=='Nail Art' ? 'selected' : '' }}>Nail Art</option>
                        <option value="Nail Extension" {{ request('treatment')=='Nail Extension' ? 'selected' : '' }}>Nail Extension</option>
                    </select>
                </div>

                <div class="filter-item">
                    <label class="filter-label-beauty">Status</label>
                    <select name="status" class="filter-input-beauty">
                        <option value="">Semua</option>
                        <option value="Lunas" {{ request('status')=='Lunas' ? 'selected' : '' }}>Lunas</option>
                        <option value="Pending" {{ request('status')=='Pending' ? 'selected' : '' }}>Pending</option>
                    </select>
                </div>

                <div class="filter-item filter-button-box">
                    <button class="filter-btn-beauty" type="submit">Filter</button>
                </div>

            </div>
        </form>
    </div>


    <div class="card-section filter-card mb-6">
        <h2 class="card-title" style="font-family: 'Georgia', serif;">Reservation Customer Data</h2>

        <div class="payment-list">
            {{-- Menggunakan $incomes yang sudah difilter dari controller --}}
            @forelse($incomes as $income)
            <div class="payment-item">
                <div>
                    <h4 class="payment-name">{{ $income->customer_name }}</h4>
                    <p class="payment-info">
                        {{ $income->treatment_type }} •
                        {{ $income->created_at->format('d M Y') }}
                    </p>
                </div>
                <h4 class="payment-amount">
                    Rp {{ number_format($income->total_price, 0, ',', '.') }}
                </h4>
            </div>
            @empty
            <p class="text-center mt-3">Belum ada data income berdasarkan filter ini.</p>
            @endforelse

        </div>
    </div>


    {{-- PERBAIKAN DISINI: Blok @php yang error telah dihapus --}}

    <div class="summary-grid mb-6">
        <div class="summary-card">
            <p class="page-subtitle">Total Income Bulanan</p>
            {{-- PERBAIKAN: Menggunakan variabel $totalMonthly dari Controller --}}
            <p class="value">Rp {{ number_format($totalMonthly, 0, ',', '.') }}</p>
        </div>
        <div class="summary-card">
            <p class="page-subtitle">Total Income Hari Ini</p>
            {{-- PERBAIKAN: Menggunakan variabel $totalToday dari Controller --}}
            <p class="value">Rp {{ number_format($totalToday, 0, ',', '.') }}</p>
        </div>
        <div class="summary-card">
            <p class="page-subtitle">Total Reservation</p>
            {{-- PERBAIKAN: Menggunakan variabel $totalReservation dari Controller --}}
            <p class="value">{{ $totalReservation }}</p>
        </div>
    </div>


    <div class="card-section income-chart-card mb-10">
        <h2 class="card-title" style="font-family: 'Georgia', serif;">Income Chart</h2>
        {{-- Placeholder dipercantik sedikit --}}
        <div class="chart-placeholder" style="height: 300px; background-color: #f8f9fa; display: flex; justify-content: center; align-items: center; border-radius: 12px; border: 2px dashed #dee2e6; color: #6c757d;">
            <p class="mb-0">(Area Chart Income - Membutuhkan implementasi JavaScript)</p>
        </div>
    </div>


    <div class="detail-income mt-5">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3 class="bold" style="color:#ffffff; font-family:'Georgia', serif;">Detail Income</h3>
            {{-- Tombol ini me-refresh halaman ke default tanpa filter --}}
            <a href="{{ route('dashboard.income') }}" class="btn btn-sm text-light px-3 py-2"
                style="background-color:#ee9ca7; border:none; border-radius:10px; font-family:'Georgia', serif;">
                Reset Filter →
            </a>
        </div>

        <div class="card border-0 shadow-sm p-4"
             style="border-radius:20px; background:linear-gradient(180deg, #fff 0%, #fff5f8 100%);">

            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead style="background-color:#ffe6ef;">
                        <tr style="color:#451a2b; font-family:'Georgia', serif; font-weight:600;">
                            <th class="text-center">Customer</th>
                            <th class="text-center">Reservasi</th>
                            <th class="text-center">Tanggal</th>
                            <th class="text-center">Total</th>
                            <th class="text-center">Status</th>
                            {{-- Menambahkan kolom aksi jika nanti dibutuhkan untuk Edit/Hapus --}}
                            <th class="text-center">Aksi</th>
                        </tr>
                    </thead>

                    <tbody>
                        @forelse($incomes as $income)
                        <tr class="reservation-row">
                            <td class="text-center fw-bold">{{ $income->customer_name }}</td>
                            <td class="text-center">{{ $income->treatment_type }}</td>
                            <td class="text-center">{{ $income->created_at->format('d M Y, H:i') }}</td>
                            <td class="text-center fw-bold" style="color: #d63384;">
                                Rp {{ number_format($income->total_price, 0, ',', '.') }}
                            </td>
                            <td class="text-center">
                                <span class="badge rounded-pill px-3 py-2"
                                      style="background-color:{{ $income->payment_status == 'paid' ? '#46b96a' : ($income->payment_status == 'cancelled' ? '#dc3545' : '#fcca33') }};
                                             color:white; font-weight:500;">
                                    {{ ucfirst($income->payment_status) }}
                                </span>
                            </td>
                            <td class="text-center">
                                {{-- Contoh tombol aksi, sesuaikan routenya nanti --}}
                                {{-- <a href="{{ route('dashboard.income.edit', $income->id) }}" class="btn btn-sm btn-outline-primary" style="border-radius: 8px;">
                                    <i class="fas fa-edit"></i>
                                </a> --}}
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
                                <i class="fas fa-inbox fa-3x mb-3" style="color: #e2e6ea;"></i>
                                <p>Belum ada data transaksi yang ditemukan.</p>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>
@endsection
