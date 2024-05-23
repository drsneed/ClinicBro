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
        <a class="brand" href="/">
            <img src="/icon.svg" alt="Home" />
            <span>Test Server</span>
        </a>
        @zig {
            if(zmpl.getT(.boolean, "logged_in").?) {
                <div class="usr-btn">
                    <span class="usr-btn-span">{{.user_name}}</span>
                </div>
            }
        }
        <ul>
           <li><a href="/">Home<span class="nav-arrow">&rsaquo;</span></a></li>
           <li><a href="{{.auth_link}}">{{.auth_link_text}}<span class="nav-arrow">&rsaquo;</span></a></li>
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

        
