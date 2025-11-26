@extends('layouts.app')

@section('title', 'Select Time')

@section('content')

<div class="container py-4">

    <h2 class="mb-4 text-center">Pilih Jadwal</h2>

    <div class="mb-3">
        <label>Tanggal</label>
        <input type="date" id="datePicker" class="form-control" value="{{ date('Y-m-d') }}">
    </div>

    <div id="slotContainer">
        <p class="text-center">Loading...</p>
    </div>
</div>

<script>
function loadSlots() {
    let date = document.getElementById("datePicker").value;
    let container = document.getElementById("slotContainer");

    container.innerHTML = "<p class='text-center'>Loading...</p>";

    fetch(`/api/v1/calendar/slots?date=` + date)
        .then(res => res.json())
        .then(json => {

            let html = "";

            json.data.forEach(artist => {
                html += `
                    <div class="card mb-4">
                        <div class="card-header bg-light">
                            <strong>${artist.artist}</strong>
                        </div>
                        <div class="card-body d-flex flex-wrap">
                `;

                artist.slots.forEach(slot => {
                    html += `
                        <button
                            class="btn m-2 ${slot.available ? 'btn-success' : 'btn-secondary'}"
                            style="min-width:120px"
                            ${slot.available ? '' : 'disabled'}
                            onclick="selectSlot('${artist.artist_id}', '${slot.time}')"
                        >
                            ${slot.time}
                        </button>
                    `;
                });

                html += `
                        </div>
                    </div>
                `;
            });

            container.innerHTML = html;
        });
}

function selectSlot(artistId, time) {
    sessionStorage.setItem("selectedArtist", artistId);
    sessionStorage.setItem("selectedTime", time);

    window.location.href = "{{ route('reservations.create') }}";
}

document.addEventListener("DOMContentLoaded", loadSlots);
document.getElementById("datePicker").addEventListener("change", loadSlots);
</script>

@endsection
