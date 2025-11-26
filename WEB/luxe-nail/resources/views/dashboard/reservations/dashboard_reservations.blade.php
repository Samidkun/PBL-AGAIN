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
                <h3 id="pendingCount">0</h3>
                <span>Pending</span>
            </div>
            <div class="stat-card">
                <h3 id="confirmedCount">0</h3>
                <span>Confirmed</span>
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

<script>
document.addEventListener('DOMContentLoaded', () => {

    let selectedDate = null;
    let currentReservationId = null;
    let currentActionType = null;

    const reservationTableBody = document.getElementById('reservationTableBody');

    const confirmationModal = new bootstrap.Modal(document.getElementById('confirmationModal'));
    const successModal = new bootstrap.Modal(document.getElementById('successModal'));
    const errorModal = new bootstrap.Modal(document.getElementById('errorModal'));

    document.getElementById('confirmActionBtn').addEventListener('click', executeConfirmedAction);

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
                    updateReservationTable(data.reservations);
                    updateStats(data.reservations);
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
                actions += `
                    <button class="btn-action btn-success" onclick="approvePayment(${r.id})">Approve Payment</button>
                    <button class="btn-action btn-danger" onclick="setStatus(${r.id}, 'cancelled', 'Reject payment & cancel?')">Reject</button>
                `;
            }

            // confirmed
            if (r.status === "confirmed") {
                actions += `<button class="btn-action btn-primary" onclick="setStatus(${r.id}, 'completed', 'Mark as completed?')">Completed</button>`;
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
                    <td>${actions}</td>
                </tr>
            `;
        }).join('');
    }


    // =======================================================================================
    // STATUS COUNTS
    // =======================================================================================

    function updateStats(data) {
        document.getElementById('pendingCount').textContent =
            data.filter(r => r.status === "pending").length;

        document.getElementById('confirmedCount').textContent =
            data.filter(r => r.status === "confirmed").length;

        document.getElementById('cancelledCount').textContent =
            data.filter(r => r.status === "cancelled").length;

        document.getElementById('completedCount').textContent =
            data.filter(r => r.status === "completed").length;
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
</script>

@endsection
