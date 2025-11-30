@extends('layouts.dashboard')

@section('title', 'Add Treatment Type - Luxe Nail')
@section('page-title', 'Add Treatment Type')

@section('content')
<div class="container-fluid mt-4">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-white border-0 py-3">
                    <h4 class="mb-0 fw-bold text-dark">Add New Treatment Type</h4>
                </div>
                <div class="card-body p-4">
                    <form action="{{ route('treatment-types.store') }}" method="POST">
                        @csrf

                        <div class="mb-3">
                            <label for="name" class="form-label fw-semibold">Name</label>
                            <input type="text" class="form-control" id="name" name="name" required placeholder="e.g. Nail Extension">
                        </div>

                        <div class="mb-3">
                            <label for="duration" class="form-label fw-semibold">Duration (Minutes)</label>
                            <input type="number" class="form-control" id="duration" name="duration" required min="1" placeholder="e.g. 60">
                            <div class="form-text">Estimated time for this treatment in minutes.</div>
                        </div>

                        <div class="mb-3">
                            <label for="description" class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3" placeholder="Brief description..."></textarea>
                        </div>

                        <div class="mb-3">
                            <label for="order" class="form-label fw-semibold">Display Order</label>
                            <input type="number" class="form-control" id="order" name="order" value="0">
                        </div>

                        <div class="d-flex justify-content-end gap-2 mt-4">
                            <a href="{{ route('treatment-types.index') }}" class="btn btn-light">Cancel</a>
                            <button type="submit" class="btn btn-primary" style="background-color: #ee9ca7; border: none;">Save Treatment Type</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
