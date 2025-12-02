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
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }
}
