<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ClinicBro</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="/clinicbro.css">
    <!-- <script src="http://localhost:8081/webui.js"></script> -->
  </head>
  <body>
    <script>0</script>
    <main>
        <div class="lc">
            <div class="lc-header">
              <a class="brand" href="/">
                <img src="/logo.svg" alt="Home" class="lc-icon"/>
                <span>ClinicBro</span>
              </a>
            </div>
            <hr />
            <form method="post">
              <div class="info-msg"><span>Email Verification Required</span></div>
              <div class="info-msg info-msg-sm"><span>Check your email for a verification code and enter it here:</span></div>
              <div class="error-msg"><span>{{.error_message}}</span></div>
              <input type="text" name="code" maxlength="6" 
                  aria-label="code"
                  aria-required="true"
                  spellcheck="false"
                  autocomplete="code"
                  placeholder="Verification Code"
                  required=""
                  autofocus="">
              <a href="/auth/resetpassword">Re-send Email</a>
              <div class="login-submit-btn-container"><input type="submit" value="Verify Code"></div>
            </form>
        </div>
    </main>
  </body>
</html>