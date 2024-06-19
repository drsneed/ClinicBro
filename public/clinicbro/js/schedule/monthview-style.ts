import {css} from 'lit';
export function monthviewStyle() {
    return css`
  :host {
    --calendar-header-fg: light-dark(#2e1804, #9EAF91);
    --calendar-header-bg: light-dark(#d4c192, #2e2d2f);
    --calendar-number-fg: light-dark(#787777, #22);
    --calendar-this-month-bg: light-dark(#f4f2d3, #442d2d);
    --calendar-month-bg: light-dark(#eeeeec, #323030);
    --calendar-today-fg: light-dark(#155741, #adf5c5);
    --table-fg: light-dark(#16181a, #a2b4b1);
  }
  
  .month-table {
    background: var(--container-bg);
    table-layout: fixed;
    height: 550px;
    border-collapse: collapse;
    padding: 0px !important;
    width: 100%;
    color: var(--table-fg);
  }
  
  
  .month-table td, .month-table th {
    border: 1px solid var(--sep);
    box-shadow: none;
    padding: 0px 8px;
  }
  
  .month-table th {
    padding-top: 6px;
    padding-bottom: 6px;
    text-align: center;
    background-color: var(--table-header-bg);
    color: var(--table-header-fg);
    border-bottom: 1px solid var(--table-header-fg);
    font-weight: 900;
    height: 30px;
  }
  
  .month-table .btn-left, .month-table .btn-right {
    display: inline-block;
    margin: 5px;
  }
  
  .month-table .btn-right {
    float: right;
  }
  
  .month-header {
    display: flex;
    background-color: var(--calendar-header-bg);
    text-align: center;
    
  }
  
  .month-header h2 {
    width: 100%;
    color: var(--calendar-header-fg);
    padding: 0;
    margin: 8px auto;
    font-size: 16px;
  }
  
  .month-table td .num {
    font-size: 10px;
    color: var(--calendar-number-fg);
    padding: 0px;
  }
  
  .month-table td {
    background-color: var(--calendar-month-bg);
    vertical-align: top;
    height: 80px;
    overflow: hidden;
  }
  
  .this-month {
    background-color: var(--calendar-this-month-bg) !important;
  }
  
  .today {
    font-weight: bold;
    border: 1px solid var(--calendar-today-fg);
    border-radius: 50%;
    padding: 0px 4px !important;
    color: var(--calendar-today-fg) !important;
  }
  .month-table .btn-left, .month-table .btn-right {
    display: inline-block;
    margin: 5px;
  }
  .btn-left, .btn-right {
    padding-top: 1px;
    padding-left: 0px;
    padding-right: 0px;
    padding-bottom: 1px;
    transition: none;
    height: 32px;
  }`;
}