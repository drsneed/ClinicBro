<select id="recent-clients-select" size="11" name="id">
    @zig {
      const clients = zmpl.getT(.array, "clients").?;
      for (clients) |client| {
          const id = client.getT(.integer, "id") orelse continue;
          const name = client.getT(.string, "name") orelse continue;
          const active = client.getT(.boolean, "active") orelse continue;
          const inactive_class = if(active) "" else "setup-item-inactive";
          <option value="{{id}}" class="{{inactive_class}}" hx-get="/clients/{{id}}"
            hx-target="#cb-window" hx-trigger="dblclick" hx-swap="outerHTML">{{name}}</option>
      }
    }
</select>