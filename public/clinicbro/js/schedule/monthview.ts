import {html, css, LitElement} from 'lit';
import {dateAdd, months, sameDay, clearAllSelectedDays} from '../util';
import {monthviewStyle} from './monthview-style';
import {customElement, property} from 'lit/decorators.js';
import 'lit-icon/pkg/dist-src/lit-icon.js';
import 'lit-icon/pkg/dist-src/lit-iconset.js';


@customElement("month-view")
export class MonthView extends LitElement {
  static styles = monthviewStyle();
    

  // @ts-ignore
  @property({converter(value) {return new Date(value);}, reflect: true})
  current_date: Date;

  // @ts-ignore
  @property({type: Array, attribute: false})
  appointments = [];

  // @ts-ignore
  @property({type: Boolean, reflect: true})
  appointment_dialog_opened: boolean;

  calendarTitle() {
    return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
  }

  constructor() {
    super();
    this.current_date = new Date();
    this.appointment_dialog_opened = false;
    var appt1 = {
      name: "AUD EXAM",
      start: new Date("2024-06-15T13:30:00"),
      end: new Date("2024-06-15T14:30:00")
    };
    this.appointments = [appt1];
  }


  updated(changedProperties) {
    //console.log(changedProperties); // logs previous values
    if(changedProperties.has('current_date')) {
      
    }
  }

  showAppointmentDialog(date_clicked: Date) {
    // if(this.appointment_dialog_opened) {
    //   console.log("Dialog is already open. Aborting mission :(");
    //   return false;
    // }
    let dialog = this.shadowRoot.querySelector("#mv_dialog");
    dialog.title = "New Appointment - " + date_clicked.toDateString();
    this.appointment_dialog_opened = true;
    return true;
  }

  private _prev(e: Event) {
    this.current_date = dateAdd(this.current_date, 'month', -1);
    clearAllSelectedDays();
  }

  private _next(e: Event) {
    this.current_date = dateAdd(this.current_date, 'month', 1);
    clearAllSelectedDays();
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

  renderDay(today: Date, id: string, date_of_day: Date) {
    let current_month = date_of_day.getMonth() == this.current_date.getMonth();
    return html`<mv-day id="${id}" current_date="${date_of_day.toISOString()}" ?current_month=${current_month}>
      ${ // @ts-ignore
        this.appointments.filter((appt) => sameDay(appt.start, date_of_day)).map((appt) => 
        html`<mv-appt name="${appt.name}" start="${appt.start.toISOString()}" end="${appt.end.toISOString()}"></mv-appt>`
      )}
    </mv-day>`;
  }

  renderDays() {
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
        days.push(html`<td>${this.renderDay(today, id, thisDaysDate)}</td>`);
        i++;
      }
      rows.push(html`<tr>${days}</tr>`);
    }
    return html`${rows}`;
  }

  saveAppointment (e) {
    console.log("We saved that mothafuckin appointment bro!");
    this.closeAppointmentDialog();
  }

  closeAppointmentDialog () {
    this.appointment_dialog_opened = false;
  }
  
  render() {
    return html`
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
      <tbody>
        ${this.renderDays()} 
      </tbody>
    </table>
    <mv-dialog id="mv_dialog" ?opened="${this.appointment_dialog_opened}" 
               @dialog.save="${this.saveAppointment.bind(this)}"
               @dialog.cancel="${this.closeAppointmentDialog}"></mv-dialog>
    `;
  }
}