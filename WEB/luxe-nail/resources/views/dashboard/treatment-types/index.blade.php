@extends('layouts.dashboard')

@section('title', 'Treatment Types - Luxe Nail')
@section('page-title', 'Treatment Types')

@section('content')
<div class="container-fluid mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="text-dark fw-bold m-0">Treatment Types</h2>
        <a href="{{ route('treatment-types.create') }}" class="btn btn-primary" style="background-color: #ee9ca7; border: none;">
            <i class="bi bi-plus-lg me-2"></i>Add New
        </a>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="px-4 py-3 text-secondary">Order</th>
                            <th class="px-4 py-3 text-secondary">Name</th>
                            <th class="px-4 py-3 text-secondary">Duration (Min)</th>
                            <th class="px-4 py-3 text-secondary">Description</th>
                            <th class="px-4 py-3 text-secondary text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($treatmentTypes as $type)
                            <tr>
                                <td class="px-4">{{ $type->order }}</td>
                                <td class="px-4 fw-bold">{{ $type->name }}</td>
                                <td class="px-4">
                                    <span class="badge bg-info text-dark">{{ $type->duration }} mins</span>
                                </td>
                                <td class="px-4 text-muted">{{ Str::limit($type->description, 50) }}</td>
                                <td class="px-4 text-end">
                                    <a href="{{ route('treatment-types.edit', $type->id) }}" class="btn btn-sm btn-outline-primary me-2">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="{{ route('treatment-types.destroy', $type->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">
                                    <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                    No treatment types found.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
