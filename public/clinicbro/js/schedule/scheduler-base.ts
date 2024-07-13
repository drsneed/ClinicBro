import { html, LitElement } from 'lit';
import { monthviewStyle } from './monthview-style';
import { classMap } from 'lit/directives/class-map.js';
import { property } from 'lit/decorators.js';
import { dateAdd, months, clearAllSelectedDays, dateSuffix } from '../util';

export class SchedulerBase extends LitElement {
  static styles = monthviewStyle();
    
  // @ts-ignore
  @property({converter(value) {
      if(!isNaN(Date.parse(value))) {
        return new Date(value);
      }
      return new Date();
    }, reflect: true})
  current_date: Date;

  // @ts-ignore
  @property({type: String, reflect: true})
  mode: string;

  constructor() {
    super();
    this.current_date = new Date();
  }


  updated(changedProperties) {
    htmx.process(this.shadowRoot);
    //console.log(changedProperties); // logs previous values
    if(changedProperties.has('current_date')) {
      
    }
    // if(changedProperties.has('mode')) {
    //     this.requestUpdate();
    // }
  }

  private _prev(e: Event) {
    this.current_date = dateAdd(this.current_date, this.mode, -1);
    clearAllSelectedDays();
  }

  private _next(e: Event) {
    this.current_date = dateAdd(this.current_date, this.mode, 1);
    clearAllSelectedDays();
  }

  private _monthViewClicked(e) {
    this.mode = "month";
  }

  private _weekViewClicked(e) {
    this.mode = "week";
  }

  private _dayViewClicked(e) {
    this.mode = "day";
  }

  calendarTitle() {
    if(this.mode == 'month') {
      return months[this.current_date.getMonth()] + " " + this.current_date.getFullYear();
    } else if(this.mode == 'day') {
      
      return months[this.current_date.getMonth()] + " " + this.current_date.getDate() + dateSuffix(this.current_date) + ", " + this.current_date.getFullYear();
    } else {
      let firstOfDaWeek = dateAdd(this.current_date, 'day', -this.current_date.getDay());
      let endOfDaWeek = dateAdd(firstOfDaWeek, 'day', 6);
      // same month, same year. simplest case
      if(firstOfDaWeek.getFullYear() == endOfDaWeek.getFullYear() && firstOfDaWeek.getMonth() == endOfDaWeek.getMonth()) {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " - " +
          endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + this.current_date.getFullYear();
      } else if(firstOfDaWeek.getFullYear() == endOfDaWeek.getFullYear()) {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " - " +
          months[endOfDaWeek.getMonth()] + " " + endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + this.current_date.getFullYear();
      } else {
        return months[firstOfDaWeek.getMonth()] + " " + firstOfDaWeek.getDate() + dateSuffix(firstOfDaWeek) + " " + firstOfDaWeek.getFullYear() + " - " +
          months[endOfDaWeek.getMonth()] + " " + endOfDaWeek.getDate() + dateSuffix(endOfDaWeek) + " " + endOfDaWeek.getFullYear();
      }
    }
  }

  renderSchedulerModesButtonBar() {
    return html`
      <div class="header-item scheduler-button-bar">
        <button type="button" class="${classMap({btn: true, 'btn-first': true, 'btn-pressed': this.mode==='month'})}"
            hx-get="/scheduler?mode=month" hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true">Month</button>
        <button type="button" class="${classMap({btn: true, 'btn-middle': true, 'btn-pressed': this.mode==='week'})}"
            hx-get="/scheduler?mode=week" hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true">Week</button>
        <button type="button" class="${classMap({btn: true, 'btn-last': true, 'btn-pressed': this.mode==='day'})}"
            hx-get="/scheduler?mode=day" hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true">Day</button>
      </div>
    `;
  }

  renderCaption() {
    return html`
    <caption>
        <div class="month-header">
            <div class="header-item">
              <button type="button" @click="${this._prev}" class="btn-left">&lt;</button>
              <button type="button" @click="${this._next}" class="btn-right">&gt;</button>
            </div>
            <h2 id="month_title">${this.calendarTitle()}</h2>
            ${this.renderSchedulerModesButtonBar()}
        </div>
    </caption>`;
  }
}