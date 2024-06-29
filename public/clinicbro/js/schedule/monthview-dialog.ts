import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import { styleMap } from 'lit/directives/style-map.js';
import { DragController } from './dragcontroller';
import { toIsoDateString, toIsoTimeString, combineDateWithTimeString} from './../util';
import { MonthViewAppointment } from './monthview-appt';

@customElement("mv-dialog")
export class MonthViewDialog extends LitElement {
    // @ts-ignore
    @property({type: Boolean, reflect: true})
    opened: boolean;

    // @ts-ignore
    @property({type: String})
    window_title: string;

    // @ts-ignore
    @property({type: Number, reflect: true})
    appt_id: number;

    // @ts-ignore
    @property({type: String, reflect: true})
    appt_title: string;

    // @ts-ignore
    @property({converter(value) {return new Date(value);}})
    appt_date: Date;

    // @ts-ignore
    @property({converter(value) {return new Date(value);}})
    appt_from: Date;

    // @ts-ignore
    @property({converter(value) {return new Date(value);}})
    appt_to: Date;


    constructor () {
        super();
        this.opened = false;
        this.window_title = "Window";
        this.appt_title = "";
        this.appt_id = 0;
        this.appt_date = new Date();
        this.appt_from = new Date();
        this.appt_to = new Date();
    }

    private _apptTitleKeyDown(e) {
        if(e.code === 'Enter') {
            this.dispatchEvent(new CustomEvent('dialog.save'));
        }
    }

    public apptDate() {
        let appt_date_input = this.shadowRoot.querySelector("#appt_date");
        return new Date(appt_date_input.value + "T00:00:00");
    }

    public ready() {
        let appt_title_input = this.shadowRoot.querySelector("#appt_title");
        appt_title_input.value = this.appt_title;

        let appt_date_input = this.shadowRoot.querySelector("#appt_date");
        appt_date_input.value = toIsoDateString(this.appt_date);

        let appt_from_input = this.shadowRoot.querySelector("#appt_from");
        appt_from_input.value = toIsoTimeString(this.appt_from);

        let appt_to_input = this.shadowRoot.querySelector("#appt_to");
        appt_to_input.value = toIsoTimeString(this.appt_to);
    }

    public collect() {
        let appt_title_input = this.shadowRoot.querySelector("#appt_title");
        this.appt_title = appt_title_input.value;

        let appt_date_input = this.shadowRoot.querySelector("#appt_date");
        this.appt_date = new Date(appt_date_input.value + "T00:00:00");

        let appt_from_input = this.shadowRoot.querySelector("#appt_from");
        this.appt_from = combineDateWithTimeString(this.apptDate(), appt_from_input.value);

        let appt_to_input = this.shadowRoot.querySelector("#appt_to");
        this.appt_to = combineDateWithTimeString(this.apptDate(), appt_to_input.value);
    }

    public updateDate(new_date: Date) {
        this.collect();
        this.appt_date = new_date;
        this.ready();
    }

    updated(changedProperties) {
        //console.log(changedProperties); // logs previous values
        if(changedProperties.has('opened')) {
          if(this.opened) {
            this.shadowRoot.querySelector("#appt_title").focus();
          }
          else {
            this.drag.resetPosition();
          }
          
          
        }
        // if(changedProperties.has('appt_from')) {
        //     let appt_from = this.shadowRoot.querySelector("#appt_from");
        //     appt_from.value = toIsoTimeString(this.appt_from);
        // }
        // if(changedProperties.has('appt_to')) {
        //     let appt_to = this.shadowRoot.querySelector("#appt_to");
        //     appt_to.value = toIsoTimeString(this.appt_to);
        // }
        // if(changedProperties.has('appt_date')) {
        //     let appt_date = this.shadowRoot.querySelector("#appt_date");
        //     appt_date.value = toIsoDateString(this.appt_date);
        // }
        // if(changedProperties.has('appt_title')) {
        //     let appt_title = this.shadowRoot.querySelector("#appt_title");
        //     appt_title.value = this.appt_title;
        // }
    }

    

    drag = new DragController(this, {
        getContainerEl: () => this.shadowRoot.querySelector("#window"),
        getDraggableEl: () => this.getDraggableEl(),
    });

    async getDraggableEl() {
        await this.updateComplete;
        return this.shadowRoot.querySelector("#draggable");
    }

    static styles = css`
    .opened {
        display: flex;
    }
    .closed {
        display: none;
    }
    .header {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        background-color: var(--header-bg);
        color: var(--header-fg);
        height: 30px;
        text-align: center;
        box-shadow: 0 0 4px var(--container-shadow);
        user-select: none;
    }

    [data-dragging="idle"] {
      cursor: grab;
    }

    [data-dragging="dragging"] {
      cursor: grabbing;
    }

    .dialog {
        flex-direction: column;
        padding: 0;
        margin: 1em;
        border: 2px outset var(--container-border);
        border-radius: 3px;
        background-color: var(--container-bg);
        width: 512px;
    }
    .content {
        margin: 40px 8px 10px 8px;
        text-align: center;
    }
    .title {
        margin-top: 4px;
    }
    .closebtn {
        position: absolute;
        top: 0px;
        right: 0px;
        width: 25px;
        height: 100%;
        padding: 0px auto;
        border-radius: 0;
        background-color: transparent;
        color: var(--dialog-header-fg);
        font-size: 16px;
        border: none;
    }

    .closebtn:hover {
        background-color: light-dark(darkred, red);
        border: 1px solid var(--header-fg);
        cursor: pointer;
    }

    .buttons {
        display: table;
        margin: 4px auto;
        text-align: center;
    }

    .btn {
        justify-content: space-around;
        align-content: space-around;
        padding: 8px 16px;
        cursor: pointer;
        border-radius: 3px;
        border: 1px solid var(--input-border);
        margin: 6px 2px;
        font-weight: bold;
    }

    .btn-save {
        background-color: var(--btn-save-bg);
        color: var(--btn-save-fg);
    }
    .btn-save:hover {
        background-color: var(--btn-save-hover-bg);
        color: var(--btn-save-bg);
    }
    
    .btn-cancel {
        background-color: var(--btn-cancel-bg);
        color: var(--btn-cancel-fg);
    }
    .btn-cancel:hover {
        background-color: var(--btn-cancel-fg);
        color: var(--btn-cancel-bg);
    }
    
    .text-field {
        position: relative;
        margin: 5px 2.5px 5px 2.5px;
    }

    .text-field input + label {
        position: absolute;
        pointer-events: none;
        left: 10px;
        top: 12px;
        transition: 0.2s;
        color: var(--placeholder-fg);
    }

    .text-field input:focus, .text-field input:valid {
        background-color: var(--container-bg);
    }

    .text-field input:focus + label, .text-field input:valid + label {
        top: -6px;
        left: 15px;
        font-size: small;
        padding: 0 5px 0 5px;
        background-color: var(--container-bg);
        color: var(--fg);
    }

        
    input {
        width: 100%;
        border: 1px solid var(--input-border);
        padding: 6px 10px;
        margin: 6px 2px;
        box-sizing: border-box;
        border-radius: 3px;
        font-size: 14px;
        background-color: var(--bg);
        color: var(--fg);
    }

    input[type=date], input[type=time] {
        text-indent: 35px;
    }

    input[type=date]:focus, input[type=date]:valid,
    input[type=time]:focus, input[type=time]:valid {
        text-indent: 0px;
    }

    .time-inputs {
        display: block;
        width: 100%;
        margin: 0;
        margin-left: 1px;
        padding: 0;
        text-align: left;
    }

    .time-input {
        /* vertical-align: middle; */
        display: inline-block;
        margin: 0;
        padding: 0;
        width: 150px;
    }

    .date-container {
        width: 306px;
    }

    ::placeholder {
        color: var(--placeholder-fg);
        opacity: 1; /* Firefox */
    }

    ::-ms-input-placeholder { /* Edge 12-18 */
        color: var(--placeholder-fg);
    }

    `;

    render() {
        return this.renderEvent();
    }
    renderEvent() {
        
        return html`
        <div id="window" class="${classMap({dialog: true, opened: this.opened, closed: !this.opened})}" style=${styleMap(this.drag.styles)}>
            <div id="draggable" class="header" data-dragging=${this.drag.state}>
                <h4 class="title">${this.window_title}</h4>
                <button class="closebtn" @click="${() => this.dispatchEvent(new CustomEvent('dialog.cancel'))}">&times;</button>
            </div>
            <div class="content">
                <div class="text-field">
                    <input id="appt_title" type="text" name="type" maxlength="255" @keydown="${this._apptTitleKeyDown}"
                        value="${this.appt_title}" required>
                    <label for="type">Title</label>
                </div>
                <div class="date-container">
                    <div class="text-field">
                        <input id="appt_date" type="date" name="date"
                            value="${toIsoDateString(this.appt_date)}" required>
                        <label for="date">Date</label>
                    </div>
                </div>
                <div class="time-inputs">
                    <div class="text-field time-input">
                        <input id="appt_from" type="time" name="from" required>
                        <label for="from">From</label>
                    </div>
                    <div class="text-field time-input">
                        <input id="appt_to" type="time" name="to" required>
                        <label for="to">&nbsp;&nbsp;&nbsp;To</label>
                    </div>
                </div>
                
                <div class="buttons">
                    <button type="button" class="btn btn-save" @click="${() => this.dispatchEvent(new CustomEvent('dialog.save'))}">Save</button>  
                    <button type="button" class="btn btn-cancel" @click="${() => this.dispatchEvent(new CustomEvent('dialog.cancel'))}">Cancel</button>  
                </div>
            </div>
        </div>`;
    }
}