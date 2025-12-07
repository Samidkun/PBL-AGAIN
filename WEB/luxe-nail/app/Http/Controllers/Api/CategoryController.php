<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Http\Resources\CategoryResource;

class CategoryController extends Controller
{
    public function index()
    {
        try {

            $categories = Category::where('is_active', 1)
                ->orderBy('order')
                ->get()
                ->groupBy('type');

            return response()->json([
                'success' => true,
                'data' => $categories
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'error' => $e->getMessage(),
                'trace' => $e->getTrace()[0] ?? null,
            ], 500);

        }
    }


    public function getByType($type)
    {
        $items = Category::where('is_active', 1)
            ->where('type', $type)
            ->orderBy('order')
            ->get();

        if ($items->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'No categories found for this type',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => CategoryResource::collection($items)->toArray(request())
        ]);
    }

    public function show($id)
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new CategoryResource($category)
        ]);
    }
}