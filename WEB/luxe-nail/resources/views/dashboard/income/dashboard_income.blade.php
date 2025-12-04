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
                        <input type="date" name="date" class="filter-input-beauty" value="{{ request('date') }}">
                    </div>

                    <div class="filter-item">
                        <label class="filter-label-beauty">Service</label>
                        <select name="treatment" class="filter-input-beauty">
                            <option value="">Semua Service</option>
                            <option value="Nail Art" {{ request('treatment') == 'Nail Art' ? 'selected' : '' }}>Nail Art
                            </option>
                            <option value="Nail Extension" {{ request('treatment') == 'Nail Extension' ? 'selected' : '' }}>
                                Nail Extension</option>
                        </select>
                    </div>

                    <div class="filter-item">
                        <label class="filter-label-beauty">Status</label>
                        <select name="status" class="filter-input-beauty">
                            <option value="">Semua</option>
                            <option value="Lunas" {{ request('status') == 'Lunas' ? 'selected' : '' }}>Lunas</option>
                            <option value="Pending" {{ request('status') == 'Pending' ? 'selected' : '' }}>Pending</option>
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

            <div style="height: 350px; background-color: #fff; padding: 20px; border-radius: 12px;">
                <canvas id="incomeChart"></canvas>
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
                                        <span class="badge rounded-pill px-3 py-2" style="background-color:{{ $income->payment_status == 'paid' ? '#46b96a' : ($income->payment_status == 'cancelled' ? '#dc3545' : '#fcca33') }};
                                                     color:white; font-weight:500;">
                                            {{ ucfirst($income->payment_status) }}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        {{-- Contoh tombol aksi, sesuaikan routenya nanti --}}
                                        {{-- <a href="{{ route('dashboard.income.edit', $income->id) }}"
                                            class="btn btn-sm btn-outline-primary" style="border-radius: 8px;">
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
@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const ctx = document.getElementById('incomeChart').getContext('2d');

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: @json($chartLabels),
            datasets: [{
                label: 'Income per Month',
                data: @json($chartData),

                // 🎨 Gradient Color (lebih menarik!)
                backgroundColor: function(context) {
                    const chart = context.chart;
                    const {ctx, chartArea} = chart;
                    if (!chartArea) return 'rgba(232, 138, 191, 0.6)';
                    
                    const gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
                    gradient.addColorStop(0, 'rgba(232, 138, 191, 0.4)');
                    gradient.addColorStop(0.5, 'rgba(232, 138, 191, 0.7)');
                    gradient.addColorStop(1, 'rgba(232, 138, 191, 1)');
                    return gradient;
                },
                borderColor: '#e88abf',
                borderWidth: 2,

                // 📏 Bar styling
                borderRadius: 12,
                barThickness: 50,
                maxBarThickness: 60,

                // ✨ Hover effect
                hoverBackgroundColor: 'rgba(232, 138, 191, 0.9)',
                hoverBorderColor: '#d6479e',
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            
            // 🎭 Animasi smooth
            animation: {
                duration: 1500,
                easing: 'easeInOutQuart'
            },

            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        font: {
                            size: 14,
                            family: 'Poppins',
                            weight: '600'
                        },
                        color: '#333',
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    titleFont: {
                        size: 14,
                        family: 'Poppins',
                        weight: 'bold'
                    },
                    bodyFont: {
                        size: 13,
                        family: 'Poppins'
                    },
                    padding: 12,
                    cornerRadius: 8,
                    displayColors: true,
                    callbacks: {
                        label: function(context) {
                            return 'Income: Rp ' + context.parsed.y.toLocaleString('id-ID');
                        }
                    }
                }
            },

            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(200, 200, 200, 0.2)',
                        drawBorder: false
                    },
                    ticks: {
                        callback(value) {
                            return 'Rp ' + value.toLocaleString('id-ID');
                        },
                        font: { 
                            size: 12,
                            family: 'Poppins'
                        },
                        color: '#666',
                        padding: 8
                    }
                },
                x: {
                    grid: {
                        display: false,
                        drawBorder: false
                    },
                    ticks: { 
                        font: { 
                            size: 12,
                            family: 'Poppins',
                            weight: '500'
                        },
                        color: '#666',
                        padding: 8
                    }
                }
            },

            // 🎯 Interaksi lebih smooth
            interaction: {
                intersect: false,
                mode: 'index'
            }
        }
    });
</script>
@endsection

