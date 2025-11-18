<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'type',
        'price',
        'image',
        'description',
        'order',
        'is_active',
        'treatment_type_id'
    ];

    protected $casts = [
        'is_active' => 'boolean'
    ];

    // AUTO GENERATE CODE
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($category) {
            if (empty($category->code)) {
                $category->code = self::generateCode($category->type);
            }
        });
    }

    // Method untuk generate kode otomatis
    public static function generateCode($type)
    {
        $prefixes = [
            'nail_shape' => 'NS',
            'nail_type' => 'NT', 
            'color' => 'CL',
            'accessory' => 'AC'
        ];

        $prefix = $prefixes[$type] ?? 'CT';
        $lastCategory = self::where('type', $type)->orderBy('id', 'desc')->first();
        $nextNumber = $lastCategory ? (int) substr($lastCategory->code, 2) + 1 : 1;
        
        return $prefix . str_pad($nextNumber, 3, '0', STR_PAD_LEFT);
    }

    // Accessor untuk format price
    public function getFormattedPriceAttribute()
    {
        return 'Rp ' . number_format($this->price, 0, ',', '.');
    }

    // Relationship
    public function treatmentType()
    {
        return $this->belongsTo(TreatmentType::class);
    }

    // Scopes
    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByTreatmentType($query, $treatmentTypeId)
    {
        return $query->where('treatment_type_id', $treatmentTypeId);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}