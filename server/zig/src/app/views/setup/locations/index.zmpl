@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
}
<div id="LocationSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <h2><span class="mdi mdi-map-marker-multiple mr-2"></span>Locations</h2>
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
          onclick="addSetupBlankItem();">
            <span class="mdi mdi-plus mr-2"></span>
        </button>
        <button type="button" class="btn" title="Save"
            hx-include="#location-form, #include_inactive"
            hx-post="/setup/locations"
            hx-target="#LocationSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-content-save mr-2"></span>
          </button>
        <button type="button" class="btn" title="Delete"
            hx-include="#location-id-input"
            hx-delete="/setup/locations/{id}"
            hx-target="#LocationSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-trash-can mr-2"></span>
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
                <li class="setup-option {{inactive_class}}" hx-get="/setup/locations/{{id}}"
                  hx-target="#LocationSetupContent" hx-trigger="click" hx-swap="outerHTML" onclick="setupItemSelected(event)">
                  <span class="mdi mdi-map-marker mr-2"></span>{{name}}</li>
            }
          }
        </ul>
      </div>
    </div>
    <div id="LocationSetupContent" class="setup-item-content">
    </div>
  </div>
</div>