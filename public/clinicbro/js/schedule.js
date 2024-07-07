// public/clinicbro/js/util.ts
function dateAdd(date, interval, units) {
  var ret = new Date(date.valueOf());
  var checkRollover = function() {
    if (ret.getDate() != date.getDate())
      ret.setDate(0);
  };
  switch (String(interval).toLowerCase()) {
    case "year":
      ret.setFullYear(ret.getFullYear() + units);
      checkRollover();
      break;
    case "quarter":
      ret.setMonth(ret.getMonth() + 3 * units);
      checkRollover();
      break;
    case "month":
      ret.setMonth(ret.getMonth() + units);
      checkRollover();
      break;
    case "week":
      ret.setDate(ret.getDate() + 7 * units);
      break;
    case "day":
      ret.setDate(ret.getDate() + units);
      break;
    case "hour":
      ret.setTime(ret.getTime() + units * 3600000);
      break;
    case "minute":
      ret.setTime(ret.getTime() + units * 60000);
      break;
    case "second":
      ret.setTime(ret.getTime() + units * 1000);
      break;
    default:
      ret = undefined;
      break;
  }
  return ret;
}
function toIsoTimeString(d) {
  return d.toTimeString().substring(0, 8);
}

// public/clinicbro/js/schedule.ts
document.addEventListener("htmx:configRequest", function(evt) {
  if (evt.detail.elt.nodeName == "MV-DAY") {
    var from_date = new Date;
    from_date.setSeconds(0);
    from_date.setMinutes(from_date.getMinutes() < 30 ? 0 : 30);
    var to_date = dateAdd(from_date, "minute", 30);
    evt.detail.parameters["from"] = toIsoTimeString(from_date);
    evt.detail.parameters["to"] = toIsoTimeString(to_date);
  }
});
document.addEventListener("htmx:afterRequest", function(evt) {
  if (evt.detail.successful && evt.detail.elt.id == "appt-save-button" && evt.detail.target.id == "scheduler") {
    document.getElementById("cb-window").opened = false;
  }
});
