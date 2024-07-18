import { html, LitElement } from 'lit';
import { monthviewStyle } from './monthview-style';
import { classMap } from 'lit/directives/class-map.js';
import { property } from 'lit/decorators.js';
import { dateAdd, months, toIsoDateString, dateSuffix } from '../util';

export class SchedulerBase extends LitElement {
  static styles = monthviewStyle();
    
  // @ts-ignore
  @property({
    converter: {
      fromAttribute: (value, type) => {
        if(!isNaN(Date.parse(value))) {
          return new Date(value);
        }
        return new Date();
      },
      toAttribute: (value, type) => {
        return value.toIsoDateString();
      }
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

  private _prev() {
    this.current_date = dateAdd(this.current_date, this.mode, -1);
    return 
  }

  private _next() {
    this.current_date = dateAdd(this.current_date, this.mode, 1);

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

  private _getMonthParams(base_date: Date) {
    let firstOfDaMonth = new Date(base_date.getFullYear(), base_date.getMonth(), 1);
    let firstOfNextMonth = dateAdd(firstOfDaMonth, 'month', 1);
    return `date=${toIsoDateString(firstOfDaMonth)}&to=${toIsoDateString(firstOfNextMonth)}`;
  }
  private _getWeekParams(base_date: Date) {
    let firstOfDaWeek = dateAdd(base_date, 'day', -base_date.getDay());
    let firstOfNextWeek = dateAdd(firstOfDaWeek, 'day', 7);
    return `date=${toIsoDateString(firstOfDaWeek)}&to=${toIsoDateString(firstOfNextWeek)}`;
  }
  private _getDayParam(base_date: Date) {
    let param_str = `date=${toIsoDateString(base_date)}`;
    return param_str;
  }

  private _getParams(base_date: Date) {
    switch(this.mode) {
      case "month":
        return this._getMonthParams(base_date);
      case "week":
        return this._getWeekParams(base_date);
      case "day":
          return this._getDayParam(base_date);
    }
    return "";
  }

  renderSchedulerModesButtonBar() {
    return html`
      <div class="header-item scheduler-button-bar float-right">
        <button type="button" class="${classMap({btn: true, 'btn-first': true, 'btn-pressed': this.mode==='month'})}"
            hx-get="/scheduler?mode=month&${this._getMonthParams(this.current_date)}" hx-target="global #scheduler"
            hx-swap="outerHTML" hx-push-url="true">Month</button>
        <button type="button" class="${classMap({btn: true, 'btn-middle': true, 'btn-pressed': this.mode==='week'})}"
            hx-get="/scheduler?mode=week&${this._getWeekParams(this.current_date)}" hx-target="global #scheduler"
            hx-swap="outerHTML" hx-push-url="true">Week</button>
        <button type="button" class="${classMap({btn: true, 'btn-last': true, 'btn-pressed': this.mode==='day'})}"
            hx-get="/scheduler?mode=day&${this._getDayParam(this.current_date)}" hx-target="global #scheduler"
            hx-swap="outerHTML" hx-push-url="true">Day</button>
      </div>
    `;
  }

  renderSchedulerNavigationButtonBar() {
    return html`
      <div class="header-item scheduler-button-bar">
        <button type="button" hx-get="/scheduler?mode=${this.mode}&${this._getParams(dateAdd(this.current_date, this.mode, -1))}"
          hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true"
          hx-trigger="click, keyup[key=='ArrowLeft'] from:body"
          class="${classMap({btn: true, 'btn-first': true})}">&lt;</button>
        <button type="button" class="${classMap({btn: true, 'btn-middle': true})}"
          hx-get="/scheduler?mode=${this.mode}&${this._getParams(new Date())}" hx-target="global #scheduler"
          hx-swap="outerHTML" hx-push-url="true">Today</button>
        <button type="button" hx-get="/scheduler?mode=${this.mode}&${this._getParams(dateAdd(this.current_date, this.mode, 1))}"
          hx-target="global #scheduler" hx-swap="outerHTML" hx-push-url="true"
          hx-trigger="click, keyup[key=='ArrowRight'] from:body"
          class="${classMap({btn: true, 'btn-last': true})}">&gt;</button>
      </div>
    `;
  }

  renderCaption() {
    return html`
    <caption>
        <div class="month-header">
          ${this.renderSchedulerNavigationButtonBar()}
          <h2 id="month_title">${this.calendarTitle()}</h2>
          ${this.renderSchedulerModesButtonBar()}
        </div>
    </caption>`;
  }
}