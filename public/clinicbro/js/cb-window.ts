import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import { styleMap } from 'lit/directives/style-map.js';
import { DragController } from './dragcontroller';

@customElement("cb-window")
export class CBWindow extends LitElement {
    // @ts-ignore
    @property({type: Boolean, reflect: true})
    opened: boolean;

    // @ts-ignore
    @property({type: String})
    window_title: string;

    // @ts-ignore
    @property({type: String, reflect: true})
    top: string;

    // @ts-ignore
    @property({type: String, reflect: true})
    left: string;

    constructor () {
        super();
        this.opened = false;
        this.window_title = "Window";
        this.top = "0";
        this.left = "-5px";
    }


    public ready() {
        
    }

    public collect() {
        
    }

    updated(changedProperties) {
        //console.log(changedProperties); // logs previous values
        if(changedProperties.has('opened')) {
          if(this.opened) {
            //this.shadowRoot.querySelector("#appt_title").focus();
          }
          else {
            this.drag.resetPosition();
          }
        }
        if(changedProperties.has("top")) {
            this.drag.styles.top = this.top;
            this.requestUpdate();
        }
        if(changedProperties.has("left")) {
            this.drag.styles.left = this.left;
            this.requestUpdate();
        }
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
    }
    .content {
        margin: 40px 8px 10px 8px;
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
        
        return html`
        <div id="window" class="${classMap({dialog: true, opened: this.opened, closed: !this.opened})}"
             style=${styleMap(this.drag.styles)}>
            <div id="draggable" class="header" data-dragging=${this.drag.state}>
                <h4 class="title">${this.window_title}</h4>
                <button class="closebtn" @click="${() => this.opened = false}">&times;</button>
            </div>
            <div class="content">
                <slot></slot>
            </div>
        </div>`;
    }
}