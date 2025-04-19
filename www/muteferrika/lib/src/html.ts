import {
Comment,
  Document,
  DocumentFragment,
  Element,
  Node,
  Text,
} from "../deps/deno-dom.ts";

export function html(string: string): SafeHtml;
export function html(
  strings: TemplateStringsArray,
  ...values: unknown[]
): SafeHtml;

export function html(
  strings: string | TemplateStringsArray,
  ...values: unknown[]
) {
  if (!Array.isArray(strings)) return new SafeHtml(String(strings));
  return new SafeHtml(String.raw(
    strings as TemplateStringsArray,
    ...values.map(htmlEscape),
  ));
}

export function htmlEscape(value: unknown) {
  if (value instanceof SafeHtml) return value.value;
  if (value && typeof value === "object" && Symbol.iterator in value) {
    const rv = [];
    for (const v of value as Iterable<unknown>) rv.push(stringify(v));
    return rv.join("");
  }
  return stringify(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

export function stringify(v: unknown) {
  if (v === null || v === undefined || v === false) return "";
  return String(v);
}

export class SafeHtml {
  constructor(readonly value: string) {}
  toString() {
    return this.value;
  }
}

export function serializeDocument(document: Document) {
  return "<!doctype html>\n" + document.documentElement!.outerHTML;
}

export function serializeFragment(fragment: DocumentFragment) {
  const rv: string[] = [];
  for (const node of fragment.childNodes) {
    if (node instanceof Element) rv.push((node as Element).outerHTML);
    else if (node instanceof Text) rv.push(htmlEscape((node as Text).data));
    else if (node instanceof Comment) rv.push("<!--" + node.data + "-->");
    else throw new Error(`Unknown node type: ${node}`);
  }
  return rv.join("");
}

export type HtmlOutline = {
  title?: string;
  id?: string;
  children: HtmlOutline[];
};

export function htmlOutline(
  document: Document | DocumentFragment,
): HtmlOutline[] {
  const headings = Array.from(
    document.querySelectorAll("h1, h2, h3, h4, h5, h6"),
  );
  const rv: HtmlOutline[] = [];

  const create = (element: Element): HtmlOutline => ({
    title: element.innerHTML,
    id: element.id,
    children: [],
  });

  const createNull = (): HtmlOutline => ({
    children: [],
  });

  const add = (outline: HtmlOutline, level: number): void => {
    if (level === 1) {
      rv.push(outline);
      return;
    }

    const lastOutline = rv.at(-1);
    let parentOutline = lastOutline ?? (rv.push(createNull()), rv[0]);
    for (let i = level - 2; i >= 0; i--) {
      const last = parentOutline.children.at(-1);
      if (last) parentOutline = last;
      else {
        const nul = createNull();
        parentOutline.children.push(nul);
        parentOutline = nul;
      }
    }

    parentOutline.children.push(outline);
  };

  headings.forEach((heading_) => {
    const heading = heading_ as Element;
    const level = parseInt(heading.tagName.charAt(1));
    const outline = create(heading);
    add(outline, level);
  });

  return rv;
}
