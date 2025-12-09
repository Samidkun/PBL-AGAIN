<!DOCTYPE html>
<html>

<head>
    <style>
        body {
            font-family: DejaVu Sans, sans-serif;
            background: #fff5f7;
            padding: 20px;
        }

        .box {
            background: white;
            padding: 25px;
            border-radius: 12px;
            border: 2px solid #ffb6c1;
        }

        h2 {
            color: #d6336c;
        }

        .label {
            font-weight: bold;
            color: #444;
        }
    </style>
</head>

<body>

    <div class="box">
        <h2>Luxe Nail — Booking Receipt</h2>

        <p><span class="label">Customer:</span> {{ $r->name }}</p>
        <p><span class="label">Treatment:</span> {{ ucfirst(str_replace('_', ' ', $r->treatment_type)) }}</p>
        <p><span class="label">Date:</span> {{ $r->reservation_date }}</p>
        <p><span class="label">Time:</span> {{ $r->reservation_time }}</p>
        <p><span class="label">Invoice Number:</span> {{ $r->queue_number }}</p>

        <hr>

        <p><span class="label">Booking Fee:</span> Rp {{ number_format($r->booking_fee, 0, ',', '.') }}</p>
        <p><span class="label">Payment Method:</span> {{ strtoupper($r->payment_method) }}</p>

        <hr>

        <p style="font-size: 12px; color: #888;">
            Harap tunjukkan struk ini saat datang ke Luxe Nail Studio.
        </p>
    </div>

</body>

</html>