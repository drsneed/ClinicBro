@zig {
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
  const id = zmpl.getT(.integer, "id").?;
  const autofocus = if(id == 0) "autofocus" else "";
}
<div id="SetupContent" class="setup-item-content {{inactive_class}}">
    <form id="appt-type-form" method="post">
      <input id="appt-type-id-input" type="hidden" name="id" value="{{.id}}">
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
        <input type="text" name="name" maxlength="50" value="{{.name}}" required {{autofocus}}>
        <label for="name">Name</label>
      </div>
      <div class="text-field">
        <input type="text" name="description" maxlength="256" value="{{.description}}">
        <label for="description">Description</label>
      </div>
      <div class="text-field">
        <input type="color" name="color" value="{{.color}}">
        <label for="color">Color</label>
      </div>
      
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