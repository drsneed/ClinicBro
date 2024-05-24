<div class="container lc">
    <form action="/login" method="post">
        <input type="text" name="email" size="20" maxlength="255" 
            aria-label="Email"
            aria-required="true"
            autocorrect="off"
            spellcheck="false"
            autocapitalize="off"
            autofocus="true"
            autocomplete="email"
            placeholder="Email"
            required="">
        <input type="password" name="password" size="20" placeholder="Password" aria-label="Password" required="">
        <a class="fpl" href="/passwordreset">Forgot Password?</a>
        <div class="login-submit-btn-container"><input type="submit" value="Log In"></div>
    </form>
</div>