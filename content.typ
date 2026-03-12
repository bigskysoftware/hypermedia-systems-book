#import "lib/definitions.typ": chapters
#import "@preview/kuddle:0.1.0": parse-kdl-typeless

#let properties(node, prop) = node.entries.filter(e => e.name == prop).map(e => e.value)
#let property(node, prop) = node.entries.find(e => e.name == prop).value

#let kdl = parse-kdl-typeless(read("outline.kdl", encoding: "utf8"))
#let book = kdl.at(0)

#let title = book.entries.at(0).value
#let authors = properties(book, "author")

#let chapter-counter = counter("chapter")

#let render-division(node) = {
  state("node-type").update(node.name)

  if node.name in ("LandingPage", "Frontmatter") {
    []

  } else if node.name in ("Copyright", "Dedication") {
    page(include property(node, "compile"), header: none, footer: none, numbering: none)
    counter(page).update(0)

  } else if node.name in ("Chapter", "Foreword", "Introduction") {
    context {
      let (chapter-no,) = chapter-counter.get()
      counter(heading).update((h1, ..) => (h1, chapter-no))
    }
    if node.name == "Chapter" {
      chapter-counter.step()
      include property(node, "compile")
    } else {
      show heading.where(depth: 2): set heading(numbering: none)
      include property(node, "compile")
    }

  } else if node.name in ("TableOfContents",) {
    pagebreak(to: "odd")
    heading(level: 1, numbering: none, node.entries.at(0).value)
    [#outline(indent: 1em, depth: 4, title: none)<table-of-contents>]

  } else if node.name in ("Part",) {
    [= #node.entries.at(0).value <part-title>]
  } else {
    panic("Unrecognized node type: " + node.type)

  }

  for node in node.children { render-division(node) }
  
  if node.name in ("Frontmatter",) {
    set page(header: none, footer: none)
    counter(heading).update(0)
    pagebreak(to: "odd")
  }
}

#for node in book.children { render-division(node) }
