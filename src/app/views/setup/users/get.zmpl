@zig {
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
  const id = zmpl.getT(.integer, "id").?;
}
<div id="UserSetupContent" class="setup-item-content {{inactive_class}}">
    <form id="user-form" method="post">
      <input id="user-id-input" type="hidden" name="id" value="{{.id}}">
      <div class="id-field">
        <span>ID</span>
        <code>{{.id}}</code>
        @zig {
          if(id > 0) {
              <label class="cb-label"><input type="checkbox" id="user_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>
              
          }
        }
      </div>
      <hr />
      
      <div class="text-field">
        @zig {
            if(id > 0) {
            <input id="user_name" type="text" name="name" maxlength="16"
                value="{{.name}}" required>
        }
        else {
            <input id="user_name" type="text" name="name" maxlength="16"
                value="{{.name}}" required autofocus>
        }
        }
        <label for="name">Name</label>
      </div>
      <label class="cb-label"><input type="checkbox" id="user_sees_clients" name="sees_clients" class="cbcb" value="1" {{.sees_clients_check}}>Sees Clients</label>
      <br />

      <!-- <div class="setup-item-buttons" hx-ext="path-params">
        <button type="button" class="btn btn-save"
            hx-include="#user-form, #include_inactive"
            hx-post="/setup/users"
            hx-target="#UserSetupScreen"
            hx-swap="outerHTML"><span class="mdi mdi-content-save mr-2"></span>Save</button>
            @zig { 
                if(id > 0) {
                <button type="button" class="btn btn-delete"
                    hx-include="#user-id-input"
                    hx-delete="/setup/users/{id}"
                    hx-target="#UserSetupScreen"
                    hx-swap="outerHTML"><span class="mdi mdi-trash-can mr-2"></span>Delete</button>  
            }
            }
      </div> -->
    </form>
@zig { 
    if(id > 0) {
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