<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'         => $this->id,
            'code'       => $this->code,
            'name'       => $this->name,
            'type'       => $this->type,
            'price'      => $this->price,
            'image'      => $this->image, 
            'description'=> $this->description,
            'order'      => $this->order,
            'is_active'  => (bool)$this->is_active,
            'treatment_type_id' => $this->treatment_type_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,

            // FULL URL 
            'image_url'  => $this->image ? asset($this->image) : null,
        ];
    }
}