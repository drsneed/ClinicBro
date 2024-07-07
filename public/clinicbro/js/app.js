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

function clearSetupSelectedItem() {
    var elements = document.getElementById("setup-select").options;
    for(var i = 0; i < elements.length; i++){
      elements[i].selected = false;
    }
}

function addSetupBlankItem() {
  clearSetupSelectedItem();
  var selectElement = document.getElementById("setup-select");
  if(selectElement.firstChild.value !== "0") {
    var opt = document.createElement('option');
    opt.value = 0;
    opt.selected = true;
    selectElement.insertBefore(opt, selectElement.firstChild);
  } else {
    selectElement.firstChild.selected = true;
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

  // Show the current tab, and add an "active" class to the button that opened the tab
  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";
} 

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