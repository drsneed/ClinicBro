import PointerTracker from "pointer-tracker";

export class DragController {
    x = 0;
    y = 0;
    state = "idle";

    styles = {
        position: "absolute",
        top: "0px",
        left: "-5px",
        // top: "calc(50% - 128px)",
        //left: "calc(50% - 256px)",
    };

    constructor(host, options) {
        const {
            getContainerEl = () => null,
            getDraggableEl = () => Promise.resolve(null),
        } = options;

        this.host = host;
        this.host.addController(this);
        this.getContainerEl = getContainerEl;

        getDraggableEl().then((el) => {
            if (!el) return;

            this.draggableEl = el;
            this.init();
        });
    }

    resetPosition() {
        this.x = 0;
        this.y = 0;
        this.updateElPosition();
    }

  init() {
    this.pointerTracker = new PointerTracker(this.draggableEl, {
      start: (pointer, event) => {
        this.onDragStart(pointer);
        this.state = "dragging";
        this.host.requestUpdate();
        return true;
      },
      move: (previousPointers, changedPointers, event) => {
        this.onDrag(changedPointers[0]);
      },
      end: (pointer, event, cancelled) => {
        this.state = "idle";
        this.host.requestUpdate();
      },
    });
  }
  

  hostDisconnected() {
    if (this.pointerTracker) {
        this.pointerTracker.stop();
    }
  }

  onDragStart = (pointer) => {
    this.cursorPositionX = Math.floor(pointer.pageX);
    this.cursorPositionY = Math.floor(pointer.pageY);
  };

  onDrag(pointer) {
    const el = this.draggableEl;
    const containerEl = this.getContainerEl();
  
    if (!el || !containerEl) return;
  
    const oldX = this.x;
    const oldY = this.y;
  
    //JavaScript’s floats can be weird, so we’re flooring these to integers.
    const parsedTop = Math.floor(pointer.pageX);
    const parsedLeft = Math.floor(pointer.pageY);
  
    //JavaScript’s floats can be weird, so we’re flooring these to integers.
    const cursorPositionX = Math.floor(pointer.pageX);
    const cursorPositionY = Math.floor(pointer.pageY);
  
    const hasCursorMoved =
      cursorPositionX !== this.cursorPositionX ||
      cursorPositionY !== this.cursorPositionY;
  
    // We only need to calculate the window position if the cursor position has changed.
    if (hasCursorMoved) {
      const { bottom, height } = el.getBoundingClientRect();
      const { right, width } = containerEl.getBoundingClientRect();
  
      // The difference between the cursor’s previous position and its current position.
      const xDelta = cursorPositionX - this.cursorPositionX;
      const yDelta = cursorPositionY - this.cursorPositionY;
  
      // The happy path - if the element doesn’t attempt to go beyond the browser’s boundaries.
      this.x = oldX + xDelta;
      this.y = oldY + yDelta;
  
      const outOfBoundsTop = this.y < 0;
      const outOfBoundsLeft = this.x < 0;
      const outOfBoundsBottom = bottom + yDelta > window.innerHeight;
      const outOfBoundsRight = right + xDelta >= window.innerWidth;
  
      const isOutOfBounds =
        outOfBoundsBottom ||
        outOfBoundsLeft ||
        outOfBoundsRight ||
        outOfBoundsTop;
  
      // Set the cursor positions for the next time this function is invoked.
      this.cursorPositionX = cursorPositionX;
      this.cursorPositionY = cursorPositionY;
  
      // Otherwise, we force the window to remain within the browser window.
    //   if (outOfBoundsTop) {
    //     this.y = 0;
    //   } else if (outOfBoundsLeft) {
    //     this.x = 0;
    //   } else if (outOfBoundsBottom) {
    //     this.y = window.innerHeight - height;
    //   } else if (outOfBoundsRight) {
    //     this.x = Math.floor(window.innerWidth - width);
    //   }
  
      this.updateElPosition();
      // We trigger a lifecycle update.
      this.host.requestUpdate();
    }
  }
  
  updateElPosition() {
      this.styles.transform = `translate(${this.x}px, ${this.y}px)`;
  }
}
