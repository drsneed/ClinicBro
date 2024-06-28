<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ClinicBro</title>
    <link rel="shortcut icon" type="image/x-icon" href="/clinicbro/img/favicon.svg">
    <link rel="stylesheet" href="/clinicbro/css/app.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300..800;1,300..800&display=swap" rel="stylesheet">
    {{.header_include}}
  </head>
  <body>
    <input type="checkbox" id="nav-toggle" name="nav-toggle"/>
    <label for="nav-toggle" id="nav-toggle-label"></label>
    <nav id="nav">
        <hr />
        <a href="/" {{.main_home}}><span class="mdi mdi-home-outline mr-2"></span>Home</a>
        <hr />
        <a href="/scheduler" {{.main_schedule}}><span class="mdi mdi-calendar-account-outline mr-2"></span>Scheduler</a>
        <hr />
        <details {{.setup_expander_state}}>
            <summary id="SetupExpander2" class="collapsible" id="setup">
                <span class="mdi mdi-tune mr-2"></span>Setup
            </summary>
            <div class="collapsible-content">
                <hr />
                <a href="/setup/users" {{.setup_users}}><span class="mdi mdi-account-multiple mr-2"></span>Users</a>
                <a href="/setup/reports" {{.setup_reports}}><span class="mdi mdi-file-chart mr-2"></span>Reports</a>
                <a href="/setup/system" {{.setup_system}}><img src="/clinicbro/img/logo.svg" alt="ClinicBro" class="sys-icon"/>System</a>
            </div>
        </details>
        
        <hr />
    </nav>
    <div id="pwr-dropdown" class="pwr-dropdown" tabindex="1">
        <input type="checkbox" id="pwr-toggle" name="pwr-toggle"/>
        <label for="pwr-toggle" class="pwr" id="pwr">
            <img src="/clinicbro/img/logo.svg" alt="Home" class="pwr-icon"/>
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
                <a href="/auth/signout"><span class="mdi mdi-logout mr-2"></span>Sign Out</a>
            </div>
        </div>
    </header>
    <main id="main">
        {{zmpl.content}}
    </main>
    
    <script src="/clinicbro/js/app.js"></script>
  </body>
</html>