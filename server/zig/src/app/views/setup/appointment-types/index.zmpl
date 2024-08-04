@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
}
<div id="ApptTypeSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <h2><span class="mdi mdi-label-multiple mr-2"></span>Appointment Types</h2>
        <span class="cb-label">Items: {{item_count}}</span>
        <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
          hx-get="/setup/appointment-types"
          hx-target="#ApptTypeSetupScreen"
          hx-swap="outerHTML"
          {{.include_inactive}}
          >Include Inactive</label>
      </div>
      <div class="setup-button-bar" hx-ext="path-params">
        <button type="button" class="btn" title="Add New"
          hx-get="/setup/appointment-types/0"
          hx-target="#SetupContent"
          hx-swap="outerHTML"
          onclick="addSetupBlankItem();">
            <span class="mdi mdi-plus"></span>
        </button>
        <button type="button" class="btn" title="Save"
            hx-include="#appt-type-form, #include_inactive"
            hx-post="/setup/appointment-types"
            hx-target="#ApptTypeSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-content-save"></span>
        </button>
        <button id="setup-delete-btn" type="button" class="btn" title="Delete"
            autocomplete="off"
            hx-include="#appt-type-id-input, #include_inactive"
            hx-delete="/setup/appointment-types/{id}"
            hx-target="#ApptTypeSetupScreen"
            hx-swap="outerHTML"
            hx-trigger="confirmed"
            onClick="confirmDelete(event)" disabled>
              <span class="mdi mdi-trash-can"></span>
        </button>  
      </div>
      <div class="setup-item-listbox">
        <ul id="setup-list-container">
          @zig {
            for (setup_items) |item| {
              const id = item.getT(.integer, "id") orelse continue;
              const name = item.getT(.string, "name") orelse continue;
              const active = item.getT(.boolean, "active") orelse continue;
              const inactive_class = if(active) "" else "setup-item-inactive";
                <li data-id="{{id}}" class="setup-option {{inactive_class}}" hx-get="/setup/appointment-types/{{id}}"
                  hx-target="#SetupContent" hx-trigger="click" hx-swap="outerHTML" onclick="setupItemSelected(event)">
                  <span class="mdi mdi-label mr-2"></span>{{name}}</li>
            }
          }
        </ul>
      </div>
    </div>
    <div id="SetupContent" class="setup-item-content">
    </div>
  </div>
</div>