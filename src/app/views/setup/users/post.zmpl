@zig {
  const bros = zmpl.getT(.array, "bros").?;
  const item_count = bros.len;
}
<div id="UserSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-button-bar">
        <button type="button" class="btnbar-btn"
          hx-get="/setup/users/0"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML"><span class="mdi mdi-plus mr-2"></span>Add New</button>
          <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
            hx-get="/setup/users"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"
            {{.include_inactive}}
            >Include Inactive</label>
      </div>
      <div class="setup-list-info">
        <span>Count: {{item_count}}</span>
      </div>
      <div class="setup-item-list" hx-ext="path-params">
        <select id="bros" size="20"
          name="id"
          hx-get="/setup/users/{id}"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML">
          @zig {
            for (bros) |bro| {
                const id = bro.getT(.integer, "id") orelse continue;
                const name = bro.getT(.string, "name") orelse continue;
                const selected = bro.getT(.string, "selected") orelse continue;
                <option value="{{id}}" {{selected}}>{{name}}</option>
            }
          }
        </select>
      </div>
    </div>
    <div id="UserSetupContent" class="setup-item-content">
      @zig {
        if(zmpl.getT(.integer, "id")) |id| {
          <form id="user-form" method="post">
            <input id="user-id-input" type="hidden" name="id" value="{{.id}}">
            <div class="id-field">
              <span>ID</span>
              <code>{{id}}</code>
            </div>
            <hr />
            <div class="text-field">
              <input id="user_name" type="text" name="name" maxlength="16"
                  value="{{.name}}" required>
              <label for="name">Name</label>
            </div>
            <label class="cb-label"><input type="checkbox" id="user_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>
            <label class="cb-label"><input type="checkbox" id="user_sees_clients" name="sees_clients" class="cbcb" value="1" {{.sees_clients_check}}>Sees Clients</label>
            <br />

            <div class="setup-item-buttons" hx-ext="path-params">
              <button type="button" class="btn btn-save"
                  hx-include="#user-form, #include_inactive"
                  hx-post="/setup/users"
                  hx-target="#UserSetupScreen"
                  hx-swap="outerHTML"><span class="mdi mdi-content-save mr-2"></span>Save</button>
              <button type="button" class="btn btn-delete"
                  hx-include="#user-id-input"
                  hx-delete="/setup/users/{id}"
                  hx-target="#UserSetupScreen"
                  hx-swap="outerHTML"><span class="mdi mdi-trash-can mr-2"></span>Delete</button>  
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

