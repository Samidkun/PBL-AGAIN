<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NailArtist extends Model
{
    protected $fillable = [
        'name',
        'status',
        'customers_today',
        'user_id',
        'is_on_break',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }

    // DYNAMIC STATUS ACCESSOR
    public function getRealTimeStatusAttribute()
    {
        // 0. CHECK MANUAL BREAK
        if ($this->is_on_break) {
            return 'break';
        }

        $now = \Carbon\Carbon::now();
        $timeStr = $now->format('H:i');

        // 1. CHECK BREAK TIMES (Global Rules)
        // 12:00-13:00, 15:00-16:00, 18:00-19:00
        $breaks = [
            ['start' => '12:00', 'end' => '13:00'],
            ['start' => '15:00', 'end' => '16:00'],
            ['start' => '18:00', 'end' => '19:00'],
        ];

        foreach ($breaks as $break) {
            if ($timeStr >= $break['start'] && $timeStr < $break['end']) {
                return 'break';
            }
        }

        // 2. CHECK BUSY (Active Reservation)
        $isBusy = $this->reservations()
            ->where('reservation_date', $now->format('Y-m-d'))
            ->where('status', 'confirmed') // Only confirmed bookings make them busy
            ->where(function ($q) use ($timeStr) {
                $q->where('reservation_time', '<=', $timeStr)
                  ->where('end_time', '>', $timeStr);
            })
            ->exists();

        if ($isBusy) {
            return 'busy';
        }

        // 3. DEFAULT
        return 'available';
    }

    public function getCustomersTodayCountAttribute()
    {
        return $this->reservations()
            ->whereDate('reservation_date', \Carbon\Carbon::today())
            ->whereIn('status', ['confirmed', 'in_progress', 'completed'])
            ->count();
    }
}
