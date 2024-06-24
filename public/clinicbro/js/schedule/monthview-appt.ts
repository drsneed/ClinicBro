import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';

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
    }
    .selected {
      border: 1px solid var(--selected-border);
    }`;
    
    // @ts-ignore
    @property({type: String})
    name: string;
    // @ts-ignore
    @property({reflect: true, converter(value) {return new Date(value);}})
    start: Date;
    // @ts-ignore
    @property({reflect: true, converter(value) {return new Date(value);}})
    end: Date;
    // @ts-ignore
    @property({type: Boolean, reflect: true})
    selected: boolean;

  constructor() {
    super();
    this.selected = false;
  }

  public clicked() {
    this.selected = true;
  }

  public doubleClicked() {
    console.log(this.name + " double clicked!");
  }

  render() {
    let startHours = this.start.getHours() % 12 || 12;
    let startMinutes = ('0'+this.start.getMinutes()).slice(-2);
    let endHours = this.end.getHours() % 12 || 12;
    let endMinutes = ('0'+this.end.getMinutes()).slice(-2);
    let pm = this.end.getHours() >= 12 ? "pm" : "am";
    let selectedClass = this.selected ? "selected" : "";
    return html`<div class="${selectedClass}"><span>${startHours}:${startMinutes}-${endHours}:${endMinutes}${pm} ${this.name}</span></div>`
  }
}

// customElements.define('mv-appt', MonthViewAppointment);
// declare global {
//   interface HTMLElementTagNameMap {
//     "mv-appt": MonthViewAppointment;
//   }
// }