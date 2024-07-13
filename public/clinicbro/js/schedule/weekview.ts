import {html, css, LitElement} from 'lit';
import {monthviewStyle} from './monthview-style';
import {MonthViewAppointment} from './monthview-appt';
import { classMap } from 'lit/directives/class-map.js';
import {customElement, property} from 'lit/decorators.js';
import { toIsoDateString, dateAdd, months, dayHeaders, clearAllSelectedDays, dateSuffix } from '../util';
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
        let time_hour = this_hour.getHours() % 12 || 12;
        let pm = this_hour.getHours() >= 12 ? "pm" : "am";
        var days = [];
        //<tr><td class="time-display">${time_hour}:00 ${pm}</td><td><div id="${id}" class="day-view-hour-1"></div><div class="day-view-hour-2"></div></td></tr>
        days.push(html`<td class="time-display">${time_hour}:00 ${pm}</td>`);
        for(let day = 0; day < 7; day++) {
          let id = "d" + day + "h" + hour;
          let thisDaysDate = dateAdd(firstOfDaWeek, "day", d);
          days.push(html`<td><div id="${id}" class="day-view-hour-1"></div><div class="day-view-hour-2"></div></td>`);
        }
        rows.push(html`<tr>${days}</tr>`);
        i++;
    }
    return html`${rows}`;
  }
  
  render() {
    let sunday = dateAdd(this.current_date, 'day', -this.current_date.getDay());
    let sundisp = "" + (sunday.getMonth()+1) + "/" + sunday.getDate();
    let monday = dateAdd(sunday, 'day', 1);
    let mondisp = "" + (monday.getMonth()+1) + "/" + monday.getDate();
    let tuesday = dateAdd(monday, 'day', 1);
    let tuedisp = "" + (tuesday.getMonth()+1) + "/" + tuesday.getDate();
    let wednesday = dateAdd(tuesday, 'day', 1);
    let weddisp = "" + (wednesday.getMonth()+1) + "/" + wednesday.getDate();
    let thursday = dateAdd(wednesday, 'day', 1);
    let thudisp = "" + (thursday.getMonth()+1) + "/" + thursday.getDate();
    let friday = dateAdd(thursday, 'day', 1);
    let fridisp = "" + (friday.getMonth()+1) + "/" + friday.getDate();
    let saturday = dateAdd(friday, 'day', 1);
    let satdisp = "" + (saturday.getMonth()+1) + "/" + saturday.getDate();
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
              <th class="row2">Sun ${sundisp}</th>
              <th class="row2">Mon ${mondisp}</th>
              <th class="row2">Tue ${tuedisp}</th>
              <th class="row2">Wed ${weddisp}</th>
              <th class="row2">Thu ${thudisp}</th>
              <th class="row2">Fri ${fridisp}</th>
              <th class="row2">Sat ${satdisp}</th>
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