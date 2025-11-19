<form id="categoryForm" enctype="multipart/form-data">
    @csrf
    
    <div class="row">
        <div class="col-md-6">
            <div class="mb-3">
                <label for="name" class="form-label">Nama Kategori <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="name" name="name" 
                       value="{{ old('name') }}" required placeholder="Masukkan nama kategori">
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="mb-3">
                <label for="treatment_type_id" class="form-label">Treatment Type <span class="text-danger">*</span></label>
                <select class="form-select" id="treatment_type_id" name="treatment_type_id" required>
                    <option value="">Pilih Treatment Type</option>
                    @foreach($treatmentTypes as $treatment)
                        <option value="{{ $treatment->id }}" {{ old('treatment_type_id') == $treatment->id ? 'selected' : '' }}>
                            {{ $treatment->name }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="mb-3">
                <label for="type" class="form-label">Jenis Kategori <span class="text-danger">*</span></label>
                <select class="form-select" id="type" name="type" required>
                    <option value="">Pilih Jenis Kategori</option>
                    @foreach($categoryTypes as $key => $value)
                        <option value="{{ $key }}" {{ old('type') == $key ? 'selected' : '' }}>
                            {{ $value }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="mb-3">
                <label for="price" class="form-label">Harga (Rp) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" id="price" name="price" 
                       value="{{ old('price') }}" min="0" step="100" required>
                <div class="form-text">Contoh: 75000, 150500, 89800</div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="mb-3">
                <label for="order" class="form-label">Urutan Tampil</label>
                <input type="number" class="form-control" id="order" name="order" 
                       value="{{ old('order', 0) }}" min="0">
            </div>
        </div>
    </div>

    <div class="mb-3">
        <label for="image" class="form-label">Gambar Kategori</label>
        <input type="file" class="form-control" id="image" name="image" accept="image/*">
    </div>

    <div class="mb-3">
        <label for="description" class="form-label">Deskripsi</label>
        <textarea class="form-control" id="description" name="description" rows="3">{{ old('description') }}</textarea>
    </div>
</form>