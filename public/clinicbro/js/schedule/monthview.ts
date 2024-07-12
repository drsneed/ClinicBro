import {html, css, LitElement} from 'lit';
import {monthviewStyle} from './monthview-style';
import {MonthViewAppointment} from './monthview-appt';
import {customElement, property} from 'lit/decorators.js';
import { toIsoDateString, dateAdd, months, dayHeaders, clearAllSelectedDays, dateSuffix } from '../util';
import 'lit-icon/pkg/dist-src/lit-icon.js';
import 'lit-icon/pkg/dist-src/lit-iconset.js';


@customElement("month-view")
export class MonthView extends LitElement {
  static styles = monthviewStyle();
    
  // @ts-ignore
  @property({converter(value) {return new Date(value);}, reflect: true})
  current_date: Date;

  // @ts-ignore
  @property({type: String, reflect: true})
  mode: string;

  constructor() {
    super();
    this.current_date = new Date();
    this.mode = "month";
  }


  updated(changedProperties) {
    htmx.process(this.shadowRoot);
    //console.log(changedProperties); // logs previous values
    if(changedProperties.has('current_date')) {
      
    }
  }

  private _prev(e: Event) {
    this.current_date = dateAdd(this.current_date, this.mode, -1);
    clearAllSelectedDays();
  }

  private _next(e: Event) {
    this.current_date = dateAdd(this.current_date, this.mode, 1);
    clearAllSelectedDays();
  }

  private _monthViewClicked(e) {
    this.mode = "month";
  }

  private _weekViewClicked(e) {
    this.mode = "week";
  }

  private _dayViewClicked(e) {
    this.mode = "day";
  }

  calendarTitle() {
    if(this.mode == 'month') {
      return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
    } else if(this.mode == 'day') {
      
      return months[this.current_date.getMonth()] + " " + this.current_date.getDate() + dateSuffix(this.current_date) + ", " + this.current_date.getFullYear();
    } else {
      let firstOfDaWeek = dateAdd(this.current_date, 'day', -this.current_date.getDay());
      let endOfDaWeek = dateAdd(firstOfDaWeek, 'day', 6);
      // same month, same year. simplest case
      if(firstOfDaWeek.getFullYear() == endOfDaWeek.getFullYear() && firstOfDaWeek.getMonth() == endOfDaWeek.getMonth()) {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " - " +
          endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + this.current_date.getFullYear();
      } else if(firstOfDaWeek.getFullYear() == endOfDaWeek.getFullYear()) {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " - " +
          months[endOfDaWeek.getMonth()] + " " + endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + this.current_date.getFullYear();
      } else {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " " + firstOfDaWeek.getFullYear() + " - " +
          months[endOfDaWeek.getMonth()] + " " + endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + endOfDaWeek.getFullYear();
      }
    }
    
  }


  renderCaption() {
    return html`
    <caption>
        <div class="month-header">
            <div class="header-item">
              <button type="button" @click="${this._prev}" class="btn-left"><lit-icon icon="chevron_left" iconset="iconset" style="width: 20px; height: 20px;"></lit-icon></button>
              <button type="button" @click="${this._next}" class="btn-right"><lit-icon icon="chevron_right" iconset="iconset" style="width: 20px; height: 20px;"></lit-icon></button>
            </div>
            <h2 id="month_title">${this.calendarTitle()}</h2>
            <div class="header-item scheduler-button-bar">
              <button type="button" class="btn btn-first" @click="${this._monthViewClicked}">Month</button>
              <button type="button" class="btn btn-middle" @click="${this._weekViewClicked}">Week</button>
              <button type="button" class="btn btn-last btn-pressed" @click="${this._dayViewClicked}">Day</button>
            </div>
            <lit-iconset iconset="iconset">
              <svg><defs>
                <g id="chevron_left"><path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"></path></g>
                <g id="chevron_right"><path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"></path></g>
              </defs></svg>
            </lit-iconset>
        </div>
    </caption>`;
  }

  renderMonthViewDay(today: Date, table_slot_id: string, date_of_day: Date) {
    let current_month = date_of_day.getMonth() == this.current_date.getMonth();
    let dod = toIsoDateString(date_of_day);
    return html`
    <mv-day id="${table_slot_id}" current_date="${date_of_day}" ?current_month=${current_month}
        hx-get="/scheduler/{id}?date=${dod}" hx-target="global #cb-window" hx-swap="outerHTML" 
        hx-trigger="dblclick target:#${table_slot_id}, drop target:#${table_slot_id}" hx-include="#dropped-appt-id, #dropped-client-id">
        <slot name="${dod}"></slot>
    </mv-day>`;
  }

  renderMonthViewDays() {
    var today = new Date();
    let rows = [];
    // @ts-ignore
    let firstOfDaMonth = new Date(this.current_date.getFullYear(), this.current_date.getMonth(), 1);
    let d = firstOfDaMonth.getDay();
    let i = 0;
    for (let week = 0;week < 6; week++) {
      var days = [];
      for(let day = 0; day < 7; day++) {
        let id = "d" + i;
        let thisDaysDate = dateAdd(firstOfDaMonth, "day", i - d);
        days.push(html`<td>${this.renderMonthViewDay(today, id, thisDaysDate)}</td>`);
        i++;
      }
      rows.push(html`<tr>${days}</tr>`);
    }
    return html`${rows}`;
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
    if(this.mode == "month") {
      return this.renderMonthView();
    }
    else if(this.mode == "day") {
      return this.renderDayView();
    }
    else {
      return this.renderWeekView();
    }
  }

  
  
  renderDayViewDay() {
    var today = new Date();
    let rows = [];
    let i = 0;
    var midnight = new Date(this.current_date.valueOf());
    midnight.setHours(0, 0, 0, 0);
    for (let hour = 0; hour < 24; hour++) {
        let id = "h" + i;
        let this_hour = dateAdd(midnight, "hour", i);;
        let time_hour = this_hour.getHours() % 12 || 12;
        let pm = this_hour.getHours() >= 12 ? "pm" : "am";
        rows.push(html`<tr><td class="time-display">${time_hour}:00 ${pm}</td><td><div id="${id}" class="day-view-hour-1"></div><div class="day-view-hour-2"></div></td></tr>`);
        i++;
    }
    return html`${rows}`;
  }

  renderDayView() {
    return html`
    <table class="month-table" cellspacing="0">
        <colgroup>
          <col span="1" style="width: 70px;">
          <col span="1" style="width: 95%;">
        </colgroup>
        <thead>
            <tr>
              <th colspan="2" class="row1">
                  <div class="sticky-header">
                    ${this.renderCaption()}
                    <div class="day-header">
                      ${dayHeaders[this.current_date.getDay()]}
                    </div>
                  </div>
              </th>
            </tr>
        </thead>
        <tbody hx-ext="path-params">
          ${this.renderDayViewDay()}
        </tbody>
    </table>
    
    <input id="dropped-appt-id" type="hidden" name="id" value="0" >
    <input id="dropped-client-id" type="hidden" name="client_id" value="0" >
    `;
  }

  renderSchedulerModesButtonBar() {
    return html`
      <div class="scheduler-button-bar">
        <button type="button" class="btn btn-first" @click="${this._monthViewClicked}">Month</button>
        <button type="button" class="btn btn-middle" @click="${this._weekViewClicked}">Week</button>
        <button type="button" class="btn btn-last btn-pressed" @click="${this._dayViewClicked}">Day</button>
      </div>
    `;
  }

  renderWeekView() {
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

  renderMonthView() {
    return html`
    <table class="month-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              ${this.renderCaption()}
            </th>
          </tr>
          <tr>
              <th class="row2">Sun</th>
              <th class="row2">Mon</th>
              <th class="row2">Tue</th>
              <th class="row2">Wed</th>
              <th class="row2">Thu</th>
              <th class="row2">Fri</th>
              <th class="row2">Sat</th>
          </tr>
      </thead>
      <tbody hx-ext="path-params">
        ${this.renderMonthViewDays()} 
      </tbody>
    </table>
    <input id="dropped-appt-id" type="hidden" name="id" value="0" >
    <input id="dropped-client-id" type="hidden" name="client_id" value="0" >
    `;
  }
}