@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
}
<div id="ApptTypeSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
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
          hx-target="#ApptTypeSetupContent"
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
        <button type="button" class="btn" title="Delete"
            hx-include="#appt-type-id-input, #include_inactive"
            hx-delete="/setup/appointment-types/{id}"
            hx-target="#ApptTypeSetupScreen"
            hx-swap="outerHTML">
              <span class="mdi mdi-trash-can"></span>
          </button>  
      </div>
      <div class="setup-item-list" hx-ext="path-params">
        <select id="setup-select" size="20"
          name="id"
          hx-get="/setup/appointment-types/{id}"
          hx-target="#ApptTypeSetupContent"
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
    @zig {
      if(zmpl.getT(.integer, "id")) |id| {
        <div id="ApptTypeSetupContent" class="setup-item-content {{inactive_class}}">
          <form id="appt-type-form" method="post">
            <input id="appt-type-id-input" type="hidden" name="id" value="{{id}}">
            <div class="id-field">
              <span>ID</span>
              <code>{{id}}</code>
              <label class="cb-label"><input type="checkbox" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>   
            </div>
            <hr />
            <div class="text-field">
              <input type="text" name="name" maxlength="16" value="{{.name}}" required>
              <label for="name">Name</label>
            </div>
            <div class="text-field">
              <input type="text" name="abbreviation" maxlength="4" value="{{.abbreviation}}">
              <label for="abbreviation">Abbreviation</label>
            </div>
            <div class="text-field">
              <input type="color" name="color" value="{{.color}}">
              <label for="color">Color</label>
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
        </div>
      }
    }

    
  </div>
</div>