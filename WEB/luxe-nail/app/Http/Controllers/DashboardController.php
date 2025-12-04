<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\Income;
use App\Models\NailArtist;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        // =========================
        // 1) PARAMETER FILTER TERPISAH
        // =========================
        $reservationDate = $request->reservation_date; // khusus tabel reservation

        $incomeFilter  = $request->income_filter ?? 'daily';
        $incomeDate    = $request->income_date; // khusus daily income
        $monthYear     = $request->month_year ?? Carbon::now()->format('Y-m');
        $yearFilter    = $request->year ?? Carbon::now()->year;

        // default daily income kalau kosong -> today
        if ($incomeFilter === 'daily' && !$incomeDate) {
            $incomeDate = Carbon::now()->toDateString();
        }

        // =========================
        // 2) RESERVATION STATISTICS
        // =========================
        $reservationsBase = Reservation::query();

        if ($reservationDate) {
            $reservationsBase->whereDate('reservation_date', $reservationDate);
        }

        $totalReservations  = (clone $reservationsBase)->count();
        $totalNailArt       = (clone $reservationsBase)->where('treatment_type', 'nail_art')->count();
        $totalNailExtension = (clone $reservationsBase)->where('treatment_type', 'nail_extension')->count();

        // recent reservations beneran recent
        $recentReservations = (clone $reservationsBase)
            ->with('nailArtist')
            ->orderBy('reservation_date', 'desc')
            ->orderBy('reservation_time', 'desc')
            ->take(5)
            ->get();

        // =========================
        // 3) INCOME BASE QUERY SESUAI FILTER
        // =========================
        $baseIncomeQuery = Income::query();

        $filterYear = null;
        $filterMonth = null;

        if ($incomeFilter === 'daily') {
            $baseIncomeQuery->whereDate('reservation_date', $incomeDate);
            $filterYear  = Carbon::parse($incomeDate)->year;
            $filterMonth = Carbon::parse($incomeDate)->month;

        } elseif ($incomeFilter === 'monthly') {
            $filterYear  = Carbon::parse($monthYear)->year;
            $filterMonth = Carbon::parse($monthYear)->month;

            $baseIncomeQuery->whereYear('reservation_date', $filterYear)
                            ->whereMonth('reservation_date', $filterMonth);

        } else { // yearly
            $filterYear = $yearFilter;
            $baseIncomeQuery->whereYear('reservation_date', $filterYear);
        }

        // =========================
        // 4) INCOME AGGREGATE (PAKAI CLONE)
        // =========================
        $totalIncome = (clone $baseIncomeQuery)->sum('total_price');

        $incomeByService = (clone $baseIncomeQuery)
            ->select('treatment_type', DB::raw('SUM(total_price) as total'))
            ->groupBy('treatment_type')
            ->get();

        $incomeByPayment = (clone $baseIncomeQuery)
            ->select('payment_method', DB::raw('SUM(total_price) as total'))
            ->groupBy('payment_method')
            ->get();

        // =========================
        // 5) INCOME TREND SESUAI FILTER
        // =========================
        // NOTE: trend daily akan dipad 7 hari full di step (7)
        if ($incomeFilter === 'daily') {
            $endDate = Carbon::parse($incomeDate);
            $startDate = (clone $endDate)->subDays(6);

            $incomeTrend = Income::whereBetween('reservation_date', [
                    $startDate->toDateString(),
                    $endDate->toDateString()
                ])
                ->select(
                    DB::raw('DATE(reservation_date) as label'),
                    DB::raw('SUM(total_price) as total')
                )
                ->groupBy('label')
                ->orderBy('label')
                ->get();

        } elseif ($incomeFilter === 'monthly') {
            $incomeTrend = Income::whereYear('reservation_date', $filterYear)
                ->whereMonth('reservation_date', $filterMonth)
                ->select(
                    DB::raw('DAY(reservation_date) as label'),
                    DB::raw('SUM(total_price) as total')
                )
                ->groupBy('label')
                ->orderBy('label')
                ->get();

        } else { // yearly
            $incomeTrend = Income::whereYear('reservation_date', $filterYear)
                ->select(
                    DB::raw('MONTH(reservation_date) as label'),
                    DB::raw('SUM(total_price) as total')
                )
                ->groupBy('label')
                ->orderBy('label')
                ->get();
        }

        // =========================
        // 6) ARTIST PERFORMANCE (ikut filter income)
        // =========================
        $artistPerformance = NailArtist::with(['reservations' => function ($q) use ($incomeFilter, $incomeDate, $filterYear, $filterMonth) {
                if ($incomeFilter === 'daily') {
                    $q->whereDate('reservation_date', $incomeDate);
                } elseif ($incomeFilter === 'monthly') {
                    $q->whereYear('reservation_date', $filterYear)
                      ->whereMonth('reservation_date', $filterMonth);
                } else {
                    $q->whereYear('reservation_date', $filterYear);
                }
            }])
            ->withCount(['reservations as completed_reservations' => function ($q) use ($incomeFilter, $incomeDate, $filterYear, $filterMonth) {
                $q->where('status', 'completed');
                if ($incomeFilter === 'daily') {
                    $q->whereDate('reservation_date', $incomeDate);
                } elseif ($incomeFilter === 'monthly') {
                    $q->whereYear('reservation_date', $filterYear)
                      ->whereMonth('reservation_date', $filterMonth);
                } else {
                    $q->whereYear('reservation_date', $filterYear);
                }
            }])
            ->withSum(['reservations as total_income' => function ($q) use ($incomeFilter, $incomeDate, $filterYear, $filterMonth) {
                $q->where('status', 'completed')->where('is_paid', 1);
                if ($incomeFilter === 'daily') {
                    $q->whereDate('reservation_date', $incomeDate);
                } elseif ($incomeFilter === 'monthly') {
                    $q->whereYear('reservation_date', $filterYear)
                      ->whereMonth('reservation_date', $filterMonth);
                } else {
                    $q->whereYear('reservation_date', $filterYear);
                }
            }], 'total_price')
            ->get()
            ->map(function ($artist) {
                $artist->real_time_status = $artist->status ?? 'available';
                return $artist;
            });

        // =========================
        // 7) PREP CHART DATA (FINAL)
        // =========================
        $chartLabels = [];
        $chartData   = [];

        if ($incomeFilter === 'daily') {

            // bikin 7 hari full terakhir (end di incomeDate)
            $endDate = Carbon::parse($incomeDate);
            $startDate = (clone $endDate)->subDays(6);

            $trendMap = $incomeTrend->keyBy('label');

            for ($d = (clone $startDate); $d <= $endDate; $d->addDay()) {
                $key = $d->toDateString();
                $chartLabels[] = $d->format('d M');
                $chartData[] = isset($trendMap[$key]) ? (float)$trendMap[$key]->total : 0;
            }

        } elseif ($incomeFilter === 'monthly') {

            $daysInMonth = Carbon::create($filterYear, $filterMonth)->daysInMonth;
            for ($i = 1; $i <= $daysInMonth; $i++) {
                $dayData = $incomeTrend->firstWhere('label', $i);
                $chartLabels[] = "Day $i";
                $chartData[]   = $dayData ? (float)$dayData->total : 0;
            }

        } else { // yearly

            for ($i = 1; $i <= 12; $i++) {
                $monthData = $incomeTrend->firstWhere('label', $i);
                $chartLabels[] = Carbon::create()->month($i)->format('M');
                $chartData[]   = $monthData ? (float)$monthData->total : 0;
            }
        }

        // pie chart service
        $serviceLabels = $incomeByService->pluck('treatment_type')
            ->map(fn($t) => ucfirst(str_replace('_', ' ', $t)))->toArray();
        $serviceData = $incomeByService->pluck('total')->map(fn($v)=>(float)$v)->toArray();
        $serviceColors = $incomeByService->map(fn($i) =>
            $i->treatment_type === 'nail_art' ? '#ff8abb' : '#46b96a'
        )->toArray();

        // pie chart payment
        $paymentLabels = $incomeByPayment->pluck('payment_method')
            ->map(fn($m) => ucfirst($m))->toArray();
        $paymentData = $incomeByPayment->pluck('total')->map(fn($v)=>(float)$v)->toArray();
        $paymentColors = $incomeByPayment->map(function ($item) {
            $colors = [
                'cash' => '#28a745',
                'transfer' => '#007bff',
                'bank_transfer' => '#6c757d',
                'qris' => '#ff6b35',
            ];
            return $colors[$item->payment_method] ?? '#6c757d';
        })->toArray();

        // fallback kalau kosong banget
        if (!count($chartLabels)) $chartLabels = ['No Data'];
        if (!count($chartData))   $chartData = [0];

        if (!count($serviceLabels)) {
            $serviceLabels = ['No Data']; $serviceData = [0]; $serviceColors = ['#6c757d'];
        }
        if (!count($paymentLabels)) {
            $paymentLabels = ['No Data']; $paymentData = [0]; $paymentColors = ['#6c757d'];
        }

        return view('dashboard.index', [
            // reservation
            'reservations'        => $recentReservations,
            'reservationDate'     => $reservationDate,
            'totalReservations'   => $totalReservations,
            'totalNailArt'        => $totalNailArt,
            'totalNailExtension'  => $totalNailExtension,

            // income
            'totalIncome'         => $totalIncome,
            'incomeByService'     => $incomeByService,
            'incomeByPayment'     => $incomeByPayment,
            'incomeFilter'        => $incomeFilter,
            'incomeDate'          => $incomeDate,
            'monthYear'           => $monthYear,
            'yearFilter'          => $yearFilter,

            // artist
            'artistPerformance'   => $artistPerformance,

            // charts
            'chartLabels'         => $chartLabels,
            'chartData'           => $chartData,
            'serviceLabels'       => $serviceLabels,
            'serviceData'         => $serviceData,
            'serviceColors'       => $serviceColors,
            'paymentLabels'       => $paymentLabels,
            'paymentData'         => $paymentData,
            'paymentColors'       => $paymentColors,
        ]);
    }
}
