<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ts~live</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="/dsx.css">
    <!-- <script src="http://localhost:8081/webui.js"></script> -->
  </head>
  <body>
    <script>0</script>
    <main>
        <div class="lc">
            <div class="lc-header">
              <a class="brand" href="/">
                <img src="/icon.svg" alt="Home" class="lc-icon"/>
                <span>Clinic Bro</span>
              </a>
            </div>
            <hr />
            <form method="post">
              <input name="return_url" type="hidden" value="{{.return_url}}">
              {{zmpl.content}}
              <input type="text" name="email" size="20" maxlength="255" 
                  aria-label="Email"
                  aria-required="true"
                  spellcheck="false"
                  autocomplete="email"
                  placeholder="Email"
                  autofocus=""
                  required="">
              <input type="password" name="password" size="20" placeholder="Password" aria-label="Password" required="">
              <a href="/resetpassword">Forgot Password?</a>
              <div class="login-submit-btn-container"><input type="submit" value="Sign In"></div>
          </form>
        </div>
    </main>
  </body>
</html>