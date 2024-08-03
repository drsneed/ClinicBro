
export const dayHeaders = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
export const months = ["January","February","March","April","May","June",
    "July","August","September","October","November","December"];

export function dateAdd(date, interval, units) {
    var ret = new Date(date.valueOf()); //don't change original date
    var checkRollover = function() { if(ret.getDate() != date.getDate()) ret.setDate(0);};
    switch(String(interval).toLowerCase()) {
      case 'year'   :  ret.setFullYear(ret.getFullYear() + units); checkRollover();  break;
      case 'quarter':  ret.setMonth(ret.getMonth() + 3*units); checkRollover();  break;
      case 'month'  :  ret.setMonth(ret.getMonth() + units); checkRollover();  break;
      case 'week'   :  ret.setDate(ret.getDate() + 7*units);  break;
      case 'day'    :  ret.setDate(ret.getDate() + units);  break;
      case 'hour'   :  ret.setTime(ret.getTime() + units*3600000);  break;
      case 'minute' :  ret.setTime(ret.getTime() + units*60000);  break;
      case 'second' :  ret.setTime(ret.getTime() + units*1000);  break;
      default       :  ret = undefined;  break;
    }
    return ret;
}

export function dateSuffix(d1) {
  let num_date_str = "" + d1.getDate();
  const ending = num_date_str.slice(-1);
  const beginning = num_date_str[0];
  let suffix = "th";
  if(num_date_str.length == 1 || beginning != "1") {
    if(ending === "1") suffix = "st";
    else if(ending === "2") suffix = "nd";
    else if(ending === "3") suffix = "rd";
  }
  return suffix;
}

export function sameDay(d1, d2) {
  return d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate();
}

export function combineDateWithTimeString(d: Date, s: string) {
  let date_str = toIsoDateString(d);
  return new Date(date_str + "T" + s);
}

export function toIsoDateString(d: Date) {
  var month = d.getMonth() + 1;
  var day = d.getDate();
  var month_str = month < 10 ? "0" + month : month;
  var day_str = day < 10 ? "0" + day: day;
  return `${d.getFullYear()}-${month_str}-${day_str}`;
  //return d.toISOString().split('T')[0];
}

export function toIsoTimeString(d: Date) {
  return d.toTimeString().substring(0, 8);
}

export function clearAllSelectedDays() {
  var schedule = document.getElementById("schedule");
  schedule.shadowRoot.querySelectorAll("mv-day").forEach(function(day) {
    day.removeAttribute("selected");
  });
  document.querySelectorAll("mv-appt").forEach(function(appt) {
    appt.removeAttribute("selected");
  });
}

export function clearAllSelectedHours() {
  var schedule = document.getElementById("schedule");
  schedule.shadowRoot.querySelectorAll("dv-half").forEach(function(half_hour) {
    half_hour.removeAttribute("selected");
  });
  document.querySelectorAll("dv-appt").forEach(function(appt) {
    appt.removeAttribute("selected");
  });
}

export function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}