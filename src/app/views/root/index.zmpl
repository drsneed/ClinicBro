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
        <ul>
           <li><a href="#">Home<span class="nav-arrow">&rsaquo;</span></a></li>
           <li><a href="#">Maps<span class="nav-arrow">&rsaquo;</span></a></li>
           <li><a href="#">Sign In<span class="nav-arrow">&rsaquo;</span></a></li>
           <li class="nav-category">0.0.1</li>
        </ul>
    </nav>
    <header>
        <h1 id="header-text" tabindex="-1">Home</h1>
    </header>
    <div id="content-body">
        @partial root/content(message: .welcome_message)
    </div>    
</body>
</html>
