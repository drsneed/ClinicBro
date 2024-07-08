<div id="recent-clients-listbox">
  <ul>
    @zig {
      const clients = zmpl.getT(.array, "clients").?;
      for (clients) |client| {
          const id = client.getT(.integer, "id") orelse continue;
          const name = client.getT(.string, "name") orelse continue;
          const active = client.getT(.boolean, "active") orelse continue;
          const selected = client.getT(.string, "selected") orelse continue;
          const inactive_class = if(active) "" else "setup-item-inactive";
          <li class="client-option {{inactive_class}} {{selected}}" hx-get="/clients/{{id}}"
            draggable="true" ondragstart="clientDragStart(event)" data-client-id="{{id}}"
            hx-target="#cb-window" hx-trigger="dblclick" hx-swap="outerHTML" onclick="clientSelected(event)">
              <span class="mdi mdi-account mr-2"></span>{{name}}</li>
      }
    }
  </ul>
</div>