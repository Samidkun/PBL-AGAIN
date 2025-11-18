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
                                <!-- UBAH: dari input type="time" ke select dropdown -->
                                <select class="form-select" id="editReservationTime" required>
                                    <option value="">Select Time</option>
                                    <option value="08:00">8:00 AM</option>
                                    <option value="09:00">9:00 AM</option>
                                    <option value="10:00">10:00 AM</option>
                                    <option value="11:00">11:00 AM</option>
                                    <option value="12:00">12:00 PM</option>
                                    <option value="13:00">1:00 PM</option>
                                    <option value="14:00">2:00 PM</option>
                                    <option value="15:00">3:00 PM</option>
                                    <option value="16:00">4:00 PM</option>
                                    <option value="17:00">5:00 PM</option>
                                    <option value="18:00">6:00 PM</option>
                                    <option value="19:00">7:00 PM</option>
                                    <option value="20:00">8:00 PM</option>
                                    <option value="21:00">9:00 PM</option>
                                    <option value="22:00">10:00 PM</option>
                                </select>
                                <div class="form-text">We're open from 8:00 AM to 10:00 PM</div>
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
<!-- Custom Confirmation Modal - Clean Version -->
<div class="modal fade" id="confirmationModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body text-center p-5">
                <div class="confirmation-icon mb-4">
                    <i class="fas fa-question-circle fa-4x text-warning"></i>
                </div>
                <h4 class="modal-title mb-3" id="confirmationModalTitle">Confirmation</h4>
                <h5 id="confirmationMessage" class="text-dark mb-2">Are you sure you want to proceed?</h5>
                <p id="confirmationDetails" class="text-muted mb-4"></p>
                
                <div class="d-flex gap-3 justify-content-center">
                    <button type="button" class="btn btn-outline-secondary btn-lg px-4" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Cancel
                    </button>
                    <button type="button" class="btn btn-lg px-4" id="confirmActionBtn">
                        <i class="fas fa-check me-2"></i>Confirm
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Success Alert Modal - Clean Version -->
<div class="modal fade" id="successModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body text-center p-5">
                <div class="success-animation mb-4">
                    <div class="checkmark">
                        <i class="fas fa-check fa-4x text-success"></i>
                    </div>
                </div>
                <h4 class="text-success mb-3" id="successMessage">Success!</h4>
                <p id="successDetails" class="text-muted mb-4">Your action has been completed successfully.</p>
                <button type="button" class="btn btn-success btn-lg px-5" data-bs-dismiss="modal">
                    <i class="fas fa-thumbs-up me-2"></i>Great!
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Error Alert Modal - Clean Version -->
<div class="modal fade" id="errorModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body text-center p-5">
                <div class="error-icon mb-4">
                    <i class="fas fa-exclamation-triangle fa-4x text-danger"></i>
                </div>
                <h4 class="text-danger mb-3" id="errorMessage">Oops!</h4>
                <p id="errorDetails" class="text-muted mb-4">Something went wrong. Please try again.</p>
                <button type="button" class="btn btn-danger btn-lg px-5" data-bs-dismiss="modal">
                    <i class="fas fa-redo me-2"></i>Try Again
                </button>
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
    const confirmationModal = new bootstrap.Modal(document.getElementById('confirmationModal'));
    const successModal = new bootstrap.Modal(document.getElementById('successModal'));
    const errorModal = new bootstrap.Modal(document.getElementById('errorModal'));
    const updateReservationBtn = document.getElementById('updateReservationBtn');
    const confirmActionBtn = document.getElementById('confirmActionBtn');

    // Variables for confirmation
    let currentReservationId = null;
    let currentActionType = null;

    // Get today's date dengan format yang benar
    function getTodayDate() {
        const today = new Date();
        const offset = today.getTimezoneOffset();
        today.setMinutes(today.getMinutes() - offset);
        return today.toISOString().split('T')[0];
    }

    function initializeDate() {
        const todayString = getTodayDate();
        selectedDate = todayString;
        selectedDateSpan.textContent = formatDate(new Date(todayString));
        loadReservationsForDate(todayString);
        updateCalendar();
    }

    // Initialize
    initializeDate();

    // Event Listeners
    datePickerBtn.addEventListener('click', toggleCalendar);
    prevMonthBtn.addEventListener('click', goToPrevMonth);
    nextMonthBtn.addEventListener('click', goToNextMonth);
    updateReservationBtn.addEventListener('click', updateReservation);
    confirmActionBtn.addEventListener('click', executeConfirmedAction);

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
            
            const todayString = getTodayDate();
            if (dateString === todayString) {
                dayElement.classList.add('selected');
            }
            
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
        
        document.querySelectorAll('.calendar-day.selected').forEach(el => {
            el.classList.remove('selected');
        });
        dayElement.classList.add('selected');
        
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
        console.log('Loading reservations for date:', date);
        
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
                console.log('Response status:', response.status);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('API Response:', data);
                if (data.success && data.reservations) {
                    updateReservationTable(data.reservations);
                    updateStats(data.reservations);
                } else {
                    throw new Error(data.message || 'Invalid response format');
                }
            })
            .catch(error => {
                console.error('Error loading reservations:', error);
                reservationTableBody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center py-4 text-danger">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            Error loading reservations: ${error.message}
                        </td>
                    </tr>
                `;
            });
    }

    function updateReservationTable(reservations) {
        if (!reservations || reservations.length === 0) {
            reservationTableBody.innerHTML = '';
            noReservations.classList.add('show');
            return;
        }

        noReservations.classList.remove('show');
        
        // Escape HTML untuk mencegah XSS
        const escapeHtml = (text) => {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        };

        reservationTableBody.innerHTML = reservations.map(reservation => `
            <tr>
                <td>
                    <strong>${escapeHtml(reservation.queue_number)}</strong>
                </td>
                <td>${escapeHtml(reservation.name)}</td>
                <td>${escapeHtml(reservation.phone)}</td>
                <td>${reservation.treatment_type === 'nail_extension' ? 'Nail Extension' : 'Nail Art'}</td>
                <td>
                    ${new Date(reservation.reservation_date).toLocaleDateString()} 
                    at ${escapeHtml(reservation.reservation_time)}
                </td>
                <td>
                    <span class="status-badge status-${reservation.status}">
                        ${reservation.status.toUpperCase()}
                    </span>
                </td>
                <td>
                    <div class="actions-container">
                        ${reservation.status === 'pending' ? `
                            <button class="btn-action btn-confirm" onclick="showConfirmation(${reservation.id}, 'confirm', '${escapeHtml(reservation.name)}')">
                                <i class="fas fa-check me-1"></i>Confirm
                            </button>
                            <button class="btn-action btn-cancel" onclick="showConfirmation(${reservation.id}, 'cancel', '${escapeHtml(reservation.name)}')">
                                <i class="fas fa-times me-1"></i>Cancel
                            </button>
                        ` : ''}
                        ${reservation.status !== 'cancelled' && reservation.status !== 'completed' ? `
                            <button class="btn-action btn-edit" onclick="editReservation(${reservation.id})">
                                <i class="fas fa-edit me-1"></i>Edit
                            </button>
                        ` : ''}
                    </div>
                </td>
            </tr>
        `).join('');
    }

    function updateStats(reservations) {
        if (!reservations) return;
        
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

    // Custom Confirmation Function
    window.showConfirmation = function(reservationId, actionType, customerName) {
        currentReservationId = reservationId;
        currentActionType = actionType;
        
        const modalTitle = document.getElementById('confirmationModalTitle');
        const modalMessage = document.getElementById('confirmationMessage');
        const modalDetails = document.getElementById('confirmationDetails');
        const confirmBtn = document.getElementById('confirmActionBtn');
        
        if (actionType === 'confirm') {
            modalTitle.textContent = 'Confirm Reservation';
            modalMessage.textContent = 'Confirm this reservation?';
            modalDetails.textContent = `Customer: ${customerName}`;
            confirmBtn.textContent = 'Yes, Confirm';
            confirmBtn.className = 'btn btn-success btn-lg px-4';
            confirmBtn.innerHTML = '<i class="fas fa-check me-2"></i>Confirm';
        } else {
            modalTitle.textContent = 'Cancel Reservation';
            modalMessage.textContent = 'Cancel this reservation?';
            modalDetails.textContent = `Customer: ${customerName}`;
            confirmBtn.textContent = 'Yes, Cancel';
            confirmBtn.className = 'btn btn-danger btn-lg px-4';
            confirmBtn.innerHTML = '<i class="fas fa-times me-2"></i>Cancel';
        }
        
        confirmationModal.show();
    }

    function executeConfirmedAction() {
        const confirmBtn = document.getElementById('confirmActionBtn');
        const originalText = confirmBtn.innerHTML;
        
        // Show loading state
        confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
        confirmBtn.disabled = true;
        
        confirmationModal.hide();
        
        const status = currentActionType === 'confirm' ? 'confirmed' : 'cancelled';
        const successMessage = currentActionType === 'confirm' 
            ? 'Reservation confirmed successfully!' 
            : 'Reservation cancelled successfully!';
        
        updateReservationStatus(currentReservationId, status, successMessage)
            .finally(() => {
                // Reset button state
                confirmBtn.innerHTML = originalText;
                confirmBtn.disabled = false;
            });
    }

    function updateReservationStatus(reservationId, status, successMessage) {
        return fetch(`/dashboard/reservations/${reservationId}/status`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({ status: status })
        })
        .then(response => {
            console.log('Status update response status:', response.status);
            if (!response.ok) {
                return response.json().then(err => {
                    throw new Error(err.message || `HTTP error! status: ${response.status}`);
                });
            }
            return response.json();
        })
        .then(data => {
            console.log('Status update response:', data);
            if (data.success) {
                showSuccessModal(successMessage);
                loadReservationsForDate(selectedDate);
            } else {
                throw new Error(data.message || 'Error updating reservation status');
            }
        })
        .catch(error => {
            console.error('Error updating reservation status:', error);
            showErrorModal('Error updating reservation: ' + error.message);
        });
    }

    function showSuccessModal(message) {
        document.getElementById('successMessage').textContent = 'Success!';
        document.getElementById('successDetails').textContent = message;
        successModal.show();
    }

    function showErrorModal(message) {
        document.getElementById('errorMessage').textContent = 'Error!';
        document.getElementById('errorDetails').textContent = message;
        errorModal.show();
    }

   window.editReservation = function(reservationId) {
    console.log('Editing reservation ID:', reservationId);
    
    fetch(`/dashboard/reservations/${reservationId}`)
        .then(response => {
            console.log('Edit response status:', response.status);
            if (!response.ok) {
                return response.json().then(err => {
                    throw new Error(err.message || `HTTP error! status: ${response.status}`);
                });
            }
            return response.json();
        })
        .then(reservation => {
            console.log('Reservation data loaded:', reservation);
            
            // Check if reservation data is valid
            if (!reservation.id) {
                throw new Error('Invalid reservation data received');
            }
            
            document.getElementById('editReservationId').value = reservation.id;
            document.getElementById('editName').value = reservation.name || '';
            document.getElementById('editPhone').value = reservation.phone || '';
            document.getElementById('editAddress').value = reservation.address || '';
            document.getElementById('editTreatmentType').value = reservation.treatment_type || 'nail_extension';
            
            // Format waktu untuk dropdown (pastikan tanpa detik)
            let reservationTime = reservation.reservation_time || '';
            if (reservationTime.length > 5) {
                reservationTime = reservationTime.substring(0, 5);
            }
            document.getElementById('editReservationTime').value = reservationTime;
            
            editReservationModal.show();
        })
        .catch(error => {
            console.error('Error loading reservation:', error);
            showErrorModal('Error loading reservation data: ' + error.message);
        });
};

    function updateReservation() {
        const reservationId = document.getElementById('editReservationId').value;
        const updateBtn = document.getElementById('updateReservationBtn');
        const originalText = updateBtn.innerHTML;

        // Show loading state
        updateBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Updating...';
        updateBtn.disabled = true;

        // Format waktu ke HH:MM (tanpa detik)
        let reservationTime = document.getElementById('editReservationTime').value;
        if (reservationTime.length > 5) {
            reservationTime = reservationTime.substring(0, 5); // Ambil hanya HH:MM
        }

        const formData = {
            name: document.getElementById('editName').value,
            phone: document.getElementById('editPhone').value,
            address: document.getElementById('editAddress').value,
            treatment_type: document.getElementById('editTreatmentType').value,
            reservation_time: reservationTime // Format HH:MM
        };

        console.log('Updating reservation:', reservationId, formData);

        fetch(`/dashboard/reservations/${reservationId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify(formData)
        })
        .then(response => {
            console.log('Update response status:', response.status);
            if (!response.ok) {
                return response.json().then(err => {
                    throw new Error(err.message || `HTTP error! status: ${response.status}`);
                });
            }
            return response.json();
        })
        .then(data => {
            console.log('Update response data:', data);
            if (data.success) {
                editReservationModal.hide();
                showSuccessModal('Reservation updated successfully!');
                loadReservationsForDate(selectedDate);
            } else {
                throw new Error(data.message || 'Error updating reservation');
            }
        })
        .catch(error => {
            console.error('Error updating reservation:', error);
            let errorMessage = 'Error updating reservation';
            
            if (error.message.includes('Validation error')) {
                errorMessage = 'Please check your input data. Time format should be HH:MM';
            } else if (error.message.includes('not found')) {
                errorMessage = 'Reservation not found';
            } else if (error.message.includes('500')) {
                errorMessage = 'Server error. Please try again later.';
            }
            
            showErrorModal(errorMessage + ': ' + error.message);
        })
        .finally(() => {
            // Reset button state
            updateBtn.innerHTML = originalText;
            updateBtn.disabled = false;
        });
    }
});
</script>
@endsection