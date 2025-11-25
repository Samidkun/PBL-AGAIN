<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
  public function index(Request $request)
    {
        $treatmentId = $request->query('treatment_type_id');

        $query = Category::query()->where('is_active', 1);

        if ($treatmentId) {
            $query->where('treatment_type_id', $treatmentId);
        }

        $categories = $query->orderBy('order')->get();

        // Kotak yang diharapkan Flutter
        $grouped = [
            'shape' => [],
            'color' => [],
            'finish' => [],
            'accessory' => []
        ];

        foreach ($categories as $cat) {
            // ==========================================
            // LOGIC PENERJEMAH (MAPPING)
            // ==========================================
            $type = $cat->type;

            // Kalau DB bilang 'nail_shape', paksa jadi 'shape'
            if ($type === 'nail_shape') {
                $type = 'shape';
            }
            // Kalau DB bilang 'nail_type', paksa jadi 'finish'
            if ($type === 'nail_type') {
                $type = 'finish';
            }

            // Cek apakah tipenya valid (ada di array $grouped)
            if (array_key_exists($type, $grouped)) {
                $grouped[$type][] = [
                    'id' => $cat->id,
                    'code' => $cat->code,
                    'name' => $cat->name,
                    'price' => $cat->price,
                    // Pastikan model Category punya accessor getFormattedPriceAttribute
                    // Kalau error, ganti jadi: 'Rp ' . number_format($cat->price, 0, ',', '.')
                    'formatted_price' => $cat->formatted_price ?? 'Rp ' . number_format($cat->price, 0, ',', '.'),
                    'image' => $cat->image ? asset($cat->image) : null, // Pastikan image jadi URL lengkap
                    'description' => $cat->description,
                    'order' => $cat->order,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => $grouped
        ]);
    }
}
