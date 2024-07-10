import {css} from 'lit';
export function monthviewStyle() {
    return css`
  .month-table {
    background: var(--container-bg);
    table-layout: fixed;
    //height: 550px;
    border-collapse: collapse;
    padding: 0px !important;
    margin: 0px;
    width: 100%;
    color: var(--table-fg);
  }
  
  .scheduler-button-bar {
    display: flex;
    overflow: hidden;
    text-align: center;
}
  .month-table td, .month-table th {
    border: 1px solid var(--sep);
    box-shadow: none;
    width: auto !important;
    padding: 0px;
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
    background-color: var(--header-bg);
    text-align: center;
    
  }
  
  .month-header h2 {
    width: 100%;
    color: var(--header-fg);
    padding: 0;
    margin: 8px auto;
    font-size: 16px;
  }
  
  .month-table td {
    background-color: var(--calendar-month-bg);
    vertical-align: top;
    height: 80px;
    overflow: hidden;
  }

  .month-table tr {
    white-space: nowrap;
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