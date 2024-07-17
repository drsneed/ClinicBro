@zig {
  const id = zmpl.getT(.integer, "id").?;
  const client_id = zmpl.getT(.integer, "client_id").?;
  const autofocus = if(id == 0) "autofocus" else "";
  const window_title = if(id == 0 and client_id == 0) "Add New Event"
     else if(id > 0 and client_id == 0) "Edit Event"
     else if(id == 0 and client_id > 0) "Add New Appointment"
     else "Edit Appointment";
}
<cb-window id="cb-window" opened="" window_title="{{window_title}}" top="160px" left="calc(50% - 160px)">
    <form id="appointment-form" method="post">
      <input id="appointment-id-input" type="hidden" name="id" value="{{id}}">
      <input type="hidden" name="client_id" value="{{client_id}}">
      @zig {
        if(client_id > 0) {
          const locations = zmpl.getT(.array, "locations").?;
          const bros = zmpl.getT(.array, "bros").?;
          const appt_types = zmpl.getT(.array, "appt_types").?;
          const appt_statuses = zmpl.getT(.array, "appt_statuses").?;
          const client_name = zmpl.getT(.string, "client_name").?;
          <div class="id-field" hx-ext="path-params">
            <label class="select-label">Patient</label>
            <code>{{client_name}}</code>
          </div>
          <hr />
          <div class="cb-row">
            <label class="select-label" for="type_id">Type</label>
            <select name="type_id">
                @zig {
                  for (appt_types) |appt_type| {
                      const type_id = appt_type.getT(.integer, "id") orelse continue;
                      const type_name = appt_type.getT(.string, "name") orelse continue;
                      const type_active = appt_type.getT(.boolean, "active") orelse continue;
                      const type_selected = appt_type.getT(.string, "selected") orelse continue;
                      const type_inactive_class = if(type_active) "" else "setup-item-inactive";
                      <option value="{{type_id}}" class="{{type_inactive_class}}" {{type_selected}}>{{type_name}}</option>
                  }
                }
            </select>
          </div>
          <div class="cb-row">
            <label class="select-label" for="status_id">Status</label>
            <select name="status_id">
                @zig {
                  for (appt_statuses) |status| {
                      const stat_id = status.getT(.integer, "id") orelse continue;
                      const stat_name = status.getT(.string, "name") orelse continue;
                      const stat_active = status.getT(.boolean, "active") orelse continue;
                      const stat_selected = status.getT(.string, "selected") orelse continue;
                      const stat_inactive_class = if(stat_active) "" else "setup-item-inactive";
                      <option value="{{stat_id}}" class="{{stat_inactive_class}}" {{stat_selected}}>{{stat_name}}</option>
                  }
                }
            </select>
          </div>
          <div class="cb-row">
            <label class="select-label" for="location_id">Location</label>
            <select name="location_id">
                @zig {
                  for (locations) |location| {
                      const loc_id = location.getT(.integer, "id") orelse continue;
                      const loc_name = location.getT(.string, "name") orelse continue;
                      const loc_active = location.getT(.boolean, "active") orelse continue;
                      const loc_selected = location.getT(.string, "selected") orelse continue;
                      const loc_inactive_class = if(loc_active) "" else "setup-item-inactive";
                      <option value="{{loc_id}}" class="{{loc_inactive_class}}" {{loc_selected}}>{{loc_name}}</option>
                  }
                }
            </select>
          </div>
          <div class="cb-row">
            <label class="select-label" for="bro_id">Provider</label>
            <select name="bro_id">
                @zig {
                  for (bros) |bro| {
                      const bro_id = bro.getT(.integer, "id") orelse continue;
                      const bro_name = bro.getT(.string, "name") orelse continue;
                      const bro_active = bro.getT(.boolean, "active") orelse continue;
                      const bro_selected = bro.getT(.string, "selected") orelse continue;
                      const bro_inactive_class = if(bro_active) "" else "setup-item-inactive";
                      <option value="{{bro_id}}" class="{{bro_inactive_class}}" {{bro_selected}}>{{bro_name}}</option>
                  }
                }
            </select>
          </div>
        } else {
          <div class="text-field">
            <input id="appt_title" type="text" name="title" maxlength="255"
                value="{{.title}}" required {{autofocus}}>
            <label for="title">Title</label>
          </div>
        }
      }
      <hr />
      <div class="date-container">
          <div class="text-field">
              <input id="appt_date" type="date" name="appt_date"
                  value="{{.appt_date}}" required>
              <label for="appt_date">Date</label>
          </div>
      </div>
      <div class="time-inputs">
          <div class="text-field time-input">
              <input id="appt_from" type="time" name="appt_from" value="{{.appt_from}}" required>
              <label for="appt_from">From</label>
          </div>
          <div class="text-field time-input">
              <input id="appt_to" type="time" name="appt_to" value="{{.appt_to}}" required>
              <label for="appt_to">&nbsp;&nbsp;&nbsp;To</label>
          </div>
      </div>
      
    </form>
    <hr />
    @zig { 
      if(id > 0) {
      <div class="tracking">
          <h2>Tracking</h2>
          <ul>
          <li>Created on {{.date_created}} by {{.created_by}}</li>
          <li>Updated on {{.date_updated}} by {{.updated_by}}</li>
          </ul>
      </div> 
    }
    }
    <div class="window-button-bar" hx-ext="path-params">
      <button type="button" class="btn btn-save" title="Save" id="appt-save-button"
          hx-include="#appointment-form"
          hx-post="/scheduler"
          hx-target="#scheduler"
          hx-swap="outerHTML">Save</button>
        <button type="button" class="btn btn-cancel" title="Close"
          onclick="document.getElementById('cb-window').opened=false;">Close</button>
    </div>

</cb-window>