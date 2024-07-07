import {dateAdd, toIsoTimeString } from './util';
document.addEventListener('htmx:configRequest', function(evt) {
  if(evt.detail.elt.nodeName == "MV-DAY") {
    var from_date = new Date();
    from_date.setSeconds(0);
    from_date.setMinutes(from_date.getMinutes() < 30 ? 0 : 30);
    var to_date = dateAdd(from_date, 'minute', 30);
    evt.detail.parameters['from'] = toIsoTimeString(from_date);
    evt.detail.parameters['to'] = toIsoTimeString(to_date);
  }
});

document.addEventListener('htmx:afterRequest', function(evt) {
  if(evt.detail.successful && evt.detail.elt.id == "appt-save-button" && evt.detail.target.id == "scheduler") {
    document.getElementById("cb-window").opened = false;
  }
});