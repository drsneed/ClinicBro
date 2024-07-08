@zig {
  const locations = zmpl.getT(.array, "locations").?;
  const bros = zmpl.getT(.array, "bros").?;
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
  const id = zmpl.getT(.integer, "id").?;
  const autofocus = if(id == 0) "autofocus" else "";
  const window_title = if(id == 0) "Add New Client" else "Edit Client";
  const can_call = zmpl.getT(.boolean, "can_call") orelse false;
  const can_text = zmpl.getT(.boolean, "can_text") orelse false;
  const can_email = zmpl.getT(.boolean, "can_email") orelse false;
  const can_call_check = if (can_call) "checked" else "";
  const can_text_check = if (can_text) "checked" else "";
  const can_email_check = if (can_email) "checked" else "";
}
<cb-window id="cb-window" opened="" window_title="{{window_title}}">
    <form id="client-form" method="post" class="{{inactive_class}}">
      <input id="client-id-input" type="hidden" name="id" value="{{id}}">
      <div class="id-field" hx-ext="path-params">
        <span>ID</span>
        <code>{{id}}</code>
        @zig {
          if(id > 0) {
              <label class="cb-label"><input type="checkbox" id="client_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>   
          }
        }
        <input id="first_name" type="text" name="first_name" placeholder="First" maxlength="50" value="{{.first_name}}" required {{autofocus}}>
        <input id="middle_name" type="text" name="middle_name" placeholder="M" maxlength="50" value="{{.middle_name}}" required>
        <input id="last_name" type="text" name="last_name" placeholder="Last" maxlength="50" value="{{.last_name}}" required>
        @zig {
          if(id > 0) {
          <button type="button" id="client-delete" class="btn" title="Delete"
            hx-include="#client-id-input"
            hx-delete="/clients/{id}"
            hx-target="#cb-window"
            hx-swap="outerHTML"><span class="mdi mdi-trash-can"></span></button>  
        }
        }
      </div>
      <hr />
      <div class="date-container">
        <div class="text-field">
            <input type="date" name="date_of_birth" value="{{.date_of_birth}}">
            <label for="date">Date of Birth</label>
        </div>
      </div>
      <div class="text-field tf-inline">
        <input id="client_phone" type="text" name="phone" maxlength="15" value="{{.phone}}">
        <label for="phone">Phone</label>
      </div>
      <div class="text-field tf-inline">
        <input id="client_email" type="text" name="email" maxlength="99" value="{{.email}}">
        <label for="email">Email</label>
      </div>
      <div class="groupbox">
        <label>Communication Preferences</label>
        <label class="cb-label"><input type="checkbox" name="can_call" class="cbcb" value="1" {{can_call_check}}>Can Call</label>
        <label class="cb-label"><input type="checkbox" name="can_text" class="cbcb" value="1" {{can_text_check}}>Can Text</label>
        <label class="cb-label"><input type="checkbox" name="can_email" class="cbcb" value="1" {{can_email_check}}>Can Email</label>
      </div>
      
      @partial address(address_1: .address_1, address_2: .address_2, city: .city, state: .state, zip_code: .zip_code)
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
        <label class="select-label-2" for="bro_id">Provider</label>
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
      <button type="button" class="btn btn-save" title="Save"
          hx-include="#client-form"
          hx-post="/clients"
          hx-target="#recent-clients-listbox"
          hx-swap="outerHTML"
          onclick="document.getElementById('cb-window').opened=false;">Save</button>
        <button type="button" class="btn btn-cancel" title="Close"
          onclick="document.getElementById('cb-window').opened=false;">Close</button>
    </div>

</cb-window>