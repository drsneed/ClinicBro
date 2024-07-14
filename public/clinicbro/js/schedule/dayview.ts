import { html } from 'lit';
import { customElement } from 'lit/decorators.js';
import { dateAdd, dayHeaders } from '../util';
import { SchedulerBase } from './scheduler-base';


@customElement("day-view")
export class DayView extends SchedulerBase {
    
  constructor() {
    super();
    this.mode = "day";
  }
  
  render() {
    return html`
    <table class="month-table" cellspacing="0">
        <colgroup>
          <col span="1" style="width: 70px;">
          <col span="1" style="width: 95%;">
        </colgroup>
        <thead>
          <tr>
            <th colspan="2" class="row1 no-border">
              ${this.renderCaption()}
            </th>
          </tr>
          <tr>
              <th colspan="2" class="row2">${dayHeaders[this.current_date.getDay()]}</th>
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

  renderDayViewDay() {
    let rows = [];
    let i = 0;
    var midnight = new Date(this.current_date.valueOf());
    midnight.setHours(0, 0, 0, 0);
    for (let hour = 0; hour < 24; hour++) {
        let id1 = "h" + i;
        let id2 = "h" + i + "m30";
        let this_hour = dateAdd(midnight, "hour", i);
        let this_hour_half = dateAdd(this_hour, "minute", 30);
        let time_hour = this_hour.getHours() % 12 || 12;
        let pm = this_hour.getHours() >= 12 ? "pm" : "am";

        let slot_name_1 = "" + this_hour.getHours() + ":00";
        if(slot_name_1.length == 4) {
          slot_name_1 = "0" + slot_name_1;
        }
        let slot_name_2 = slot_name_1.slice(0, 2) + ":30";
        rows.push(html`
        <tr>
          <td class="time-display">${time_hour}:00 ${pm}</td>
          <td>
              <dv-half id="${id1}" current_date="${this_hour.toISOString()}"><slot name="${slot_name_1}"></slot></dv-half>
              <dv-half id="${id2}" current_date="${this_hour_half.toISOString()}"><slot name="${slot_name_2}"></slot></dv-half>
          </td>
        </tr>`);
        i++;
    }
    return html`${rows}`;
  }
}

/* <div id="${id}" class="day-view-hour-1"></div><div class="day-view-hour-2"></div> */