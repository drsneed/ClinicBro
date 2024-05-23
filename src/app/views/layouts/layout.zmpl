<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Test Server</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.svg">
    <link rel="stylesheet" href="/layout.css">
</head>

<body>
    <input type="checkbox" id="nav-toggle" name="nav-toggle"/>
    <label for="nav-toggle" id="nav-toggle-label"></label>
    <nav id="nav" aria-hidden="false">
        <div class="no-padding">
            <a class="brand" href="/">
                <img src="/icon.svg" alt="Home" />
                <span>Test Server</span>
            </a>
        </div>
        @zig { 
            if(zmpl.getT(.boolean, "logged_in").?) {
            <div class="dropdown" tabindex="1">
                <i class="db2" tabindex="1"></i>
                <a class="dropbtn">{{.user_name}}</a>
                <div class="dropdown-content">
                    <a href="/">Account Settings<span class="nav-arrow">&rsaquo;</span></a>
                    <a href="/logout">Log Out<span class="nav-arrow">&rsaquo;</span></a>
                </div>
            </div>
            }
        }
        <ul>
           <li><a href="/">Home<span class="nav-arrow">&rsaquo;</span></a></li>
           @zig { 
            if(!zmpl.getT(.boolean, "logged_in").?) {
            <li><a href="/login">Log In<span class="nav-arrow">&rsaquo;</span></a></li>
                }
            }
           <li class="nav-category">0.0.1</li>
        </ul>
    </nav>
    <header>
        <h1 id="header-text" tabindex="-1">{{.page_title}}</h1>
    </header>
    <main id="content-body">
        {{zmpl.content}}
    </main>
</body>
</html>

        
