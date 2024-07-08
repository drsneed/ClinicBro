<details class="client-card" open="">
    <summary class="client-card-header collapsible">
        <span>Clients</span>
        <button type="button" class="btn-add-client" title="Add New"
            hx-get="/clients/0"
            hx-target="#cb-window"
            hx-swap="outerHTML">
            <span class="mdi mdi-account-plus mr-2"></span>
        </button>
    </summary>
    <div class="client-card-details collapsible-content">
        <div class="tab-button-bar">
            <button id="defaultOpen" class="tab-button" hx-get="/clients" hx-target="#recent-clients" hx-swap="innerHTML"
                onclick="openClientTab(event, 'recent-clients')">Recent</button>
            <button class="tab-button" onclick="openClientTab(event, 'client-appt')"><span style="white-space: nowrap;">Appt Today</span></button>
            <button class="tab-button stretch-button" onclick="openClientTab(event, 'client-finder')">Search</button>
          </div>
        <div id="recent-clients" class="client-menu-tab">
            
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
        <div id="client-finder" class="client-menu-tab">
            <span class="search-field">
                <input type="text" class="client-search" placeholder="Search Clients..." value="">
                <button type="button" class="btn search-field-addon"><span class="mdi mdi-account-search"></span></button>
            </span>
        </div>
    </div>
</details>