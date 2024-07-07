import { LitElement, html, css } from 'lit-element';
import {sameDay, clearAllSelectedDays} from '../util';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';

@customElement("mv-day")
export class MonthViewDay extends LitElement {
    static styles = css`
      :host {
        --calendar-number-fg: light-dark(#787777, #22);
        --calendar-this-month-bg: light-dark(#dae2f8, #3b463b);
        --calendar-this-month-active-bg: light-dark(#fff, #000);
        --calendar-month-bg: light-dark(#eeeeec, #323030);
        --calendar-today-fg: light-dark(#155741, #adf5c5);
        --table-fg: light-dark(#16181a, #a2b4b1);
        --btn-add-fg: light-dark()
      }
      div {
        width: 100%;
        height: 100%;
        max-width: 100%;
        white-space: nowrap;
        user-select: none;
        overflow-y: auto;
      }
      
      .num {
        font-size: 10px;
        padding-left: 4px;
        padding-top: 2px;
        padding-right: 4px;
        padding-bottom: 2px;
        cursor: pointer;
        border-radius: 50%;
        border: none;
        margin-left: 2px;
        margin-top: 2px;
        background-color: transparent;
      }
      .today {
        border: 1px solid var(--calendar-today-fg);
        color: var(--calendar-today-fg) !important;
      }
      .num:hover {
        font-weight: bold;
      }

      .this_month {
        background-color: var(--calendar-this-month-bg) !important;
      }

      .selected {
        background-color: var(--calendar-this-month-active-bg) !important;
      }
      


      .menu {
        position: absolute;
        top: -20px;
        left: 0;
        margin: 0;
      }

      .menu_opened {
        display: flex;
      }
      .menu_closed {
        display: none;
      }

      .btn_add {
        padding-left: 2px;
        padding-top: 0px;
        padding-right: 2px;
        padding-bottom: 1px;
        cursor: pointer;
        border-radius: 50%;
        /* border: 1px solid var(--btn-save-bg); */
        border: none;
        margin-right: 2px;
        margin-top: 2px;
        font-size: 11px;
        font-weight: bold;
        background-color: transparent;
        color: var(--btn-save-bg);
        float: right;
      }

      .btn_add_show {
        display: flex;
      }
      .btn_add_hide {
        display: none;
      }

      .btn_add:hover {
        background-color: var(--btn-save-bg);
        color: var(--btn-save-hover-bg);
        /* text-decoration: underline; */
        
      }
    `;

    // @ts-ignore
    @property({type: String, reflect: true})
    id: string;
    // @ts-ignore
    @property({converter(value) {return new Date(value);}, reflect: true})
    current_date: Date;
    // @ts-ignore
    @property({type: Boolean})
    current_month: boolean;
    // @ts-ignore
    @property({type: Boolean, reflect: true})
    selected: boolean;

    constructor() {
      super();
      this.current_month = false;
      this.selected = false;
      this.addEventListener('click', this._clickHandler);
      //this.addEventListener('dblclick', this._doubleClickHandler);
    }

    firstUpdated() {
    }

    updated(changedProperties) {
      if(changedProperties.has('selected')) {
        if(this.selected) {
          console.log("wtf");
        }
      }
    }

    public clicked() {
      let schedule = document.querySelector("#schedule");
      if(schedule.appointment_dialog_opened) {
        let dialog = schedule.shadowRoot.querySelector("#mv_dialog");
        dialog.updateDate(this.current_date);
      }
      this.selected = true;
    }

    public doubleClicked() {
      const schedule = document.getElementById("schedule");
      schedule.showCreateAppointmentDialog(this.current_date);
    }

    private _clickHandler(e) {
      clearAllSelectedDays();
      switch(e.target.localName) {
        case 'mv-day':
        case 'mv-appt':
          e.target.clicked();
          break;
      }
    }

    private _doubleClickHandler(e) {
      switch(e.target.localName) {
        case 'mv-day':
        case 'mv-appt':
          e.target.doubleClicked();
          break;
      }
    }

    private _addAppointment() {
      const schedule = document.getElementById("schedule");
      schedule.showCreateAppointmentDialog(this.current_date);
    }

    private _drop(e) {
      e.preventDefault();
      let appt_id = e.dataTransfer.getData("appt-id");
      let schedule = document.getElementById("schedule");
      let dropped_appt_id_input = schedule.shadowRoot.querySelector("#dropped-appt-id");
      dropped_appt_id_input.value = appt_id;
      //schedule.moveAppointment(appt_id, this.current_date);
    }

    private _allowDrop(e) {
      e.preventDefault();
    }

    private _gotoDayView(e) {
      e.preventDefault();
      alert("Gone baby boom!");
    }

    protected render() {
        let num = this.current_date.getDate();
        return html`
          <div class="${classMap({selected: this.selected, this_month: this.current_month})}" @drop="${this._drop}" @dragover="${this._allowDrop}">
            <!-- <span class="${classMap({num: true, today: sameDay(this.current_date, new Date())})}">${num}</span> -->
            <button class="${classMap({num: true, today: sameDay(this.current_date, new Date())})}">${num}</button>
            <!-- <button type="button" class="${classMap({btn_add: true, btn_add_show: this.selected, btn_add_hide: !this.selected})}" 
              @click="${this._addAppointment}" title="Add New Event">+</button> -->
            <slot></slot>
          </div>
      `;
    }

}

// customElements.define('mv-day', MonthViewDay);

// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-day": MonthViewDay;
//   }
// }