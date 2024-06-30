@zig {
  if(zmpl.getT(.integer, "id")) |id| {
    const name = zmpl.getT(.string, "name").?;
    <div id="UserSetupContent" class="setup-item-content">
      <form id="user-form" method="post">
        <input type="hidden" name="id" value="{{id}}">
        <div>
          <span>ID</span>
          <code>{{id}}</code>
        </div>
        <div class="text-field">
          <input id="user_name" type="text" name="name" maxlength="16"
              value="{{name}}" required>
          <label for="name">Name</label>
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
  else {
    <div id="UserSetupScreen" class="container">
      <div class="setup-screen">
        <div class="setup-item-menu">
          <div class="setup-button-bar">
            <button type="button" class="btn tool-btn"><span class="mdi mdi-plus"></span></button>
            <button type="button" class="btn tool-btn"
              hx-include="#user-form"
              hx-post="/setup/users"
              hx-target="#UserSetupScreen"
              hx-swap="outerHTML"><span class="mdi mdi-content-save"></span></button>
            <button type="button" class="btn tool-btn"><span class="mdi mdi-trash-can"></span></button>
          </div>
          <div class="setup-item-list">
            <select id="bros" size="20"
              name="id"
              hx-get="/setup/users"
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
  }
}

