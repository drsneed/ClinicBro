import {html, css, LitElement} from 'lit';

export class Appointment extends LitElement {
  static styles = css`
    :host {
    --border-left: light-dark(#FF000055, #CCC);
    --bg: light-dark(#CCC, #222);
    --fg: light-dark(#444, #CCC);
  }
    div {
      border-left: 4px solid var(--border-left);
      font-size: 12px;
      background-color: var(--bg);
      color: var(--fg);
      padding: 0px 2px;
      margin: 2px 0px;
    }`;
    
  static properties = {
    name: {type: String},
    start: {
      reflect: true,
      converter(value) {
        return new Date(value);
      }
    },
    end: {
      reflect: true,
      converter(value) {
        return new Date(value);
      }
    }
  };

  constructor() {
    super();
  }

  render() {
    let startHours = this.start.getHours() % 12 || 12;
    let startMinutes = ('0'+this.start.getMinutes()).slice(-2);
    let endHours = this.end.getHours() % 12 || 12;
    let endMinutes = ('0'+this.end.getMinutes()).slice(-2);
    let pm = this.end.getHours() >= 12 ? "pm" : "am";
    return html`<div><span>${startHours}:${startMinutes}-${endHours}:${endMinutes}${pm} ${this.name}</span></div>`
  }
}

customElements.define('x-appt', Appointment);
