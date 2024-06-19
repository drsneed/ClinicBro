import {html, css, LitElement} from 'lit';
import {dateAdd, months, sameDay} from '../util';
import {monthviewStyle} from './monthview-style';
import {Appointment} from './appointment';

import 'lit-icon/pkg/dist-src/lit-icon.js';
import 'lit-icon/pkg/dist-src/lit-iconset.js';

export class MonthView extends LitElement {
  static styles = monthviewStyle();
    
  static properties = {
    current_date: {
        reflect: true,
        converter(value) {
          return new Date(value);
        }
      },
    appointments: {type: Array},
  };

  calendarTitle() {
    return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
  }

  constructor() {
    super();
    this.current_date = new Date();
    // '<x-appt name="AUD EXAM" start="2024-06-15T13:30:00" end="2024-06-15T14:30:00"></x-appt>'
    var appt1 = new Appointment();
    appt1.name = "AUD EXAM";
    appt1.start = new Date("2024-06-15T13:30:00");
    appt1.end = new Date("2024-06-15T14:30:00");
    this.appointments = [appt1];
  }

  updated(changedProperties) {
    //console.log(changedProperties); // logs previous values
    if(changedProperties.has('current_date')) {
      //this.calendar_title = months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
    }
  }

  private _prev(e: Event) {
    this.current_date = dateAdd(this.current_date, 'month', -1);
  }

  private _next(e: Event) {
    this.current_date = dateAdd(this.current_date, 'month', 1);
  }

  renderCaption() {
    return html`
    <caption align="top">
        <div class="month-header">
            <button type="button" @click="${this._prev}" class="btn-left"><lit-icon icon="chevron_left" iconset="iconset"></lit-icon></button>
            <h2 align="center" id="month_title">${this.calendarTitle()}</h2>
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

  renderDays() {
    let rows = [];
    const today = new Date();
    let firstOfDaMonth = new Date(this.current_date.getFullYear(), this.current_date.getMonth(), 1);
    let d = firstOfDaMonth.getDay();
    let i = 0;
    for (let week = 0;week < 6; week++) {
      var days = [];
      for(let day = 0; day < 7; day++) {
        let id = "d" + i;
        let thisDaysDate = dateAdd(firstOfDaMonth, "day", i - d);
        let dayClass = thisDaysDate.getMonth() == this.current_date.getMonth() ? "this-month" : "";
        //let numClass = thisDaysDate.toDateString() === today.toDateString() ? "today" : "";
        let numClass = sameDay(thisDaysDate, today) ? "today" : "";
        let num = thisDaysDate.getDate();
        days.push(html`<td id="${id}" class="${dayClass}"><span class="num ${numClass}">${num}</span>
          ${this.appointments.filter((appt) => sameDay(appt.start, thisDaysDate)).map((appt) => 
            html`<x-appt name="${appt.name}" start="${appt.start}" end="${appt.end}"></x-appt>`
          )}</td>`);
        i++;
      }
      rows.push(html`<tr>${days}</tr>`);
    }
    return html`${rows}`;
    
  }
  
  render() {
    return html`
<table class="month-table" align="center" cellspacing="0">
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
    <tbody>
       ${this.renderDays()} 
    </tbody>
</table>
    `;
  }
}

customElements.define('month-view', MonthView);
