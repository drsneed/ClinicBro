<form action="/code" method="post">
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
  <a href="/resetpassword">Re-send Email</a>
  <div class="login-submit-btn-container"><input type="submit" value="Verify Code"></div>
</form>