@zig {
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
  const id = zmpl.getT(.integer, "id").?;
}
<div id="ApptStatusSetupContent" class="setup-item-content {{inactive_class}}">
    <form id="appt-status-form" method="post">
      <input id="appt-status-id-input" type="hidden" name="id" value="{{.id}}">
      <div class="id-field">
        <span>ID</span>
        <code>{{.id}}</code>
        @zig {
          if(id > 0) {
              <label class="cb-label"><input type="checkbox" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>   
          }
        }
      </div>
      <hr />
      
      <div class="text-field">
        @zig {
            if(id > 0) {
            <input type="text" name="name" maxlength="50"
                value="{{.name}}" required>
        }
        else {
            <input type="text" name="name" maxlength="50"
                value="{{.name}}" required autofocus>
        }
        }
        <label for="name">Name</label>
      </div>
      <label class="cb-label ml-2"><input type="checkbox" name="show" class="cbcb" value="1" {{.show_check}}>Show</label>
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