#!/usr/bin/env -S deno run -A --unstable

import type {
  Element,
  Text,
} from "./muteferrika/lib/deps/deno-dom.ts";
import {
  build,
  Book,
  Frontmatter,
  Copyright,
  Dedication,
  Foreword,
  Part,
  Introduction,
  Chapter,
  write,
  TableOfContents,
  LandingPage,
  Division,
} from "./muteferrika/lib/muteferrika.ts";

const typstJsonToString = (json) => {
  if (json.func === "sequence")
    return json.children.map(typstJsonToString).join("")
  else if (json.func === "space")
    return " "
  else if (json.func === "text")
    return json.text
}

const compile = (path: string) => {
  return {
    file: path,
    url: path.replace(/\.typ$/, "/").replace(/ch\d\d-|-\d-/, "/"),
    async compile(this: Division) {
      const typst = new Deno.Command("typst", {
        args: [
          "compile",
          "--features", "html",
          "--format", "html",
          "--input", "single_chapter=1",
          "--", this.file, "-",
        ],
      });
      const typstOutput = await typst.output();
      if (!typstOutput.success) {
        console.error("typst:", new TextDecoder().decode(typstOutput.stderr));
        Deno.exit(typstOutput.code);
      }
      const compiled = new TextDecoder().decode(typstOutput.stdout);

      const titleQuery = new Deno.Command("typst", {
        args: [
          "query",
          "--features", "html",
          "--one",
          "--field", "value",
          "--", this.file, "<title-metadata>",
        ],
      });
      const titleOutput = await titleQuery.output();
      const titleJson = new TextDecoder().decode(titleOutput.stdout);
      console.log("title JSON", titleJson)
      if (titleJson) {
        const title = typstJsonToString(JSON.parse(titleJson))
        this.title = title;
      }
      return compiled;
    },
  };
};

const HypermediaSystems = new Book("Hypermedia Systems").with(
  {
    lang: "en",
    htmlHead: `
    <meta charset=utf8 name=viewport content=width=device-width>
    <link rel="stylesheet" href="/style.css">
    <link rel="shortcut icon" href="/images/favicon.png">
    <script type="module" src="/color-customizer.js"></script>
    `,
    htmlFooter: `
    <footer class="book-footer">
      <a href="/" class="footer-book-title">Hypermedia Systems</a>
      <a href="/book/contents/">Contents</a>
      <color-customizer></color-customizer>
    </footer>
    `,
  },
  new LandingPage("Hypermedia Systems").with({
    url: "/",
    content: await Deno.readTextFile("www/cover.html"),
  }),
  new Frontmatter().with(
    new Copyright("Copyright & Acknowledgments").with(
      compile("-1-copy-ack.typ"),
    ),
    new Dedication("Dedication").with(compile("-2-dedication.typ")),
    new Foreword("Foreword").with(compile("-3-foreword.typ")),
    new TableOfContents("Contents").with({
      url: "/book/contents/",
      file: "www/tocheader.html",
      compile: (it) => Promise.resolve(it),
    }),
  ),
  new Part("Hypermedia Concepts").with(
    { url: "/part/hypermedia-concepts/" },
    new Introduction().with(compile("ch00-introduction.typ")),
    new Chapter().with(compile("ch01-hypermedia-a-reintroduction.typ")),
    new Chapter().with(compile("ch02-components-of-a-hypermedia-system.typ")),
    new Chapter().with(compile("ch03-a-web-1-0-application.typ")),
  ),
  new Part("Hypermedia-Driven Web Applications With Htmx").with(
    { url: "/part/htmx/" },
    new Chapter().with(compile("ch04-extending-html-as-hypermedia.typ")),
    new Chapter().with(compile("ch05-htmx-patterns.typ")),
    new Chapter().with(compile("ch06-more-htmx-patterns.typ")),
    new Chapter().with(compile("ch07-a-dynamic-archive-ui.typ")),
    new Chapter().with(compile("ch08-tricks-of-the-htmx-masters.typ")),
    new Chapter().with(compile("ch09-client-side-scripting.typ")),
    new Chapter().with(compile("ch10-json-data-apis.typ")),
  ),
  new Part("Bringing Hypermedia To Mobile").with(
    { url: "/part/hyperview/" },
    new Chapter().with(compile("ch11-hyperview-a-mobile-hypermedia.typ")),
    new Chapter().with(
      compile("ch12-building-a-contacts-app-with-hyperview.typ"),
    ),
    new Chapter().with(compile("ch13-extending-the-hyperview-client.typ")),
  ),
  new Part("Conclusion").with(
    { url: "/part/conclusion/" },
    new Chapter().with(compile("ch14-conclusion.typ")),
  ),
);

const built = await build(HypermediaSystems);
write(built, { directory: "_site" });
