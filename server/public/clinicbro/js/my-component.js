customElements.define('my-component', class MyComponent extends HTMLElement {
    // This method runs when your custom element is added to the page
    connectedCallback() {
      const root = this.attachShadow({ mode: 'open' });
      root.innerHTML = `
        <button hx-get="/my-component-clicked" hx-target="next div">Click me!</button>
        <div></div>
      `;
      htmx.process(root); // Tell HTMX about this component's shadow DOM
    }
  });