@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
}
<div id="LocationSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <span class="cb-label">Items: {{item_count}}</span>
        <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
          hx-get="/setup/locations"
          hx-target="#LocationSetupScreen"
          hx-swap="outerHTML"
          {{.include_inactive}}
          >Include Inactive</label>
      </div>
      <div class="setup-button-bar" hx-ext="path-params">
        <button type="button" class="btn" title="Add New"
          hx-get="/setup/locations/0"
          hx-target="#LocationSetupContent"
          hx-swap="outerHTML"
          onclick="addSetupBlankItem();"><span class="mdi mdi-plus mr-2"></span></button>
            <button type="button" class="btn" title="Save"
            hx-include="#location-form, #include_inactive"
            hx-post="/setup/locations"
            hx-target="#LocationSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-content-save mr-2"></span></button>
            <button type="button" class="btn" title="Delete"
            hx-include="#location-id-input"
            hx-delete="/setup/locations/{id}"
            hx-target="#LocationSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-trash-can mr-2"></span></button>  
      </div>
      <div class="setup-item-list" hx-ext="path-params">
        <select id="setup-select" size="20"
          name="id"
          hx-get="/setup/locations/{id}"
          hx-target="#LocationSetupContent"
          hx-swap="outerHTML">
          @zig {
            for (setup_items) |item| {
                const id = item.getT(.integer, "id") orelse continue;
                const name = item.getT(.string, "name") orelse continue;
                const this_active = item.getT(.boolean, "active") orelse continue;
                const this_inactive_class = if(this_active) "" else "setup-item-inactive";
                const selected = item.getT(.string, "selected") orelse continue;
                <option value="{{id}}" class="{{this_inactive_class}}" {{selected}}>{{name}}</option>
            }
          }
        </select>
      </div>
    </div>
    <div id="LocationSetupContent" class="setup-item-content {{inactive_class}}">
      @zig {
        if(zmpl.getT(.integer, "id")) |id| {

          <form id="location-form" method="post">
            <input id="location-id-input" type="hidden" name="id" value="{{id}}">
            <div class="id-field">
              <span>ID</span>
              <code>{{id}}</code>
              <label class="cb-label"><input type="checkbox" id="location_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>
            </div>
            <hr />
            <div class="text-field">
              <input id="location_name" type="text" name="name" maxlength="50" value="{{.name}}" required>
              <label for="name">Name</label>
            </div>
            <div class="text-field">
              <input id="location_phone" type="text" name="phone" maxlength="15" value="{{.phone}}">
              <label for="phone">Phone</label>
            </div>
            <div class="text-field">
              <input id="location_address_1" type="text" name="address_1" maxlength="128" value="{{.address_1}}">
              <label for="address_1">Address Line 1</label>
            </div>
            <div class="text-field">
              <input id="location_address_2" type="text" name="address_2" maxlength="32" value="{{.address_2}}">
              <label for="address_2">Address Line 2</label>
            </div>
            <div class="text-field">
              <input id="location_city" type="text" name="city" maxlength="32" value="{{.city}}">
              <label for="city">City</label>
            </div>
            <div class="text-field">
              <input id="location_state" type="text" name="state" maxlength="32" value="{{.state}}">
              <label for="state">State</label>
            </div>
            <div class="text-field">
              <input id="location_zip_code" type="text" name="zip_code" maxlength="32" value="{{.zip_code}}">
              <label for="zip_code">Zip Code</label>
            </div>
          </form>
          <hr />
          <div class="tracking">
              <h2>Tracking</h2>
              <ul>
              <li>Created on {{.date_created}} by {{.created_by}}</li>
              <li>Updated on {{.date_updated}} by {{.updated_by}}</li>
              </ul>
          </div> 
        }
      }
      
      
    </div>
  </div>
</div>

