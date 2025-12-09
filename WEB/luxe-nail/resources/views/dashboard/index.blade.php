@extends('layouts.dashboard')

@section('title', 'Dashboard - Luxe Nail')

@section('greeting')
    <h2>Hello Owner!</h2>
    <h5>Get ready for a productive day with Luxe Nail</h5>
@endsection

@section('content')

    <div class="row g-4 mt-2">
        <div class="col-xl-3 col-md-6">
            <div class="card-stat">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6>Total Reservations</h6>
                        <h3>{{ number_format($totalReservations) }}</h3>
                    </div>
                    <i class="bi bi-calendar-check fs-1"></i>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card-stat">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6>Total Nail Art</h6>
                        <h3>{{ number_format($totalNailArt) }}</h3>
                    </div>
                    <i class="bi bi-brush fs-1"></i>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card-stat">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6>Total Nail Extension</h6>
                        <h3>{{ number_format($totalNailExtension) }}</h3>
                    </div>
                    <i class="bi bi-brush-fill fs-1"></i>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card-stat income-card">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6>Total Income</h6>
                        <h3>Rp {{ number_format($totalIncome, 0, ',', '.') }}</h3>
                        <small class="text-muted">{{ ucfirst($incomeFilter) }} view</small>
                    </div>
                    <i class="bi bi-cash-stack fs-1 text-success"></i>
                </div>
            </div>
        </div>
    </div>

    <hr class="section-divider">

    {{-- INCOME STATISTICS --}}
    <div class="card border-0 shadow-sm mb-4"
        style="border-radius:20px; background:linear-gradient(180deg, #fff 0%, #fff5f8 100%);">
        <div class="card-body p-4">

            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
                <h3 class="bold mb-0" style="color:#d87a87; font-family:'Georgia', serif;">
                    <i class="bi bi-graph-up me-2"></i>Income Statistics
                </h3>

                <form action="{{ route('dashboard') }}" method="GET" class="d-flex flex-wrap gap-2 align-items-center"
                    id="incomeFilterForm">

                    @if($reservationDate)
                        <input type="hidden" name="reservation_date" value="{{ $reservationDate }}">
                    @endif

                    <div class="input-group input-group-sm" style="width: auto;">
                        <span class="input-group-text">
                            <i class="bi bi-funnel"></i>
                        </span>
                        <select name="income_filter" class="form-select" style="width: 120px;" id="incomeFilterSelect">
                            <option value="daily" {{ $incomeFilter == 'daily' ? 'selected' : '' }}>Daily</option>
                            <option value="monthly" {{ $incomeFilter == 'monthly' ? 'selected' : '' }}>Monthly</option>
                            <option value="yearly" {{ $incomeFilter == 'yearly' ? 'selected' : '' }}>Yearly</option>
                        </select>
                    </div>

                    <div class="input-group input-group-sm filter-input" id="dailyFilter"
                        style="width:auto; display: {{ $incomeFilter == 'daily' ? 'block' : 'none' }};">
                        <input type="date" name="income_date" class="form-control" style="width: 150px;"
                            value="{{ $incomeDate }}">
                    </div>

                    <div class="input-group input-group-sm filter-input" id="monthlyFilter"
                        style="width:auto; display: {{ $incomeFilter == 'monthly' ? 'block' : 'none' }};">
                        <input type="month" name="month_year" class="form-control" style="width: 150px;"
                            value="{{ $monthYear }}">
                    </div>

                    <div class="input-group input-group-sm filter-input" id="yearlyFilter"
                        style="width:auto; display: {{ $incomeFilter == 'yearly' ? 'block' : 'none' }};">
                        <input type="number" name="year" class="form-control" style="width: 100px;" min="2020" max="2035"
                            value="{{ $yearFilter }}">
                    </div>

                    <button type="submit" class="btn btn-sm text-light"
                        style="background:#f3b8c2; border-radius:10px; padding: 6px 20px;">
                        Apply
                    </button>
                </form>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="chart-wrapper">
                        <h6 class="text-center mb-3" style="color:#d87a87;">
                            <i class="bi bi-graph-up me-2"></i>Income Trend
                        </h6>

                        @php $hasChartData = is_array($chartData) && count($chartData) > 0; @endphp

                        @if($hasChartData)
                            <div class="chart-container">
                                <canvas id="incomeLineChart"></canvas>
                            </div>
                        @else
                            <div class="chart-no-data">
                                <i class="bi bi-graph-up fs-1"></i>
                                <p class="mt-2">No income data available for selected period</p>
                            </div>
                        @endif
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="row g-4">
                        {{-- SERVICE PIE --}}
                        <div class="col-md-6 col-lg-12">
                            <div class="chart-card">
                                <h6 class="text-center mb-3" style="color:#d87a87;">
                                    <i class="bi bi-pie-chart me-2"></i>By Service Type
                                </h6>

                                @php $hasServiceData = is_array($serviceData) && array_sum($serviceData) > 0; @endphp

                                @if($hasServiceData)
                                    <div class="chart-container-sm">
                                        <canvas id="servicePieChart"></canvas>
                                    </div>

                                    <div class="mt-3">
                                        @foreach($incomeByService as $service)
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <span>
                                                    <span class="legend-dot me-2"
                                                        style="background-color: {{ $service->treatment_type == 'nail_art' ? '#ff8abb' : '#46b96a' }};"></span>
                                                    {{ ucfirst(str_replace('_', ' ', $service->treatment_type)) }}
                                                </span>
                                                <span class="fw-bold">
                                                    Rp {{ number_format($service->total, 0, ',', '.') }}
                                                </span>
                                            </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="chart-no-data">
                                        <i class="bi bi-pie-chart fs-1"></i>
                                        <p class="mt-2">No service data available</p>
                                    </div>
                                @endif
                            </div>
                        </div>

                        {{-- PAYMENT PIE --}}
                        <div class="col-md-6 col-lg-12">
                            <div class="chart-card">
                                <h6 class="text-center mb-3" style="color:#d87a87;">
                                    <i class="bi bi-credit-card me-2"></i>By Payment Method
                                </h6>

                                @php $hasPaymentData = is_array($paymentData) && array_sum($paymentData) > 0; @endphp

                                @if($hasPaymentData)
                                    <div class="chart-container-sm">
                                        <canvas id="paymentPieChart"></canvas>
                                    </div>

                                    <div class="mt-3">
                                        @foreach($incomeByPayment as $payment)
                                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                                    <span>
                                                                        <span class="legend-dot me-2" style="background-color: {{

                                            $payment->payment_method == 'cash' ? '#28a745' :
                                            ($payment->payment_method == 'transfer' ? '#007bff' :
                                                ($payment->payment_method == 'bank_transfer' ? '#6c757d' : '#ff6b35'))
                                                                                                                      }};"></span>
                                                                        {{ ucfirst($payment->payment_method) }}
                                                                    </span>
                                                                    <span class="fw-bold">
                                                                        Rp {{ number_format($payment->total, 0, ',', '.') }}
                                                                    </span>
                                                                </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="chart-no-data">
                                        <i class="bi bi-credit-card fs-1"></i>
                                        <p class="mt-2">No payment data available</p>
                                    </div>
                                @endif
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>

    {{-- RECENT + ARTIST --}}
    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm"
                style="border-radius:20px; background:linear-gradient(180deg, #fff 0%, #fff5f8 100%);">
                <div class="card-body p-4">

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="bold mb-0" style="color:#d87a87; font-family:'Georgia', serif;">
                            <i class="bi bi-clock-history me-2"></i>Recent Reservations
                        </h3>

                        <form action="{{ route('dashboard') }}" method="GET" class="d-flex gap-2">
                            <input type="hidden" name="income_filter" value="{{ $incomeFilter }}">
                            @if($incomeFilter === 'daily')
                                <input type="hidden" name="income_date" value="{{ $incomeDate }}">
                            @elseif($incomeFilter === 'monthly')
                                <input type="hidden" name="month_year" value="{{ $monthYear }}">
                            @else
                                <input type="hidden" name="year" value="{{ $yearFilter }}">
                            @endif

                            <input type="date" name="reservation_date" class="form-control form-control-sm"
                                style="width:auto;" value="{{ $reservationDate }}">

                            <button class="btn btn-sm text-light"
                                style="background:#f3b8c2; border-radius:10px; padding:6px 20px;">
                                Filter
                            </button>

                            <a href="{{ route('dashboard', [
        'income_filter' => $incomeFilter,
        'income_date' => $incomeFilter === 'daily' ? $incomeDate : null,
        'month_year' => $incomeFilter === 'monthly' ? $monthYear : null,
        'year' => $incomeFilter === 'yearly' ? $yearFilter : null,
    ]) }}" class="btn btn-sm text-light" style="background:#d87a87; border-radius:10px; padding:6px 20px;">
                                Reset
                            </a>
                        </form>
                    </div>

                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                                <tr style="color:#451a2b; font-family:'Georgia', serif; font-weight:600;">
                                    <th>Customer</th>
                                    <th>Service</th>
                                    <th>Artist</th>
                                    <th>Date & Time</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center">Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse ($reservations as $item)
                                    <tr class="reservation-row">
                                        <td>{{ $item->name }}</td>
                                        <td>{{ ucfirst(str_replace('_', ' ', $item->treatment_type)) }}</td>
                                        <td>{{ $item->nailArtist->name ?? 'Not Assigned' }}</td>
                                        <td>
                                            <small>{{ \Carbon\Carbon::parse($item->reservation_date)->format('d M Y') }}</small><br>
                                            <small class="text-muted">{{ $item->reservation_time }}</small>
                                        </td>
                                        <td class="text-center">{{ ucfirst($item->status) }}</td>
                                        <td class="text-center fw-bold" style="color:#28a745;">
                                            Rp {{ number_format($item->total_price ?? 0, 0, ',', '.') }}
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            No reservations found
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body p-4">
                    <h3 class="bold mb-4" style="color:#d87a87; font-family:'Georgia', serif;">
                        <i class="bi bi-people me-2"></i>Artist Performance
                    </h3>

                    <div class="artist-list">
                        @foreach($artistPerformance as $artist)
                            <div class="artist-card mb-3 p-3 rounded-3">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <h6 class="mb-1 fw-bold">{{ $artist->name }}</h6>
                                        <small class="text-muted">Completed:
                                            {{ $artist->completed_reservations ?? 0 }}</small><br>
                                        <small class="text-muted">Income: Rp
                                            {{ number_format($artist->total_income ?? 0, 0, ',', '.') }}</small>
                                    </div>
                                    <span class="badge">
                                        {{ ucfirst($artist->real_time_status ?? 'available') }}
                                    </span>
                                </div>
                            </div>
                        @endforeach
                    </div>

                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const incomeSelect = document.getElementById('incomeFilterSelect');

            function updateFilterForm() {
                const val = incomeSelect.value;

                document.querySelectorAll('.filter-input').forEach(el => {
                    el.style.display = 'none';
                    el.querySelectorAll('input').forEach(i => i.disabled = true);
                });

                const active = document.getElementById(val + 'Filter');
                active.style.display = 'block';
                active.querySelectorAll('input').forEach(i => i.disabled = false);
            }

            incomeSelect.addEventListener('change', updateFilterForm);
            updateFilterForm();

            // LINE CHART
            const lineCtx = document.getElementById('incomeLineChart');
            if (lineCtx) {
                new Chart(lineCtx, {
                    type: 'line',
                    data: {
                        labels: @json($chartLabels),
                        datasets: [{
                            label: 'Income (Rp)',
                            data: @json($chartData),
                            backgroundColor: 'rgba(216, 122, 135, 0.1)',
                            borderColor: '#d87a87',
                            borderWidth: 3,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: true },
                            tooltip: {
                                callbacks: {
                                    label: (ctx) => 'Rp ' + (ctx.parsed.y || 0).toLocaleString('id-ID')
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: { callback: (v) => 'Rp ' + v.toLocaleString('id-ID') }
                            }
                        }
                    }
                });
            }

            // SERVICE PIE
            const serviceCtx = document.getElementById('servicePieChart');
            if (serviceCtx) {
                new Chart(serviceCtx, {
                    type: 'pie',
                    data: {
                        labels: @json($serviceLabels),
                        datasets: [{ data: @json($serviceData), backgroundColor: @json($serviceColors) }]
                    },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }

            // PAYMENT PIE
            const paymentCtx = document.getElementById('paymentPieChart');
            if (paymentCtx) {
                new Chart(paymentCtx, {
                    type: 'pie',
                    data: {
                        labels: @json($paymentLabels),
                        datasets: [{ data: @json($paymentData), backgroundColor: @json($paymentColors) }]
                    },
                    options: { responsive: true, maintainAspectRatio: false }
                });
            }

            // Auto-refresh every 30 seconds
            setInterval(function () {
                location.reload();
            }, 30000);
        });
    </script>
@endpush