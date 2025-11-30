<?php

namespace App\Http\Controllers;

use App\Models\TreatmentType;
use Illuminate\Http\Request;

class TreatmentTypeController extends Controller
{
    public function index()
    {
        $treatmentTypes = TreatmentType::orderBy('order')->get();
        return view('dashboard.treatment-types.index', compact('treatmentTypes'));
    }

    public function create()
    {
        return view('dashboard.treatment-types.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'duration' => 'required|integer|min:1',
            'description' => 'nullable|string',
            'order' => 'nullable|integer'
        ]);

        TreatmentType::create($request->all());

        return redirect()->route('treatment-types.index')
            ->with('success', 'Treatment type berhasil ditambahkan!');
    }

    public function edit(TreatmentType $treatmentType)
    {
        return view('dashboard.treatment-types.edit', compact('treatmentType'));
    }

    public function update(Request $request, TreatmentType $treatmentType)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'duration' => 'required|integer|min:1',
            'description' => 'nullable|string',
            'order' => 'nullable|integer'
        ]);

        $treatmentType->update($request->all());

        return redirect()->route('treatment-types.index')
            ->with('success', 'Treatment type berhasil diperbarui!');
    }

    public function destroy(TreatmentType $treatmentType)
    {
        $treatmentType->delete();

        return redirect()->route('treatment-types.index')
            ->with('success', 'Treatment type berhasil dihapus!');
    }
}