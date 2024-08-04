@zig {
  const setup_items = zmpl.getT(.array, "setup_items").?;
  const item_count = setup_items.len;
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
}
<div id="UserSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <h2><span class="mdi mdi-account-multiple mr-2"></span>Users</h2>
        <span class="cb-label">Items: {{item_count}}</span>
        <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
          hx-get="/setup/users"
          hx-target="#UserSetupScreen"
          hx-swap="outerHTML"
          {{.include_inactive}}
          >Include Inactive</label>
      </div>
      <div class="setup-button-bar" hx-ext="path-params">
        <button type="button" class="btn" title="Add New"
          hx-get="/setup/users/0"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML"
          onclick="addSetupBlankItem();"><span class="mdi mdi-plus mr-2"></span></button>
            <button type="button" class="btn" title="Save"
            hx-include="#user-form, #include_inactive"
            hx-post="/setup/users"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-content-save mr-2"></span></button>
            <button type="button" class="btn" title="Delete"
            hx-include="#user-id-input"
            hx-delete="/setup/users/{id}"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-trash-can mr-2"></span></button>  
      </div>
      <div class="setup-item-listbox">
        <ul>
          @zig {
            for (setup_items) |item| {
              const id = item.getT(.integer, "id") orelse continue;
              const name = item.getT(.string, "name") orelse continue;
              const selected = item.getT(.string, "selected") orelse continue;
                <li class="setup-option {{inactive_class}} {{selected}}" hx-get="/setup/users/{{id}}"
                  hx-target="#UserSetupContent" hx-trigger="click" hx-swap="outerHTML" onclick="setupItemSelected(event)">
                  <span class="mdi mdi mdi-account mr-2"></span>{{name}}</li>
            }
          }
        </ul>
      </div>
    </div>
    <div id="UserSetupContent" class="setup-item-content {{inactive_class}}">
      @zig {
        if(zmpl.getT(.integer, "id")) |id| {
          <form id="user-form" method="post">
            <input id="user-id-input" type="hidden" name="id" value="{{.id}}">
            <div class="id-field">
              <span>ID</span>
              <code>{{id}}</code>
              <label class="cb-label"><input type="checkbox" id="user_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>
            </div>
            <hr />
            <div class="text-field">
              <input id="user_name" type="text" name="name" maxlength="16"
                  value="{{.name}}" required>
              <label for="name">Name</label>
            </div>
            <label class="cb-label ml-2"><input type="checkbox" id="user_sees_clients" name="sees_clients" class="cbcb" value="1" {{.sees_clients_check}}>Sees Clients</label>
            <br />
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
        }
      }
      
    </div>
  </div>
</div>

