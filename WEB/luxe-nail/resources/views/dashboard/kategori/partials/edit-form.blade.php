<form id="categoryForm" enctype="multipart/form-data">
    @if(isset($category) && $category->id)
        @method('PUT')
    @endif
    @csrf
    
    <div class="row">
        <div class="col-md-6">
            <div class="mb-3">
                <label for="name" class="form-label">Nama Kategori</label>
                <input type="text" class="form-control" id="name" name="name" 
                       value="{{ $category->name ?? '' }}" required>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="mb-3">
                <label for="treatment_type_id" class="form-label">Treatment Type</label>
                <select class="form-select" id="treatment_type_id" name="treatment_type_id" required>
                    <option value="">Pilih Treatment Type</option>
                    @foreach($treatmentTypes as $treatment)
                        <option value="{{ $treatment->id }}" 
                            {{ (isset($category) && $category->treatment_type_id == $treatment->id) ? 'selected' : '' }}>
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
                <label for="type" class="form-label">Jenis Kategori</label>
                <select class="form-select" id="type" name="type" required>
                    <option value="">Pilih Jenis Kategori</option>
                    @foreach($categoryTypes as $key => $value)
                        <option value="{{ $key }}" 
                            {{ (isset($category) && $category->type == $key) ? 'selected' : '' }}>
                            {{ $value }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="mb-3">
                <label for="price" class="form-label">Harga (Rp)</label>
                <input type="number" class="form-control" id="price" name="price" 
                       value="{{ $category->price ?? '' }}" min="0" step="100" required>
            </div>
        </div>
    </div>

    <div class="mb-3">
        <label for="image" class="form-label">Gambar Kategori</label>
        @if(isset($category) && $category->image)
        <div class="mb-2">
            <img src="{{ asset($category->image) }}" alt="Current image" class="img-thumbnail" style="max-height: 100px;">
            <div class="form-check mt-2">
                <input class="form-check-input" type="checkbox" name="remove_image" id="remove_image">
                <label class="form-check-label" for="remove_image">
                    Hapus gambar saat ini
                </label>
            </div>
        </div>
        @endif
        <input type="file" class="form-control" id="image" name="image" accept="image/*">
    </div>

    <div class="mb-3">
        <label for="description" class="form-label">Deskripsi</label>
        <textarea class="form-control" id="description" name="description" rows="3">{{ $category->description ?? '' }}</textarea>
    </div>
</form>