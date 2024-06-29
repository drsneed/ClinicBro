<div class="container">
  <div id="user-list">
    <ul>
      @zig {
        const bros = zmpl.getT(.array, "bros").?;
        for (bros) |bro| {
            const name = bro.getT(.string, "name") orelse continue;
            <li>{{name}}</li>
        }
      }
    </ul>
  </div>
</div>