import {html, css, LitElement} from 'lit';
import {dateAdd, months, sameDay, clearAllSelectedDays} from '../util';
import {monthviewStyle} from './monthview-style';
import {MonthViewAppointment} from './monthview-appt';
import {customElement, property} from 'lit/decorators.js';
import { toIsoDateString, dateAdd, toIsoTimeString } from '../util';
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
      appt_id: 1,
      appt_title: "Staff Meeting",
      appt_date: new Date("2024-07-14T00:00:00"),
      appt_from: new Date("2024-07-14T13:30:00"),
      appt_to: new Date("2024-07-14T14:30:00")
    };
    this.appointments = [appt1];
  }


  updated(changedProperties) {
    htmx.process(this.shadowRoot);
    //console.log(changedProperties); // logs previous values
    if(changedProperties.has('current_date')) {
      
    }
  }

  showCreateAppointmentDialog(date_clicked: Date) {
    if(this.appointment_dialog_opened) {
      console.log("Dialog is already open. Aborting mission :(");
      return false;
    }
    let dialog = this.shadowRoot.querySelector("#mv_dialog");
    dialog.window_title = "New Event";
    dialog.appt_id = 0;
    dialog.appt_title = "";
    dialog.appt_date = date_clicked;
    let from = new Date();
    from.setSeconds(0);
    from.setMinutes(from.getMinutes() < 30 ? 0 : 30);
    console.log("from = " + from.toLocaleTimeString());
    dialog.appt_from = from;
    dialog.appt_to = dateAdd(from, 'minute', 30);
    dialog.ready();
    this.appointment_dialog_opened = true;
    return true;
  }

  showEditAppointmentDialog(appointment: MonthViewAppointment) {
    if(this.appointment_dialog_opened) {
      console.log("Dialog is already open. Aborting mission :(");
      return false;
    }
    let dialog = this.shadowRoot.querySelector("#mv_dialog");
    dialog.window_title = "Edit Event";
    dialog.appt_title = appointment.appt_title;
    dialog.appt_id = appointment.appt_id;
    dialog.appt_date = appointment.appt_date;
    dialog.appt_from = appointment.appt_from;
    dialog.appt_to = appointment.appt_to;
    dialog.ready();
    this.appointment_dialog_opened = true;
    return true;
  }


  saveAppointment (e) {
    this.closeAppointmentDialog();
    let dialog = this.shadowRoot.querySelector("#mv_dialog");
    dialog.collect();
    if(dialog.appt_id > 0) {
      let index = this.appointments.findIndex(appt => appt.appt_id == dialog.appt_id);
      this.appointments[index].appt_title = dialog.appt_title;
      this.appointments[index].appt_from = dialog.appt_from;
      this.appointments[index].appt_to = dialog.appt_to;
      this.appointments[index].appt_date = dialog.appt_date;
    }
    else {
      var id = Math.max(...this.appointments.map(o => o.appt_id)) + 1;
      this.appointments.push({
        appt_id: id,
        appt_title: dialog.appt_title,
        appt_date: dialog.appt_date,
        appt_from: dialog.appt_from,
        appt_to: dialog.appt_to
      });
    }
  }

  moveAppointment(appt_id: number, new_date: Date) {
    let index = this.appointments.findIndex(appt => appt.appt_id == appt_id);
    this.appointments[index].appt_date = new_date;
    this.requestUpdate();
  }

  closeAppointmentDialog () {
    this.appointment_dialog_opened = false;
    clearAllSelectedDays();
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
    // let from = new Date();
    // from.setSeconds(0);
    // from.setMinutes(from.getMinutes() < 30 ? 0 : 30);
    // let to = dateAdd(from, 'minute', 30);
    return html`
    <mv-day id="${id}" current_date="${date_of_day.toISOString()}" ?current_month=${current_month}
        hx-get="/appointments/0?date=${toIsoDateString(date_of_day)}" hx-target="global #cb-window" hx-swap="outerHTML" hx-trigger="dblclick">
      ${this.appointments.filter((appt) => sameDay(appt.appt_date, date_of_day)).map((appt) => 
        html`<mv-appt appt_id="${appt.appt_id}" appt_title="${appt.appt_title}" appt_date = "${appt.appt_date.toISOString()}" 
          appt_from="${appt.appt_from.toISOString()}" appt_to="${appt.appt_to.toISOString()}"></mv-appt>`
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