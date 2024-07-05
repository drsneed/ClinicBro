var __legacyDecorateClassTS = function(decorators, target, key, desc) {
  var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
  if (typeof Reflect === "object" && typeof Reflect.decorate === "function")
    r = Reflect.decorate(decorators, target, key, desc);
  else
    for (var i = decorators.length - 1;i >= 0; i--)
      if (d = decorators[i])
        r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
  return c > 3 && r && Object.defineProperty(target, key, r), r;
};

// node_modules/@lit/reactive-element/css-tag.js
var t = globalThis;
var e = t.ShadowRoot && (t.ShadyCSS === undefined || t.ShadyCSS.nativeShadow) && "adoptedStyleSheets" in Document.prototype && "replace" in CSSStyleSheet.prototype;
var s = Symbol();
var o = new WeakMap;

class n {
  constructor(t2, e2, o2) {
    if (this._$cssResult$ = true, o2 !== s)
      throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");
    this.cssText = t2, this.t = e2;
  }
  get styleSheet() {
    let t2 = this.o;
    const s2 = this.t;
    if (e && t2 === undefined) {
      const e2 = s2 !== undefined && s2.length === 1;
      e2 && (t2 = o.get(s2)), t2 === undefined && ((this.o = t2 = new CSSStyleSheet).replaceSync(this.cssText), e2 && o.set(s2, t2));
    }
    return t2;
  }
  toString() {
    return this.cssText;
  }
}
var r = (t2) => new n(typeof t2 == "string" ? t2 : t2 + "", undefined, s);
var i = (t2, ...e2) => {
  const o2 = t2.length === 1 ? t2[0] : e2.reduce((e3, s2, o3) => e3 + ((t3) => {
    if (t3._$cssResult$ === true)
      return t3.cssText;
    if (typeof t3 == "number")
      return t3;
    throw Error("Value passed to 'css' function must be a 'css' function result: " + t3 + ". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.");
  })(s2) + t2[o3 + 1], t2[0]);
  return new n(o2, t2, s);
};
var S = (s2, o2) => {
  if (e)
    s2.adoptedStyleSheets = o2.map((t2) => t2 instanceof CSSStyleSheet ? t2 : t2.styleSheet);
  else
    for (const e2 of o2) {
      const o3 = document.createElement("style"), n2 = t.litNonce;
      n2 !== undefined && o3.setAttribute("nonce", n2), o3.textContent = e2.cssText, s2.appendChild(o3);
    }
};
var c = e ? (t2) => t2 : (t2) => t2 instanceof CSSStyleSheet ? ((t3) => {
  let e2 = "";
  for (const s2 of t3.cssRules)
    e2 += s2.cssText;
  return r(e2);
})(t2) : t2;

// node_modules/@lit/reactive-element/reactive-element.js
var { is: i2, defineProperty: e2, getOwnPropertyDescriptor: r2, getOwnPropertyNames: h, getOwnPropertySymbols: o2, getPrototypeOf: n2 } = Object;
var a = globalThis;
var c2 = a.trustedTypes;
var l = c2 ? c2.emptyScript : "";
var p = a.reactiveElementPolyfillSupport;
var d = (t2, s2) => t2;
var u = { toAttribute(t2, s2) {
  switch (s2) {
    case Boolean:
      t2 = t2 ? l : null;
      break;
    case Object:
    case Array:
      t2 = t2 == null ? t2 : JSON.stringify(t2);
  }
  return t2;
}, fromAttribute(t2, s2) {
  let i3 = t2;
  switch (s2) {
    case Boolean:
      i3 = t2 !== null;
      break;
    case Number:
      i3 = t2 === null ? null : Number(t2);
      break;
    case Object:
    case Array:
      try {
        i3 = JSON.parse(t2);
      } catch (t3) {
        i3 = null;
      }
  }
  return i3;
} };
var f = (t2, s2) => !i2(t2, s2);
var y = { attribute: true, type: String, converter: u, reflect: false, hasChanged: f };
Symbol.metadata ??= Symbol("metadata"), a.litPropertyMetadata ??= new WeakMap;

class b extends HTMLElement {
  static addInitializer(t2) {
    this._$Ei(), (this.l ??= []).push(t2);
  }
  static get observedAttributes() {
    return this.finalize(), this._$Eh && [...this._$Eh.keys()];
  }
  static createProperty(t2, s2 = y) {
    if (s2.state && (s2.attribute = false), this._$Ei(), this.elementProperties.set(t2, s2), !s2.noAccessor) {
      const i3 = Symbol(), r3 = this.getPropertyDescriptor(t2, i3, s2);
      r3 !== undefined && e2(this.prototype, t2, r3);
    }
  }
  static getPropertyDescriptor(t2, s2, i3) {
    const { get: e3, set: h2 } = r2(this.prototype, t2) ?? { get() {
      return this[s2];
    }, set(t3) {
      this[s2] = t3;
    } };
    return { get() {
      return e3?.call(this);
    }, set(s3) {
      const r3 = e3?.call(this);
      h2.call(this, s3), this.requestUpdate(t2, r3, i3);
    }, configurable: true, enumerable: true };
  }
  static getPropertyOptions(t2) {
    return this.elementProperties.get(t2) ?? y;
  }
  static _$Ei() {
    if (this.hasOwnProperty(d("elementProperties")))
      return;
    const t2 = n2(this);
    t2.finalize(), t2.l !== undefined && (this.l = [...t2.l]), this.elementProperties = new Map(t2.elementProperties);
  }
  static finalize() {
    if (this.hasOwnProperty(d("finalized")))
      return;
    if (this.finalized = true, this._$Ei(), this.hasOwnProperty(d("properties"))) {
      const t3 = this.properties, s2 = [...h(t3), ...o2(t3)];
      for (const i3 of s2)
        this.createProperty(i3, t3[i3]);
    }
    const t2 = this[Symbol.metadata];
    if (t2 !== null) {
      const s2 = litPropertyMetadata.get(t2);
      if (s2 !== undefined)
        for (const [t3, i3] of s2)
          this.elementProperties.set(t3, i3);
    }
    this._$Eh = new Map;
    for (const [t3, s2] of this.elementProperties) {
      const i3 = this._$Eu(t3, s2);
      i3 !== undefined && this._$Eh.set(i3, t3);
    }
    this.elementStyles = this.finalizeStyles(this.styles);
  }
  static finalizeStyles(s2) {
    const i3 = [];
    if (Array.isArray(s2)) {
      const e3 = new Set(s2.flat(1 / 0).reverse());
      for (const s3 of e3)
        i3.unshift(c(s3));
    } else
      s2 !== undefined && i3.push(c(s2));
    return i3;
  }
  static _$Eu(t2, s2) {
    const i3 = s2.attribute;
    return i3 === false ? undefined : typeof i3 == "string" ? i3 : typeof t2 == "string" ? t2.toLowerCase() : undefined;
  }
  constructor() {
    super(), this._$Ep = undefined, this.isUpdatePending = false, this.hasUpdated = false, this._$Em = null, this._$Ev();
  }
  _$Ev() {
    this._$ES = new Promise((t2) => this.enableUpdating = t2), this._$AL = new Map, this._$E_(), this.requestUpdate(), this.constructor.l?.forEach((t2) => t2(this));
  }
  addController(t2) {
    (this._$EO ??= new Set).add(t2), this.renderRoot !== undefined && this.isConnected && t2.hostConnected?.();
  }
  removeController(t2) {
    this._$EO?.delete(t2);
  }
  _$E_() {
    const t2 = new Map, s2 = this.constructor.elementProperties;
    for (const i3 of s2.keys())
      this.hasOwnProperty(i3) && (t2.set(i3, this[i3]), delete this[i3]);
    t2.size > 0 && (this._$Ep = t2);
  }
  createRenderRoot() {
    const t2 = this.shadowRoot ?? this.attachShadow(this.constructor.shadowRootOptions);
    return S(t2, this.constructor.elementStyles), t2;
  }
  connectedCallback() {
    this.renderRoot ??= this.createRenderRoot(), this.enableUpdating(true), this._$EO?.forEach((t2) => t2.hostConnected?.());
  }
  enableUpdating(t2) {
  }
  disconnectedCallback() {
    this._$EO?.forEach((t2) => t2.hostDisconnected?.());
  }
  attributeChangedCallback(t2, s2, i3) {
    this._$AK(t2, i3);
  }
  _$EC(t2, s2) {
    const i3 = this.constructor.elementProperties.get(t2), e3 = this.constructor._$Eu(t2, i3);
    if (e3 !== undefined && i3.reflect === true) {
      const r3 = (i3.converter?.toAttribute !== undefined ? i3.converter : u).toAttribute(s2, i3.type);
      this._$Em = t2, r3 == null ? this.removeAttribute(e3) : this.setAttribute(e3, r3), this._$Em = null;
    }
  }
  _$AK(t2, s2) {
    const i3 = this.constructor, e3 = i3._$Eh.get(t2);
    if (e3 !== undefined && this._$Em !== e3) {
      const t3 = i3.getPropertyOptions(e3), r3 = typeof t3.converter == "function" ? { fromAttribute: t3.converter } : t3.converter?.fromAttribute !== undefined ? t3.converter : u;
      this._$Em = e3, this[e3] = r3.fromAttribute(s2, t3.type), this._$Em = null;
    }
  }
  requestUpdate(t2, s2, i3) {
    if (t2 !== undefined) {
      if (i3 ??= this.constructor.getPropertyOptions(t2), !(i3.hasChanged ?? f)(this[t2], s2))
        return;
      this.P(t2, s2, i3);
    }
    this.isUpdatePending === false && (this._$ES = this._$ET());
  }
  P(t2, s2, i3) {
    this._$AL.has(t2) || this._$AL.set(t2, s2), i3.reflect === true && this._$Em !== t2 && (this._$Ej ??= new Set).add(t2);
  }
  async _$ET() {
    this.isUpdatePending = true;
    try {
      await this._$ES;
    } catch (t3) {
      Promise.reject(t3);
    }
    const t2 = this.scheduleUpdate();
    return t2 != null && await t2, !this.isUpdatePending;
  }
  scheduleUpdate() {
    return this.performUpdate();
  }
  performUpdate() {
    if (!this.isUpdatePending)
      return;
    if (!this.hasUpdated) {
      if (this.renderRoot ??= this.createRenderRoot(), this._$Ep) {
        for (const [t4, s3] of this._$Ep)
          this[t4] = s3;
        this._$Ep = undefined;
      }
      const t3 = this.constructor.elementProperties;
      if (t3.size > 0)
        for (const [s3, i3] of t3)
          i3.wrapped !== true || this._$AL.has(s3) || this[s3] === undefined || this.P(s3, this[s3], i3);
    }
    let t2 = false;
    const s2 = this._$AL;
    try {
      t2 = this.shouldUpdate(s2), t2 ? (this.willUpdate(s2), this._$EO?.forEach((t3) => t3.hostUpdate?.()), this.update(s2)) : this._$EU();
    } catch (s3) {
      throw t2 = false, this._$EU(), s3;
    }
    t2 && this._$AE(s2);
  }
  willUpdate(t2) {
  }
  _$AE(t2) {
    this._$EO?.forEach((t3) => t3.hostUpdated?.()), this.hasUpdated || (this.hasUpdated = true, this.firstUpdated(t2)), this.updated(t2);
  }
  _$EU() {
    this._$AL = new Map, this.isUpdatePending = false;
  }
  get updateComplete() {
    return this.getUpdateComplete();
  }
  getUpdateComplete() {
    return this._$ES;
  }
  shouldUpdate(t2) {
    return true;
  }
  update(t2) {
    this._$Ej &&= this._$Ej.forEach((t3) => this._$EC(t3, this[t3])), this._$EU();
  }
  updated(t2) {
  }
  firstUpdated(t2) {
  }
}
b.elementStyles = [], b.shadowRootOptions = { mode: "open" }, b[d("elementProperties")] = new Map, b[d("finalized")] = new Map, p?.({ ReactiveElement: b }), (a.reactiveElementVersions ??= []).push("2.0.4");

// node_modules/lit-html/lit-html.js
var C = function(t2, i3) {
  if (!Array.isArray(t2) || !t2.hasOwnProperty("raw"))
    throw Error("invalid template strings array");
  return s2 !== undefined ? s2.createHTML(i3) : i3;
};
var N = function(t2, i3, s2 = t2, e3) {
  if (i3 === w)
    return i3;
  let h2 = e3 !== undefined ? s2._$Co?.[e3] : s2._$Cl;
  const o3 = c3(i3) ? undefined : i3._$litDirective$;
  return h2?.constructor !== o3 && (h2?._$AO?.(false), o3 === undefined ? h2 = undefined : (h2 = new o3(t2), h2._$AT(t2, s2, e3)), e3 !== undefined ? (s2._$Co ??= [])[e3] = h2 : s2._$Cl = h2), h2 !== undefined && (i3 = N(t2, h2._$AS(t2, i3.values), h2, e3)), i3;
};
var t2 = globalThis;
var i3 = t2.trustedTypes;
var s2 = i3 ? i3.createPolicy("lit-html", { createHTML: (t3) => t3 }) : undefined;
var e3 = "$lit$";
var h2 = `lit\$${Math.random().toFixed(9).slice(2)}\$`;
var o3 = "?" + h2;
var n3 = `<${o3}>`;
var r3 = document;
var l2 = () => r3.createComment("");
var c3 = (t3) => t3 === null || typeof t3 != "object" && typeof t3 != "function";
var a2 = Array.isArray;
var u2 = (t3) => a2(t3) || typeof t3?.[Symbol.iterator] == "function";
var d2 = "[ \t\n\f\r]";
var f2 = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g;
var v = /-->/g;
var _ = />/g;
var m = RegExp(`>|${d2}(?:([^\\s"'>=/]+)(${d2}*=${d2}*(?:[^ \t\n\f\r"'\`<>=]|("|')|))|\$)`, "g");
var p2 = /'/g;
var g = /"/g;
var $ = /^(?:script|style|textarea|title)$/i;
var y2 = (t3) => (i4, ...s3) => ({ _$litType$: t3, strings: i4, values: s3 });
var x = y2(1);
var b2 = y2(2);
var w = Symbol.for("lit-noChange");
var T = Symbol.for("lit-nothing");
var A = new WeakMap;
var E = r3.createTreeWalker(r3, 129);
var P = (t3, i4) => {
  const s3 = t3.length - 1, o4 = [];
  let r4, l3 = i4 === 2 ? "<svg>" : "", c4 = f2;
  for (let i5 = 0;i5 < s3; i5++) {
    const s4 = t3[i5];
    let a3, u3, d3 = -1, y3 = 0;
    for (;y3 < s4.length && (c4.lastIndex = y3, u3 = c4.exec(s4), u3 !== null); )
      y3 = c4.lastIndex, c4 === f2 ? u3[1] === "!--" ? c4 = v : u3[1] !== undefined ? c4 = _ : u3[2] !== undefined ? ($.test(u3[2]) && (r4 = RegExp("</" + u3[2], "g")), c4 = m) : u3[3] !== undefined && (c4 = m) : c4 === m ? u3[0] === ">" ? (c4 = r4 ?? f2, d3 = -1) : u3[1] === undefined ? d3 = -2 : (d3 = c4.lastIndex - u3[2].length, a3 = u3[1], c4 = u3[3] === undefined ? m : u3[3] === '"' ? g : p2) : c4 === g || c4 === p2 ? c4 = m : c4 === v || c4 === _ ? c4 = f2 : (c4 = m, r4 = undefined);
    const x2 = c4 === m && t3[i5 + 1].startsWith("/>") ? " " : "";
    l3 += c4 === f2 ? s4 + n3 : d3 >= 0 ? (o4.push(a3), s4.slice(0, d3) + e3 + s4.slice(d3) + h2 + x2) : s4 + h2 + (d3 === -2 ? i5 : x2);
  }
  return [C(t3, l3 + (t3[s3] || "<?>") + (i4 === 2 ? "</svg>" : "")), o4];
};

class V {
  constructor({ strings: t3, _$litType$: s3 }, n4) {
    let r4;
    this.parts = [];
    let c4 = 0, a3 = 0;
    const u3 = t3.length - 1, d3 = this.parts, [f3, v2] = P(t3, s3);
    if (this.el = V.createElement(f3, n4), E.currentNode = this.el.content, s3 === 2) {
      const t4 = this.el.content.firstChild;
      t4.replaceWith(...t4.childNodes);
    }
    for (;(r4 = E.nextNode()) !== null && d3.length < u3; ) {
      if (r4.nodeType === 1) {
        if (r4.hasAttributes())
          for (const t4 of r4.getAttributeNames())
            if (t4.endsWith(e3)) {
              const i4 = v2[a3++], s4 = r4.getAttribute(t4).split(h2), e4 = /([.?@])?(.*)/.exec(i4);
              d3.push({ type: 1, index: c4, name: e4[2], strings: s4, ctor: e4[1] === "." ? k : e4[1] === "?" ? H : e4[1] === "@" ? I : R }), r4.removeAttribute(t4);
            } else
              t4.startsWith(h2) && (d3.push({ type: 6, index: c4 }), r4.removeAttribute(t4));
        if ($.test(r4.tagName)) {
          const t4 = r4.textContent.split(h2), s4 = t4.length - 1;
          if (s4 > 0) {
            r4.textContent = i3 ? i3.emptyScript : "";
            for (let i4 = 0;i4 < s4; i4++)
              r4.append(t4[i4], l2()), E.nextNode(), d3.push({ type: 2, index: ++c4 });
            r4.append(t4[s4], l2());
          }
        }
      } else if (r4.nodeType === 8)
        if (r4.data === o3)
          d3.push({ type: 2, index: c4 });
        else {
          let t4 = -1;
          for (;(t4 = r4.data.indexOf(h2, t4 + 1)) !== -1; )
            d3.push({ type: 7, index: c4 }), t4 += h2.length - 1;
        }
      c4++;
    }
  }
  static createElement(t3, i4) {
    const s3 = r3.createElement("template");
    return s3.innerHTML = t3, s3;
  }
}

class S2 {
  constructor(t3, i4) {
    this._$AV = [], this._$AN = undefined, this._$AD = t3, this._$AM = i4;
  }
  get parentNode() {
    return this._$AM.parentNode;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  u(t3) {
    const { el: { content: i4 }, parts: s3 } = this._$AD, e4 = (t3?.creationScope ?? r3).importNode(i4, true);
    E.currentNode = e4;
    let h3 = E.nextNode(), o4 = 0, n4 = 0, l3 = s3[0];
    for (;l3 !== undefined; ) {
      if (o4 === l3.index) {
        let i5;
        l3.type === 2 ? i5 = new M(h3, h3.nextSibling, this, t3) : l3.type === 1 ? i5 = new l3.ctor(h3, l3.name, l3.strings, this, t3) : l3.type === 6 && (i5 = new L(h3, this, t3)), this._$AV.push(i5), l3 = s3[++n4];
      }
      o4 !== l3?.index && (h3 = E.nextNode(), o4++);
    }
    return E.currentNode = r3, e4;
  }
  p(t3) {
    let i4 = 0;
    for (const s3 of this._$AV)
      s3 !== undefined && (s3.strings !== undefined ? (s3._$AI(t3, s3, i4), i4 += s3.strings.length - 2) : s3._$AI(t3[i4])), i4++;
  }
}

class M {
  get _$AU() {
    return this._$AM?._$AU ?? this._$Cv;
  }
  constructor(t3, i4, s3, e4) {
    this.type = 2, this._$AH = T, this._$AN = undefined, this._$AA = t3, this._$AB = i4, this._$AM = s3, this.options = e4, this._$Cv = e4?.isConnected ?? true;
  }
  get parentNode() {
    let t3 = this._$AA.parentNode;
    const i4 = this._$AM;
    return i4 !== undefined && t3?.nodeType === 11 && (t3 = i4.parentNode), t3;
  }
  get startNode() {
    return this._$AA;
  }
  get endNode() {
    return this._$AB;
  }
  _$AI(t3, i4 = this) {
    t3 = N(this, t3, i4), c3(t3) ? t3 === T || t3 == null || t3 === "" ? (this._$AH !== T && this._$AR(), this._$AH = T) : t3 !== this._$AH && t3 !== w && this._(t3) : t3._$litType$ !== undefined ? this.$(t3) : t3.nodeType !== undefined ? this.T(t3) : u2(t3) ? this.k(t3) : this._(t3);
  }
  S(t3) {
    return this._$AA.parentNode.insertBefore(t3, this._$AB);
  }
  T(t3) {
    this._$AH !== t3 && (this._$AR(), this._$AH = this.S(t3));
  }
  _(t3) {
    this._$AH !== T && c3(this._$AH) ? this._$AA.nextSibling.data = t3 : this.T(r3.createTextNode(t3)), this._$AH = t3;
  }
  $(t3) {
    const { values: i4, _$litType$: s3 } = t3, e4 = typeof s3 == "number" ? this._$AC(t3) : (s3.el === undefined && (s3.el = V.createElement(C(s3.h, s3.h[0]), this.options)), s3);
    if (this._$AH?._$AD === e4)
      this._$AH.p(i4);
    else {
      const t4 = new S2(e4, this), s4 = t4.u(this.options);
      t4.p(i4), this.T(s4), this._$AH = t4;
    }
  }
  _$AC(t3) {
    let i4 = A.get(t3.strings);
    return i4 === undefined && A.set(t3.strings, i4 = new V(t3)), i4;
  }
  k(t3) {
    a2(this._$AH) || (this._$AH = [], this._$AR());
    const i4 = this._$AH;
    let s3, e4 = 0;
    for (const h3 of t3)
      e4 === i4.length ? i4.push(s3 = new M(this.S(l2()), this.S(l2()), this, this.options)) : s3 = i4[e4], s3._$AI(h3), e4++;
    e4 < i4.length && (this._$AR(s3 && s3._$AB.nextSibling, e4), i4.length = e4);
  }
  _$AR(t3 = this._$AA.nextSibling, i4) {
    for (this._$AP?.(false, true, i4);t3 && t3 !== this._$AB; ) {
      const i5 = t3.nextSibling;
      t3.remove(), t3 = i5;
    }
  }
  setConnected(t3) {
    this._$AM === undefined && (this._$Cv = t3, this._$AP?.(t3));
  }
}

class R {
  get tagName() {
    return this.element.tagName;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  constructor(t3, i4, s3, e4, h3) {
    this.type = 1, this._$AH = T, this._$AN = undefined, this.element = t3, this.name = i4, this._$AM = e4, this.options = h3, s3.length > 2 || s3[0] !== "" || s3[1] !== "" ? (this._$AH = Array(s3.length - 1).fill(new String), this.strings = s3) : this._$AH = T;
  }
  _$AI(t3, i4 = this, s3, e4) {
    const h3 = this.strings;
    let o4 = false;
    if (h3 === undefined)
      t3 = N(this, t3, i4, 0), o4 = !c3(t3) || t3 !== this._$AH && t3 !== w, o4 && (this._$AH = t3);
    else {
      const e5 = t3;
      let n4, r4;
      for (t3 = h3[0], n4 = 0;n4 < h3.length - 1; n4++)
        r4 = N(this, e5[s3 + n4], i4, n4), r4 === w && (r4 = this._$AH[n4]), o4 ||= !c3(r4) || r4 !== this._$AH[n4], r4 === T ? t3 = T : t3 !== T && (t3 += (r4 ?? "") + h3[n4 + 1]), this._$AH[n4] = r4;
    }
    o4 && !e4 && this.j(t3);
  }
  j(t3) {
    t3 === T ? this.element.removeAttribute(this.name) : this.element.setAttribute(this.name, t3 ?? "");
  }
}

class k extends R {
  constructor() {
    super(...arguments), this.type = 3;
  }
  j(t3) {
    this.element[this.name] = t3 === T ? undefined : t3;
  }
}

class H extends R {
  constructor() {
    super(...arguments), this.type = 4;
  }
  j(t3) {
    this.element.toggleAttribute(this.name, !!t3 && t3 !== T);
  }
}

class I extends R {
  constructor(t3, i4, s3, e4, h3) {
    super(t3, i4, s3, e4, h3), this.type = 5;
  }
  _$AI(t3, i4 = this) {
    if ((t3 = N(this, t3, i4, 0) ?? T) === w)
      return;
    const s3 = this._$AH, e4 = t3 === T && s3 !== T || t3.capture !== s3.capture || t3.once !== s3.once || t3.passive !== s3.passive, h3 = t3 !== T && (s3 === T || e4);
    e4 && this.element.removeEventListener(this.name, this, s3), h3 && this.element.addEventListener(this.name, this, t3), this._$AH = t3;
  }
  handleEvent(t3) {
    typeof this._$AH == "function" ? this._$AH.call(this.options?.host ?? this.element, t3) : this._$AH.handleEvent(t3);
  }
}

class L {
  constructor(t3, i4, s3) {
    this.element = t3, this.type = 6, this._$AN = undefined, this._$AM = i4, this.options = s3;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AI(t3) {
    N(this, t3);
  }
}
var Z = t2.litHtmlPolyfillSupport;
Z?.(V, M), (t2.litHtmlVersions ??= []).push("3.1.4");
var j = (t3, i4, s3) => {
  const e4 = s3?.renderBefore ?? i4;
  let h3 = e4._$litPart$;
  if (h3 === undefined) {
    const t4 = s3?.renderBefore ?? null;
    e4._$litPart$ = h3 = new M(i4.insertBefore(l2(), t4), t4, undefined, s3 ?? {});
  }
  return h3._$AI(t3), h3;
};
// node_modules/lit-element/lit-element.js
class s3 extends b {
  constructor() {
    super(...arguments), this.renderOptions = { host: this }, this._$Do = undefined;
  }
  createRenderRoot() {
    const t3 = super.createRenderRoot();
    return this.renderOptions.renderBefore ??= t3.firstChild, t3;
  }
  update(t3) {
    const i4 = this.render();
    this.hasUpdated || (this.renderOptions.isConnected = this.isConnected), super.update(t3), this._$Do = j(i4, this.renderRoot, this.renderOptions);
  }
  connectedCallback() {
    super.connectedCallback(), this._$Do?.setConnected(true);
  }
  disconnectedCallback() {
    super.disconnectedCallback(), this._$Do?.setConnected(false);
  }
  render() {
    return w;
  }
}
s3._$litElement$ = true, s3["finalized", "finalized"] = true, globalThis.litElementHydrateSupport?.({ LitElement: s3 });
var r4 = globalThis.litElementPolyfillSupport;
r4?.({ LitElement: s3 });
(globalThis.litElementVersions ??= []).push("4.0.6");
// node_modules/@lit/reactive-element/decorators/custom-element.js
var t3 = (t4) => (e4, o4) => {
  o4 !== undefined ? o4.addInitializer(() => {
    customElements.define(t4, e4);
  }) : customElements.define(t4, e4);
};
// node_modules/@lit/reactive-element/decorators/property.js
var n4 = function(t4) {
  return (e4, o4) => typeof o4 == "object" ? r5(t4, e4, o4) : ((t5, e5, o5) => {
    const r5 = e5.hasOwnProperty(o5);
    return e5.constructor.createProperty(o5, r5 ? { ...t5, wrapped: true } : t5), r5 ? Object.getOwnPropertyDescriptor(e5, o5) : undefined;
  })(t4, e4, o4);
};
var o4 = { attribute: true, type: String, converter: u, reflect: false, hasChanged: f };
var r5 = (t4 = o4, e4, r6) => {
  const { kind: n5, metadata: i4 } = r6;
  let s4 = globalThis.litPropertyMetadata.get(i4);
  if (s4 === undefined && globalThis.litPropertyMetadata.set(i4, s4 = new Map), s4.set(r6.name, t4), n5 === "accessor") {
    const { name: o5 } = r6;
    return { set(r7) {
      const n6 = e4.get.call(this);
      e4.set.call(this, r7), this.requestUpdate(o5, n6, t4);
    }, init(e5) {
      return e5 !== undefined && this.P(o5, undefined, t4), e5;
    } };
  }
  if (n5 === "setter") {
    const { name: o5 } = r6;
    return function(r7) {
      const n6 = this[o5];
      e4.call(this, r7), this.requestUpdate(o5, n6, t4);
    };
  }
  throw Error("Unsupported decorator location: " + n5);
};
// node_modules/lit-html/directive.js
var t4 = { ATTRIBUTE: 1, CHILD: 2, PROPERTY: 3, BOOLEAN_ATTRIBUTE: 4, EVENT: 5, ELEMENT: 6 };
var e5 = (t5) => (...e6) => ({ _$litDirective$: t5, values: e6 });

class i4 {
  constructor(t5) {
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AT(t5, e6, i5) {
    this._$Ct = t5, this._$AM = e6, this._$Ci = i5;
  }
  _$AS(t5, e6) {
    return this.update(t5, e6);
  }
  update(t5, e6) {
    return this.render(...e6);
  }
}

// node_modules/lit-html/directives/class-map.js
var e6 = e5(class extends i4 {
  constructor(t5) {
    if (super(t5), t5.type !== t4.ATTRIBUTE || t5.name !== "class" || t5.strings?.length > 2)
      throw Error("`classMap()` can only be used in the `class` attribute and must be the only part in the attribute.");
  }
  render(t5) {
    return " " + Object.keys(t5).filter((s4) => t5[s4]).join(" ") + " ";
  }
  update(s4, [i5]) {
    if (this.st === undefined) {
      this.st = new Set, s4.strings !== undefined && (this.nt = new Set(s4.strings.join(" ").split(/\s/).filter((t5) => t5 !== "")));
      for (const t5 in i5)
        i5[t5] && !this.nt?.has(t5) && this.st.add(t5);
      return this.render(i5);
    }
    const r6 = s4.element.classList;
    for (const t5 of this.st)
      t5 in i5 || (r6.remove(t5), this.st.delete(t5));
    for (const t5 in i5) {
      const s5 = !!i5[t5];
      s5 === this.st.has(t5) || this.nt?.has(t5) || (s5 ? (r6.add(t5), this.st.add(t5)) : (r6.remove(t5), this.st.delete(t5)));
    }
    return w;
  }
});
// node_modules/lit-html/directives/style-map.js
var n5 = "important";
var i5 = " !" + n5;
var o5 = e5(class extends i4 {
  constructor(t5) {
    if (super(t5), t5.type !== t4.ATTRIBUTE || t5.name !== "style" || t5.strings?.length > 2)
      throw Error("The `styleMap` directive must be used in the `style` attribute and must be the only part in the attribute.");
  }
  render(t5) {
    return Object.keys(t5).reduce((e7, r6) => {
      const s4 = t5[r6];
      return s4 == null ? e7 : e7 + `${r6 = r6.includes("-") ? r6 : r6.replace(/(?:^(webkit|moz|ms|o)|)(?=[A-Z])/g, "-$&").toLowerCase()}:${s4};`;
    }, "");
  }
  update(e7, [r6]) {
    const { style: s4 } = e7.element;
    if (this.ft === undefined)
      return this.ft = new Set(Object.keys(r6)), this.render(r6);
    for (const t5 of this.ft)
      r6[t5] == null && (this.ft.delete(t5), t5.includes("-") ? s4.removeProperty(t5) : s4[t5] = null);
    for (const t5 in r6) {
      const e8 = r6[t5];
      if (e8 != null) {
        this.ft.add(t5);
        const r7 = typeof e8 == "string" && e8.endsWith(i5);
        t5.includes("-") || r7 ? s4.setProperty(t5, r7 ? e8.slice(0, -11) : e8, r7 ? n5 : "") : s4[t5] = e8;
      }
    }
    return w;
  }
});
// node_modules/pointer-tracker/dist/PointerTracker.mjs
class Pointer {
  constructor(nativePointer) {
    this.id = -1;
    this.nativePointer = nativePointer;
    this.pageX = nativePointer.pageX;
    this.pageY = nativePointer.pageY;
    this.clientX = nativePointer.clientX;
    this.clientY = nativePointer.clientY;
    if (self.Touch && nativePointer instanceof Touch) {
      this.id = nativePointer.identifier;
    } else if (isPointerEvent(nativePointer)) {
      this.id = nativePointer.pointerId;
    }
  }
  getCoalesced() {
    if ("getCoalescedEvents" in this.nativePointer) {
      const events = this.nativePointer.getCoalescedEvents().map((p3) => new Pointer(p3));
      if (events.length > 0)
        return events;
    }
    return [this];
  }
}
var isPointerEvent = (event) => ("pointerId" in event);
var isTouchEvent = (event) => ("changedTouches" in event);
var noop = () => {
};

class PointerTracker {
  constructor(_element, { start = () => true, move = noop, end = noop, rawUpdates = false, avoidPointerEvents = false } = {}) {
    this._element = _element;
    this.startPointers = [];
    this.currentPointers = [];
    this._excludeFromButtonsCheck = new Set;
    this._pointerStart = (event) => {
      if (isPointerEvent(event) && event.buttons === 0) {
        this._excludeFromButtonsCheck.add(event.pointerId);
      } else if (!(event.buttons & 1)) {
        return;
      }
      const pointer = new Pointer(event);
      if (this.currentPointers.some((p3) => p3.id === pointer.id))
        return;
      if (!this._triggerPointerStart(pointer, event))
        return;
      if (isPointerEvent(event)) {
        const capturingElement = event.target && "setPointerCapture" in event.target ? event.target : this._element;
        capturingElement.setPointerCapture(event.pointerId);
        this._element.addEventListener(this._rawUpdates ? "pointerrawupdate" : "pointermove", this._move);
        this._element.addEventListener("pointerup", this._pointerEnd);
        this._element.addEventListener("pointercancel", this._pointerEnd);
      } else {
        window.addEventListener("mousemove", this._move);
        window.addEventListener("mouseup", this._pointerEnd);
      }
    };
    this._touchStart = (event) => {
      for (const touch of Array.from(event.changedTouches)) {
        this._triggerPointerStart(new Pointer(touch), event);
      }
    };
    this._move = (event) => {
      if (!isTouchEvent(event) && (!isPointerEvent(event) || !this._excludeFromButtonsCheck.has(event.pointerId)) && event.buttons === 0) {
        this._pointerEnd(event);
        return;
      }
      const previousPointers = this.currentPointers.slice();
      const changedPointers = isTouchEvent(event) ? Array.from(event.changedTouches).map((t5) => new Pointer(t5)) : [new Pointer(event)];
      const trackedChangedPointers = [];
      for (const pointer of changedPointers) {
        const index = this.currentPointers.findIndex((p3) => p3.id === pointer.id);
        if (index === -1)
          continue;
        trackedChangedPointers.push(pointer);
        this.currentPointers[index] = pointer;
      }
      if (trackedChangedPointers.length === 0)
        return;
      this._moveCallback(previousPointers, trackedChangedPointers, event);
    };
    this._triggerPointerEnd = (pointer, event) => {
      if (!isTouchEvent(event) && event.buttons & 1) {
        return false;
      }
      const index = this.currentPointers.findIndex((p3) => p3.id === pointer.id);
      if (index === -1)
        return false;
      this.currentPointers.splice(index, 1);
      this.startPointers.splice(index, 1);
      this._excludeFromButtonsCheck.delete(pointer.id);
      const cancelled = !(event.type === "mouseup" || event.type === "touchend" || event.type === "pointerup");
      this._endCallback(pointer, event, cancelled);
      return true;
    };
    this._pointerEnd = (event) => {
      if (!this._triggerPointerEnd(new Pointer(event), event))
        return;
      if (isPointerEvent(event)) {
        if (this.currentPointers.length)
          return;
        this._element.removeEventListener(this._rawUpdates ? "pointerrawupdate" : "pointermove", this._move);
        this._element.removeEventListener("pointerup", this._pointerEnd);
        this._element.removeEventListener("pointercancel", this._pointerEnd);
      } else {
        window.removeEventListener("mousemove", this._move);
        window.removeEventListener("mouseup", this._pointerEnd);
      }
    };
    this._touchEnd = (event) => {
      for (const touch of Array.from(event.changedTouches)) {
        this._triggerPointerEnd(new Pointer(touch), event);
      }
    };
    this._startCallback = start;
    this._moveCallback = move;
    this._endCallback = end;
    this._rawUpdates = rawUpdates && "onpointerrawupdate" in window;
    if (self.PointerEvent && !avoidPointerEvents) {
      this._element.addEventListener("pointerdown", this._pointerStart);
    } else {
      this._element.addEventListener("mousedown", this._pointerStart);
      this._element.addEventListener("touchstart", this._touchStart);
      this._element.addEventListener("touchmove", this._move);
      this._element.addEventListener("touchend", this._touchEnd);
      this._element.addEventListener("touchcancel", this._touchEnd);
    }
  }
  stop() {
    this._element.removeEventListener("pointerdown", this._pointerStart);
    this._element.removeEventListener("mousedown", this._pointerStart);
    this._element.removeEventListener("touchstart", this._touchStart);
    this._element.removeEventListener("touchmove", this._move);
    this._element.removeEventListener("touchend", this._touchEnd);
    this._element.removeEventListener("touchcancel", this._touchEnd);
    this._element.removeEventListener(this._rawUpdates ? "pointerrawupdate" : "pointermove", this._move);
    this._element.removeEventListener("pointerup", this._pointerEnd);
    this._element.removeEventListener("pointercancel", this._pointerEnd);
    window.removeEventListener("mousemove", this._move);
    window.removeEventListener("mouseup", this._pointerEnd);
  }
  _triggerPointerStart(pointer, event) {
    if (!this._startCallback(pointer, event))
      return false;
    this.currentPointers.push(pointer);
    this.startPointers.push(pointer);
    return true;
  }
}

// public/clinicbro/js/dragcontroller.ts
class DragController {
  x = 0;
  y = 0;
  state = "idle";
  styles = {
    position: "absolute",
    top: "0px",
    left: "-5px"
  };
  constructor(host, options) {
    const {
      getContainerEl = () => null,
      getDraggableEl = () => Promise.resolve(null)
    } = options;
    this.host = host;
    this.host.addController(this);
    this.getContainerEl = getContainerEl;
    getDraggableEl().then((el) => {
      if (!el)
        return;
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
      }
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
    if (!el || !containerEl)
      return;
    const oldX = this.x;
    const oldY = this.y;
    const parsedTop = Math.floor(pointer.pageX);
    const parsedLeft = Math.floor(pointer.pageY);
    const cursorPositionX = Math.floor(pointer.pageX);
    const cursorPositionY = Math.floor(pointer.pageY);
    const hasCursorMoved = cursorPositionX !== this.cursorPositionX || cursorPositionY !== this.cursorPositionY;
    if (hasCursorMoved) {
      const { bottom, height } = el.getBoundingClientRect();
      const { right, width } = containerEl.getBoundingClientRect();
      const xDelta = cursorPositionX - this.cursorPositionX;
      const yDelta = cursorPositionY - this.cursorPositionY;
      this.x = oldX + xDelta;
      this.y = oldY + yDelta;
      const outOfBoundsTop = this.y < 0;
      const outOfBoundsLeft = this.x < 0;
      const outOfBoundsBottom = bottom + yDelta > window.innerHeight;
      const outOfBoundsRight = right + xDelta >= window.innerWidth;
      const isOutOfBounds = outOfBoundsBottom || outOfBoundsLeft || outOfBoundsRight || outOfBoundsTop;
      this.cursorPositionX = cursorPositionX;
      this.cursorPositionY = cursorPositionY;
      this.updateElPosition();
      this.host.requestUpdate();
    }
  }
  updateElPosition() {
    this.styles.transform = `translate(${this.x}px, ${this.y}px)`;
  }
}

// public/clinicbro/js/cb-window.ts
class CBWindow extends s3 {
  constructor() {
    super();
    this.opened = false;
    this.window_title = "Window";
  }
  ready() {
  }
  collect() {
  }
  updated(changedProperties) {
    if (changedProperties.has("opened")) {
      if (this.opened) {
      } else {
        this.drag.resetPosition();
      }
    }
  }
  drag = new DragController(this, {
    getContainerEl: () => this.shadowRoot.querySelector("#window"),
    getDraggableEl: () => this.getDraggableEl()
  });
  async getDraggableEl() {
    await this.updateComplete;
    return this.shadowRoot.querySelector("#draggable");
  }
  static styles = i`
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
    return x`
        <div id="window" class="${e6({ dialog: true, opened: this.opened, closed: !this.opened })}" style=${o5(this.drag.styles)}>
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
__legacyDecorateClassTS([
  n4({ type: Boolean, reflect: true })
], CBWindow.prototype, "opened", undefined);
__legacyDecorateClassTS([
  n4({ type: String })
], CBWindow.prototype, "window_title", undefined);
CBWindow = __legacyDecorateClassTS([
  t3("cb-window")
], CBWindow);
export {
  CBWindow
};
