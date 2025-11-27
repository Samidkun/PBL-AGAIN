@extends('layouts.app')

@section('title', 'Create Reservation')

@section('content')
<section class="contact-section" id="contact" style="padding-top:140px;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="reservation-form">
                    <h3 class="mb-4">Book Your Appointment</h3>

                    {{-- rules disembunyiin tetep sama --}}
                    <div id="bookingRules" class="d-none">
                        <h4 class="mb-3">Booking Rules</h4>
                        <ul>
                            <li>Jika tidak hadir → uang booking hangus.</li>
                            <li>Wajib download struk booking untuk mendapatkan nomor antrian.</li>
                            <li>Metode pembayaran: Transfer.</li>
                            <li>Booking on-site tersedia tetapi slot terbatas.</li>
                        </ul>
                    </div>

                    <form id="bookingForm" action="{{ route('reservations.store') }}" method="POST">
                        @csrf

                        {{-- CUSTOMER --}}
                        <div class="form-section mb-4">
                            <h5 class="form-section-title">Customer Information</h5>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Address</label>
                                <textarea name="address" rows="3" class="form-control" required></textarea>
                            </div>
                        </div>

                        {{-- TREATMENT --}}
                        <div class="form-section mb-4">
                            <h5 class="form-section-title">Treatment Type</h5>
                            <select name="treatment_type" class="form-select" required>
                                <option value="">Select Treatment</option>
                                <option value="nail_extension">Nail Extension</option>
                                <option value="nail_art">Nail Art</option>
                            </select>
                        </div>

                        {{-- DATE --}}
                        <div class="form-section mb-4">
                            <h5 class="form-section-title">Pick a Date</h5>
                            <input
                                type="date"
                                id="reservationDate"
                                name="reservation_date"
                                min="{{ date('Y-m-d') }}"
                                class="form-control"
                                required
                            >
                        </div>

                        {{-- SLOTS --}}
                        <div class="form-section mb-4">
                            <h5 class="form-section-title">Available Time Slots</h5>

                            <div id="timeSlotContainer" class="row g-2"></div>

                            {{-- hidden input tetap --}}
                            <input type="hidden" id="selectedTimeInput" name="reservation_time" required>
                        </div>

                        {{-- CAPTCHA --}}
                        <div class="form-section mb-4">
                            <h5 class="form-section-title">Security Check</h5>

                            <div class="captcha-box mb-3">
                                <span id="captcha_text" class="captcha-text"></span>
                                <button type="button" onclick="generateCaptcha()" class="btn btn-captcha">
                                    <i class="fas fa-rotate-right me-1"></i> Refresh
                                </button>
                            </div>

                            <input id="captcha_input" type="text" class="form-control" placeholder="Type captcha here" required>
                        </div>

                        <button class="btn btn-submit mt-2">Continue</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection


@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
let captchaText = "";

function generateCaptcha() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    captchaText = [...Array(5)].map(() => chars[Math.floor(Math.random()*chars.length)]).join("");
    document.getElementById("captcha_text").innerText = captchaText;
}
generateCaptcha();

// LOAD SLOTS
document.getElementById("reservationDate").addEventListener("change", loadSlots);

function loadSlots() {
    const date = reservationDate.value;
    if(!date) return;

    fetch(`/api/v1/calendar/slots?date=${date}`)
        .then(r => r.json())
        .then(res => {
            const c = document.getElementById("timeSlotContainer");
            c.innerHTML = "";
            res.data.forEach(s => {
                c.innerHTML += `
                    <div class="col-6 col-md-3">
                        <button class="btn w-100 slotBtn ${s.available?'btn-slot':'btn-slot-disabled'}"
                                ${s.available?'':'disabled'}
                                data-time="${s.time}">
                            ${s.time}
                        </button>
                    </div>`;
            });
            initSlotSelectors();
        });
}

function initSlotSelectors() {
    document.querySelectorAll(".slotBtn").forEach(btn => {
        btn.onclick = () => {
            document.querySelectorAll(".slotBtn").forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            selectedTimeInput.value = btn.dataset.time;
        };
    });
}

// SUBMISSION
bookingForm.addEventListener("submit", async(e)=>{
    e.preventDefault();

    if(captcha_input.value.trim() !== captchaText){
        Swal.fire("Captcha Salah","Coba lagi.", "error");
        generateCaptcha();
        return;
    }

    Swal.fire({
        title:"Booking Confirmation",
        html: bookingRules.innerHTML,
        icon:"info",
        showCancelButton:true,
        confirmButtonText:"Lanjut",
        cancelButtonText:"Batal"
    }).then(async(r)=>{
        if(!r.isConfirmed) return;

        const res = await fetch(bookingForm.action,{
            method:"POST",
            body:new FormData(bookingForm)
        });
        const data = await res.json();

        if(!data.success){
            Swal.fire("Error", data.message ?? "Booking gagal", "error");
            return;
        }

        window.location.href = data.redirect_url;
    });
});
</script>
@endsection
