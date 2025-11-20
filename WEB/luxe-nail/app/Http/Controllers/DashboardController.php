<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reservation;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $date = $request->date;

        // Query utama untuk filter tanggal
        $reservationsQuery = Reservation::query();

        if ($date) {
            $reservationsQuery->whereDate('reservation_date', $date);
        }

        // Menghitung total berdasarkan filter tanggal
        $totalReservations = Reservation::when($date, function ($q) use ($date) {
            $q->whereDate('reservation_date', $date);
        })->count();

        $totalNailArt = Reservation::when($date, function ($q) use ($date) {
            $q->whereDate('reservation_date', $date);
        })->where('treatment_type', 'nail_art')->count();

        $totalNailExtension = Reservation::when($date, function ($q) use ($date) {
            $q->whereDate('reservation_date', $date);
        })->where('treatment_type', 'nail_extension')->count();

        // Recent reservations (top 5)
        $recentReservations = $reservationsQuery
            ->orderBy('reservation_time', 'asc')
            ->take(5)
            ->get();

        return view('dashboard.index', [
            'reservations'        => $recentReservations,
            'selectedDate'        => $date,
            'totalReservations'   => $totalReservations,
            'totalNailArt'        => $totalNailArt,
            'totalNailExtension'  => $totalNailExtension,
        ]);
    }
}