import {html, css, LitElement} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import { styleMap } from 'lit/directives/style-map.js';
import { DragController } from './dragcontroller';

@customElement("mv-dialog")
export class MonthViewDialog extends LitElement {
    // @ts-ignore
    @property({type: Boolean, reflect: true})
    opened: boolean;

    // @ts-ignore
    @property({type: String})
    title: string;


    constructor () {
        super();
        this.opened = false;
        this.title = "Window";
    }

    updated(changedProperties) {
        //console.log(changedProperties); // logs previous values
        if(changedProperties.has('opened')) {
          this.drag.reset();
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
        margin: 6px;
        font-weight: bold;
    }

    .btn-save {
        background-color: var(--btn-save-bg);
        color: var(--btn-save-fg);
    }
    .btn-save:hover {
        background-color: var(--btn-save-fg);
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

    `;

    render() {
        
        return html`
        <div id="window" class="${classMap({dialog: true, opened: this.opened, closed: !this.opened})}" style=${styleMap(this.drag.styles)}>
            <div id="draggable" class="header" data-dragging=${this.drag.state}>
                <h4 class="title">${this.title}</h4>
                <button class="closebtn" @click="${() => this.dispatchEvent(new CustomEvent('dialog.cancel'))}">&times;</button>
            </div>
            <div class="content">
                <form>
                    <div class="text-field">
                        <input type="text" name="name" size="20" maxlength="255" 
                            aria-label="Name"
                            aria-required="true"
                            spellcheck="false"
                            required>
                        <label for="name">Name</label>
                    </div>
                    <div class="text-field">
                        <input type="date" name="date" size="20" maxlength="255" 
                            aria-label="Date"
                            aria-required="true"
                            spellcheck="false"
                            required>
                        <label for="date">Date</label>
                    </div>
                    <div class="text-field">
                        <input type="time" name="from" size="20" maxlength="255" 
                            aria-label="From"
                            aria-required="true"
                            spellcheck="false"
                            required>
                        <label for="from">From</label>
                    </div>
                    <div class="text-field">
                        <input type="time" name="to" size="20" maxlength="255" 
                            aria-label="To"
                            aria-required="true"
                            spellcheck="false"
                            required>
                        <label for="to">To</label>
                    </div>
                    <div class="buttons">
                        <button class="btn btn-cancel" @click="${() => this.dispatchEvent(new CustomEvent('dialog.cancel'))}">Cancel</button>
                        <button class="btn btn-save" @click="${() => this.dispatchEvent(new CustomEvent('dialog.save'))}">Save</button>    
                    </div>
                </form>
            </div>
        </div>`;
    }
}