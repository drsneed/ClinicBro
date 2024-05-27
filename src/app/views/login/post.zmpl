<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ts~live</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="/riptide.css">
  </head>
  <body>
    <script>0</script>
    <div class="pwr-dropdown" tabindex="1">
        <i class="pwr-db2" tabindex="1"></i>
        <a class="pwr" id="pwr">
            <img src="/icon.svg" alt="Home" class="pwr-icon"/>
            <span>ts~live</span>
        </a>
        <div class="pwr-dropdown-content">
            <a href="/about"><span class="mdi mdi-information mr-2"></span><span>About</span></a>
        </div>
    </div>
    <header id="header">
        {{.page_title}}
    </header>
    <main id="main">
        <div class="container lc">
            <form action="/login" method="post">
                <div class="login-error"><span>{{.error_message}}</span></div>
                <input type="text" name="email" size="20" maxlength="255" 
                    aria-label="Email"
                    aria-required="true"
                    spellcheck="false"
                    autocomplete="email"
                    placeholder="Email"
                    required="">
                <input type="password" name="password" size="20" placeholder="Password" aria-label="Password" required="">
                <a class="fpl" href="/passwordreset">Forgot Password?</a>
                <div class="login-submit-btn-container"><input type="submit" value="Log In"></div>
            </form>
        </div>
    </main>
  </body>
</html>