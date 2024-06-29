

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
  return d.toISOString().split('T')[0];
}

export function toIsoTimeString(d: Date) {
  return d.toTimeString().substring(0, 8);
}

export function clearAllSelectedDays() {
  var schedule = document.getElementById("schedule");
  schedule.shadowRoot.querySelectorAll("mv-day").forEach(function(day) {
    day.removeAttribute("selected");
  });
  schedule.shadowRoot.querySelectorAll("mv-appt").forEach(function(appt) {
    appt.removeAttribute("selected");
  });
}