<div id="UserSetupScreen" class="container">
  <div class="setup-screen">
    <div class="setup-item-menu">
      <div class="setup-button-bar">
        <button type="button" class="btnbar-btn"
          hx-get="/setup/users/0"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML"><span class="mdi mdi-plus mr-2"></span>Add New</button>
      </div>
      <div class="setup-item-list" hx-ext="path-params">
        <select id="bros" size="20"
          name="id"
          hx-get="/setup/users/{id}"
          hx-target="#UserSetupContent"
          hx-swap="outerHTML">
          @zig {
            const bros = zmpl.getT(.array, "bros").?;
            for (bros) |bro| {
                const id = bro.getT(.integer, "id") orelse continue;
                const name = bro.getT(.string, "name") orelse continue;
                <option value="{{id}}">{{name}}</option>
            }
          }
        </select>
      </div>
    </div>
    <div id="UserSetupContent" class="setup-item-content">
    </div>
  </div>
</div>

