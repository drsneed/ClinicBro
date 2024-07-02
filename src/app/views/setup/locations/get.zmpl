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
      <div class="text-field">
        <input id="location_address_1" type="text" name="address_1" maxlength="128" value="{{.address_1}}">
        <label for="address_1">Address Line 1</label>
      </div>
      <div class="text-field">
        <input id="location_address_2" type="text" name="address_2" maxlength="32" value="{{.address_2}}">
        <label for="address_2">Address Line 2</label>
      </div>
      <div class="text-field">
        <input id="location_city" type="text" name="city" maxlength="32" value="{{.city}}">
        <label for="city">City</label>
      </div>
      <div class="text-field">
        <input id="location_state" type="text" name="state" maxlength="32" value="{{.state}}">
        <label for="state">State</label>
      </div>
      <div class="text-field">
        <input id="location_zip_code" type="text" name="zip_code" maxlength="32" value="{{.zip_code}}">
        <label for="zip_code">Zip Code</label>
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