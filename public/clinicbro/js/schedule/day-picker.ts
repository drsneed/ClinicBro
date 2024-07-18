import { html, css, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { dateAdd, months, toIsoDateString, sameDay } from '../util';
import { classMap } from 'lit/directives/class-map.js';

@customElement("day-picker")
export class DayPicker extends LitElement {
  static styles = css`
  .day-picker-table {
    background: var(--container-bg);
    table-layout: fixed;
    border-collapse: separate;
    border-spacing: 0;
    padding: 0px !important;
    margin: 0px;
    width: 100%;
    color: var(--table-fg);
  }

  .day-picker-table td, .day-picker-table th {
    border: 1px solid var(--input-border);
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
    background-color: var(--bg);
    vertical-align: top;
    overflow: hidden;
  }

  .day-picker-table tr {
    white-space: nowrap;
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
    padding: 4px 8px;
    height: 32px;
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
    background-color: var(--header-bg);
    text-align: center;
    margin: 0;
  }
  
  .day-picker-header h2 {
    width: 50%;
    color: var(--header-fg);
    padding: 0;
    margin: 8px auto;
    font-size: 14px;
  }
  .num {
    font-size: 14px;
    padding: 2px;
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
      font-weight: bold;
  }
  .today {
    //background-color: var(--calendar-today-fg);
    color: var(--calendar-today-fg) !important;
  }
  .current-month, .other-month {
    margin: 0;
    padding: 4px;
  }
  .current-month {
        background-color: var(--calendar-this-month-bg) !important;
  }`;

  // @ts-ignore
  // @property({reflect: true,
  //   converter: {
  //     fromAttribute: (value, type) => {
  //       return new Date(value.replace(/-/g, '\/'));
  //     },
  //     toAttribute: (value, type) => {
  //       return toIsoDateString(value);
  //     }
  //   }})
  current_date: Date;

  constructor() {
    super();
    this.current_date = new Date();
  }

  renderMonthViewDay(today: Date, table_slot_id: string, date_of_day: Date) {
    let current_month = date_of_day.getMonth() == this.current_date.getMonth() ? "current-month" : "other-month";
    let dod = toIsoDateString(date_of_day);
    return html`
    <div id="${table_slot_id}" class="${current_month}"
         hx-target="global #cb-window" hx-swap="outerHTML" 
        hx-trigger="dblclick target:#${table_slot_id}">
        <a hx-get="/scheduler?mode=day&date=${dod}" hx-target="global #scheduler"
              hx-swap="outerHTML" hx-push-url="true"
              class="${classMap({num: true, today: sameDay(date_of_day, new Date())})}">${date_of_day.getDate()}</a>
    </div>`;
  }

  renderMonthViewDays() {
    var today = new Date();
    let rows = [];
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

  private _getParams(base_date: Date) {
    let firstOfDaMonth = new Date(base_date.getFullYear(), base_date.getMonth(), 1);
    let firstOfNextMonth = dateAdd(firstOfDaMonth, 'month', 1);
    return `date=${toIsoDateString(firstOfDaMonth)}&to=${toIsoDateString(firstOfNextMonth)}`;
  }

  calendarTitle() {
    return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
  }
  
  render() {
    return html`
    <div class='day-picker-nav'>
        <button type="button" hx-get="/scheduler?mode=day-picker&${this._getParams(dateAdd(this.current_date, 'month', -1))}"
            hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true" hx-trigger="click"
            class="${classMap({btn: true})}">&lt;</button>
        <button type="button" hx-get="/scheduler?mode=day-picker&${this._getParams(dateAdd(this.current_date, 'month', 1))}"
            hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true" hx-trigger="click"
            class="${classMap({btn: true, 'float-right': true})}">&gt;</button>
    </div>
    <table class="day-picker-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              <caption>
                <div class="day-picker-header">
                  <h2 id="month_title">${this.calendarTitle()}</h2>
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
        ${this.renderMonthViewDays()} 
      </tbody>
    </table>
    `;
  }
}