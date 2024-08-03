<form method="post">
  <div class="info-msg"><span>Reset Password</span></div>
  <div class="error-msg pwreset-error"><span>{{.error_message}}</span></div>
  <input type="text" name="email" size="20" maxlength="255" 
      aria-label="Email"
      aria-required="true"
      spellcheck="false"
      autocomplete="email"
      placeholder="Email"
      autofocus=""
      required="">
  <div class="login-submit-btn-container"><input type="submit" value="Send Email" Title="Send email with instructions to reset password"></div>
</form>