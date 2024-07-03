<details class="client-card">
    <summary class="client-card-header collapsible">
        <span>Clients</span>
        <button type="button" class="btn-add-client" title="Add New">
            <span class="mdi mdi-account-plus mr-2"></span>
        </button>
    </summary>
    <div class="client-card-details collapsible-content">
        <div class="tab-button-bar">
            <button id="defaultOpen" class="tab-button" onclick="openClientTab(event, 'client-finder')">Search</button>
            <button class="tab-button" onclick="openClientTab(event, 'client-recent')">Recent</button>
            <button class="tab-button last-tab-button" onclick="openClientTab(event, 'client-appt')">Appt Today</button>
          </div>
        <div id="client-finder" class="client-menu-tab">
            <span class="search-field">
                <input type="text" class="client-search" placeholder="Search Clients..." value="">
                <button type="button" class="btn search-field-addon"><span class="mdi mdi-account-search"></span></button>
            </span>
        </div>
        <div id="client-recent" class="client-menu-tab">
            <h2>Recent Clients</h2>
            <ul>
                <li>Smith, Charlie</li>
                <li>Felton, Edward</li>
                <li>Green, Samantha</li>
            </ul>
        </div>
        <div id="client-appt" class="client-menu-tab">
            <h2>Appt Today</h2>
            <ul>
                <li>Beard, Timothy</li>
                <li>Juarez, Guillermo</li>
                <li>McNutt, Brandon</li>
                <li>Thomas, Aaron</li>
            </ul>
        </div>
    </div>
</details>