document.addEventListener("DOMContentLoaded", function(event) {
    // document.querySelectorAll('.cb_date').forEach(function(date_td) {
    //     var intDate = parseInt(date_td.innerHTML) / 1000;
    //     var dt = new Date(intDate);
    //     date_td.innerHTML = dt.toLocaleString();
    // });
  });

function clearSetupSelectedItem() {
    var elements = document.getElementById("setup-select").options;
    for(var i = 0; i < elements.length; i++){
      elements[i].selected = false;
    }
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