<div class="container">
    <table id="users">
        <tr>
          <th>UID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Role</th>
          <th>Date Created</th>
          <th>Date Updated</th>
        </tr>
        @zig {
            const users = zmpl.getT(.array, "users").?;
            for (users) |user| {
                const uid = user.getT(.integer, "uid") orelse continue;
                const name = user.getT(.string, "name") orelse continue;
                const email = user.getT(.string, "email") orelse continue;
                const mod = user.getT(.integer, "mod") orelse continue;
                const iat = user.getT(.string, "iat") orelse continue;
                const uat = user.getT(.string, "uat") orelse continue;
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
    </table>
</div>
<script>
  var setupExpander = document.getElementById("SetupExpander");
  setupExpander.classList.toggle("active");
  var content = setupExpander.nextElementSibling;
  content.style.maxHeight = content.scrollHeight + "px";
  content.classList.toggle("active");
</script>