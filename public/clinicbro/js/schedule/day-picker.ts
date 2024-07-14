import { html, css, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { dateAdd, months, toIsoDateString, dateSuffix } from '../util';

@customElement("day-picker")
export class DayPicker extends LitElement {
  static styles = css``;
  // @ts-ignore
  @property({
    converter: {
      fromAttribute: (value, type) => {
        if(!isNaN(Date.parse(value))) {
          return new Date(value);
        }
        return new Date();
      },
      toAttribute: (value, type) => {
        return toIsoDateString(value);
      }
    }, reflect: true})
  current_date: Date;

  constructor() {
    super();
    this.current_date = new Date();
  }

  renderMonthViewDay(today: Date, table_slot_id: string, date_of_day: Date) {
    let current_month = date_of_day.getMonth() == this.current_date.getMonth();
    let dod = toIsoDateString(date_of_day);
    return html`
    <div id="${table_slot_id}" current_date="${date_of_day}" ?current_month=${current_month}
         hx-target="global #cb-window" hx-swap="outerHTML" 
        hx-trigger="dblclick target:#${table_slot_id}">
        <button type="button" class="btn" hx-get="/scheduler?{id}?date=${dod}"
    </div>`;
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

  calendarTitle() {
    return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
  }
  
  render() {
    return html`
    <table class="day-picker-table" cellspacing="0">
      <thead>
          <tr>
            <th colspan="7" class="row1 no-border">
              <caption>
                <div class="month-header">
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