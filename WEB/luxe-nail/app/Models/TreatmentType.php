<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TreatmentType extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description', 'order', 'is_active', 'duration'];

    protected $casts = [
        'is_active' => 'boolean'
    ];

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}