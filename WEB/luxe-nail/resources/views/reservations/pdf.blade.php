<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Invoice {{ $reservation->queue_number }}</title>

    <style>
        body {
            font-family: DejaVu Sans, sans-serif;
            font-size: 12px;
            padding: 10px;
        }
        .box {
            border: 2px dashed #d889a6;
            padding: 20px;
            border-radius: 10px;
        }
        .title {
            text-align:center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .sub {
            text-align:center;
            font-size: 12px;
            margin-bottom: 20px;
        }
        .row { margin-bottom: 8px; }
        .label { font-weight: bold; }
        .footer {
            margin-top: 25px;
            text-align: center;
            font-size: 11px;
            opacity: .7;
        }
    </style>
</head>
<body>

<div class="box">

    <div class="title">LUXE NAIL STUDIO</div>
    <div class="sub">Booking Invoice / Payment Record</div>

    <div class="row">
        <span class="label">Queue Number:</span> {{ $reservation->queue_number }}
    </div>

    <div class="row">
        <span class="label">Name:</span> {{ $reservation->name }}
    </div>

    <div class="row">
        <span class="label">Treatment:</span> {{ ucfirst(str_replace('_',' ',$reservation->treatment_type)) }}
    </div>

    <div class="row">
        <span class="label">Date:</span> {{ $reservation->reservation_date }}
    </div>

    <div class="row">
        <span class="label">Time:</span> {{ $reservation->reservation_time }}
    </div>

    <div class="row">
        <span class="label">Booking Fee:</span>
        Rp {{ number_format($reservation->booking_fee ?? 25000,0,',','.') }}
    </div>

    <div class="row">
        <span class="label">Service Price:</span>
        Rp {{ number_format($reservation->total_price,0,',','.') }}
    </div>

    <div class="row">
        <span class="label">Total:</span>
        Rp {{ number_format(($reservation->total_price + ($reservation->booking_fee ?? 25000)),0,',','.') }}
    </div>

    <br>

    <div class="footer">
        Show this invoice at the studio. Admin will validate your payment.
    </div>

</div>

</body>
</html>
