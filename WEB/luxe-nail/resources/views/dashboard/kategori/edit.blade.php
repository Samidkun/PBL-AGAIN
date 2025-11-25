@extends('layouts.dashboard')

@section('content')
<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-warning text-dark">
                    <h5 class="mb-0"><i class="bi bi-pencil me-2"></i>Edit Kategori</h5>
                </div>

                <div class="card-body">

                    <form action="{{ route('kategori.update', $category->id) }}" method="POST" enctype="multipart/form-data">
                        @csrf
                        @method('PUT')

                        {{-- NAME --}}
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori</label>
                            <input type="text" name="name" class="form-control"
                                   value="{{ $category->name }}" required>
                        </div>

                        {{-- TREATMENT TYPE --}}
                        <div class="mb-3">
                            <label class="form-label">Treatment Type</label>
                            <select name="treatment_type_id" class="form-select" required>
                                @foreach($treatmentTypes as $t)
                                    <option value="{{ $t->id }}" {{ $category->treatment_type_id == $t->id ? 'selected' : '' }}>
                                        {{ $t->name }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        {{-- CATEGORY TYPE --}}
                        <div class="mb-3">
                            <label class="form-label">Jenis Kategori</label>
                            <select name="type" class="form-select" required>
                                @foreach($categoryTypes as $key => $label)
                                    <option value="{{ $key }}" {{ $category->type == $key ? 'selected' : '' }}>
                                        {{ $label }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        {{-- PRICE --}}
                        <div class="mb-3">
                            <label class="form-label">Harga</label>
                            <input type="number" class="form-control" name="price"
                                   value="{{ $category->price }}" step="100" min="0" required>
                        </div>

                        {{-- CURRENT IMAGE --}}
                        <div class="mb-3">
                            <label class="form-label">Gambar</label>
                            @if($category->image)
                                <img src="{{ asset($category->image) }}" class="img-thumbnail mb-2" style="max-height: 200px;">
                                <div>
                                    <label>
                                        <input type="checkbox" name="remove_image"> Hapus gambar
                                    </label>
                                </div>
                            @endif
                            <input type="file" class="form-control mt-2" name="image" accept="image/*">
                        </div>

                        {{-- DESCRIPTION --}}
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea name="description" rows="3" class="form-control">{{ $category->description }}</textarea>
                        </div>

                        {{-- ACTIVE --}}
                        <div class="mb-3 form-check">
                            <input type="checkbox" name="is_active" class="form-check-input"
                                   {{ $category->is_active ? 'checked' : '' }}>
                            <label class="form-check-label">Kategori Aktif</label>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="{{ route('kategori.index') }}" class="btn btn-secondary">
                                <i class="bi bi-arrow-left me-2"></i>Kembali
                            </a>
                            <button class="btn btn-primary"><i class="bi bi-save me-2"></i>Update</button>
                        </div>

                    </form>

                </div>
            </div>
        </div>
    </div>
</div>
@endsection
