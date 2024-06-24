class ColorCustomizer extends HTMLElement {
  constructor() {
    super();
    this.innerHTML = /* html */ `
      <button popovertarget="color-customizer-dialog">Customize colors</button>
      <dialog id="color-customizer-dialog" popover>
        <h2>Customize colors</h2>
        <form method="dialog">
          <label>
            <span>Background</span>
            <input type="color" name="bg">
          </label>
          <label>
            <span>Text</span>
            <input type="color" name="fg">
          </label>
          <label>
            <span>Links</span>
            <input type="color" name="link-color">
          </label>
          <label>
            <span>Borders</span>
            <input type="color" name="line-color">
          </label>
          <div class="buttons">
            <button type="submit">Apply</button>
            <button type="reset">Reset</button>
          </div>
      </dialog>
    `;
    const openButton = this.querySelector("button[popovertarget]");
    const form = this.querySelector("form");
    const backgroundInput = this.querySelector('[name="bg"]');
    const colorInput = this.querySelector('[name="fg"]');
    const linkColorInput = this.querySelector('[name="link-color"]');
    const borderColorInput = this.querySelector('[name="line-color"]');
    const resetButton = this.querySelector('[type="reset"]');

    openButton.onclick = () => {
      backgroundInput.value = localStorage.getItem("bg") ??
        getComputedStyle(document.documentElement)
          .getPropertyValue("--bg");
      colorInput.value = localStorage.getItem("fg") ??
        getComputedStyle(document.documentElement)
          .getPropertyValue("--fg");
      linkColorInput.value = localStorage.getItem("link-color") ??
        getComputedStyle(document.documentElement)
          .getPropertyValue("--link-color");
      borderColorInput.value = localStorage.getItem("line-color") ??
        getComputedStyle(document.documentElement)
          .getPropertyValue("--line-color");
    }

    form.oninput = (e) => {
      const { name, value } = e.target;
      document.documentElement.style.setProperty(`--${name}`, value);
      localStorage.setItem(name, value);
    };

    resetButton.onclick = () => {
      document.documentElement.style.removeProperty("--bg");
      document.documentElement.style.removeProperty("--fg");
      document.documentElement.style.removeProperty("--link-color");
      document.documentElement.style.removeProperty("--line-color");

      localStorage.removeItem("bg");
      localStorage.removeItem("fg");
      localStorage.removeItem("link-color");
      localStorage.removeItem("line-color");

      backgroundInput.value = getComputedStyle(document.documentElement)
        .getPropertyValue("--bg");
      colorInput.value = getComputedStyle(document.documentElement)
        .getPropertyValue("--fg");
      linkColorInput.value = getComputedStyle(document.documentElement)
        .getPropertyValue("--link-color");
      borderColorInput.value = getComputedStyle(document.documentElement)
        .getPropertyValue("--line-color");
    };
  }
}

if (localStorage.getItem("bg")) {
  document.documentElement.style.setProperty(
    "--bg",
    localStorage.getItem("bg")
  );
}
if (localStorage.getItem("fg")) {
  document.documentElement.style.setProperty(
    "--fg",
    localStorage.getItem("fg")
  );
}
if (localStorage.getItem("link-color")) {
  document.documentElement.style.setProperty(
    "--link-color",
    localStorage.getItem("link-color")
  );
}
if (localStorage.getItem("line-color")) {
  document.documentElement.style.setProperty(
    "--line-color",
    localStorage.getItem("line-color")
  );
}

customElements.define("color-customizer", ColorCustomizer);
