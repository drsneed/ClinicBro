<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ClinicBro</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <link rel="stylesheet" href="/clinicbro.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <!-- <script src="http://localhost:8081/webui.js"></script> -->
  </head>
  <body>
    <input type="checkbox" id="nav-toggle" name="nav-toggle"/>
    <label for="nav-toggle" id="nav-toggle-label"></label>
    <nav id="nav">
        <hr />
        <a href="/"><span class="mdi mdi-home-outline mr-2"></span>Home</a>
        <hr />
        <a href="/reports"><span class="mdi mdi-file-chart mr-2"></span>Reports</a>
        <hr />
        <button type="button" id="SetupExpander" class="collapsible"><span class="mdi mdi-tune mr-2"></span>Setup</a></button>
        <div class="collapsible-content">
            <a href="/setup/users"><span class="mdi mdi-account-multiple mr-2"></span>Users</a>
            <a href="/setup/system"><img src="/logo.svg" alt="ClinicBro" class="sys-icon mr-2"/>System</a>
        </div>
        <hr />
    </nav>
    <div id="pwr-dropdown" class="pwr-dropdown" tabindex="1">
        <input type="checkbox" id="pwr-toggle" name="pwr-toggle"/>
        <label for="pwr-toggle" class="pwr" id="pwr">
            <img src="/logo.svg" alt="Home" class="pwr-icon"/>
            ClinicBro
        </label>
        <div class="pwr-dropdown-content">
            <a href="/about"><span class="mdi mdi-information-outline mr-2"></span>About</a>
        </div>
    </div>
    <header id="header">
        {{.page_title}}
        <div class="acct-dropdown" tabindex="2">
            <input type="checkbox" id="acct-toggle" name="acct-toggle"/>
            <label for="acct-toggle" class="acct">
                <span class="mdi mdi-account-circle-outline mr-2 acct-icon"></span>
                {{.user_name}}
            </label>
            <div class="acct-dropdown-content">
                <a href="/signout"><span class="mdi mdi-logout mr-2"></span>Sign Out</a>
            </div>
        </div>
    </header>
    <main id="main">
        {{zmpl.content}}
    </main>
    <script src="/clinicbro.js"></script>
  </body>
</html>