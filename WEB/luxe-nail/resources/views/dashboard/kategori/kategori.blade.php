@extends('layouts.dashboard')

@push('styles')
    <link rel="stylesheet" href="{{ asset('css/kategori.css') }}">
@endpush

@section('content')
    <div class="kategori-container">
        <!-- HEADER -->
        <div class="kategori-header">
            <div class="header-content">
                <h1 class="mb-1 fw-bold">Category Management</h1>
                <p class="mb-0 opacity-75">Manage treatment types and their categories</p>
            </div>

            <!-- FILTER & TOMBOL DI HEADER -->
            <div class="header-filters">
                <select name="treatment_type" class="filter-select" onchange="submitFilter()">
                    <option value="">All Treatments</option>
                    @foreach($allTreatmentTypes as $treatment)
                        <option value="{{ $treatment->id }}" {{ $selectedTreatmentType == $treatment->id ? 'selected' : '' }}>
                            {{ $treatment->name }}
                        </option>
                    @endforeach
                </select>

                <select name="category_type" class="filter-select" onchange="submitFilter()">
                    <option value="">All Categories</option>
                    @foreach($categoryTypes as $key => $name)
                        <option value="{{ $key }}" {{ $selectedCategoryType == $key ? 'selected' : '' }}>
                            {{ $name }}
                        </option>
                    @endforeach
                </select>

                <a href="{{ route('kategori.index') }}" class="btn-reset">
                    Reset Filter
                </a>

                <button class="btn btn-primary" onclick="showCategoryModal()">
                    <i class="bi bi-plus-circle me-2"></i>Add Category
                </button>
            </div>
        </div>

        <!-- FORM HIDDEN UNTUK FILTER -->
        <form method="GET" action="{{ route('kategori.index') }}" id="filterForm">
            <input type="hidden" name="treatment_type" id="treatmentTypeInput" value="{{ $selectedTreatmentType }}">
            <input type="hidden" name="category_type" id="categoryTypeInput" value="{{ $selectedCategoryType }}">
        </form>

        @if(session('success'))
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>
                {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        @endif

        <!-- KONTEN KATEGORI -->
        @foreach($treatmentTypes as $treatmentType)
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header py-3 category-badge">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="mb-0 text-white">
                                <i class="bi bi-stars me-2"></i>{{ $treatmentType->name }}
                            </h4>
                            @if($treatmentType->description)
                                <p class="mb-0 text-white opacity-75 mt-1">{{ $treatmentType->description }}</p>
                            @endif
                        </div>
                        <div>
                            <span class="badge bg-light text-dark">
                                {{ $treatmentType->categories->count() }} Categories
                            </span>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    @foreach($categoryTypes as $typeKey => $typeName)
                        @php
                            $typeCategories = $treatmentType->categories->where('type', $typeKey);
                        @endphp

                        @if($typeCategories->count() > 0 || !$selectedCategoryType)
                            <div class="mb-4">
                                <h6 class="fw-bold mb-3 text-dark-pink">
                                    <i class="bi bi-chevron-right me-1"></i>{{ $typeName }}
                                    <span class="badge bg-secondary ms-2">{{ $typeCategories->count() }}</span>
                                </h6>

                                <div class="row">
                                    @foreach($typeCategories as $category)
                                        <div class="col-md-3 mb-3">
                                            <div class="card h-100 kategori-card">
                                                @if($category->image)
                                                    <img src="{{ asset($category->image) }}" class="card-img-top" alt="{{ $category->name }}"
                                                        style="height: 120px; object-fit: cover; border-radius: 8px 8px 0 0;">
                                                @else
                                                    <div class="card-img-top bg-light d-flex align-items-center justify-content-center"
                                                        style="height: 120px; border-radius: 8px 8px 0 0;">
                                                        <i class="bi bi-image text-muted" style="font-size: 2rem;"></i>
                                                    </div>
                                                @endif
                                                <div class="card-body">
                                                    <h6 class="card-title fw-bold mb-1">{{ $category->name }}</h6>
                                                    <small class="text-muted d-block mb-1">Kode: {{ $category->code }}</small>
                                                    <p class="card-text text-muted small mb-2">
                                                        {{ $category->description ?: 'No description' }}</p>
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <span class="fw-bold text-primary">{{ $category->formatted_price }}</span>
                                                        <div class="btn-group">
                                                            <button class="btn btn-sm btn-outline-primary"
                                                                onclick="editCategory({{ $category->id }})">
                                                                <i class="bi bi-pencil"></i>
                                                            </button>
                                                            <button class="btn btn-sm btn-outline-danger"
                                                                onclick="deleteCategory({{ $category->id }}, '{{ $category->name }}')">
                                                                <i class="bi bi-trash"></i>
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        @endif
                    @endforeach
                </div>
            </div>
        @endforeach
    </div>

    <!-- MODAL UNTUK CREATE/EDIT -->
    <div class="modal fade" id="categoryModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Add Category</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="modalBody">
                    <!-- Form akan di-load via AJAX -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="submitCategoryForm()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL SUCCESS -->
    <div class="modal fade" id="successModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-body text-center p-5">
                    <i class="bi bi-check-circle-fill text-success display-4"></i>
                    <h4 class="text-success mt-3" id="successMessage">Success!</h4>
                    <button type="button" class="btn btn-success mt-3" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Deklarasi variabel global
        let currentCategoryId = null;
        let categoryModal = null;
        let successModal = null;

        // Fungsi untuk inisialisasi modal
        function initModals() {
            if (!categoryModal) {
                const categoryModalElement = document.getElementById('categoryModal');
                if (categoryModalElement) {
                    categoryModal = new bootstrap.Modal(categoryModalElement);
                }
            }

            if (!successModal) {
                const successModalElement = document.getElementById('successModal');
                if (successModalElement) {
                    successModal = new bootstrap.Modal(successModalElement);
                }
            }
        }

        function showCategoryModal() {
            initModals();
            currentCategoryId = null;
            document.getElementById('modalTitle').textContent = 'Add Category';
            document.getElementById('modalBody').innerHTML = '<div class="text-center"><div class="spinner-border"></div><p>Loading...</p></div>';

            // ✅ PERBAIKAN: Panggil route baru untuk partial form
            fetch(`/kategori/get-create-form`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(html => {
                    document.getElementById('modalBody').innerHTML = html;
                    if (categoryModal) {
                        categoryModal.show();
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('modalBody').innerHTML = '<div class="alert alert-danger">Error loading form: ' + error.message + '</div>';
                });
        }

        function editCategory(categoryId) {
            initModals();
            console.log('Editing category:', categoryId);
            currentCategoryId = categoryId;
            document.getElementById('modalTitle').textContent = 'Edit Category';
            document.getElementById('modalBody').innerHTML = '<div class="text-center"><div class="spinner-border"></div><p>Loading...</p></div>';

            // Load form edit via AJAX
            fetch(`/kategori/${categoryId}/ajax-edit`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        document.getElementById('modalBody').innerHTML = data.html;
                        if (categoryModal) {
                            categoryModal.show();
                        }
                    } else {
                        throw new Error(data.message || 'Failed to load form');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('modalBody').innerHTML = '<div class="alert alert-danger">Error loading form: ' + error.message + '</div>';
                });
        }

        function submitCategoryForm() {
            const form = document.getElementById('categoryForm');
            if (!form) {
                alert('Form tidak ditemukan!');
                return;
            }

            const formData = new FormData(form);
            const submitBtn = document.querySelector('#categoryModal .btn-primary');

            // Disable button dan show loading
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Saving...';

            let url, method;

            if (currentCategoryId) {
                url = `/kategori/${currentCategoryId}/ajax-update`;
                method = 'POST';
                formData.append('_method', 'PUT');
            } else {
                url = `{{ route('kategori.ajax-store') }}`;
                method = 'POST';
            }

            // Debug: lihat data yang dikirim
            console.log('Sending data:');
            for (let [key, value] of formData.entries()) {
                console.log(key + ': ' + value);
            }

            fetch(url, {
                method: method,
                body: formData,
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                    'Accept': 'application/json'
                }
            })
                .then(response => {
                    console.log('Response status:', response.status);
                    if (!response.ok) {
                        // Jika error 422, coba baca response untuk detail error
                        return response.json().then(errorData => {
                            throw new Error(`HTTP ${response.status}: ${JSON.stringify(errorData)}`);
                        });
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        if (categoryModal) {
                            categoryModal.hide();
                        }
                        document.getElementById('successMessage').textContent = data.message;
                        if (successModal) {
                            successModal.show();
                        }

                        // Reload page setelah 2 detik
                        setTimeout(() => {
                            window.location.reload();
                        }, 2000);
                    } else {
                        alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                    }
                })
                .catch(error => {
                    console.error('Error details:', error);
                    alert('Terjadi kesalahan: ' + error.message);
                })
                .finally(() => {
                    // Reset button
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = 'Save';
                });
        }

        function deleteCategory(categoryId, categoryName) {
            if (confirm(`Are you sure you want to delete category "${categoryName}"?`)) {
                fetch(`/kategori/${categoryId}/ajax-delete`, {
                    method: 'DELETE',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                })
                    .then(response => {
                        console.log('Delete response status:', response.status);
                        if (!response.ok) {
                            return response.json().then(errorData => {
                                throw new Error(`HTTP ${response.status}: ${JSON.stringify(errorData)}`);
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        if (data.success) {
                            document.getElementById('successMessage').textContent = data.message;
                            if (successModal) {
                                successModal.show();
                            }

                            setTimeout(() => {
                                window.location.reload();
                            }, 2000);
                        } else {
                            alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                        }
                    })
                    .catch(error => {
                        console.error('Delete Error:', error);
                        alert('Terjadi kesalahan: ' + error.message);
                    });
            }
        }

        function submitFilter() {
            document.getElementById('treatmentTypeInput').value = document.querySelector('select[name="treatment_type"]').value;
            document.getElementById('categoryTypeInput').value = document.querySelector('select[name="category_type"]').value;
            document.getElementById('filterForm').submit();
        }

        document.addEventListener('DOMContentLoaded', function () {
            initModals();
        });

        window.showCategoryModal = showCategoryModal;
        window.editCategory = editCategory;
        window.submitCategoryForm = submitCategoryForm;
        window.deleteCategory = deleteCategory;
        window.submitFilter = submitFilter;
        window.initModals = initModals;

        // Auto-refresh every 25 seconds
        setInterval(function() {
    location.reload();
}, 30000); // Auto-refresh every 30 seconds
    </script>
@endsection