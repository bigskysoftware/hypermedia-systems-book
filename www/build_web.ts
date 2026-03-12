#!/usr/bin/env -S deno run -A --unstable
import * as kdl from "npm:kdljs"

import { build, Book, write } from "./muteferrika/lib/muteferrika.ts";
import * as contentTypes from "./muteferrika/lib/src/content-types.ts";

const typstJsonToString = (json) => {
  if (json.func === "sequence")
    return json.children.map(typstJsonToString).join("")
  else if (json.func === "space")
    return " "
  else if (json.func === "text")
    return json.text
}

const typst = async (...args) => {
  const cmd = new Deno.Command("typst", { args })
  const output = await cmd.output();
  if (!output.success) {
    console.error("typst:", new TextDecoder().decode(output.stderr));
    Deno.exit(output.code);
  }
  return new TextDecoder().decode(output.stdout);
}

const compile = (path: string) => {
  return {
    file: path,
    url: path.replace(/\.typ$/, "/").replace(/ch\d\d-|-\d-/, "/"),
    async compile(this: Division) {
      const compiled = await typst(
        "compile", "--format", "html",
        "--features", "html",
        "--input", "single_chapter=1",
        "--", this.file, "-",
      );
      
      const titleJson = await typst(
        "query", "--field", "value",
        "--features", "html",
        "--", this.file, "<title-metadata>",
      );
      if (titleJson) {
        const titleData = JSON.parse(titleJson)
        if (titleData.length) {
          const title = typstJsonToString(titleData[0])
          this.title = title;
        }
      }
      return compiled
    },
  };
};

const parseNode = (node) => {
  const constructor = contentTypes[node.name]
  if (!constructor) throw new Error("Unexpected node " + node.name)
  
  let div = new constructor(...node.values)
  if ('compile' in node.properties) {
    div = div.with(compile(node.properties.compile))
    delete node.properties.compile
  }
  const props = node.properties
  for (const [prop, tag] of Object.entries(node.tags.properties)) {
    if (tag === "file") props[prop] = Deno.readTextFileSync(props[prop])
  }
  div = div.with(node.properties)
  if (node.children) {
    div = div.with(...parseNodes(node.children))
  }
  return div
}

const parseNodes = (nodes) => nodes.map(parseNode)

const outlineFile = "outline.kdl"
const outline = kdl.parse(Deno.readTextFileSync(outlineFile))

if (outline.errors.length) {
  outline.errors.forEach(er => console.error(
    "%cKDL error: %c%s:%d:%d: %c%s",
    "color: red; font-weight: bold;",
    "color: cyan",
    outlineFile,
    er.token.startLine,
    er.token.startColumn,
    "all: initial",
    er.message,
  ))
  Deno.exit(1)
}

const HypermediaSystems = parseNode(outline.output[0])
// new Book("Hypermedia Systems").with(
//   {
//     lang: "en",
//     htmlHead: `
//     <meta charset=utf8 name=viewport content=width=device-width>
//     <link rel="stylesheet" href="/style.css">
//     <link rel="shortcut icon" href="/images/favicon.png">
//     <script type="module" src="/color-customizer.js"></script>
//     `,
//     htmlFooter: `
//     <footer class="book-footer">
//       <a href="/" class="footer-book-title">Hypermedia Systems</a>
//       <a href="/book/contents/">Contents</a>
//       <color-customizer></color-customizer>
//     </footer>
//     `,
//   },
//   new Part("Hypermedia Concepts").with(
//     { url: "/part/hypermedia-concepts/" },
//     new Introduction().with(compile("ch00-introduction.typ")),
//     new Chapter().with(compile("ch01-hypermedia-a-reintroduction.typ")),
//     new Chapter().with(compile("ch02-components-of-a-hypermedia-system.typ")),
//     new Chapter().with(compile("ch03-a-web-1-0-application.typ")),
//   ),
//   new Part("Hypermedia-Driven Web Applications With Htmx").with(
//     { url: "/part/htmx/" },
//     new Chapter().with(compile("ch04-extending-html-as-hypermedia.typ")),
//     new Chapter().with(compile("ch05-htmx-patterns.typ")),
//     new Chapter().with(compile("ch06-more-htmx-patterns.typ")),
//     new Chapter().with(compile("ch07-a-dynamic-archive-ui.typ")),
//     new Chapter().with(compile("ch08-tricks-of-the-htmx-masters.typ")),
//     new Chapter().with(compile("ch09-client-side-scripting.typ")),
//     new Chapter().with(compile("ch10-json-data-apis.typ")),
//   ),
//   new Part("Bringing Hypermedia To Mobile").with(
//     { url: "/part/hyperview/" },
//     new Chapter().with(compile("ch11-hyperview-a-mobile-hypermedia.typ")),
//     new Chapter().with(
//       compile("ch12-building-a-contacts-app-with-hyperview.typ"),
//     ),
//     new Chapter().with(compile("ch13-extending-the-hyperview-client.typ")),
//   ),
//   new Part("Conclusion").with(
//     { url: "/part/conclusion/" },
//     new Chapter().with(compile("ch14-conclusion.typ")),
//   ),
// );

const built = await build(HypermediaSystems);
write(built, { directory: "_site" });
