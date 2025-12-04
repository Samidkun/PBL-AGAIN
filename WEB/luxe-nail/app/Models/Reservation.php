<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'address',
        'phone',
        'treatment_type',
        'reservation_date',
        'reservation_time',
        'queue_number',
        'nail_artist_id',
        'status',
        'is_paid',
        'booking_fee',
        'total_price',
        'payment_method',
        'payment_proof',
        'end_time'
    ];
    public function income()
    {
        return $this->hasOne(Income::class);
    }
    public function nailArtist()
    {
        return $this->belongsTo(NailArtist::class, 'nail_artist_id');
    }
}
