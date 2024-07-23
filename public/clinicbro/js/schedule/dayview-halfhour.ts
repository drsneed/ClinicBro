import { LitElement, html, css } from 'lit-element';
import {clearAllSelectedHours} from '../util';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';

@customElement("dv-half")
export class DayViewHalfHour extends LitElement {
    static styles = css`
      div {
        display: flex;
        align-items: stretch;
        width: 100%;
        height: 50%;
        max-width: 100%;
        white-space: nowrap;
        text-overflow: wrap;
        overflow-x: wrap;
        user-select: none;
        overflow-y: visible;
      }
      .half_hour {
        border-top: 1px dashed var(--input-border);
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
    @property({type: Boolean, reflect: true})
    selected: boolean;

    constructor() {
      super();
      this.selected = false;
      this.addEventListener('click', this._clickHandler);
    }

    public clicked() {
      let schedule = document.querySelector("#schedule");
      let dropped_appt_id_input = schedule.shadowRoot.querySelector("#dropped-appt-id");
      dropped_appt_id_input.value = "0";
      let dropped_client_id_input = schedule.shadowRoot.querySelector("#dropped-client-id");
      dropped_client_id_input.value = "0";
      this.selected = true;
    }

    private _clickHandler(e) {
      clearAllSelectedHours();
      switch(e.target.localName) {
        case 'dv-half':
        case 'dv-appt':
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
        let half_hour = this.current_date.getMinutes() > 0;
        return html`
          <div class="${classMap({selected: this.selected, half_hour: half_hour})}" @drop="${this._drop}" @dragover="${this._allowDrop}">
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