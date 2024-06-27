<div class="container">
    <table id="users">
        <tr>
          <th>Id</th>
          <th>Name</th>
          <th>Date Created</th>
        </tr>
        @zig {
            const bros = zmpl.getT(.array, "bros").?;
            for (bros) |bro| {
                const id = bro.getT(.integer, "id") orelse continue;
                const name = bro.getT(.string, "name") orelse continue;
                const date_created = bro.getT(.integer, "date_created") orelse continue;
                <tr>
                  <td>{{id}}</td>
                  <td>{{name}}</td>
                  <td class="cb_date">{{date_created}}</td>
                </tr>
            }
        }
    </table>
</div>