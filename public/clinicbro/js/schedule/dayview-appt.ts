import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import { styleMap } from 'lit/directives/style-map.js';
import { dateAdd, toIsoDateString } from './../util';

@customElement("dv-appt")
export class DayViewAppointment extends LitElement {
  static styles = css`
    div {
      font-size: 12px;
      color: var(--appt-fg);
      padding: 0px 2px;
      margin: 2px 0px;
      width: 90%;
      user-select: none;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .appt {
      /* background-color: var(--appt-bg1); */
    }

    .event {
      background: repeating-linear-gradient(
        45deg,
        var(--appt-bg),
        var(--appt-bg) 10px,
        var(--appt-bg-alt) 10px,
        var(--appt-bg-alt) 20px
      );
    }
    
    .selected {
      border: 1px solid var(--appt-selected-border);
    }
    `;
    
    // @ts-ignore
    @property({reflect: true, type: String})
    appt_id;

    // @ts-ignore
    @property({reflect: true, type: String})
    appt_title;

    // @ts-ignore
    @property({reflect: true, type: String})
    status;

    // @ts-ignore
    @property({reflect: true, type: String})
    client: string;

    // @ts-ignore
    @property({reflect: true, type: String})
    provider: string;

    // @ts-ignore
    @property({reflect: true, type: String})
    location: string;

    // @ts-ignore
    @property({reflect: true, type: String})
    color: string;

    // @ts-ignore
    @property({reflect: true,
      converter: {
        fromAttribute: (value, type) => {
          return new Date(value);
        },
        toAttribute: (value, type) => {
          return toIsoDateString(value);
        }
      }})
    appt_date: Date;

    // @ts-ignore
    @property({reflect: true, type: String})
    appt_from: string;
    // @ts-ignore
    @property({reflect: true, type: String})
    appt_to: string;

    // @ts-ignore
    @property({type: Boolean, reflect: true})
    selected: boolean;

    constructor() {
      super();
      this.appt_title = "title";
      this.client = "client";
      this.status = "status";
      this.provider = "provider";
      this.location = "location";
      this.selected = false;
      this.appt_date = new Date();
      this.appt_from = "00:00";
      this.appt_to = "00:30";
      this.color = "";
    }

    public clicked() {
      this.selected = true;
    }

    private _drag(e) {
      e.dataTransfer.setData("appt-id", e.target.dataset.apptId);
    }

    render() {
      // let startHours = this.appt_from.getHours() % 12 || 12;
      // let startMinutes = ('0'+this.appt_from.getMinutes()).slice(-2);
      // let endHours = this.appt_to.getHours() % 12 || 12;
      // let endMinutes = ('0'+this.appt_to.getMinutes()).slice(-2);
      // let pm = this.appt_to.getHours() >= 12 ? "pm" : "am";
      // return html`<div id="appt${this.appt_id}" class="${classMap({selected: this.selected})}"
      //               draggable="true" @dragstart="${this._drag}"><span>${startHours}:${startMinutes}-${endHours}:${endMinutes}${pm} ${this.appt_title}</span></div>`
      let text = this.appt_title;
      let appt = this.client.length > 0;
      if(appt) {
        text = text + " - " + this.client;
      }
      let backgroundColor = "var(--appt-bg1)";
      if(this.color.length > 0)
        backgroundColor = this.color;
      let startHours24 = parseInt(this.appt_from.slice(0,2));
      let startHours = startHours24 % 12 || 12;
      let startMinutes = this.appt_from.slice(-2);
      let endHours24 = parseInt(this.appt_to.slice(0,2));
      let endHours = endHours24 % 12 || 12;
      let endMinutes = this.appt_to.slice(-2);
      let pm = endHours24 >= 12 ? "pm" : "am";
      let startDate = new Date(this.appt_date.valueOf());
      startDate.setHours(startHours24);
      startDate.setMinutes(parseInt(startMinutes));
      let endDate = new Date(this.appt_date.valueOf());
      endDate.setHours(endHours24);
      endDate.setMinutes(parseInt(endMinutes));
      let duration = (Math.abs(endDate - startDate)/1000)/60;
      let display_height = duration * 1.5;

      //let color = this.color.length > 0 ? this.color : "#FF000055";
      return html`<div data-appt-id="${this.appt_id}" class="${classMap({selected: this.selected, appt: appt, event: !appt})}"
               style="${styleMap({backgroundColor: backgroundColor, height: display_height})}"
               draggable="true" @dragstart="${this._drag}"><span class="appt-title">${startHours}:${startMinutes}-${endHours}:${endMinutes}${pm} ${text}</span></div>`;
                    
    }
}

// customElements.define('mv-appt', MonthViewAppointment);
// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-appt": MonthViewAppointment;
//   }
// }