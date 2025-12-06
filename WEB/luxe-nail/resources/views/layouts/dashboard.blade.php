<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <meta http-equiv="Content-Security-Policy" content="
        default-src 'self';
        script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com;
        style-src  'self' 'unsafe-inline' https://cdn.jsdelivr.net https://fonts.googleapis.com https://cdnjs.cloudflare.com;
        font-src   'self' https://fonts.gstatic.com https://cdn.jsdelivr.net https://cdnjs.cloudflare.com data:;
        img-src    'self' data: blob:;
        connect-src 'self' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com;
    ">

    <title>@yield('title', 'Luxe Nail Dashboard')</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="{{ asset('css/dashboard.css') }}">

    <meta name="csrf-token" content="{{ csrf_token() }}">
    @stack('styles')
</head>

<body>
    <!-- === SIDEBAR (punyamu, ga diubah) === -->
    @include('layouts.sidebar')

    <!-- === MAIN CONTENT === -->
    <div id="main-content" class="main-content">
        <div class="topbar d-flex justify-content-between align-items-center mb-4 px-2">
            <div class="greeting">
                @yield('greeting')
            </div>
            <div class="user-info d-flex align-items-center gap-2">
            </div>
        </div>

        <div class="container-fluid">
            @yield('content')
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Chart.js LOCAL -->
    <script src="{{ asset('js/chart.min.js') }}"></script>

    <!-- Sidebar Toggle Script (Fix mobile + desktop) -->
    <script>
        const toggleBtn = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');

        function isMobile() {
            return window.innerWidth <= 992;
        }

        if (toggleBtn && sidebar && mainContent) {
            toggleBtn.addEventListener('click', () => {
                if (isMobile()) {
                    sidebar.classList.toggle('active'); // mobile offcanvas
                } else {
                    sidebar.classList.toggle('collapsed'); // desktop mini
                    mainContent.classList.toggle('sidebar-collapsed');
                }
            });

            window.addEventListener('resize', () => {
                if (isMobile()) {
                    sidebar.classList.remove('collapsed');
                    mainContent.classList.remove('sidebar-collapsed');
                } else {
                    sidebar.classList.remove('active');
                }
            });
        }
    </script>

    @stack('scripts')
</body>
</html>
