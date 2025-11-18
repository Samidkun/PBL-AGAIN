@extends('layouts.dashboard')

@section('title', 'Reservation Dashboard')

@section('content')
<link rel="stylesheet" href="{{ asset('css/reservations.css') }}">

<div class="dashboard-container">
    <!-- Header Section -->
    <div class="dashboard-header">
        <div class="header-content">
            <h1 class="dashboard-title">
                <i class="fas fa-calendar-check me-3"></i>Reservation Dashboard
            </h1>
            <p class="dashboard-subtitle">Manage customer bookings and reservations</p>
        </div>
        
        <!-- Calendar Filter -->
        <div class="calendar-filter">
            <div class="date-picker-container">
                <button class="btn btn-calendar" id="datePickerBtn">
                    <i class="fas fa-calendar-alt me-2"></i>
                    <span id="selectedDate">Select Date</span>
                    <i class="fas fa-chevron-down ms-2"></i>
                </button>
                <div class="calendar-popup" id="calendarPopup">
                    <div class="calendar-header">
                        <button class="btn btn-nav" id="prevMonth">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <h4 id="calendarMonth"></h4>
                        <button class="btn btn-nav" id="nextMonth">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    </div>
                    <div class="calendar-grid" id="calendarGrid">
                        <!-- Calendar will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Reservation List Section -->
    <div class="reservation-list-section">
        <div class="reservation-stats">
            <div class="stat-card">
                <div class="stat-icon pending">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-info">
                    <h3 id="pendingCount">0</h3>
                    <span>Pending</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon confirmed">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-info">
                    <h3 id="confirmedCount">0</h3>
                    <span>Confirmed</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon cancelled">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-info">
                    <h3 id="cancelledCount">0</h3>
                    <span>Cancelled</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon completed">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="stat-info">
                    <h3 id="completedCount">0</h3>
                    <span>Completed</span>
                </div>
            </div>
        </div>

        <!-- Reservation Table -->
        <div class="reservation-table-container">
            <div class="table-responsive">
                <table class="reservation-table">
                    <thead>
                        <tr>
                            <th>Queue No</th>
                            <th>Customer Name</th>
                            <th>Phone</th>
                            <th>Treatment</th>
                            <th>Date & Time</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="reservationTableBody">
                        <!-- Reservations will be loaded here -->
                    </tbody>
                </table>
            </div>
            <div class="no-reservations" id="noReservations">
                <i class="fas fa-calendar-times fa-3x mb-3"></i>
                <h4>No reservations found</h4>
                <p>Select a date to view reservations</p>
            </div>
        </div>
    </div>
</div>

<!-- Edit Reservation Modal -->
<div class="modal fade" id="editReservationModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Edit Reservation</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="editReservationForm">
                    <input type="hidden" id="editReservationId">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="editName" class="form-label">Name</label>
                                <input type="text" class="form-control" id="editName" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="editPhone" class="form-label">Phone</label>
                                <input type="text" class="form-control" id="editPhone" required>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="editAddress" class="form-label">Address</label>
                        <textarea class="form-control" id="editAddress" rows="3" required></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="editTreatmentType" class="form-label">Treatment Type</label>
                                <select class="form-select" id="editTreatmentType" required>
                                    <option value="nail_extension">Nail Extension</option>
                                    <option value="nail_art">Nail Art</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="editReservationTime" class="form-label">Time</label>
                                <input type="time" class="form-control" id="editReservationTime" required>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="updateReservationBtn">Update Reservation</button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    let selectedDate = null;
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();
    
    const datePickerBtn = document.getElementById('datePickerBtn');
    const calendarPopup = document.getElementById('calendarPopup');
    const selectedDateSpan = document.getElementById('selectedDate');
    const calendarMonth = document.getElementById('calendarMonth');
    const calendarGrid = document.getElementById('calendarGrid');
    const prevMonthBtn = document.getElementById('prevMonth');
    const nextMonthBtn = document.getElementById('nextMonth');
    const reservationTableBody = document.getElementById('reservationTableBody');
    const noReservations = document.getElementById('noReservations');
    
    // Modal elements
    const editReservationModal = new bootstrap.Modal(document.getElementById('editReservationModal'));
    const updateReservationBtn = document.getElementById('updateReservationBtn');

    // Get today's date dengan format yang benar
    function getTodayDate() {
        const today = new Date();
        // Adjust untuk timezone Indonesia (UTC+7)
        const offset = today.getTimezoneOffset();
        today.setMinutes(today.getMinutes() - offset);
        return today.toISOString().split('T')[0]; // Format: YYYY-MM-DD
    }

    function initializeDate() {
        const todayString = getTodayDate();
        
        console.log('Today date:', todayString); // Debug
        
        // Set selected date ke hari ini
        selectedDate = todayString;
        selectedDateSpan.textContent = formatDate(new Date(todayString));
        
        // Load reservations untuk hari ini
        loadReservationsForDate(todayString);
        
        // Update calendar
        updateCalendar();
    }

    // Initialize
    initializeDate();

    // Event Listeners
    datePickerBtn.addEventListener('click', toggleCalendar);
    prevMonthBtn.addEventListener('click', goToPrevMonth);
    nextMonthBtn.addEventListener('click', goToNextMonth);
    updateReservationBtn.addEventListener('click', updateReservation);

    // Close calendar when clicking outside
    document.addEventListener('click', function(event) {
        if (!datePickerBtn.contains(event.target) && !calendarPopup.contains(event.target)) {
            calendarPopup.classList.remove('show');
        }
    });

    function toggleCalendar() {
        calendarPopup.classList.toggle('show');
    }

    function goToPrevMonth() {
        currentMonth--;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
        updateCalendar();
    }

    function goToNextMonth() {
        currentMonth++;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        updateCalendar();
    }

    function updateCalendar() {
        const firstDay = new Date(currentYear, currentMonth, 1);
        const lastDay = new Date(currentYear, currentMonth + 1, 0);
        const startingDay = firstDay.getDay();
        const totalDays = lastDay.getDate();

        calendarMonth.textContent = new Date(currentYear, currentMonth).toLocaleString('default', { 
            month: 'long', 
            year: 'numeric' 
        });

        calendarGrid.innerHTML = '';

        // Add day headers
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        days.forEach(day => {
            const dayHeader = document.createElement('div');
            dayHeader.className = 'calendar-day';
            dayHeader.style.fontWeight = '600';
            dayHeader.textContent = day;
            calendarGrid.appendChild(dayHeader);
        });

        // Add empty cells for days before month starts
        for (let i = 0; i < startingDay; i++) {
            const emptyDay = document.createElement('div');
            emptyDay.className = 'calendar-day other-month';
            calendarGrid.appendChild(emptyDay);
        }

        // Add days of the month
        for (let day = 1; day <= totalDays; day++) {
            const dayElement = document.createElement('div');
            const dateString = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            
            dayElement.className = 'calendar-day';
            dayElement.textContent = day;
            
            // Highlight hari ini
            const todayString = getTodayDate();
            if (dateString === todayString) {
                dayElement.classList.add('selected');
            }
            
            // Check jika ini selected date
            if (selectedDate === dateString) {
                dayElement.classList.add('selected');
            }
            
            dayElement.addEventListener('click', () => selectDate(dateString, dayElement));
            calendarGrid.appendChild(dayElement);
        }
    }

    function selectDate(dateString, dayElement) {
        selectedDate = dateString;
        selectedDateSpan.textContent = formatDate(new Date(dateString));
        calendarPopup.classList.remove('show');
        
        // Update selected day in calendar
        document.querySelectorAll('.calendar-day.selected').forEach(el => {
            el.classList.remove('selected');
        });
        dayElement.classList.add('selected');
        
        // Load reservations for selected date
        loadReservationsForDate(dateString);
    }

    function formatDate(date) {
        return date.toLocaleDateString('en-US', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
        });
    }

    function loadReservationsForDate(date) {
        console.log('Loading reservations for date:', date); // Debug
        
        // Show loading state
        reservationTableBody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2 mb-0">Loading reservations...</p>
                </td>
            </tr>
        `;
        
        fetch(`/dashboard/reservations/date/${date}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                console.log('API Response:', data); // Debug
                updateReservationTable(data.reservations);
                updateStats(data.reservations);
            })
            .catch(error => {
                console.error('Error loading reservations:', error);
                reservationTableBody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center py-4 text-danger">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            Error loading reservations
                        </td>
                    </tr>
                `;
            });
    }

    function updateReservationTable(reservations) {
    if (reservations.length === 0) {
        reservationTableBody.innerHTML = '';
        noReservations.classList.add('show');
        return;
    }

    noReservations.classList.remove('show');
    
    reservationTableBody.innerHTML = reservations.map(reservation => `
        <tr>
            <td>
                <strong>${reservation.queue_number}</strong>
            </td>
            <td>${reservation.name}</td>
            <td>${reservation.phone}</td>
            <td>${reservation.treatment_type === 'nail_extension' ? 'Nail Extension' : 'Nail Art'}</td>
            <td>
                ${new Date(reservation.reservation_date).toLocaleDateString()} 
                at ${reservation.reservation_time}
            </td>
            <td>
                <span class="status-badge status-${reservation.status}">
                    ${reservation.status.toUpperCase()}
                </span>
            </td>
            <td>
                <div class="actions-container">
                    ${reservation.status === 'pending' ? `
                        <button class="btn-action btn-confirm" onclick="confirmReservation(${reservation.id})" title="Confirm">
                            <i class="fas fa-check me-1"></i>Confirm
                        </button>
                        <button class="btn-action btn-cancel" onclick="cancelReservation(${reservation.id})" title="Cancel">
                            <i class="fas fa-times me-1"></i>Cancel
                        </button>
                    ` : ''}
                    ${reservation.status !== 'cancelled' && reservation.status !== 'completed' ? `
                        <button class="btn-action btn-edit" onclick="editReservation(${reservation.id})" title="Edit">
                            <i class="fas fa-edit me-1"></i>Edit
                        </button>
                    ` : ''}
                </div>
            </td>
        </tr>
    `).join('');
}

    function updateStats(reservations) {
        const counts = {
            pending: reservations.filter(r => r.status === 'pending').length,
            confirmed: reservations.filter(r => r.status === 'confirmed').length,
            cancelled: reservations.filter(r => r.status === 'cancelled').length,
            completed: reservations.filter(r => r.status === 'completed').length
        };

        document.getElementById('pendingCount').textContent = counts.pending;
        document.getElementById('confirmedCount').textContent = counts.confirmed;
        document.getElementById('cancelledCount').textContent = counts.cancelled;
        document.getElementById('completedCount').textContent = counts.completed;
    }

    window.confirmReservation = function(reservationId) {
        if (confirm('Are you sure you want to confirm this reservation?')) {
            updateReservationStatus(reservationId, 'confirmed', 'Reservation confirmed successfully!');
        }
    }

    window.cancelReservation = function(reservationId) {
        if (confirm('Are you sure you want to cancel this reservation?')) {
            updateReservationStatus(reservationId, 'cancelled', 'Reservation cancelled successfully!');
        }
    }

    function updateReservationStatus(reservationId, status, successMessage) {
        fetch(`/dashboard/reservations/${reservationId}/status`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({ status: status })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showAlert(successMessage, 'success');
                loadReservationsForDate(selectedDate);
            } else {
                showAlert('Error updating reservation', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showAlert('Error updating reservation', 'error');
        });
    }

    window.editReservation = function(reservationId) {
        fetch(`/dashboard/reservations/${reservationId}`)
            .then(response => response.json())
            .then(reservation => {
                document.getElementById('editReservationId').value = reservation.id;
                document.getElementById('editName').value = reservation.name;
                document.getElementById('editPhone').value = reservation.phone;
                document.getElementById('editAddress').value = reservation.address;
                document.getElementById('editTreatmentType').value = reservation.treatment_type;
                document.getElementById('editReservationTime').value = reservation.reservation_time;
                
                editReservationModal.show();
            })
            .catch(error => {
                console.error('Error loading reservation:', error);
                showAlert('Error loading reservation data', 'error');
            });
    }

    function updateReservation() {
        const reservationId = document.getElementById('editReservationId').value;
        const formData = {
            name: document.getElementById('editName').value,
            phone: document.getElementById('editPhone').value,
            address: document.getElementById('editAddress').value,
            treatment_type: document.getElementById('editTreatmentType').value,
            reservation_time: document.getElementById('editReservationTime').value
        };

        fetch(`/dashboard/reservations/${reservationId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify(formData)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                editReservationModal.hide();
                showAlert('Reservation updated successfully!', 'success');
                loadReservationsForDate(selectedDate);
            } else {
                showAlert('Error updating reservation', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showAlert('Error updating reservation', 'error');
        });
    }

    function showAlert(message, type) {
        const alert = document.createElement('div');
        alert.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show`;
        alert.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
        `;
        alert.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        document.body.appendChild(alert);
        
        setTimeout(() => {
            if (alert.parentNode) {
                alert.parentNode.removeChild(alert);
            }
        }, 3000);
    }
});

</script>
@endsection