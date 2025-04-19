import vento from "https://deno.land/x/vento@v0.10.1/mod.ts";
import * as markdown from "./markdown.ts";
import { intl } from "./intl.ts";
import { htmlOutline } from "./html.ts";
import type Division from "./division.ts";

export type TemplateContext = {
  d: Division;
  content: string;
  intl: ReturnType<typeof intl>;
};

const builtinTemplates: Record<
  string,
  { default: string }
> = {
  "division.html": await import("../templates/division.ts"),
  "landing-page.html": await import("../templates/landing-page.ts"),
  "table-of-contents.html": await import("../templates/table-of-contents.ts"),
  "part.html": await import("../templates/part.ts"),
  "copy-ack.html": await import("../templates/copy-ack.ts"),
  "dedication.html": await import("../templates/dedication.ts"),
};

// TODO support custom template dir
// TODO how will we load templates from deno.land/x?
const vto = vento({
  autoescape: false,
  useWith: true,
});
vto.filters.htmlOutline = htmlOutline;
vto.filters.formatDate = () => "TODO: date formatting";
vto.filters.markdown = markdown.render;

export const render = (
  template: string,
  d: Division,
  content: string,
) => {
  const context = { ...d, intl: intl(d.language) };
  return vto.runStringSync((builtinTemplates[template] ?? builtinTemplates["division.html"]).default, context);
};
