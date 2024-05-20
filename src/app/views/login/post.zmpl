<div class="container">
    <form action="/login" method="post">
        <div class="login-error"><span>{{.error_message}}</span></div>
        <input type="text" name="email" size="20" 
            aria-label="Email"
            aria-required="true"
            autocorrect="off"
            spellcheck="false"
            autocapitalize="off"
            autofocus="true"
            autocomplete="email"
            placeholder="Email"
            required="">
        <br>
        <input type="password" name="password" size="20" placeholder="Password" aria-label="Password" required="">
        <br>
        <a class="fpl" href="/passwordreset">Forgot Password?</a>
        <br>
        <div class="login-btn-container"><input class="login-btn" type="submit" value="Log In"></div>
    </form>
</div>