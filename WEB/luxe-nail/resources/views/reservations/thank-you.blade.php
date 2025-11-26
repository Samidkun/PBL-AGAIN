@extends('layouts.app')

@section('title', 'Thank You')

@section('content')
<div class="container py-5 text-center">

    <img src="{{ asset('img/luxe-nail-1.png') }}" width="120" class="mb-4">

    <h2 class="fw-bold" style="font-family: 'Playfair Display', serif;">
        Thank You for Your Booking!
    </h2>

    <p class="text-muted mb-4">
        Your booking request has been received.
        We will confirm your payment soon.
    </p>

    <a href="{{ route('home') }}"
       class="btn btn-primary px-4 py-3"
       style="background:#d889a6; border:none; border-radius:12px;">
       Back to Home
    </a>

</div>
@endsection
