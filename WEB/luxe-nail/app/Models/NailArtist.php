<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NailArtist extends Model
{
    protected $fillable = [
        'name',
        'status',
        'customers_today',
    ];

    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }
}
