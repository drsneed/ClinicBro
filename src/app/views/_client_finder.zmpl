<details class="client-card" open="">
    <summary class="client-card-header collapsible">
        <span>Patient Finder</span>
        <button type="button" class="btn-add-client" title="Add New"
            hx-get="/clients/0"
            hx-target="#cb-window"
            hx-swap="outerHTML">
            <span class="mdi mdi-account-plus mr-2"></span>
        </button>
    </summary>
    <div class="client-card-details collapsible-content">
        <div class="tab-button-bar">
            <div id="defaultOpen" class="tab-button" onclick="openClientTab(event, 'recent-clients')">
                <span style="white-space: nowrap;">Recent</span>
                <button id="refresh-recent-clients" type="button" class="tab-inner-button" hx-get="/clients?mode=recent"
                    hx-target="#recent-clients" hx-swap="innerHTML" onclick="tabRefreshClicked(event)">
                    <span class="mdi mdi-refresh"></span>
                </button>
            </div>
            <div class="tab-button" onclick="openClientTab(event, 'appt-today')">
                <span style="white-space: nowrap;">Appt Today</span>
                <button id="refresh-appt-today" type="button" class="tab-inner-button" hx-get="/clients?mode=appt-today"
                    hx-target="#appt-today" hx-swap="innerHTML" onclick="tabRefreshClicked(event)">
                    <span class="mdi mdi-refresh"></span>
                </button>
            </div>
            <div class="stretch-button" onclick="openClientTab(event, 'search-clients')">Search</div>
          </div>
        <div id="recent-clients" class="client-menu-tab">
        </div>
        <div id="appt-today" class="client-menu-tab">
        </div>
        <div id="search-clients" class="client-menu-tab">
            <form id="client-search-form">
                <span class="search-field">
                    <input name="q" type="text" class="client-search" placeholder="Search Clients..." value="">
                    <button type="button" class="btn search-field-addon" hx-get="/clients?mode=search"
                        hx-target="#search-results" hx-swap="innerHTML" hx-include="#client-search-form"><span class="mdi mdi-account-search"></span></button>
                </span>
            </form>
            <div id="search-results">
            </div>
        </div>
    </div>
</details>