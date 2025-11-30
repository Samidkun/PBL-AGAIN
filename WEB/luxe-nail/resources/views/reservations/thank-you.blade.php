@extends('layouts.app')

@section('title', 'Thank You')

@section('content')
<section class="thankyou-page">
    <div class="container">
        <div class="thankyou-wrap">
            
            <div class="thankyou-card">
                <div class="thankyou-icon">
                    <i class="fas fa-hand-sparkles luxe-icon"></i>
                </div>

                <h2 class="thankyou-title">
                    Thank You for Your Booking!
                </h2>

                <p class="thankyou-subtitle">
                    Your booking request has been received.<br>
                    We will confirm your payment soon.
                </p>

                <div class="thankyou-actions">
                    <a href="{{ route('home') }}" class="btn btn-home">
                        Back to Home
                    </a>
                </div>
            </div>

        </div>
    </div>
</section>
@endsection
