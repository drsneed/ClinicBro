@zig {
  const active = zmpl.getT(.boolean, "active") orelse true;
  const inactive_class = if(active) "" else "setup-item-inactive";
  const id = zmpl.getT(.integer, "id").?;
}
<div id="LocationSetupContent" class="setup-item-content {{inactive_class}}">
    <form id="location-form" method="post">
      <input id="location-id-input" type="hidden" name="id" value="{{.id}}">
      <div class="id-field">
        <span>ID</span>
        <code>{{.id}}</code>
        @zig {
          if(id > 0) {
              <label class="cb-label"><input type="checkbox" id="location_active" name="active" class="cbcb" value="1" {{.active_check}}>Active</label>   
          }
        }
      </div>
      <hr />
      
      <div class="text-field">
        @zig {
            if(id > 0) {
            <input id="location_name" type="text" name="name" maxlength="16"
                value="{{.name}}" required>
        }
        else {
            <input id="location_name" type="text" name="name" maxlength="50"
                value="{{.name}}" required autofocus>
        }
        }
        <label for="name">Name</label>
      </div>
      <div class="text-field">
        <input id="location_phone" type="text" name="phone" maxlength="15" value="{{.phone}}">
        <label for="phone">Phone</label>
      </div>
      @partial address(address_1: .address_1, address_2: .address_2, city: .city, state: .state, zip_code: .zip_code)
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