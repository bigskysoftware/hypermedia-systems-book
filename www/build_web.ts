#!/usr/bin/env -S deno run -A --unstable

import { build, Book, Frontmatter, Copyright, Dedication, Foreword, Part, Introduction, Chapter, write, TableOfContents, LandingPage, Division } from "https://codeberg.org/dz4k/muteferrika/raw/commit/4446c946f7216ca9d848b91b9dbcd56db95e9b1f/lib/muteferrika.ts";
import { copySync } from "https://deno.land/std@0.157.0/fs/copy.ts";

const compile = async (path: string) => {
  const pandoc = new Deno.Command("pandoc", {
    args: ["-f", "typst", "-t", "html", "--", path],
  });
  const compiled = new TextDecoder().decode((await pandoc.output()).stdout);
  const headingsUpleveled = compiled.replace(/<(\/?)h(\d)/g, (_, slash, level) => `<${slash}h${+level - 1}`);
  const title = headingsUpleveled.match(/<h1>(.*)<\/h1>/)?.[1];
  const h1Removed = headingsUpleveled.replace(/<h1>.*<\/h1>/, "");
  const url = path
    .replace(/\.typ$/, "/")
    .replace(/ch\d\d-|-\d-/, "/");
  return {
    compiledContent: h1Removed,
    title,
    url,
    // add ids to headings
    process() {
      const ids = new Map<string, number>();
      this.dom.querySelectorAll("h1, h2, h3, h4, h5, h6").forEach((heading) => {
        if (heading.hasAttribute("id")) return;
        let id = heading.textContent.toLowerCase().replace(/[^a-z0-9]/g, "-");
        const count = ids.get(id) || 0;
        if (count) id += `-${count}`;
        ids.set(id, count + 1);
        heading.setAttribute("id", id);
      })
      this.dom.querySelectorAll("img").forEach((img) => {
        if (img.hasAttribute("src") && !img.getAttribute("src")?.startsWith("http")) {
          img.setAttribute("src", `/${img.getAttribute("src")}`);
        }
      })
      this.dom.querySelectorAll("blockquote p:last-child").forEach((line) => {
        if (line.textContent?.startsWith("℄")) {
          line.classList.add("quote-attribution");
          line.parentElement.after(line);
          line.firstChild.data = line.firstChild.data.replace("℄", "");
        }
      })
    }
  };
}

const HypermediaSystems = new Book("Hypermedia Systems",
  {
    lang: "en",
    htmlHead: `
    <link rel="stylesheet" href="/style.css">
    <script type="module" src="/color-customizer.js"></script>
    <header class="book-header">
      <a href="/" class="homepage-link">Hypermedia Systems</a>
    </header>
    `,
    htmlFooter: `
    <footer class="book-footer">
      <a href="/" class="footer-book-title">Hypermedia Systems</a>
      <a href="/book/contents/">Contents</a>
      <color-customizer></color-customizer>
    </footer>
    `
  },
  new LandingPage("Hypermedia Systems", { url: '/', content: await Deno.readTextFile("www/cover.html") }),
  new Frontmatter(
    new Copyright(await compile("-1-copy-ack.typ"), "Copyright & Acknowledgments"),
    new Dedication(await compile("-2-dedication.typ"), "Dedication"),
    new Foreword(await compile("-3-foreword.typ"), "Foreword"),
    new TableOfContents("Contents", {
      url: '/book/contents/',
      file: "www/tocheader.html",
      compile: it => it
    }),
  ),
  new Part("Hypermedia Concepts",
    { url: '/part/hypermedia-concepts/' },
    new Introduction(await compile("ch00-introduction.typ")),
    new Chapter(await compile("ch01-hypermedia-a-reintroduction.typ")),
    new Chapter(await compile("ch02-components-of-a-hypermedia-system.typ")),
    new Chapter(await compile("ch03-a-web-1-0-application.typ")),
  ),
  new Part("Hypermedia-Driven Web Applications With Htmx",
    { url: '/part/htmx/' },
    new Chapter(await compile("ch04-extending-html-as-hypermedia.typ")),
    new Chapter(await compile("ch05-htmx-patterns.typ")),
    new Chapter(await compile("ch06-more-htmx-patterns.typ")),
    new Chapter(await compile("ch07-a-dynamic-archive-ui.typ")),
    new Chapter(await compile("ch08-tricks-of-the-htmx-masters.typ")),
    new Chapter(await compile("ch09-client-side-scripting.typ")),
    new Chapter(await compile("ch10-json-data-apis.typ")),
  ),
  new Part("Bringing Hypermedia To Mobile",
    { url: '/part/hyperview/' },
    new Chapter(await compile("ch11-hyperview-a-mobile-hypermedia.typ")),
    new Chapter(await compile("ch12-building-a-contacts-app-with-hyperview.typ")),
    new Chapter(await compile("ch13-extending-the-hyperview-client.typ")),
  ),
  new Part("Conclusion",
    { url: '/part/conclusion/' },
    new Chapter(await compile("ch14-conclusion.typ")),
  ),
);

const built = await build(HypermediaSystems);
console.log(built.length);
write(built, { directory: "_site" })
copySync("www/style.css", "_site/style.css");
copySync("fonts", "_site/fonts");
copySync("www/color-customizer.js", "_site/color-customizer.js");
