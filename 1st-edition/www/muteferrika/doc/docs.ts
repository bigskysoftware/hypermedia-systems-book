import {
  Book,
  build,
  Chapter,
  Introduction,
  LandingPage,
  TableOfContents,
  write,
} from "../lib/müteferrika.ts";
import $ from "https://deno.land/x/dax@0.33.0/mod.ts";

const htmlHead = `
<link rel="stylesheet" href="https://unpkg.com/missing.css@1.0.13/dist/missing.min.css" webc:keep>
<style>
  @font-face {
    font-family: Literata;
    src: url(/font/Literata[opsz,wght].woff2) format(woff2);
  }
  @font-face {
    font-family: Literata;
    src: url(/font/Literata-Italic[opsz,wght].woff2) format(woff2);
    font-style: italic;
  }
  :root {
    --main-font: Literata, serif;
    --accent: #fa1610 !important;
  }
  @media (prefers-color-scheme: dark) {
    :root:root {
      --bg: #000;
    }
  }
  body > :is(header, footer) {
    border: none;
  }
</style>
`;

const book = new Book(
  "Müteferrika Documentation",
  {
    lang: "en",
    htmlHead,
  },
  new LandingPage({ file: "index.html" }),
  new TableOfContents("Contents", { url: "/docs/" }),
  new Introduction("Prelude"),
  new Chapter("Installing and Running"),
  new Chapter("Introduction - Your First Book"),
  new Chapter("Writing Parts and Chapters"),
  new Chapter("Content Types"),
  new Chapter("Custom Content Types"),
  new Chapter("Internationalization"),
  new Chapter("Custom Templates"),
  new Chapter("Postprocessing"),
  new Chapter("Printing"),
);

if (import.meta.main) {
  await $`rm -rf _site`;
  write(build(book));
  await $`cp -r font/ .domains _site/`;
}
