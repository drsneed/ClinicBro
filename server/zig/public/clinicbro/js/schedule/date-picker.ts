import { html, css, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { dateAdd, months, toIsoDateString, sameDay } from '../util';
import { classMap } from 'lit/directives/class-map.js';
import {Task} from '@lit/task';

class DateList{
  dates: [string];
}

@customElement("date-picker")
export class DatePicker extends LitElement {
  static styles = css`
  .day-picker-table {
    background: var(--container-bg);
    table-layout: fixed;
    border-collapse: separate;
    border-spacing: 0;
    padding: 0px !important;
    margin: 8px 0px;
    width: 100%;
    color: var(--table-fg);
  }

  .day-picker-table td, .day-picker-table th {
    /* border: 1px solid var(--input-border); */
    border: none;
    box-shadow: none;
    width: auto !important;
    text-align: center;
    padding: 0;
    margin: 0;
  }

  .day-picker-table thead {
    text-align: center;
  }

  .day-picker-table td {
    background-color: var(--container-bg);
    vertical-align: top;
    overflow: hidden;
  }

  .day-picker-table tr {
    white-space: nowrap;
  }

  .day-picker-nav {
    display: block;
    text-align: center;
    margin-top: -10px;
  }


  .day-picker-nav h3 {
    display: inline-block;
    margin: 4px 8px;
  }

  .header-item {
    width: 150px;
    text-align: left;
  }

  .float-right {
    float: right;
  }

  .btn {
    display: inline-block;
    padding: 2px 8px;
    height: 25px;
    transition: none;
    cursor: pointer;
  }
  .scheduler-button-bar button {
    margin: 0px;
    height: 32px;
    padding: 4px 8px;
    cursor: pointer;
  }
  .scheduler-button-bar {
    margin-bottom: 4px;
  }

  caption {
    width: 100%;
  }

  .day-picker-header {
    display: flex;
    background-color: var(--date-picker-header-bg);
    text-align: center;
    margin: 0;
  }
  
  .day-picker-header h2 {
    color: var(--fg);
    padding: 0;
    margin: 4px auto;
    font-size: 14px;
  }
  .num {
    font-size: 14px;
    padding: 4px;
    cursor: pointer;
    border: none;
    margin: 0;
    background-color: transparent;
  }
  .num:link, .num:visited {
      color: var(--link);
      text-decoration: none;
  }
  .num:hover {
      color: var(--fg);
  }
  .today {
    color: var(--calendar-today-fg);
    
  }
  .current-month, .other-month {
    margin: 0;
    padding: 4px;
  }

  .has_appt {
    font-weight: bolder;
    /* text-shadow: 1px 1px 1px black; */
  }
  
  .current-month {
       //color: var(--calendar-this-month-bg) !important;
  }
  .other-month {
    color: var(--calendar-other-month-fg);
  }`;

  //@ts-ignore
  @property({reflect: true,
    converter: {
      fromAttribute: (value, type) => {
        return new Date(value.replace(/-/g, '\/'));
      },
      toAttribute: (value, type) => {
        return toIsoDateString(value);
      }
    }})
  current_date: Date;

  appt_dates: [string];

  constructor() {
    super();
    this.current_date = new Date();
    this.appt_dates = [''];
  }

  renderMonthViewDay(current_date: Date, table_slot_id: string, date_of_day: Date) {
    
    let current_month = date_of_day.getMonth() == current_date.getMonth() ? "current-month" : "other-month";
    let dod = toIsoDateString(date_of_day);
    let has_appt = date_of_day.getMonth() == current_date.getMonth() && this.appt_dates.includes(dod);
    return html`
    <div id="${table_slot_id}" class="${current_month}">
        <a hx-get="/scheduler?mode=day&date=${dod}" hx-target="global #scheduler"
              hx-swap="outerHTML" hx-push-url="true"
              class="${classMap({num: true, has_appt, today: sameDay(date_of_day, new Date())})}">${date_of_day.getDate()}</a>
    </div>`;
    
  }

  private _prev() {
    this.current_date = dateAdd(this.current_date, 'month', -1);
  }

  private _next() {
    this.current_date = dateAdd(this.current_date, 'month', 1);
  }

  updated(changedProperties) {
    htmx.process(this.shadowRoot);
  }

  renderMonthViewDays(d: Date) {
    let rows = [];
    let firstOfDaMonth = new Date(d.getFullYear(), d.getMonth(), 1);
    let first_day = firstOfDaMonth.getDay();
    let i = 0;
    
    for (let week = 0;week < 6; week++) {
      var days = [];
      for(let day = 0; day < 7; day++) {
        let id = "d" + i;
        let thisDaysDate = dateAdd(firstOfDaMonth, "day", i - first_day);
        // if this day falls on the next month and is sunday, we can skip this entire row
        if(week == 5 && day == 0 && thisDaysDate.getMonth() != d.getMonth()) {
          break;
        }
        days.push(html`<td>${this.renderMonthViewDay(d, id, thisDaysDate)}</td>`);
        i++;
      }
      rows.push(html`<tr>${days}</tr>`);
    }
    return html`${rows}`;
  }

  private _getParams(base_date: Date) {
    let firstOfDaMonth = new Date(base_date.getFullYear(), base_date.getMonth(), 1);
    let firstOfNextMonth = dateAdd(firstOfDaMonth, 'month', 1);
    return `date=${toIsoDateString(firstOfDaMonth)}&to=${toIsoDateString(firstOfNextMonth)}`;
  }

  calendarTitle(d: Date) {
    return months[d.getMonth()] + " " + d.getFullYear();
  }

  private _apptDatesTask = new Task(this, {

    task: async ([current_date], {signal}) => {
      let firstOfDaMonth = new Date(this.current_date.getFullYear(), this.current_date.getMonth(), 1);
      let from = dateAdd(firstOfDaMonth, 'month', -1);
      let to = dateAdd(from, 'month', 3);
      const response = await fetch(`/date-picker.json?from=${toIsoDateString(from)}&to=${toIsoDateString(to)}`, {signal});

      if (!response.ok) { throw new Error(response.status); }

      return response.json() as DateList;

    },

    args: () => [this.current_date]

  });


  render() {

    return this._apptDatesTask.render({

      pending: () => html`<p>Loading dates...</p>`,

      complete: (response_data) => {
        this.appt_dates = response_data.dates.map(date => date.date);
        return this.renderWithData();
      },

      error: (e) => html`<p>Error: ${e}</p>`

    });

  }
  
  renderWithData() {
    return html`
    <div class='day-picker-nav'>
      <button type="button" @click=${this._prev}
            class="${classMap({btn: true})}">&lt;</button>
            <h3>Months</h3>
        <button type="button" @click=${this._next}
            class="${classMap({btn: true})}">&gt;</button>
        <!-- <button type="button" hx-get="/scheduler?mode=day-picker&${this._getParams(dateAdd(this.current_date, 'month', -1))}"
            hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true" hx-trigger="click"
            class="${classMap({btn: true})}">&lt;</button>
            <h3>Months</h3>
        <button type="button" hx-get="/scheduler?mode=day-picker&${this._getParams(dateAdd(this.current_date, 'month', 1))}"
            hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true" hx-trigger="click"
            class="${classMap({btn: true})}">&gt;</button> -->
    </div>
    <table class="day-picker-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              <caption>
                <div class="day-picker-header">
                  <h2 id="month_title">${this.calendarTitle(dateAdd(this.current_date, 'month', -1))}</h2>
                </div>
              </caption>
            </th>
          </tr>
          <tr>
              <th class="row2">Su</th>
              <th class="row2">Mo</th>
              <th class="row2">Tu</th>
              <th class="row2">We</th>
              <th class="row2">Th</th>
              <th class="row2">Fr</th>
              <th class="row2">Sa</th>
          </tr>
      </thead>
      <tbody hx-ext="path-params">
        ${this.renderMonthViewDays(dateAdd(this.current_date, 'month', -1))} 
      </tbody>
    </table>
    <table class="day-picker-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              <caption>
                <div class="day-picker-header">
                  <h2 id="month_title">${this.calendarTitle(this.current_date)}</h2>
                </div>
              </caption>
            </th>
          </tr>
          <tr>
              <th class="row2">Su</th>
              <th class="row2">Mo</th>
              <th class="row2">Tu</th>
              <th class="row2">We</th>
              <th class="row2">Th</th>
              <th class="row2">Fr</th>
              <th class="row2">Sa</th>
          </tr>
      </thead>
      <tbody hx-ext="path-params">
        ${this.renderMonthViewDays(this.current_date)} 
      </tbody>
    </table>
    <table class="day-picker-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              <caption>
                <div class="day-picker-header">
                  <h2 id="month_title">${this.calendarTitle(dateAdd(this.current_date, 'month', 1))}</h2>
                </div>
              </caption>
            </th>
          </tr>
          <tr>
              <th class="row2">Su</th>
              <th class="row2">Mo</th>
              <th class="row2">Tu</th>
              <th class="row2">We</th>
              <th class="row2">Th</th>
              <th class="row2">Fr</th>
              <th class="row2">Sa</th>
          </tr>
      </thead>
      <tbody hx-ext="path-params">
        ${this.renderMonthViewDays(dateAdd(this.current_date, 'month', 1))} 
      </tbody>
    </table>
    `;
  }
}