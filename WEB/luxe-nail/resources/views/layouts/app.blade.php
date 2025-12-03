<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LUXE NAIL - @yield('title')</title>

    {{-- Bootstrap & Fonts --}}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;700;900&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    {{-- Custom CSS --}}
    <link rel="stylesheet" href="{{ asset('css/style.css') }}">
</head>

{{-- ✅ TAMBAH CLASS INI --}}
<body class="layout-root">

{{-- HEADER --}}
<header class="luxe-header">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center">
            <div class="logo-container">
                <img src="{{ asset('img/luxe-nail-1.png') }}" alt="Luxe Nail" class="logo-img">
                <div class="logo-text">LUXE NAIL</div>
            </div>

            <nav class="d-none d-lg-flex align-items-center">
                <a class="nav-link" href="{{ route('home') }}">Home</a>
                <a class="nav-link" href="#about">About</a>
                <a class="nav-link" href="#services">Services</a>
                <a class="nav-link" href="#gallery">Gallery</a>
                <a class="nav-link" href="#contact">Contact</a>
                <a class="nav-link" href="{{ route('payment.check_invoice_form') }}">Check Booking</a>
                <a class="btn btn-book" href="{{ route('reservations.create') }}">Book Now</a>
                <a class="btn btn-login-nav" href="{{ route('login') }}">Login</a>
            </nav>

            <div class="d-lg-none">
                <button class="btn btn-book" type="button" data-bs-toggle="collapse" data-bs-target="#mobileMenu">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
        </div>

        {{-- MOBILE MENU --}}
        <div class="collapse d-lg-none" id="mobileMenu">
            <div class="d-flex flex-column bg-white p-3 mt-3 rounded shadow">
                <a class="nav-link py-2" href="#home">Home</a>
                <a class="nav-link py-2" href="#about">About</a>
                <a class="nav-link py-2" href="#services">Services</a>
                <a class="nav-link py-2" href="#gallery">Gallery</a>
                <a class="nav-link py-2" href="#contact">Contact</a>
                <a class="nav-link py-2" href="{{ route('payment.check_invoice_form') }}">Check Booking</a>
                <a class="btn btn-book mt-2" href="{{ route('reservations.create') }}">Book Now</a>
            </div>
        </div>
    </div>
</header>

<main class="main-content">
    @yield('content')
</main>

{{-- FOOTER --}}
<footer class="footer">
    <div class="container">
        <div class="row">

            <div class="col-lg-4 col-md-6 mb-4 mb-md-0">
                <div class="footer-logo">LUXE NAIL</div>
                <p class="footer-description">
                    Transform your nails with our premium nail services.
                </p>
            </div>

            <div class="col-lg-2 col-md-6 mb-4 mb-md-0">
                <h5 class="footer-title">Links</h5>
                <ul class="footer-links">
                    <li><a href="#home">Home</a></li>
                    <li><a href="#about">About</a></li>
                    <li><a href="#services">Services</a></li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
                <h5 class="footer-title">Services</h5>
                <ul class="footer-links">
                    <li><a href="#">Nail Extensions</a></li>
                    <li><a href="#">Nail Art</a></li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6">
                <h5 class="footer-title">Contact</h5>
                <ul class="footer-links">
                    <li><i class="fas fa-phone me-2"></i> +62 812 3456 7890</li>
                </ul>
            </div>
        </div>

        <div class="copyright">
            &copy; 2023 Luxe Nail. All rights reserved.
        </div>
    </div>
</footer>

{{-- BOOTSTRAP JS --}}
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

{{-- GENERAL HEADER BEHAVIOR --}}
<script>
    window.addEventListener('scroll', function() {
        const header = document.querySelector('.luxe-header');
        if (window.scrollY > 50) {
            header.style.padding = '10px 0';
            header.style.boxShadow = '0 5px 15px rgba(0,0,0,0.1)';
        } else {
            header.style.padding = '15px 0';
            header.style.boxShadow = '0 2px 15px rgba(214,122,135,0.1)';
        }
    });
</script>

{{-- PAGE SPECIFIC SCRIPTS --}}
@yield('scripts')

</body>
</html>
