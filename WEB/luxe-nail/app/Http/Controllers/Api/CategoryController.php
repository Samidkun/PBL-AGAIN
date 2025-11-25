<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::where('is_active', 1)
            ->orderBy('order')
            ->get()
            ->groupBy('type');

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
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
            'data' => $items
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
            'data' => $category
        ]);
    }
}
