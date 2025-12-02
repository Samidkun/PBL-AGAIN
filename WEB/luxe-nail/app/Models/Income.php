<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Income extends Model
{
    use HasFactory;

    protected $fillable = [
        'reservation_id',

        // === FIXED 1: SNAPSHOT CUSTOMER (INI YANG HILANG DAN MENGAKIBATKAN ERROR 500) ===
        'customer_name',
        'customer_phone',
        'treatment_type',

        // AI Design
        'shape',
        'color',
        'finish',
        'accessory',

        // Price breakdown
        'price_shape',
        'price_color',
        'price_finish',
        'price_accessory',
        'total_price',

        // === FIXED 2: GANTI NAMA DARI 'ai_image' MENJADI 'ai_image_url' ===
        'ai_image_url',

        'payment_status',
        'payment_method',
        'reservation_date',
    ];

    protected $casts = [
        'reservation_date' => 'date',
    ];

    // RELATIONSHIP → OPTIONAL
    public function reservation()
    {
        return $this->belongsTo(Reservation::class);
    }
}
