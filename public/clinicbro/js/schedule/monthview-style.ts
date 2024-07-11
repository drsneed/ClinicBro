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
    transition: none;
    cursor: pointer;
  }


  .scheduler-button-bar button {
    margin: 0px;
    padding: 4px 8px;
    cursor: pointer;
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

  .month-table td, .month-table th {
    border: 1px solid var(--sep);
    box-shadow: none;
    width: auto !important;
    padding: 0px;
  }
  
  .month-table th {
    position: sticky;
    top: 0;
    padding-bottom: 6px;
    text-align: center;
    background-color: var(--table-header-bg);
    color: var(--table-header-fg);
    border-bottom: 1px solid var(--table-header-fg);
    font-weight: 900;
    height: 30px;
    width: 100%;
    z-index: 5;
  }

  caption {
    width: 100%;
  }

  .month-header {
    position: sticky;
    top: 0;
    display: flex;
    background-color: var(--header-bg);
    text-align: center;
    
  }

  .day-header {
    padding-top: 6px;
    padding-bottom: 6px;
  }
  
  .month-header h2 {
    width: 50%;
    color: var(--header-fg);
    padding: 0;
    margin: 8px auto;
    font-size: 20px;
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
  
  .day-view-hour {
        width: 100%;
        height: 100px;
        max-width: 100%;
        white-space: nowrap;
        user-select: none;
        overflow-y: auto;
  }
  `;
}