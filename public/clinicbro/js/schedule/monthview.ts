import {html, css, LitElement} from 'lit';
import {monthviewStyle} from './monthview-style';
import {MonthViewAppointment} from './monthview-appt';
import {customElement, property} from 'lit/decorators.js';
import { toIsoDateString, dateAdd, months, dayHeaders, clearAllSelectedDays, toIsoTimeString } from '../util';
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

  calendarTitle() {
    if(this.mode == 'month') {
      return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
    } else if(this.mode == 'day') {
      return this.current_date.toLocaleDateString();
    } else {
      return 'Unknown Mode';
    }
    
  }

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

  renderCaption() {
    return html`
    <caption>
        <div class="month-header">
            <button type="button" @click="${this._prev}" class="btn-left"><lit-icon icon="chevron_left" iconset="iconset"></lit-icon></button>
            <h2 id="month_title">${this.calendarTitle()}</h2>
            <button type="button" @click="${this._next}" class="btn-right"><lit-icon icon="chevron_right" iconset="iconset"></lit-icon></button>
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
  
  render() {
    if(this.mode == "month") {
      return this.renderMonthView();
    }
    else if(this.mode == "day") {
      return this.renderDayView();
    }
    else {
      return html`<p>Invalid Scheduler Mode: ${this.mode}</p>`;
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
        let this_hour = dateAdd(midnight, "hour", i);
        rows.push(html`<tr><td><div id="${id}" class="day-view-hour">${toIsoTimeString(this_hour)}</div></td></tr>`);
        i++;
    }
    return html`${rows}`;
  }

  renderDayView() {
    return html`
    ${this.renderSchedulerModesButtonBar()}
    <table class="month-table" cellspacing="0">
      ${this.renderCaption()}
      <thead>
          <tr>
              <th>${dayHeaders[this.current_date.getDay()]}</th>
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
        <button type="button" class="btn btn-last" @click="${this._dayViewClicked}">Day</button>
      </div>
    `;
  }

  renderMonthView() {
    return html`
    ${this.renderSchedulerModesButtonBar()}
    <table class="month-table" cellspacing="0">
      ${this.renderCaption()}
      <thead>
          <tr>
              <th>Sun</th>
              <th>Mon</th>
              <th>Tue</th>
              <th>Wed</th>
              <th>Thu</th>
              <th>Fri</th>
              <th>Sat</th>
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