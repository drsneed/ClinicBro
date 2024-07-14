@zig {
  const appt_id = zmpl.getT(.integer, "appt_id").?;
  const client = zmpl.getT(.string, "client").?;
  const is_appointment = client.len > 0;
  const groupbox_header = if(is_appointment) "Appointment Details" else "Event Details";
  const hidden = if(appt_id == 0) "hidden" else "";
}
<div id="appointment-details" class="groupbox {{hidden}}">
  <Label class="gb-header">{{groupbox_header}}</Label>
  @zig {
    if(is_appointment) {
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Patient</label>
        <span>{{client}}</code>
      </div>
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Type</label>
        <span>{{.title}}</code>
      </div>
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Status</label>
        <span>{{.status}}</code>
      </div>
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Location</label>
        <span>{{.location}}</code>
      </div>
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Provider</label>
        <span>{{.provider}}</code>
      </div>
    } else {
      <div class="cb-row display-field" hx-ext="path-params">
        <label>Title</label>
        <span>{{.title}}</code>
      </div>
    }
  }
  <hr />
  <div class="date-container">
      <div class="text-field">
          <input id="appt_date" type="date" name="appt_date" readonly=""
              value="{{.appt_date}}" required>
          <label for="appt_date">Date</label>
      </div>
  </div>
  <div class="time-inputs">
      <div class="text-field time-input">
          <input id="appt_from" type="time" name="appt_from" value="{{.appt_from}}" readonly="">
          <label for="appt_from">From</label>
      </div>
      <div class="text-field time-input">
          <input id="appt_to" type="time" name="appt_to" value="{{.appt_to}}" readonly="">
          <label for="appt_to">To</label>
      </div>
  </div>

</div>
      