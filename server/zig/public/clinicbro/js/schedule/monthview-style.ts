import {css} from 'lit';
export function monthviewStyle() {
    return css`
  .month-table, .day-table {
    background: var(--container-bg);
    table-layout: fixed;
    //height: 550px;
    border-collapse: separate;
    border-spacing: 0;
    padding: 0px !important;
    margin: 0px;
    width: 100%;
    color: var(--table-fg);
  }

  .month-table td, .month-table th, .day-table td, .day-table th {
    border: 1px solid var(--input-border);
    box-shadow: none;
    width: auto !important;
  }

  .month-table thead, .day-table thead {
    text-align: center;
  }

  .month-table td {
    background-color: var(--bg);
    vertical-align: top;
    height: 90px;
    overflow: hidden;
    padding: 0;
  }

  .month-table tr, .day-table tr {
    white-space: nowrap;
  }
  
  .day-table td {
    background-color: var(--bg);
    vertical-align: top;
    height: 90px;
    overflow-y: visible;
    padding: 0;
  }

  .caption {
    position: sticky;
  }
  
  .header-item {
    width: 150px;
    text-align: left;
  }
  .scheduler-button-bar {
    display: flex;
    overflow: hidden;
    margin: 6px 8px;
  }

  .float-right {
    float: right;
  }

  .btn-left {
    margin-top: 6px;
    margin-left: 8px;
    margin-right: 0px;
    margin-bottom: 6px;
  }
  .btn-right {
    margin: 6px 0px;
  }
  .btn-left, .btn-right {
    display: inline-block;
    padding: 4px 8px;
    height: 25px;
    transition: none;
    cursor: pointer;
  }
  .scheduler-button-bar button {
    margin: 0px;
    height: 32px;
    padding: 4px 8px;
    cursor: pointer;
  }
  .scheduler-button-bar {
    margin-bottom: 4px;
  }

  .btn-first {
    border-top-left-radius: 6px;
    border-bottom-left-radius: 6px;
    border-top-right-radius: 0px;
    border-bottom-right-radius: 0px;
  }

  .btn-middle {
    border-radius: 0px;
  }

  .btn-last {
    border-top-left-radius: 0px;
    border-bottom-left-radius: 0px;
    border-top-right-radius: 6px;
    border-bottom-right-radius: 6px;
  }

  .scheduler-container {
    overflow-y: visible;
  }
  
  .row1 {
    position: sticky;
    top: 0;
    background-color: var(--container-bg);
    z-index: 1;
    padding: 0;
  }
  .row2 {
    position: sticky;
    background-color: var(--container-bg);
    border-bottom: 1px solid var(--table-header-fg) !important;
    top: 44px;
    z-index: 1;
  }



  .sticky-header {
    border-bottom: 1px solid var(--table-header-fg);
    text-align: center;
    background-color: var(--container-bg);
    color: var(--container-fg);
    font-weight: 900;
    width: 100%;
    margin: 0;
  }

  .btn-pressed {
    border-style:inset;
    background-color: var(--btn-pressed);
  }

  .no-border {
    border-bottom: none !important;
  }

  caption {
    width: 100%;
  }

  .month-header {
    display: flex;
    background-color: var(--header-bg);
    text-align: center;
    margin: 0;
  }

  .row2, .day-header {
    padding-top: 4px;
    padding-bottom: 4px;
  }
  
  .month-header h2 {
    width: 50%;
    color: var(--header-fg);
    padding: 0;
    margin: 8px auto;
    font-size: 20px;
  }

  .half-hour-mark {
    position: relative;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    border-top: 2px dashed #8d5603;
    color: inherit;
    background-color: inherit;
    height: 1px;
    width: 100%;

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
  .num:link, .num:visited {
      color: var(--link);
      text-decoration: none;
  }
  .num:hover {
      color: var(--fg);
      font-weight: bold;
  }
  .today {
    border: 1px solid var(--calendar-today-fg);
    color: var(--calendar-today-fg) !important;
  }
  .weekheader {
    font-size: 14px;
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
    font-weight: bold;
  }
  .weekheader:link, .weekheader:visited {
      color: var(--link);
      text-decoration: none;
  }
  .weekheader:hover {
      color: var(--fg);
  }
  .weekheadertoday {
    color: var(--calendar-today-fg) !important;
  }
  `;
}