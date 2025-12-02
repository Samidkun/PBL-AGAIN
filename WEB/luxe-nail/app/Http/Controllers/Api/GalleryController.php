<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Gallery;
use App\Http\Resources\GalleryResource;

class GalleryController extends Controller
{
    public function index()
    {
        $data = Gallery::latest()->get();
        return CategoryResource::collection($data);
    }

    public function show($id)
    {
        $gallery = Gallery::find($id);

        if (!$gallery) {
            return response()->json([
                'message' => 'Data gallery not found'
            ], 404);
        }

        return new CategoryResource($gallery);
    }
}