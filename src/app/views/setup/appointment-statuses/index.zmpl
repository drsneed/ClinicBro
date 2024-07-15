@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
}
<div id="ApptStatusSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <span class="cb-label">Items: {{item_count}}</span>
        <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
          hx-get="/setup/appointment-statuses"
          hx-target="#ApptStatusSetupScreen"
          hx-swap="outerHTML"
          {{.include_inactive}}
          >Include Inactive</label>
      </div>
      <div class="setup-button-bar" hx-ext="path-params">
        <button type="button" class="btn" title="Add New"
          hx-get="/setup/appointment-statuses/0"
          hx-target="#ApptStatusSetupContent"
          hx-swap="outerHTML"
          onclick="addSetupBlankItem();">
            <span class="mdi mdi-plus"></span>
        </button>
        <button type="button" class="btn" title="Save"
            hx-include="#appt-status-form, #include_inactive"
            hx-post="/setup/appointment-statuses"
            hx-target="#ApptStatusSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-content-save"></span>
          </button>
        <button type="button" class="btn" title="Delete"
            hx-include="#appt-status-id-input, #include_inactive"
            hx-delete="/setup/appointment-statuses/{id}"
            hx-target="#ApptStatusSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-trash-can"></span>
          </button>  
      </div>
      <div class="setup-item-listbox">
        <ul>
          @zig {
            for (setup_items) |item| {
              const id = item.getT(.integer, "id") orelse continue;
              const name = item.getT(.string, "name") orelse continue;
              const active = item.getT(.boolean, "active") orelse continue;
              const inactive_class = if(active) "" else "setup-item-inactive";
                <li class="setup-option {{inactive_class}}" hx-get="/setup/appointment-statuses/{{id}}"
                  hx-target="#ApptStatusSetupContent" hx-trigger="click" hx-swap="outerHTML" onclick="setupItemSelected(event)">
                  <span class="mdi mdi-application-brackets-outline mr-2"></span>{{name}}</li>
            }
          }
        </ul>
      </div>
    </div>
    <div id="ApptStatusSetupContent" class="setup-item-content">
    </div>
  </div>
</div>