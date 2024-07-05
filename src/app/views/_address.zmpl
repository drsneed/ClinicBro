@args address_1: *ZmplValue, address_2: *ZmplValue, city: *ZmplValue, state: *ZmplValue, zip_code: *ZmplValue


<div class="groupbox">
    <label>Address</label>
    <input id="address-line-1" type="text" name="address_1" maxlength="128" value="{{address_1}}" placeholder="Address Line 1">
    <input id="address-line-2" type="text" name="address_2" maxlength="32" value="{{address_2}}" placeholder="Address Line 2">
    <span>
        <input id="address-city" class="address-city" type="text" name="city" maxlength="32" value="{{city}}" placeholder="City">
        <select id="address-state" name="state" value="{{state}}">
            @zig {
                const state_options = [_][]const u8 {
                    "",
                    "AL",
                    "AK",
                    "AR",
                    "AZ",
                    "CA",
                    "CO",
                    "CT",
                    "DC",
                    "DE",
                    "FL",
                    "GA",
                    "HI",
                    "IA",
                    "ID",
                    "IL",
                    "IN",
                    "KS",
                    "KY",
                    "LA",
                    "MA",
                    "MD",
                    "ME",
                    "MI",
                    "MN",
                    "MO",
                    "MS",
                    "MT",
                    "NC",
                    "NE",
                    "NH",
                    "NJ",
                    "NM",
                    "NV",
                    "NY",
                    "ND",
                    "OH",
                    "OK",
                    "OR",
                    "PA",
                    "RI",
                    "SC",
                    "SD",
                    "TN",
                    "TX",
                    "UT",
                    "VT",
                    "VA",
                    "WA",
                    "WI",
                    "WV",
                    "WY",
                };
                const selected_state = state.string.value;
                for(state_options)|state_option| {
                    const selected = if(std.mem.eql(u8, selected_state, state_option)) "selected" else "";
                    <option value="{{state_option}}" {{selected}}>{{state_option}}</option>
                }
            }
<!--             
            <option disabled selected value></option>
            <option value="AL">AL</option>
            <option value="AK">AK</option>
            <option value="AR">AR</option>
            <option value="AZ">AZ</option>
            <option value="CA">CA</option>
            <option value="CO">CO</option>
            <option value="CT">CT</option>
            <option value="DC">DC</option>
            <option value="DE">DE</option>
            <option value="FL">FL</option>
            <option value="GA">GA</option>
            <option value="HI">HI</option>
            <option value="IA">IA</option>
            <option value="ID">ID</option>
            <option value="IL">IL</option>
            <option value="IN">IN</option>
            <option value="KS">KS</option>
            <option value="KY">KY</option>
            <option value="LA">LA</option>
            <option value="MA">MA</option>
            <option value="MD">MD</option>
            <option value="ME">ME</option>
            <option value="MI">MI</option>
            <option value="MN">MN</option>
            <option value="MO">MO</option>
            <option value="MS">MS</option>
            <option value="MT">MT</option>
            <option value="NC">NC</option>
            <option value="NE">NE</option>
            <option value="NH">NH</option>
            <option value="NJ">NJ</option>
            <option value="NM">NM</option>
            <option value="NV">NV</option>
            <option value="NY">NY</option>
            <option value="ND">ND</option>
            <option value="OH">OH</option>
            <option value="OK">OK</option>
            <option value="OR">OR</option>
            <option value="PA">PA</option>
            <option value="RI">RI</option>
            <option value="SC">SC</option>
            <option value="SD">SD</option>
            <option value="TN">TN</option>
            <option value="TX">TX</option>
            <option value="UT">UT</option>
            <option value="VT">VT</option>
            <option value="VA">VA</option>
            <option value="WA">WA</option>
            <option value="WI">WI</option>
            <option value="WV">WV</option>
            <option value="WY">WY</option> -->
        </select>
        <input id="address-zip-code" class="address-zip-code" type="text" name="zip_code" maxlength="32" value="{{zip_code}}" placeholder="Zip Code">
    </span>
    
  </div>