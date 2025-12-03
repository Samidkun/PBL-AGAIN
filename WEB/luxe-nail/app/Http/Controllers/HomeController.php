<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index()
    {
        $pendingReservation = null;
        $queueNumber = \Illuminate\Support\Facades\Cookie::get('pending_booking');

        if ($queueNumber) {
            $reservation = \App\Models\Reservation::where('queue_number', $queueNumber)
                ->where('status', 'pending')
                ->first();

            if ($reservation) {
                // Check if expired (1 hour)
                if ($reservation->created_at->diffInHours(now()) < 1) {
                    $pendingReservation = $reservation;
                } else {
                    // Expired, clear cookie (optional, but good practice)
                    \Illuminate\Support\Facades\Cookie::queue(\Illuminate\Support\Facades\Cookie::forget('pending_booking'));
                }
            }
        }

        return view('home', compact('pendingReservation'));
    }

    public function about()
    {
        return view('about');
    }

    public function gallery()
    {
        return view('gallery');
    }

    public function contact()
    {
        return view('contact');
    }
}