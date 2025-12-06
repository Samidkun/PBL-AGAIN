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
                            <li>If you do not attend → booking fee is forfeited.</li>
                            <li>Must download the booking receipt to get a queue number.</li>
                            <li>Payment method: Transfer.</li>
                            <li>On-site booking is available but slots are limited.</li>
                        </ul>
                    </div>

                    <form id="bookingForm" action="{{ route('reservations.store') }}" method="POST">
                        @csrf

                        {{-- CUSTOMER --}}
                        <div class="card p-4 mb-4">
                            <h5>Customer Information</h5>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label>Full Name</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label>Phone Number</label>
                                    <input type="text" name="phone" class="form-control" required>
                                </div>
                            </div>
                            <label>Address</label>
                            <textarea name="address" rows="2" class="form-control" required></textarea>
                        </div>

                        {{-- TREATMENT --}}
                        <div class="card p-4 mb-4">
                            <h5>Treatment</h5>
                            <select name="treatment_type" class="form-select" required>
                                <option value="">Select Treatment</option>
                                <option value="nail_extension">Nail Extension</option>
                                <option value="nail_art">Nail Art</option>
                            </select>
                        </div>

                        {{-- DATE --}}
                        <div class="card p-4 mb-4">
                            <h5>Pick a Date</h5>
                            <input type="date" id="reservationDate" name="reservation_date"
                                min="{{ date('Y-m-d') }}" class="form-control" required>
                        </div>

                        {{-- SLOTS --}}
                        <div class="card p-4 mb-4">
                            <h5>Available Time Slots</h5>

                            <div id="timeSlotContainer" class="row"></div>

                            <input type="hidden" id="selectedTimeInput" name="reservation_time" required>
                        </div>

                        {{-- CAPTCHA --}}
                        <div class="card p-4 mb-4">
                            <h5>Security Check</h5>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Enter the code below</label>
                                <div class="d-flex align-items-center mb-2">
                                    <img src="{{ route('captcha.image') }}" alt="captcha" id="captcha-image">
                                    <button type="button" class="btn btn-sm btn-secondary ms-2" id="reload-captcha">
                                        Reload
                                    </button>
                                </div>
                                <input type="text" name="captcha" class="form-control" required placeholder="Enter characters shown">
                            </div>
                        </div>

                        <button class="btn btn-primary w-100 py-2 fs-5">Continue</button>
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

// CAPTCHA RELOAD
document.getElementById('reload-captcha').addEventListener('click', function() {
    document.getElementById('captcha-image').src = '{{ route("captcha.image") }}' + '?' + Math.random();
});

// LOAD SLOTS
const dateInput = document.getElementById("reservationDate");
const treatmentInput = document.querySelector("select[name='treatment_type']");

dateInput.addEventListener("change", loadSlots);
treatmentInput.addEventListener("change", loadSlots);

function loadSlots() {
    const date = dateInput.value;
    const treatment = treatmentInput.value;

    if(!date || !treatment) return;

    fetch(`/api/v1/calendar/slots?date=${date}&treatment_type=${treatment}`)
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
            document.getElementById('selectedTimeInput').value = btn.dataset.time;
        };
    });
}

// SUBMISSION
bookingForm.addEventListener("submit", async(e)=>{
    e.preventDefault();

    // Captcha validation is now server-side

    Swal.fire({
        title:"Booking Confirmation",
        html: document.getElementById('bookingRules').innerHTML,
        icon:"info",
        showCancelButton:true,
        confirmButtonText:"Continue",
        cancelButtonText:"Cancel"
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
