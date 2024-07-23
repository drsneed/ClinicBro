document.addEventListener("DOMContentLoaded", function(event) {
    // document.querySelectorAll('.cb_date').forEach(function(date_td) {
    //     var intDate = parseInt(date_td.innerHTML) / 1000;
    //     var dt = new Date(intDate);
    //     date_td.innerHTML = dt.toLocaleString();
    // });
    document.getElementById("defaultOpen").click();
  });


function clientDragStart(e) {
    e.dataTransfer.setData("client-id", e.target.dataset.clientId);
}

function tabRefreshClicked(e) {
  console.log("Refresh button " + e.currentTarget.id + " clicked");
}

function clientSelected(evt) {
  var i;
  // Get all elements with class="client-option" and remove the class "active"
  clientListItems = document.getElementsByClassName("client-option");
  for (i = 0; i < clientListItems.length; i++) {
    clientListItems[i].className = clientListItems[i].className.replace(" active", "");
  }
  // add an "active" class to the selected list item
  evt.currentTarget.className += " active";
}
function setupItemSelected(evt) {
  var i;
  // Get all elements with class="client-option" and remove the class "active"
  setupListItems = document.getElementsByClassName("setup-option");
  for (i = 0; i < setupListItems.length; i++) {
    setupListItems[i].className = setupListItems[i].className.replace(" selected", "");
  }
  // add an "active" class to the selected list item
  evt.currentTarget.className += " selected";
}
function clearSetupSelectedItem() {
  setupListItems = document.getElementsByClassName("setup-option");
  for (i = 0; i < setupListItems.length; i++) {
    setupListItems[i].className = setupListItems[i].className.replace(" selected", "");
  }
}

function addSetupBlankItem() {
  clearSetupSelectedItem();
  var setupListContainer = document.querySelector("#setup-list-container");
  if(setupListContainer.firstElementChild.dataset.id !== "0") {
    var listItem = document.createElement('li');
    listItem.setAttribute('data-id', '0');
    listItem.className = "setup-option selected";
    listItem.setAttribute('hx-get', '/setup/appointment-types/0');
    listItem.setAttribute('hx-trigger', 'click');
    listItem.setAttribute('hx-swap', 'outerHTML');
    listItem.setAttribute('hx-target', '#SetupContent');
    listItem.setAttribute('onclick', 'setupItemSelected(event)');
    listItem.innerHTML = "&nbsp;";
    setupListContainer.insertBefore(listItem, setupListContainer.firstChild);
    htmx.process(listItem);
  } else {
    setupListContainer.firstElementChild.classList.add("selected");
  }
}

function openClientTab(evt, tabName) {
  // Declare all variables
  var i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabcontent = document.getElementsByClassName("client-menu-tab");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tablinks = document.getElementsByClassName("tab-button");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  tablinks = document.getElementsByClassName("stretch-button");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the button that opened the tab
  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";

  var tab = document.getElementById(tabName);
  var divChild = tab.childNodes[0];
  if(!divChild.hasChildNodes()) {

    if(!initializedTabs.includes(tabName)) {
      initializedTabs.push(tabName);
      var innerButton = evt.currentTarget.querySelector(".tab-inner-button");
      if(innerButton) {
        innerButton.click();
      }

    }

  }
}

var initializedTabs = [];

// document.addEventListener('htmx:afterRequest', function(evt) {
//     if(evt.detail.xhr.status == 404){
//         /* Notify the user of a 404 Not Found response */
//         return alert("Error: Could Not Find Resource");
//     } 
//     if (evt.detail.successful != true) {
//         /* Notify of an unexpected error, & print error to console */
//         alert("Unexpected Error");
//         return console.error(evt);
//     }
//     if (evt.detail.target.id == 'info-div') {
//         /* Execute code on the target of the HTMX request, which will
//         be either the hx-target attribute if set, or the triggering 
//         element itself if not set. */
//         let infoDiv = document.getElementById('info-div');
//         infoDiv.style.backgroundColor = '#000000';  // black background
//         infoDiv.style.color = '#FFFFFF';  // white text
//     }
// });