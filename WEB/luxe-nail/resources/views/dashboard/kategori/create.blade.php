@extends('layouts.dashboard')

@section('content')
<div class="container-fluid">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="bi bi-plus-circle me-2"></i>Tambah Kategori Baru</h5>
                </div>
                <div class="card-body">

                    <form action="{{ route('kategori.store') }}" method="POST" enctype="multipart/form-data">
                        @csrf

                        {{-- NAMA --}}
                        <div class="mb-3">
                            <label class="form-label">Nama Kategori</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>

                        {{-- TREATMENT TYPE --}}
                        <div class="mb-3">
                            <label class="form-label">Treatment Type</label>
                            <select name="treatment_type_id" class="form-select" required>
                                <option value="">Pilih Treatment</option>
                                @foreach($treatmentTypes as $t)
                                    <option value="{{ $t->id }}">{{ $t->name }}</option>
                                @endforeach
                            </select>
                        </div>

                        {{-- CATEGORY TYPE (FINAL) --}}
                        <div class="mb-3">
                            <label class="form-label">Jenis Kategori</label>
                            <select name="type" class="form-select" required>
                                <option value="">Pilih</option>
                                @foreach($categoryTypes as $key => $value)
                                    <option value="{{ $key }}">{{ $value }}</option>
                                @endforeach
                            </select>
                        </div>

                        {{-- PRICE --}}
                        <div class="mb-3">
                            <label class="form-label">Harga (Rp)</label>
                            <input type="number" name="price" class="form-control" step="100" min="0" required>
                            <div class="form-text">Contoh: 50000, 75000, 100000</div>
                        </div>

                        {{-- IMAGE --}}
                        <div class="mb-3">
                            <label class="form-label">Gambar</label>
                            <input type="file" class="form-control" name="image" accept="image/*">
                        </div>

                        {{-- DESCRIPTION --}}
                        <div class="mb-3">
                            <label class="form-label">Deskripsi</label>
                            <textarea name="description" class="form-control" rows="3"></textarea>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="{{ route('kategori.index') }}" class="btn btn-secondary">
                                <i class="bi bi-arrow-left me-2"></i>Kembali
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-save me-2"></i>Simpan
                            </button>
                        </div>

                    </form>

                </div>
            </div>
        </div>
    </div>
</div>
@endsection
