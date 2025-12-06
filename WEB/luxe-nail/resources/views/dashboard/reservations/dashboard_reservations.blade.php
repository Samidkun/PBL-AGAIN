@extends('layouts.dashboard')

@section('title', 'Reservation Dashboard')

@section('content')
<link rel="stylesheet" href="{{ asset('css/reservations.css') }}">

<style>
    .status-badge {
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        display: inline-block;
    }

    .bg-warning { background: #ffdd57; color: #000; }
    .bg-info { background: #5bc0de; color: #fff; }
    .bg-success { background: #28a745; color: #fff; }
    .bg-danger { background: #dc3545; color: #fff; }
    .bg-primary { background: #007bff; color: #fff; }

    .btn-action {
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 12px;
        margin-right: 5px;
    }
    .btn-confirm { background: #28a745; color: white; }
    .btn-cancel { background: #dc3545; color: white; }
    .btn-edit { background: #ffc107; color: black; }
    .btn-success { background: #198754; color: white; }
    .btn-danger { background: #dc3545; color: white; }
    .btn-primary { background: #0d6efd; color: white; }
</style>

<div class="dashboard-container">

    <div class="dashboard-header">
        <div class="header-content">
            <h1 class="dashboard-title"><i class="fas fa-calendar-check me-3"></i>Reservation Dashboard</h1>
            <p class="dashboard-subtitle">Manage customer bookings and payments</p>
        </div>

        <div class="calendar-filter">
            <button class="btn btn-calendar" id="datePickerBtn">
                <i class="fas fa-calendar-alt me-2"></i>
                <span id="selectedDate">Select Date</span>
                <i class="fas fa-chevron-down ms-2"></i>
            </button>

            <div class="calendar-popup" id="calendarPopup">
                <div class="calendar-header">
                    <button class="btn btn-nav" id="prevMonth"><i class="fas fa-chevron-left"></i></button>
                    <h4 id="calendarMonth"></h4>
                    <button class="btn btn-nav" id="nextMonth"><i class="fas fa-chevron-right"></i></button>
                </div>
                <div class="calendar-grid" id="calendarGrid"></div>
            </div>
        </div>
    </div>

    <div class="reservation-list-section">
        <div class="reservation-stats">
            <div class="stat-card">
                <h3 id="waitingValidationCount">0</h3>
                <span>Waiting Validation</span>
            </div>
            <div class="stat-card">
                <h3 id="confirmedCount">0</h3>
                <span>Confirmed</span>
            </div>
            <div class="stat-card">
                <h3 id="waitingPaymentCount">0</h3>
                <span>Waiting Payment</span>
            </div>
            <div class="stat-card">
                <h3 id="cancelledCount">0</h3>
                <span>Cancelled</span>
            </div>
            <div class="stat-card">
                <h3 id="completedCount">0</h3>
                <span>Completed</span>
            </div>
        </div>

        <div class="reservation-table-container">
            <table class="reservation-table">
                <thead>
                    <tr>
                        <th>Queue No</th>
                        <th>Name</th>
                        <th>Phone</th>
                        <th>Treatment</th>
                        <th>Date & Time</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="reservationTableBody"></tbody>
            </table>

            <div class="no-reservations" id="noReservations">
                <i class="fas fa-calendar-times fa-3x"></i>
                <p>No reservations found</p>
            </div>
        </div>
    </div>
</div>


{{-- ======================================================================== --}}
{{-- =============================== MODALS ================================= --}}
{{-- ======================================================================== --}}

<div class="modal fade" id="confirmationModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content p-4 text-center">
            <h4 id="confirmationMessage"></h4>
            <div class="mt-4">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-primary" id="confirmActionBtn">Confirm</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="successModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content p-4 text-center">
            <h4 id="successMessage"></h4>
            <button class="btn btn-success mt-3" data-bs-dismiss="modal">OK</button>
        </div>
    </div>
</div>

<div class="modal fade" id="errorModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content p-4 text-center">
            <h4 id="errorMessage"></h4>
            <button class="btn btn-danger mt-3" data-bs-dismiss="modal">Close</button>
        </div>
    </div>
</div>

<div class="modal fade" id="proofModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Payment Proof Verification</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body bg-light p-4">
                <div class="row">
                    <div class="col-md-7 text-center border-end">
                        <h6 class="fw-bold mb-3 text-muted">Proof of Payment</h6>
                        <img id="proofImage" src="" class="img-fluid rounded shadow-sm" style="max-height: 400px; border: 1px solid #ddd;">
                        <p id="noProofText" class="text-danger d-none mt-3">No proof uploaded</p>
                    </div>
                    <div class="col-md-5">
                        <h6 class="fw-bold mb-3 text-muted">Reservation Details</h6>
                        
                        <div class="mb-3">
                            <small class="text-uppercase text-muted fw-bold" style="font-size: 0.7rem;">Invoice Number</small>
                            <div class="fs-5 fw-bold text-dark" id="modalQueue"></div>
                        </div>

                        <div class="mb-3">
                            <small class="text-uppercase text-muted fw-bold" style="font-size: 0.7rem;">Customer Name</small>
                            <div class="fs-6 text-dark" id="modalName"></div>
                        </div>

                        <div class="mb-3">
                            <small class="text-uppercase text-muted fw-bold" style="font-size: 0.7rem;">Total Amount</small>
                            <div class="fs-4 fw-bold text-primary" id="modalAmount"></div>
                        </div>

                        <div class="mb-4">
                            <small class="text-uppercase text-muted fw-bold" style="font-size: 0.7rem;">Date & Time</small>
                            <div class="fs-6 text-dark" id="modalDate"></div>
                        </div>

                        <div class="alert alert-info small">
                            <i class="fas fa-info-circle me-1"></i>
                            Please verify the transfer amount matches the proof.
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer justify-content-center">
                <button class="btn btn-danger px-4" id="rejectProofBtn">
                    <i class="fas fa-times me-2"></i>Reject & Cancel
                </button>
                <button class="btn btn-success px-4" id="approveProofBtn">
                    <i class="fas fa-check me-2"></i>Approve Payment
                </button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {

    let selectedDate = null;
    let currentReservationId = null;
    let currentActionType = null;

    const reservationTableBody = document.getElementById('reservationTableBody');

    const confirmationModal = new bootstrap.Modal(document.getElementById('confirmationModal'));
    const successModal = new bootstrap.Modal(document.getElementById('successModal'));
    const errorModal = new bootstrap.Modal(document.getElementById('errorModal'));
    const proofModal = new bootstrap.Modal(document.getElementById('proofModal'));

    document.getElementById('confirmActionBtn').addEventListener('click', executeConfirmedAction);

    // =======================================================================================
    // PROOF MODAL LOGIC
    // =======================================================================================
    window.viewProof = function(id, proofPath, queue, name, amount, date) {
        currentReservationId = id;
        const img = document.getElementById('proofImage');
        const noProofText = document.getElementById('noProofText');

        // Populate Details
        document.getElementById('modalQueue').textContent = queue;
        document.getElementById('modalName').textContent = name;
        document.getElementById('modalAmount').textContent = 'Rp ' + new Intl.NumberFormat('id-ID').format(amount);
        document.getElementById('modalDate').textContent = date;

        if (proofPath && proofPath !== 'null') {
            // Use the served-image route with storage prefix
            img.src = `/served-image/storage/${proofPath}`; 
            img.classList.remove('d-none');
            noProofText.classList.add('d-none');
        } else {
            img.classList.add('d-none');
            noProofText.classList.remove('d-none');
        }
        proofModal.show();
    };

    document.getElementById('approveProofBtn').addEventListener('click', () => {
        proofModal.hide();
        approvePayment(currentReservationId);
    });

    document.getElementById('rejectProofBtn').addEventListener('click', () => {
        proofModal.hide();
        setStatus(currentReservationId, 'cancelled', 'Reject payment & cancel reservation?');
    });

    // =======================================================================================
    // CALENDAR INIT
    // =======================================================================================

    function getTodayDate() {
        const today = new Date();
        const offset = today.getTimezoneOffset();
        today.setMinutes(today.getMinutes() - offset);
        return today.toISOString().split('T')[0];
    }

    function initialize() {
        selectedDate = getTodayDate();
        document.getElementById('selectedDate').textContent = selectedDate;
        loadReservationsForDate(selectedDate);
    }

    initialize();

    const datePickerBtn  = document.getElementById("datePickerBtn");
const calendarPopup  = document.getElementById("calendarPopup");
const calendarGrid   = document.getElementById("calendarGrid");
const calendarMonth  = document.getElementById("calendarMonth");
const prevMonthBtn   = document.getElementById("prevMonth");
const nextMonthBtn   = document.getElementById("nextMonth");

let currentMonth = new Date();
currentMonth.setDate(1);

datePickerBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    calendarPopup.classList.toggle("show");
    renderCalendar();
});

document.addEventListener("click", (e) => {
    if (!calendarPopup.contains(e.target) && !datePickerBtn.contains(e.target)) {
        calendarPopup.classList.remove("show");
    }
});

prevMonthBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    currentMonth.setMonth(currentMonth.getMonth() - 1);
    renderCalendar();
});
nextMonthBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    currentMonth.setMonth(currentMonth.getMonth() + 1);
    renderCalendar();
});

function renderCalendar() {
    const year  = currentMonth.getFullYear();
    const month = currentMonth.getMonth();

    const monthName = currentMonth.toLocaleString("default", { month: "long" });
    calendarMonth.textContent = `${monthName} ${year}`;

    calendarGrid.innerHTML = "";

    const dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    dayNames.forEach(d => {
        const el = document.createElement("div");
        el.className = "calendar-day other-month";
        el.style.fontWeight = "700";
        el.textContent = d;
        calendarGrid.appendChild(el);
    });

    const firstDay = new Date(year, month, 1);
    const startDayIndex = firstDay.getDay();

    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();

    for (let i = 0; i < startDayIndex; i++) {
        const el = document.createElement("div");
        el.className = "calendar-day other-month";
        el.textContent = "";
        calendarGrid.appendChild(el);
    }

    for (let day = 1; day <= daysInMonth; day++) {
        const el = document.createElement("div");
        el.className = "calendar-day";
        el.textContent = day;

        const dateStr = formatDate(year, month + 1, day);

        if (dateStr === selectedDate) {
            el.classList.add("selected");
        }

        el.addEventListener("click", (e) => {
            e.stopPropagation();
            selectedDate = dateStr;
            document.getElementById("selectedDate").textContent = selectedDate;
            calendarPopup.classList.remove("show");
            loadReservationsForDate(selectedDate);
            renderCalendar();
        });

        calendarGrid.appendChild(el);
    }
}

function formatDate(y, m, d) {
    const mm = String(m).padStart(2, "0");
    const dd = String(d).padStart(2, "0");
    return `${y}-${mm}-${dd}`;
}


    // =======================================================================================
    // LOAD RESERVATIONS
    // =======================================================================================

    function loadReservationsForDate(date) {
        reservationTableBody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center">Loading...</td>
            </tr>
        `;

        fetch(`/dashboard/reservations/date/${date}`)
    .then(r => r.json())
    .then(data => {
        if (data.success) {

            const priority = {
                waiting_validation: 1,
                confirmed: 2,
                completed: 4,
                cancelled: 5
            };

            const sortedReservations = data.reservations.sort((a, b) => {
                const pa = priority[a.status] ?? 999;
                const pb = priority[b.status] ?? 999;

                if (pa !== pb) return pa - pb;

                const ta = `${a.reservation_date} ${a.reservation_time}`;
                const tb = `${b.reservation_date} ${b.reservation_time}`;
                return ta.localeCompare(tb);
            });

            updateReservationTable(sortedReservations);
            updateStats(sortedReservations);
        }
    });

    }


    // =======================================================================================
    // TABLE RENDER
    // =======================================================================================

    function updateReservationTable(reservations) {

        if (reservations.length === 0) {
            reservationTableBody.innerHTML = "";
            document.getElementById('noReservations').style.display = "block";
            return;
        }

        document.getElementById('noReservations').style.display = "none";

        const badge = (status) => {
            const color = {
                pending: "warning",
                waiting_validation: "info",
                waiting_payment: "warning", // New Status
                confirmed: "success",
                cancelled: "danger",
                completed: "primary"
            }[status];

            return `<span class="status-badge bg-${color}">${status.toUpperCase()}</span>`;
        };

        reservationTableBody.innerHTML = reservations.map(r => {

            let actions = "";

            // pending
            if (r.status === "pending") {
                actions += `
                    <button class="btn-action btn-confirm" onclick="setStatus(${r.id}, 'waiting_validation', 'Mark as waiting for validation?')">Confirm</button>
                    <button class="btn-action btn-cancel" onclick="setStatus(${r.id}, 'cancelled', 'Cancel reservation?')">Cancel</button>
                `;
            }

            // waiting_validation
            if (r.status === "waiting_validation") {
                let amount = r.total_price ? r.total_price : 0;
                actions += `
                    <button class="btn-action btn-info text-white" 
                        onclick="viewProof(${r.id}, '${r.payment_proof}', '${r.queue_number}', '${r.name}', ${amount}, '${r.reservation_date} ${r.reservation_time}')">
                        <i class="fas fa-eye me-1"></i> Verify Payment
                    </button>
                `;
            }

            // waiting_payment (NEW - Ready for Cashier)
            if (r.status === "waiting_payment") {
                actions += `
                    <a href="/dashboard/cashier/${r.id}" class="btn-action btn-success text-white text-decoration-none">
                        <i class="fas fa-cash-register me-1"></i> Pay / Finish
                    </a>
                `;
            }

            // edit allowed except completed/cancel
            if (r.status !== "cancelled" && r.status !== "completed") {
                actions += `<button class="btn-action btn-edit" onclick="editReservation(${r.id})">Edit</button>`;
            }

            return `
                <tr>
                    <td><strong>${r.queue_number}</strong></td>
                    <td>${r.name}</td>
                    <td>${r.phone}</td>
                    <td>${r.treatment_type}</td>
                    <td>${r.reservation_date} ${r.reservation_time}</td>
                    <td>${badge(r.status)}</td>
                    <td><div class="actions-container">${actions}</div></td>
                </tr>
            `;
        }).join('');
    }


    // =======================================================================================
    // STATUS COUNTS
    // =======================================================================================

    function updateStats(data) {
        document.getElementById('waitingValidationCount').textContent =
        data.filter(r => r.status === "waiting_validation").length;

        document.getElementById('confirmedCount').textContent =
            data.filter(r => r.status === "confirmed").length;

        document.getElementById('waitingPaymentCount').textContent =
            data.filter(r => r.status === "waiting_payment").length;

        document.getElementById('cancelledCount').textContent =
            data.filter(r => r.status === "cancelled").length;

    }


    // =======================================================================================
    // STATUS CHANGE
    // =======================================================================================

    window.setStatus = function(id, status, message) {
        currentReservationId = id;
        currentActionType = status;
        document.getElementById('confirmationMessage').textContent = message;
        confirmationModal.show();
    };

    function executeConfirmedAction() {
        confirmationModal.hide();

        fetch(`/dashboard/reservations/${currentReservationId}/status`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-TOKEN": document.querySelector("meta[name=csrf-token]").content
            },
            body: JSON.stringify({ status: currentActionType })
        })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                document.getElementById('successMessage').textContent = "Status updated!";
                successModal.show();
                loadReservationsForDate(selectedDate);
            }
        })
        .catch(err => {
            document.getElementById('errorMessage').textContent = err.message;
            errorModal.show();
        });
    }


    // =======================================================================================
    // APPROVE PAYMENT
    // =======================================================================================

    window.approvePayment = function(id) {
        fetch(`/admin/payment/${id}/confirm`, {
            method: "POST",
            headers: {
                "X-CSRF-TOKEN": document.querySelector("meta[name=csrf-token]").content
            }
        })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                document.getElementById('successMessage').textContent = "Payment approved!";
                successModal.show();
                loadReservationsForDate(selectedDate);
            }
        })
        .catch(err => {
            document.getElementById('errorMessage').textContent = err.message;
            errorModal.show();
        });
    };

});

// Auto-refresh every 10 seconds
setInterval(function() {
    location.reload();
}, 10000);
</script>

@endsection
