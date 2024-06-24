<div class="container">
    <table id="users">
        <tr>
          <th>Id</th>
          <th>Name</th>
          <th>Date Created</th>
        </tr>
        @zig {
            const users = zmpl.getT(.array, "users").?;
            for (users) |user| {
                const id = user.getT(.integer, "id") orelse continue;
                const name = user.getT(.string, "name") orelse continue;
                const date_created = user.getT(.integer, "date_created") orelse continue;
                <tr>
                  <td>{{id}}</td>
                  <td>{{name}}</td>
                  <td class="cb_date">{{date_created}}</td>
                </tr>
            }
        }
    </table>
</div>