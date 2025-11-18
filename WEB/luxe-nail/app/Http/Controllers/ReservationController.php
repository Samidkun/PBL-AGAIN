<?php

namespace App\Http\Controllers;

use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class ReservationController extends Controller
{
    public function create()
    {
        return view('reservations.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string|max:500',
            'phone' => 'required|string|max:20',
            'treatment_type' => 'required|in:nail_extension,nail_art',
            'reservation_date' => 'required|date|after:today',
            'reservation_time' => 'required|date_format:H:i'
        ]);

        try {
            // Validasi jam operasional (8:00 - 22:00)
            $reservationTime = Carbon::parse($validated['reservation_time']);
            $openTime = Carbon::parse('08:00');
            $closeTime = Carbon::parse('22:00');

            if ($reservationTime->lt($openTime) || $reservationTime->gt($closeTime)) {
                return response()->json([
                    'success' => false,
                    'message' => 'We are only open from 8:00 AM to 10:00 PM.'
                ], 422);
            }

            // Cek apakah sudah mencapai batas 8 booking di tanggal yang sama
            $existingBookings = Reservation::where('reservation_date', $validated['reservation_date'])->count();
            if ($existingBookings >= 8) {
                return response()->json([
                    'success' => false,
                    'message' => 'This date is fully booked. Please choose another date.'
                ], 422);
            }

            // Cek apakah waktu sudah dipesan
            $existingTime = Reservation::where('reservation_date', $validated['reservation_date'])
                ->where('reservation_time', $validated['reservation_time'])
                ->exists();

            if ($existingTime) {
                return response()->json([
                    'success' => false,
                    'message' => 'This time slot is already booked. Please choose another time.'
                ], 422);
            }

            // Generate queue number
            $queueNumber = $this->generateQueueNumber();

            $reservation = Reservation::create([
                'name' => $validated['name'],
                'address' => $validated['address'],
                'phone' => $validated['phone'],
                'treatment_type' => $validated['treatment_type'],
                'reservation_date' => $validated['reservation_date'],
                'reservation_time' => $validated['reservation_time'],
                'queue_number' => $queueNumber,
                'status' => 'pending'
            ]);

            Log::info('New reservation created: ' . $queueNumber);

            return response()->json([
                'success' => true,
                'queue_number' => $queueNumber,
                'redirect_url' => route('reservations.thank-you', ['queue_number' => $queueNumber])
            ]);

        } catch (\Exception $e) {
            Log::error('Error creating reservation: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error creating reservation. Please try again.'
            ], 500);
        }
    }

    public function thankYou(Request $request)
    {
        $queueNumber = $request->query('queue_number');
        $reservation = Reservation::where('queue_number', $queueNumber)->first();

        if (!$reservation) {
            abort(404, 'Reservation not found');
        }

        return view('reservations.thank-you', compact('reservation'));
    }

    private function generateQueueNumber()
    {
        return 'LX' . date('Ymd') . strtoupper(Str::random(4));
    }

    public function downloadPdf($queue_number)
    {
        $reservation = Reservation::where('queue_number', $queue_number)->firstOrFail();
        $pdf = Pdf::loadView('reservations.pdf', compact('reservation'));
        return $pdf->download('reservation_' . $queue_number . '.pdf');
    }

    public function calendar()
    {
        return view('reservations.calendar');
    }

    public function getScheduleData(Request $request)
    {
        try {
            $month = $request->month;
            $year = $request->year;
            
            $reservations = Reservation::whereMonth('reservation_date', $month)
                                      ->whereYear('reservation_date', $year)
                                      ->get();

            $bookingsPerDay = Reservation::whereMonth('reservation_date', $month)
                                        ->whereYear('reservation_date', $year)
                                        ->selectRaw('reservation_date, COUNT(*) as total')
                                        ->groupBy('reservation_date')
                                        ->pluck('total', 'reservation_date');

            $scheduleData = [];
            foreach ($reservations as $reservation) {
                $date = $reservation->reservation_date->format('Y-m-d');
                if (!isset($scheduleData[$date])) {
                    $scheduleData[$date] = [];
                }
                
                $scheduleData[$date][] = [
                    'time' => $reservation->reservation_time,
                    'name' => $reservation->name,
                    'treatment' => $reservation->treatment_type,
                    'phone' => $reservation->phone,
                    'queue_number' => $reservation->queue_number,
                ];
            }

            return response()->json([
                'success' => true,
                'scheduleData' => $scheduleData,
                'bookingsPerDay' => $bookingsPerDay,
                'month' => $month,
                'year' => $year
            ]);

        } catch (\Exception $e) {
            Log::error('Error getting schedule data: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error loading schedule data'
            ], 500);
        }
    }

    public function getDateDetails($date)
    {
        try {
            $reservations = Reservation::where('reservation_date', $date)
                ->whereIn('status', ['pending', 'confirmed'])
                ->orderBy('reservation_time')
                ->get();

            return response()->json([
                'success' => true,
                'date' => $date,
                'reservations' => $reservations,
                'formatted_date' => Carbon::parse($date)->format('F j, Y'),
                'total_bookings' => $reservations->count(),
                'is_full' => $reservations->count() >= 8
            ]);

        } catch (\Exception $e) {
            Log::error('Error getting date details: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error loading date details'
            ], 500);
        }
    }

    public function checkAvailability(Request $request)
    {
        try {
            $date = $request->date;
            $time = $request->time;

            if (Carbon::parse($date)->isPast()) {
                return response()->json([
                    'available' => false,
                    'message' => 'Cannot book for past dates. Please choose a future date.'
                ]);
            }

            $reservationTime = Carbon::parse($time);
            $openTime = Carbon::parse('08:00');
            $closeTime = Carbon::parse('22:00');

            if ($reservationTime->lt($openTime) || $reservationTime->gt($closeTime)) {
                return response()->json([
                    'available' => false,
                    'message' => 'We are only open from 8:00 AM to 10:00 PM. Please select a time within our operating hours.'
                ]);
            }

            $existingBookings = Reservation::where('reservation_date', $date)->count();
            if ($existingBookings >= 8) {
                return response()->json([
                    'available' => false,
                    'message' => 'This date is fully booked. Please choose another date.'
                ]);
            }

            $existingTime = Reservation::where('reservation_date', $date)
                ->where('reservation_time', $time)
                ->exists();

            if ($existingTime) {
                return response()->json([
                    'available' => false,
                    'message' => 'This time slot is already booked. Please choose another time.'
                ]);
            }

            return response()->json([
                'available' => true
            ]);

        } catch (\Exception $e) {
            Log::error('Error checking availability: ' . $e->getMessage());
            return response()->json([
                'available' => false,
                'message' => 'Error checking availability'
            ]);
        }
    }

    public function dashboard()
    {
        return view('dashboard.reservations.dashboard_reservations');
    }

    public function getReservationsByDate($date)
    {
        try {
            Log::info('Fetching reservations for date: ' . $date);
            
            $reservations = Reservation::where('reservation_date', $date)
                ->orderBy('reservation_time')
                ->get();

            return response()->json([
                'success' => true,
                'reservations' => $reservations
            ]);

        } catch (\Exception $e) {
            Log::error('Error in getReservationsByDate: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error fetching reservations: ' . $e->getMessage(),
                'reservations' => []
            ], 500);
        }
    }

    public function updateStatus(Request $request, $id)
    {
        try {
            Log::info('Updating reservation status', ['id' => $id, 'request' => $request->all()]);
            
            $request->validate([
                'status' => 'required|in:pending,confirmed,completed,cancelled'
            ]);

            $reservation = Reservation::findOrFail($id);
            $reservation->update(['status' => $request->status]);

            Log::info('Reservation status updated successfully: ' . $id);

            return response()->json([
                'success' => true,
                'message' => 'Status updated successfully'
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validation error updating status: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error updating reservation status: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error updating status: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getReservation($id)
    {
        try {
            Log::info('Fetching reservation with ID: ' . $id);
            
            $reservation = Reservation::findOrFail($id);
            
            Log::info('Reservation found: ' . $reservation->queue_number);

            return response()->json([
                'success' => true,
                'id' => $reservation->id,
                'name' => $reservation->name,
                'phone' => $reservation->phone,
                'address' => $reservation->address,
                'treatment_type' => $reservation->treatment_type,
                'reservation_date' => $reservation->reservation_date,
                'reservation_time' => $reservation->reservation_time,
                'status' => $reservation->status,
                'queue_number' => $reservation->queue_number
            ]);

        } catch (\Exception $e) {
            Log::error('Error fetching reservation ' . $id . ': ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'error' => 'Reservation not found',
                'message' => $e->getMessage()
            ], 404);
        }
    }

public function updateReservation(Request $request, $id)
{
    try {
        Log::info('Updating reservation with ID: ' . $id, $request->all());
        
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'address' => 'required|string|max:500',
            'treatment_type' => 'required|in:nail_extension,nail_art',
            'reservation_time' => 'required' // Hapus format validation sementara
        ]);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        $validated = $validator->validated();

        // Handle waktu - terima kedua format (dengan/tanpa detik)
        $reservationTime = $validated['reservation_time'];
        if (strlen($reservationTime) > 5) {
            // Format dengan detik: "08:00:00" -> "08:00"
            $validated['reservation_time'] = substr($reservationTime, 0, 5);
        } else {
            // Format tanpa detik: "21:00" -> tetap "21:00"
            $validated['reservation_time'] = $reservationTime;
        }

        $reservation = Reservation::findOrFail($id);
        $reservation->update($validated);

        Log::info('Reservation updated successfully: ' . $id);

        return response()->json([
            'success' => true,
            'message' => 'Reservation updated successfully'
        ]);

    } catch (\Illuminate\Validation\ValidationException $e) {
        Log::error('Validation error updating reservation: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Validation error',
            'errors' => $e->errors()
        ], 422);
    } catch (\Exception $e) {
        Log::error('Error updating reservation ' . $id . ': ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Error updating reservation: ' . $e->getMessage()
        ], 500);
    }
}
}