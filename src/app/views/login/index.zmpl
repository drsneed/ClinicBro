<form action="/login" method="post">
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
    <div class="login-submit-btn-container"><input type="submit" value="Log In"></div>
</form>