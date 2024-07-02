@zig {
  const bros = zmpl.getT(.array, "bros").?;
  const item_count = bros.len;
}
<div id="UserSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-list-info">
        <span class="cb-label">Items: {{item_count}}</span>
        <label class="cb-label"><input type="checkbox" id="include_inactive" name="include_inactive" class="cbcb" value="1"
          hx-get="/setup/users"
          hx-target="#UserSetupScreen"
          hx-swap="outerHTML"
          {{.include_inactive}}
          >Include Inactive</label>
      </div>
      <div class="setup-button-bar" hx-ext="path-params">
        <button type="button" class="btn btn-add" title="Add New"
          hx-get="/setup/users/0"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML"
          onclick="clearSetupSelectedItem();"><span class="mdi mdi-plus mr-2"></span></button>
            <button type="button" class="btn btn-save" title="Save"
            hx-include="#user-form, #include_inactive"
            hx-post="/setup/users"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-content-save mr-2"></span></button>
            <button type="button" class="btn btn-delete" title="Delete"
            hx-include="#user-id-input"
            hx-delete="/setup/users/{id}"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-trash-can mr-2"></span></button>  
      </div>
      <div class="setup-item-list" hx-ext="path-params">
        <select id="setup-select" size="20"
          name="id"
          hx-get="/setup/users/{id}"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML">
          @zig {
            for (bros) |bro| {
                const id = bro.getT(.integer, "id") orelse continue;
                const name = bro.getT(.string, "name") orelse continue;
                const active = bro.getT(.boolean, "active") orelse continue;
                const inactive_class = if(active) "" else "setup-item-inactive";
                <option value="{{id}}" class="{{inactive_class}}">{{name}}</option>
            }
          }
        </select>
      </div>
    </div>
    <div id="UserSetupContent" class="setup-item-content">
    </div>
  </div>
</div>