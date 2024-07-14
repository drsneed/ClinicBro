import { LitElement, html, css } from 'lit-element';
import {sameDay, clearAllSelectedDays, toIsoDateString} from '../util';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';

@customElement("mv-day")
export class MonthViewDay extends LitElement {
    static styles = css`
      div {
        width: 100%;
        height: 100%;
        max-width: 100%;
        white-space: nowrap;
        user-select: none;
        overflow-y: auto;
      }
      
      
      .this_month {
        background-color: var(--calendar-this-month-bg) !important;
      }
      .selected {
        background-color: var(--calendar-this-month-active-bg) !important;
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
    }

    updated(changedProperties) {
      htmx.process(this.shadowRoot);
    }

    public clicked() {
      let schedule = document.querySelector("#schedule");
      // if(schedule.appointment_dialog_opened) {
      //   let dialog = schedule.shadowRoot.querySelector("#mv_dialog");
      //   dialog.updateDate(this.current_date);
      // }
      let dropped_appt_id_input = schedule.shadowRoot.querySelector("#dropped-appt-id");
      dropped_appt_id_input.value = "0";
      let dropped_client_id_input = schedule.shadowRoot.querySelector("#dropped-client-id");
      dropped_client_id_input.value = "0";
      this.selected = true;
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

    private _drop(e) {
      e.preventDefault();
      let appt_id = 0;
      let client_id = 0;
      if(e.dataTransfer) {
        let appt_id_data_xfer = e.dataTransfer.getData("appt-id");
        if(appt_id_data_xfer !== "") {
          appt_id = parseInt(appt_id_data_xfer);
        }
        let client_id_data_xfer = e.dataTransfer.getData("client-id");
        if(client_id_data_xfer !== "") {
          client_id = parseInt(client_id_data_xfer);
        }
      }
      let schedule = document.getElementById("schedule");
      let dropped_appt_id_input = schedule.shadowRoot.querySelector("#dropped-appt-id");
      dropped_appt_id_input.value = appt_id;
      let dropped_client_id_input = schedule.shadowRoot.querySelector("#dropped-client-id");
      dropped_client_id_input.value = client_id;
    }

    private _allowDrop(e) {
      e.preventDefault();
    }

    protected render() {
        let num = this.current_date.getDate();
        return html`
          <div class="${classMap({selected: this.selected, this_month: this.current_month})}" @drop="${this._drop}" @dragover="${this._allowDrop}">

            <slot></slot>
          </div>
      `;
    }

}

// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-day": MonthViewDay;
//   }
// }