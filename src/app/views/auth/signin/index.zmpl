<form method="post">
    <input name="return_url" type="hidden" value="{{.return_url}}">
    <div class="text-field">
      <input type="text" name="name" size="20" maxlength="255" 
      aria-label="Name"
      aria-required="true"
      spellcheck="false"
      autocomplete="Name"
      required>
      <label for="name">Name</label>
    </div>
    <div class="text-field">
      <input type="password" name="password" size="20" aria-label="Password" required>
      <label>Password</label>
    </div>
    <a href="/resetpassword">Forgot Password?</a>
    <div class="login-submit-btn-container"><input type="submit" value="Sign In"></div>
</form>