
#import "lib/definitions.typ": *
#import "lib/style.typ": *

#import "lib/definitions.typ": chapters
#import "lib/kdl.typ": parse-kdl-typeless, property, properties, value

#let html-document(path, content, ..args) = {
  document(
    path,
    ..args,
    {
      html.link(rel: "stylesheet", href: "/style.css")
      html.link(rel: "icon", href: "/favicon.png")
      content
    }
  )
}

// Division templates
#let render-division(node) = {
  let div-type = node.name
  let div-title = value(node, 0)
  let source = property(node, "compile")

  state("node-type").update(div-type)

  if node.name in ("LandingPage", "Frontmatter") {
    []

  } else if div-type in ("Copyright", "Dedication", "Foreword", "Introduction") {
    html-document(
      lower(div-type) + "/index.html",
      title: text(div-type),
      include source
    )

  } else if div-type in ("Chapter",) {
    let chapter-counter = counter("chapter")
    context {
      let (chapter-no,) = chapter-counter.get()
      counter(heading).update((h1, ..) => (h1, chapter-no))
    }
    chapter-counter.step()
    html-document(
      source
        .replace(regex("ch\\d\\d-|-\\d-"), "")
        .replace(regex("\\.typ$"), "/index.html"),
      title: text(div-type),
      include source
    )

  } else if div-type in ("TableOfContents",) {
    html-document(
      "book/contents/index.html",
      title: [Table of Contents],
      outline(indent: 1em, depth: 4, title: none)
    )

  } else if div-type in ("Index",) {
    
  } else if div-type in ("Part",) {
    html-document(
      property(node, "url") + "index.html",
      title: div-title,
      outline(indent: 1em, depth: 4, title: none)
    )

  } else {
    panic("Unrecognized node type: " + node.type)

  }

  for node in node.children { render-division(node) }
}

// Assemble book from outline
#let outline = parse-kdl-typeless(read("HypermediaSystems.kdl", encoding: "utf8"))
#let book = outline.at(0)

#let book-title = value(book, 0)
#let authors = properties(book, "author")

#for node in book.children { render-division(node) }

#asset("index.html", read("www/cover.html"))
#asset("cover.css", read("www/cover.css"))
#asset("style.css", read("www/style.css"))
#asset("color-customizer.js", read("www/color-customizer.js"))
#asset("favicon.png", read("images/favicon.png", encoding: none))
