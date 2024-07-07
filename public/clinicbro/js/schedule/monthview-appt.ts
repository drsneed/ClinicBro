import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import { dateAdd } from './../util';

@customElement("mv-appt")
export class MonthViewAppointment extends LitElement {
  static styles = css`
    :host {
    --border-left: light-dark(#FF000055, #CCC);
    --bg: light-dark(#CCC, #222);
    --fg: light-dark(#444, #CCC);
    --selected-border: light-dark(#232323, #f5f2f2);
  }
    div {
      border-left: 4px solid var(--border-left);
      font-size: 12px;
      background-color: var(--bg);
      color: var(--fg);
      padding: 0px 2px;
      margin: 2px 0px;
      user-select: none;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    
    .selected {
      border: 1px solid var(--selected-border);
    }
    .appt-title {

    }
    `;
    
    // @ts-ignore
    @property({reflect: true,type: String, reflect: true})
    appt_id;

    // @ts-ignore
    @property({reflect: true,type: String, reflect: true})
    appt_title: string;

    // @ts-ignore
    @property({reflect: true,converter(value) {return new Date(value);}})
    appt_date: Date;

    // // @ts-ignore
    // @property({reflect: true,converter(value) {return new Date(value);}})
    // appt_from: Date;

    // // @ts-ignore
    // @property({reflect: true,converter(value) {return new Date(value);}})
    // appt_to: Date;

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
      this.appt_title = "New Appt";
      this.selected = false;
      this.appt_date = new Date();
      this.appt_from = "00:00";
      this.appt_to = "00:30";
    }

    public clicked() {
      this.selected = true;
    }

    public doubleClicked() {
      const schedule = document.getElementById("schedule");
      schedule.showEditAppointmentDialog(this);
    }

    private _drag(e) {
      e.dataTransfer.setData("text", e.target.id);
    }

    render() {
      // let startHours = this.appt_from.getHours() % 12 || 12;
      // let startMinutes = ('0'+this.appt_from.getMinutes()).slice(-2);
      // let endHours = this.appt_to.getHours() % 12 || 12;
      // let endMinutes = ('0'+this.appt_to.getMinutes()).slice(-2);
      // let pm = this.appt_to.getHours() >= 12 ? "pm" : "am";
      // return html`<div id="appt${this.appt_id}" class="${classMap({selected: this.selected})}"
      //               draggable="true" @dragstart="${this._drag}"><span>${startHours}:${startMinutes}-${endHours}:${endMinutes}${pm} ${this.appt_title}</span></div>`

      return html`<div id="appt${this.appt_id}" class="${classMap({selected: this.selected})}"
               draggable="true" @dragstart="${this._drag}"><span class="appt-title">${this.appt_from}-${this.appt_to} ${this.appt_title}</span></div>`
                    
    }
}

// customElements.define('mv-appt', MonthViewAppointment);
// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-appt": MonthViewAppointment;
//   }
// }