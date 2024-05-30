<div class="container">
    <table id="accounts">
        <tr>
          <th>UID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Role</th>
          <th>Date Created</th>
          <th>Date Updated</th>
        </tr>
        @zig {
            if (zmpl.get("accounts")) |accounts| {
              for (accounts.array.array.items) |account| {
                  const uid = account.getT(.integer, "uid") orelse continue;
                  const name = account.getT(.string, "name") orelse continue;
                  const email = account.getT(.string, "email") orelse continue;
                  const mod = account.getT(.integer, "mod") orelse continue;
                  const iat = account.getT(.string, "iat") orelse continue;
                  const uat = account.getT(.string, "uat") orelse continue;
                  <tr>
                    <td>{{uid}}</td>
                    <td>{{name}}</td>
                    <td>{{email}}</td>
                    <td>{{mod}}</td>
                    <td>{{iat}}</td>
                    <td>{{uat}}</td>
                  </tr>
              }
            }
        }
    </table>
</div>