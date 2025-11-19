<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\TreatmentType;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $selectedTreatmentType = $request->get('treatment_type');
        $selectedCategoryType = $request->get('category_type');
        
        $allTreatmentTypes = TreatmentType::active()->orderBy('order')->get();
        $treatmentTypesQuery = TreatmentType::with(['categories' => function($query) use ($selectedCategoryType) {
            if ($selectedCategoryType) {
                $query->where('type', $selectedCategoryType);
            }
            $query->orderBy('type')->orderBy('order');
        }])->active()->orderBy('order');

        if ($selectedTreatmentType) {
            $treatmentTypesQuery->where('id', $selectedTreatmentType);
        }

        $treatmentTypes = $treatmentTypesQuery->get();

        $categoryTypes = [
            'nail_shape' => 'Kategori Kuku',
            'nail_type' => 'Type Nails', 
            'color' => 'Warna Kuku',
            'accessory' => 'Accessoris Kuku'
        ];

        return view('dashboard.kategori.kategori', [
            'treatmentTypes' => $treatmentTypes,
            'allTreatmentTypes' => $allTreatmentTypes,
            'selectedTreatmentType' => $selectedTreatmentType,
            'selectedCategoryType' => $selectedCategoryType,
            'categoryTypes' => $categoryTypes
        ]);
    }

    // TAMBAH METHOD INI
    public function getCreateForm()
    {
        $treatmentTypes = TreatmentType::active()->get();
        $categoryTypes = [
            'nail_shape' => 'Kategori Kuku',
            'nail_type' => 'Type Nails',
            'color' => 'Warna Kuku',
            'accessory' => 'Accessoris Kuku'
        ];
        
        return view('dashboard.kategori.partials.create-form', compact('treatmentTypes', 'categoryTypes'));
    }

    public function create()
    {
        $treatmentTypes = TreatmentType::active()->get();
        $categoryTypes = [
            'nail_shape' => 'Kategori Kuku',
            'nail_type' => 'Type Nails',
            'color' => 'Warna Kuku',
            'accessory' => 'Accessoris Kuku'
        ];
        
        return view('dashboard.kategori.create', compact('treatmentTypes', 'categoryTypes'));
    }

    public function store(Request $request)
{
    $request->validate([
        'name' => 'required|string|max:255',
        'type' => 'required|string|in:nail_shape,nail_type,color,accessory',
        'price' => 'required|integer|min:0',
        'treatment_type_id' => 'required|exists:treatment_types,id',
        'code' => 'nullable|string|unique:categories,code',
        'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        'description' => 'nullable|string',
        'order' => 'nullable|integer'
    ]);

    $data = $request->all();

    // ⚠️ PERBAIKAN: Gunakan method generateCode dari Model
    if (empty($data['code'])) {
        $data['code'] = Category::generateCode($data['type']);
    }

    if ($request->hasFile('image')) {
        $imagePath = $request->file('image')->store('categories', 'public');
        $data['image'] = $imagePath;
    }

    Category::create($data);

    return redirect()->route('kategori.index')
        ->with('success', 'Kategori berhasil ditambahkan!');
}

    public function edit(Category $category)
    {
        $treatmentTypes = TreatmentType::active()->get();
        $categoryTypes = [
            'nail_shape' => 'Kategori Kuku',
            'nail_type' => 'Type Nails',
            'color' => 'Warna Kuku',
            'accessory' => 'Accessoris Kuku'
        ];
        
        return view('dashboard.kategori.edit', compact('category', 'treatmentTypes', 'categoryTypes'));
    }

    public function update(Request $request, Category $category)
{
    $request->validate([
        'name' => 'required|string|max:255',
        'type' => 'required|string|in:nail_shape,nail_type,color,accessory',
        'price' => 'required|integer|min:0',
        'treatment_type_id' => 'required|exists:treatment_types,id',
        'code' => 'nullable|string|unique:categories,code,' . $category->id,
        'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        'description' => 'nullable|string',
        'order' => 'nullable|integer'
    ]);

    $data = $request->all();

    // ⚠️ PERBAIKAN: Jika code kosong, generate otomatis
    if (empty($data['code'])) {
        $data['code'] = Category::generateCode($data['type']);
    }

    if ($request->hasFile('image')) {
        if ($category->image) {
            Storage::disk('public')->delete($category->image);
        }
        
        $imagePath = $request->file('image')->store('categories', 'public');
        $data['image'] = $imagePath;
    }

    if ($request->has('remove_image')) {
        if ($category->image) {
            Storage::disk('public')->delete($category->image);
        }
        $data['image'] = null;
    }

    $category->update($data);

    return redirect()->route('kategori.index')
        ->with('success', 'Kategori berhasil diperbarui!');
}

    public function destroy(Category $category)
    {
        if ($category->image) {
            Storage::disk('public')->delete($category->image);
        }

        $category->delete();

        return redirect()->route('kategori.index')
            ->with('success', 'Kategori berhasil dihapus!');
    }

    public function ajaxEdit(Category $category)
    {
        try {
            $treatmentTypes = TreatmentType::active()->get();
            $categoryTypes = [
                'nail_shape' => 'Kategori Kuku',
                'nail_type' => 'Type Nails',
                'color' => 'Warna Kuku',
                'accessory' => 'Accessoris Kuku'
            ];
            
            $html = view('dashboard.kategori.partials.edit-form', compact('category', 'treatmentTypes', 'categoryTypes'))->render();
            
            return response()->json([
                'success' => true,
                'html' => $html
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error loading form: ' . $e->getMessage()
            ], 500);
        }
    }

    public function ajaxStore(Request $request)
{
    try {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|in:nail_shape,nail_type,color,accessory',
            'price' => 'required|integer|min:0',
            'treatment_type_id' => 'required|exists:treatment_types,id',
            'code' => 'nullable|string|unique:categories,code',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description' => 'nullable|string',
            'order' => 'nullable|integer'
        ], [
            'name.required' => 'Nama kategori wajib diisi',
            'type.required' => 'Jenis kategori wajib dipilih',
            'type.in' => 'Jenis kategori tidak valid',
            'price.required' => 'Harga wajib diisi',
            'price.integer' => 'Harga harus berupa angka',
            'treatment_type_id.required' => 'Treatment type wajib dipilih',
            'treatment_type_id.exists' => 'Treatment type tidak valid',
        ]);

        $data = $request->all();

        if (empty($data['code'])) {
            $data['code'] = Category::generateCode($data['type']);
        }

        if ($request->hasFile('image')) {
            $type = $request->type;
            $folder = 'img/kategori/';
            
            switch($type) {
                case 'nail_shape': $folder .= 'nail_shape'; break;
                case 'nail_type': $folder .= 'nail_type'; break;
                case 'color': $folder .= 'nail_color'; break;
                case 'accessory': $folder .= 'nail_accessoris'; break;
                default: $folder .= 'other';
            }
            
            if (!file_exists(public_path($folder))) {
                mkdir(public_path($folder), 0755, true);
            }
            
            $imageName = time() . '_' . $request->file('image')->getClientOriginalName();
            $request->file('image')->move(public_path($folder), $imageName);
            $data['image'] = $folder . '/' . $imageName;
        }

        $category = Category::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil ditambahkan!',
            'category' => $category
        ]);

    } catch (\Illuminate\Validation\ValidationException $e) {
        return response()->json([
            'success' => false,
            'message' => 'Validasi gagal',
            'errors' => $e->errors()
        ], 422);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
}

    public function ajaxUpdate(Request $request, Category $category)
{
    try {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|in:nail_shape,nail_type,color,accessory',
            'price' => 'required|integer|min:0',
            'treatment_type_id' => 'required|exists:treatment_types,id',
            'code' => 'nullable|string|unique:categories,code,' . $category->id,
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description' => 'nullable|string',
            'order' => 'nullable|integer'
        ]);

        $data = $request->all();

        if (empty($data['code'])) {
            $data['code'] = Category::generateCode($data['type']);
        }

        if ($request->hasFile('image')) {
            if ($category->image && file_exists(public_path($category->image))) {
                unlink(public_path($category->image));
            }
            
            $type = $request->type;
            $folder = 'img/kategori/';
            
            switch($type) {
                case 'nail_shape': $folder .= 'nail_shape'; break;
                case 'nail_type': $folder .= 'nail_type'; break;
                case 'color': $folder .= 'nail_color'; break;
                case 'accessory': $folder .= 'nail_accessoris'; break;
                default: $folder .= 'other';
            }
            
            $imageName = time() . '_' . $request->file('image')->getClientOriginalName();
            $request->file('image')->move(public_path($folder), $imageName);
            $data['image'] = $folder . '/' . $imageName;
        }

        if ($request->has('remove_image')) {
            if ($category->image && file_exists(public_path($category->image))) {
                unlink(public_path($category->image));
            }
            $data['image'] = null;
        }

        $category->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diperbarui!',
            'category' => $category
        ]);

    } catch (\Illuminate\Validation\ValidationException $e) {
        return response()->json([
            'success' => false,
            'message' => 'Validasi gagal',
            'errors' => $e->errors()
        ], 422);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
}
public function ajaxDestroy(Category $category)
{
    try {
        if ($category->image) {
            Storage::disk('public')->delete($category->image);
        }

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil dihapus!'
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan: ' . $e->getMessage()
        ], 500);
    }
}
}