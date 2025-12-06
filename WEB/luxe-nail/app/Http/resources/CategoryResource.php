<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray($request)
    {
        $imagePath = $this->image;

        // Fix for legacy/broken paths where only filename is stored
        if ($imagePath && !str_contains($imagePath, '/')) {
            $folders = [
                'img/kategori/ai_color/',
                'img/kategori/nail_color/',
                'img/kategori/ai_shape/',
                'img/kategori/nail_shape/',
                'img/kategori/ai_finish/',
                'img/kategori/nail_type/',
                'img/kategori/ai_accessories/',
                'img/kategori/nail_accessoris/',
                'img/kategori/ai_final/',
            ];

            foreach ($folders as $folder) {
                if (file_exists(public_path($folder . $imagePath))) {
                    $imagePath = $folder . $imagePath;
                    break;
                }
            }
        }

        // Prepend 'served-image/' to force routing through the CORS-enabled route
        // This is necessary for Flutter Web to avoid CORS issues with static files
        $displayPath = $imagePath;
        if ($imagePath && !str_starts_with($imagePath, 'served-image/')) {
            $displayPath = 'served-image/' . $imagePath;
        }

        return [
            'id'         => $this->id,
            'code'       => $this->code,
            'name'       => $this->name,
            'type'       => $this->type,
            'price'      => $this->price,
            'image'      => $displayPath, 
            'description'=> $this->description,
            'order'      => $this->order,
            'treatment_type' => $this->treatmentType ? $this->treatmentType->name : null,
            'is_active'  => (bool)$this->is_active,
            'treatment_type_id' => $this->treatment_type_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,

            // FULL URL 
            'image_url'  => $displayPath ? asset($displayPath) : null,
        ];
    }
}