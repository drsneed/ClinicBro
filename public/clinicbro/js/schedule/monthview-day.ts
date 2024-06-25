import { LitElement, html, css } from 'lit-element';
import {sameDay, clearAllSelectedDays} from '../util';
import {customElement, property} from 'lit/decorators.js';

@customElement("mv-day")
export class MonthViewDay extends LitElement {
    static styles = css`
      :host {
        --calendar-number-fg: light-dark(#787777, #22);
        --calendar-this-month-bg: light-dark(#dae2f8, #442d2d);
        --calendar-this-month-active-bg: light-dark(#fff, #000);
        --calendar-month-bg: light-dark(#eeeeec, #323030);
        --calendar-today-fg: light-dark(#155741, #adf5c5);
        --table-fg: light-dark(#16181a, #a2b4b1);
      }
      div {
        width: 100%;
        height: 100%;
        max-width: 100%;
        white-space: nowrap;
      }
      
      .num {
        font-size: 10px;
        color: var(--calendar-number-fg);
        padding: 0px 6px;
      }

      .this-month {
        background-color: var(--calendar-this-month-bg) !important;
      }

      .this-month-active {
        background-color: var(--calendar-this-month-active-bg) !important;
      }
      
      .today {
        font-weight: bold;
        border: 1px solid var(--calendar-today-fg);
        border-radius: 50%;
        padding: 0px 4px !important;
        color: var(--calendar-today-fg) !important;
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
      this.addEventListener('dblclick', this._doubleClickHandler);
    }

    numClass() {
      return sameDay(this.current_date, new Date()) ? "today" : "";
    }

    public clicked() {
      this.selected = true;
    }

    public doubleClicked() {
      const schedule = document.getElementById("schedule");
      schedule.showAppointmentDialog(this.current_date);
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

    protected render() {
        // @ts-ignore
        let dayClass = this.selected ? "this-month-active" : (this.current_month ? "this-month" : "");
        let num = this.current_date.getDate();
        return html`<div class="${dayClass}">
        <span class="num ${this.numClass()}">${num}</span>
        <slot></slot>
      </div>`;
    }

}

// customElements.define('mv-day', MonthViewDay);

// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-day": MonthViewDay;
//   }
// }