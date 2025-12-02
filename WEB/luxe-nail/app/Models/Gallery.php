<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Gallery extends Model
{
    protected $table = 'gallery';
    protected $primaryKey = 'gallery_id';

    protected $fillable = [
        // fields sesuai tabel gallery
        'judul', 'deskripsi', 'gambar', 'kategori', 'harga'
    ];

    protected $appends = ['image_url'];

    public function getImageUrlAttribute()
    {
        
        if (!$this->image) return null;
        return asset($this->image);
    }
}