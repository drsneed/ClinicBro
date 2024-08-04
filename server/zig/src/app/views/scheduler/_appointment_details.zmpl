<div id="appointment-details" class="groupbox hidden">
    <label id="appt-details-header" class="gb-header"></label>
    <div id="appt-details-client" class="cb-row display-field" hx-ext="path-params">
        <label>Patient</label>
        <span id="appt-details-client-span"></span>
    </div>
    <div class="cb-row display-field" hx-ext="path-params">
        <label id="appt-details-title-label"></label>
        <span id="appt-details-title-span"></span>
    </div>
    <div id="appt-details-status" class="cb-row display-field" hx-ext="path-params">
        <label>Status</label>
        <span id="appt-details-status-span"></span>
    </div>
    <div id="appt-details-location" class="cb-row display-field" hx-ext="path-params">
        <label>Location</label>
        <span id="appt-details-location-span"></span>
    </div>
    <div id="appt-details-provider" class="cb-row display-field" hx-ext="path-params">
        <label>Provider</label>
        <span id="appt-details-provider-span"></span>
    </div>
    <hr />
    <div class="date-container">
      <div class="text-field">
          <input id="appt-details-date" type="date" name="appt_date" readonly="" value="">
          <label for="appt_date">Date</label>
      </div>
    </div>
    <div class="time-inputs">
      <div class="text-field time-input">
          <input id="appt-details-from" type="time" name="appt_from" value="" readonly="">
          <label for="appt_from">From</label>
      </div>
      <div class="text-field time-input">
          <input id="appt-details-to" type="time" name="appt_to" value="" readonly="">
          <label for="appt_to">To</label>
      </div>
    </div>
</div>