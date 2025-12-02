<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\TreatmentType;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    // ===========================
    // INDEX
    // ===========================
    public function index(Request $request)
    {
        $selectedTreatmentType = $request->get('treatment_type');
        $selectedCategoryType  = $request->get('category_type');

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

        // FINAL AI TYPES
        $categoryTypes = [
            'shape'     => 'Shape (AI)',
            'color'     => 'Color (AI)',
            'finish'    => 'Finish (AI)',
            'accessory' => 'Accessories (AI)',
        ];

        return view('dashboard.kategori.kategori', compact(
            'treatmentTypes',
            'allTreatmentTypes',
            'selectedTreatmentType',
            'selectedCategoryType',
            'categoryTypes'
        ));
    }

    // ===========================
    // GET CREATE FORM (AJAX)
    // ===========================
    public function getCreateForm()
    {
        $treatmentTypes = TreatmentType::active()->get();

        $categoryTypes = [
            'shape'     => 'Shape (AI)',
            'color'     => 'Color (AI)',
            'finish'    => 'Finish (AI)',
            'accessory' => 'Accessories (AI)',
        ];

        return view('dashboard.kategori.partials.create-form', compact(
            'treatmentTypes', 'categoryTypes'
        ));
    }

    public function create()
    {
        $treatmentTypes = TreatmentType::active()->get();

        $categoryTypes = [
            'shape'     => 'Shape (AI)',
            'color'     => 'Color (AI)',
            'finish'    => 'Finish (AI)',
            'accessory' => 'Accessories (AI)',
        ];

        return view('dashboard.kategori.create', compact(
            'treatmentTypes','categoryTypes'
        ));
    }

    // ===========================
    // STORE KATEGORI
    // ===========================
    public function store(Request $request)
    {
        $request->validate([
            'name'               => 'required|string|max:255',
            'type'               => 'required|string|in:shape,color,finish,accessory',
            'price'              => 'required|integer|min:0',
            'treatment_type_id'  => 'required|exists:treatment_types,id',
            'code'               => 'nullable|string|unique:categories,code',
            'image'              => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description'        => 'nullable|string',
            'order'              => 'nullable|integer',
        ]);

        $data = $request->all();

        // generate kode otomatis
        if (empty($data['code'])) {
            $data['code'] = Category::generateCode($data['type']);
        }

        // upload image
        if ($request->hasFile('image')) {
            $data['image'] = $this->storeImageByType($request->type, $request->file('image'));
        }

        Category::create($data);

        return redirect()->route('kategori.index')
            ->with('success', 'Kategori berhasil ditambahkan!');
    }

    // ===========================
    // EDIT
    // ===========================
    public function edit(Category $category)
    {
        $treatmentTypes = TreatmentType::active()->get();

        $categoryTypes = [
            'shape'     => 'Shape (AI)',
            'color'     => 'Color (AI)',
            'finish'    => 'Finish (AI)',
            'accessory' => 'Accessories (AI)',
        ];

        return view('dashboard.kategori.edit', compact(
            'category','treatmentTypes','categoryTypes'
        ));
    }

    // ===========================
    // UPDATE
    // ===========================
    public function update(Request $request, Category $category)
    {
        $request->validate([
            'name'               => 'required|string|max:255',
            'type'               => 'required|string|in:shape,color,finish,accessory',
            'price'              => 'required|integer|min:0',
            'treatment_type_id'  => 'required|exists:treatment_types,id',
            'code'               => 'nullable|string|unique:categories,code,' . $category->id,
            'image'              => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description'        => 'nullable|string',
            'order'              => 'nullable|integer',
        ]);

        $data = $request->all();

        if (!isset($data['code']) || $data['code'] === '' || $data['code'] === null) {
    $data['code'] = $category->code;
}


        // upload image
        if ($request->hasFile('image')) {
            if ($category->image && file_exists(public_path($category->image))) {
                unlink(public_path($category->image));
            }
            $data['image'] = $this->storeImageByType($request->type, $request->file('image'));
        }

        if ($request->has('remove_image')) {
            if ($category->image && file_exists(public_path($category->image))) {
                unlink(public_path($category->image));
            }
            $data['image'] = null;
        }

        $category->update($data);

        return redirect()->route('kategori.index')
            ->with('success', 'Kategori berhasil diperbarui!');
    }

    // ===========================
    // AJAX EDIT
    // ===========================
    public function ajaxEdit(Category $category)
    {
        try {
            $treatmentTypes = TreatmentType::active()->get();

            $categoryTypes = [
                'shape'     => 'Shape (AI)',
                'color'     => 'Color (AI)',
                'finish'    => 'Finish (AI)',
                'accessory' => 'Accessories (AI)',
            ];

            $html = view('dashboard.kategori.partials.edit-form', compact(
                'category','treatmentTypes','categoryTypes'
            ))->render();

            return response()->json(['success' => true, 'html' => $html]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // ===========================
    // AJAX STORE
    // ===========================
    public function ajaxStore(Request $request)
    {
        try {
            $request->validate([
                'name'               => 'required|string|max:255',
                'type'               => 'required|string|in:shape,color,finish,accessory',
                'price'              => 'required|integer|min:0',
                'treatment_type_id'  => 'required|exists:treatment_types,id',
                'code'               => 'nullable|string|unique:categories,code',
                'image'              => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
                'description'        => 'nullable|string',
                'order'              => 'nullable|integer',
            ]);

            $data = $request->all();

            if (empty($data['code'])) {
                $data['code'] = Category::generateCode($data['type']);
            }

            if ($request->hasFile('image')) {
                $data['image'] = $this->storeImageByType($request->type, $request->file('image'));
            }

            $category = Category::create($data);

            return response()->json([
                'success'  => true,
                'message'  => 'Kategori berhasil ditambahkan!',
                'category' => $category
            ]);

        } catch (\Exception $e) {
            return response()->json(['success'=>false,'message'=>$e->getMessage()],500);
        }
    }

    // ===========================
    // AJAX UPDATE
    // ===========================
    public function ajaxUpdate(Request $request, Category $category)
    {
        try {
            $request->validate([
                'name'               => 'required|string|max:255',
                'type'               => 'required|string|in:shape,color,finish,accessory',
                'price'              => 'required|integer|min:0',
                'treatment_type_id'  => 'required|exists:treatment_types,id',
                'code'               => 'nullable|string|unique:categories,code,' . $category->id,
                'image'              => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
                'description'        => 'nullable|string',
                'order'              => 'nullable|integer',
            ]);

            $data = $request->all();

            if (!isset($data['code']) || $data['code'] === '' || $data['code'] === null) {
                $data['code'] = $category->code;
            }

            if ($request->hasFile('image')) {
                if ($category->image && file_exists(public_path($category->image))) {
                    unlink(public_path($category->image));
                }
                $data['image'] = $this->storeImageByType($request->type,$request->file('image'));
            }

            if ($request->has('remove_image')) {
                if ($category->image && file_exists(public_path($category->image))) {
                    unlink(public_path($category->image));
                }
                $data['image'] = null;
            }

            $category->update($data);

            return response()->json([
                'success'=>true,
                'message'=>'Kategori berhasil diperbarui!'
            ]);
        } catch (\Exception $e) {
            return response()->json(['success'=>false,'message'=>$e->getMessage()],500);
        }
    }

    // ===========================
    // AJAX DELETE
    // ===========================
    public function ajaxDestroy(Category $category)
    {
        try {
            if ($category->image && file_exists(public_path($category->image))) {
                unlink(public_path($category->image));
            }

            $category->delete();

            return response()->json([
                'success'=>true,
                'message'=>'Kategori berhasil dihapus!'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success'=>false,
                'message'=>$e->getMessage()
            ],500);
        }
    }

    // ===========================
    // HELPER: STORE IMAGE
    // ===========================
    private function storeImageByType($type, $file)
    {
        $folder = 'img/kategori/';

        switch($type) {
            case 'shape':
                $folder .= 'nail_shape';
                break;
            case 'color':
                $folder .= 'nail_color';
                break;
            case 'finish':
                $folder .= 'nail_type';
                break;
            case 'accessory':
                $folder .= 'nail_accessoris';
                break;
            default:
                $folder .= 'other';
        }

        if (!file_exists(public_path($folder))) {
            mkdir(public_path($folder), 0755, true);
        }

        $imageName = time() . '_' . $file->getClientOriginalName();
        $file->move(public_path($folder), $imageName);

        return $folder . '/' . $imageName;
    }
}
