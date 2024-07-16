import {html, css, LitElement} from 'lit';
import {monthviewStyle} from './monthview-style';
import {MonthViewAppointment} from './monthview-appt';
import { classMap } from 'lit/directives/class-map.js';
import {customElement, property} from 'lit/decorators.js';
import { toIsoDateString, dateAdd, sameDay, dayHeaders, clearAllSelectedDays, dateSuffix } from '../util';
import { SchedulerBase } from './scheduler-base';


@customElement("week-view")
export class WeekView extends SchedulerBase {
    
  constructor() {
    super();
    this.mode = "week";
  }

  renderWeekViewDays() {
    var today = new Date();
    let rows = [];
    let firstOfDaWeek = dateAdd(this.current_date, 'day', -this.current_date.getDay());
    let d = firstOfDaWeek.getDay();
    let i = 0;
    var midnight = new Date(this.current_date.valueOf());
    midnight.setHours(0, 0, 0, 0);
    for (let hour = 0; hour < 24; hour++) {
      let this_hour = dateAdd(midnight, "hour", i);
      let this_hour_half = dateAdd(this_hour, "minute", 30);
      let time_hour = this_hour.getHours() % 12 || 12;
      let pm = this_hour.getHours() >= 12 ? "pm" : "am";

      let first_half_hour = "" + this_hour.getHours() + ":00";
      let to = "" + dateAdd(this_hour, 'hour', 1).getHours() + ":00";
      if(to.length == 4) {
        to = "0" + to;
      }
      if(first_half_hour.length == 4) {
        first_half_hour = "0" + first_half_hour;
      }
      let second_half_hour = first_half_hour.slice(0, 2) + ":30";
      var days = [];
      //<tr><td class="time-display">${time_hour}:00 ${pm}</td><td><div id="${id}" class="day-view-hour-1"></div><div class="day-view-hour-2"></div></td></tr>
      days.push(html`<td class="time-display">${time_hour}:00 ${pm}</td>`);
      for(let day = 0; day < 7; day++) {
        let id1 = "d" + day + "h" + i;
        let id2 = "d" + day + "h" + i + "m30";
        let thisDaysDate = dateAdd(firstOfDaWeek, "day", day);
        thisDaysDate.setHours(this_hour.getHours(), 0, 0, 0);
        let thisDaysDate2 = dateAdd(thisDaysDate, 'minute', 30);
        let this_first_half_hour = toIsoDateString(thisDaysDate) + "T" + first_half_hour;
        let this_second_half_hour = toIsoDateString(thisDaysDate) + "T" + second_half_hour;
        days.push(html`
          <td>
              <dv-half id="${id1}" current_date="${thisDaysDate.toISOString()}"
                hx-get="/scheduler/{id}?date=${toIsoDateString(thisDaysDate)}&from=${first_half_hour}&to=${second_half_hour}" hx-target="global #cb-window" hx-swap="outerHTML" 
                hx-trigger="dblclick target:#${id1}, drop target:#${id1}" hx-include="#dropped-appt-id, #dropped-client-id"><slot name="${this_first_half_hour}"></slot></dv-half>
              <dv-half id="${id2}" current_date="${thisDaysDate2.toISOString()}"
                hx-get="/scheduler/{id}?date=${toIsoDateString(thisDaysDate)}&from=${second_half_hour}&to=${to}" hx-target="global #cb-window" hx-swap="outerHTML" 
                hx-trigger="dblclick target:#${id2}, drop target:#${id2}" hx-include="#dropped-appt-id, #dropped-client-id"><slot name="${this_second_half_hour}"></slot></dv-half>
          </td>`);
      }
      rows.push(html`<tr>${days}</tr>`);
      i++;
    }
    return html`${rows}`;
  }

  private _link(date_of_day, text) {
    return html`<a hx-get="/scheduler?mode=day&date=${toIsoDateString(date_of_day)}" hx-target="global #scheduler"
       hx-swap="outerHTML" hx-push-url="true"
    class="${classMap({weekheader: true, weekheadertoday: sameDay(date_of_day, new Date())})}">${text}</a>`;
  }
  
  render() {
    let sunday = dateAdd(this.current_date, 'day', -this.current_date.getDay());
    let sundisp = "Sun " + (sunday.getMonth()+1) + "/" + sunday.getDate();
    let monday = dateAdd(sunday, 'day', 1);
    let mondisp = "Mon " + (monday.getMonth()+1) + "/" + monday.getDate();
    let tuesday = dateAdd(monday, 'day', 1);
    let tuedisp = "Tue " + (tuesday.getMonth()+1) + "/" + tuesday.getDate();
    let wednesday = dateAdd(tuesday, 'day', 1);
    let weddisp = "Wed " + (wednesday.getMonth()+1) + "/" + wednesday.getDate();
    let thursday = dateAdd(wednesday, 'day', 1);
    let thudisp = "Thu " + (thursday.getMonth()+1) + "/" + thursday.getDate();
    let friday = dateAdd(thursday, 'day', 1);
    let fridisp = "Sat " + (friday.getMonth()+1) + "/" + friday.getDate();
    let saturday = dateAdd(friday, 'day', 1);
    let satdisp = "Sun " + (saturday.getMonth()+1) + "/" + saturday.getDate();
    return html`
    <table class="month-table" cellspacing="0">
      <colgroup>
          <col span="1" style="width: 70px;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
          <col span="1" style="width: 13.95%;">
      </colgroup>
      <thead>
          <tr>
              <th colspan="8" class="row1 no-border">
                ${this.renderCaption()}
              </th>
          </tr>
          <tr>
              <th class="row2"></th>
              <th class="row2">${this._link(sunday, sundisp)}</th>
              <th class="row2">${this._link(monday, mondisp)}</th>
              <th class="row2">${this._link(tuesday, tuedisp)}</th>
              <th class="row2">${this._link(wednesday, weddisp)}</th>
              <th class="row2">${this._link(thursday, thudisp)}</th>
              <th class="row2">${this._link(friday, fridisp)}</th>
              <th class="row2">${this._link(saturday, satdisp)}</th>
          </tr>
      </thead>
      <tbody hx-ext="path-params">
        ${this.renderWeekViewDays()} 
      </tbody>
    </table>
    <input id="dropped-appt-id" type="hidden" name="id" value="0" >
    <input id="dropped-client-id" type="hidden" name="client_id" value="0" >
    `;
  }
}