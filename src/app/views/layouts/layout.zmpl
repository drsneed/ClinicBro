<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>TS LIVE</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <!-- https://pictogrammers.com/library/mdi/ -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="/riptide.css">
  </head>
  <body>
    <input type="checkbox" id="nav-toggle" name="nav-toggle"/>
    <label for="nav-toggle" id="nav-toggle-label"></label>
    <nav id="nav">
      <ul>
        <li class="nav-category">Main Menu</li>
        <li><a href="/"><span class="mdi mdi-home-outline mr-2"></span><span>Home</span></a></li>
        <li><a href="/about"><span class="mdi mdi-information-outline mr-2"></span><span>About</span></a></li>
        <li class="nav-category">0.0.1</li>
     </ul>
    </nav>
    <header id="header">
        <div class="pwr-dropdown" tabindex="1">
            <i class="pwr-db2" tabindex="1"></i>
            <a class="pwr" id="pwr">
                <img src="/icon.svg" alt="Home" class="pwr-icon"/>
            </a>
            <div class="pwr-dropdown-content">
                <a href="/configuration"><span class="mdi mdi-tune mr-2"></span></span><span>Configuration</span></a>
            </div>
        </div>
        @zig { 
            if(zmpl.getT(.boolean, "logged_in").?) {
                <div class="acct-dropdown" tabindex="2">
                    <i class="acct-db2" tabindex="2"></i>
                    <a class="acct">
                        <span class="mdi mdi-account-circle-outline mr-2"></span>
                        <span>{{.user_name}}</span>
                    </a>
                    <div class="acct-dropdown-content">
                        <a href="/account"><span class="mdi mdi-cog mr-2"></span><span>Account Settings</span></a>
                        <a href="/logout"><span class="mdi mdi-logout mr-2"></span><span>Log Out</span></a>
                    </div>
                </div>
            }
            else if(zmpl.getT(.boolean, "hide_login_btn")) |hide_login_btn| {
                _ = hide_login_btn;
                

            } else {
                <div class="acct-dropdown" tabindex="2">
                    <i class="acct-db2" tabindex="2"></i>
                    <a class="acct">
                        <span class="mdi mdi-login mr-2"></span>
                        <span>Log In</span>
                    </a>
                    <div class="acct-dropdown-content" style="width: 400px;">
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
                </div>
                <!-- <a href="/login" class="login-btn">Log In</a> -->
            }
        }
    
        {{.page_title}}
    </header>
    <main id="main">
        {{zmpl.content}}
    </main>
  </body>
</html>