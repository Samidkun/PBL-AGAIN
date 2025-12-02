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

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($category) {
            if (empty($category->code)) {
                $category->code = self::generateCode($category->type);
            }
        });
    }

    public static function generateCode($type)
    {
        $prefix = match($type) {
            'shape'     => 'SH',
            'color'     => 'CL',
            'finish'    => 'FN',
            'accessory' => 'AC',
            default     => 'CT'
        };

        $last = self::where('code', 'like', $prefix . '%')
                    ->orderBy('id', 'desc')
                    ->first();

        $number = $last ? intval(substr($last->code, strlen($prefix))) + 1 : 1;

        return $prefix . str_pad($number, 3, '0', STR_PAD_LEFT);
    }

    public function getFormattedPriceAttribute()
    {
        return 'Rp ' . number_format($this->price, 0, ',', '.');
    }

    public function treatmentType()
    {
        return $this->belongsTo(TreatmentType::class);
    }

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

    protected $appends = ['image_url'];

    public function getImageUrlAttribute()
    {
        if (!$this->image) {
            return null;
        }

        // Lokasi gambar kategori yang benar
        return asset('img/kategori/' . $this->image);
    }

    public function galleries()
    {
        return $this->hasMany(Gallery::class, 'category_id');
    }
}
