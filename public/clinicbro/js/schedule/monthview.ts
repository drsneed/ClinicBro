import { html } from 'lit';
import { customElement } from 'lit/decorators.js';
import { toIsoDateString, dateAdd } from '../util';
import { SchedulerBase } from './scheduler-base';


@customElement("month-view")
export class MonthView extends SchedulerBase {
    
  constructor() {
    super();
    this.mode = "month";
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