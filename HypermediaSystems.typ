
#import "lib/definitions.typ": *
#import "lib/style.typ": *

#import "lib/definitions.typ": chapters
#import "lib/kdl.typ": parse-kdl-typeless, property, properties, value

// Division templates
#let render-division(node) = {
  let div-type = node.name
  let div-title = value(node, 0)
  let source = property(node, "compile")

  state("node-type").update(div-type)

  if node.name in ("LandingPage", "Frontmatter") {
    []

  } else if div-type in ("Copyright", "Dedication") {
    page(header: none, footer: none, numbering: none, {
      if "ebook" in sys.inputs {
        heading(level: 1, numbering: none, div-title)
      }
      include source
    })
    counter(page).update(0)

  } else if div-type in ("Chapter",) {
    let chapter-counter = counter("chapter")
    context {
      let (chapter-no,) = chapter-counter.get()
      counter(heading).update((h1, ..) => (h1, chapter-no))
    }
    chapter-counter.step()
    include source

  } else if div-type in ("Foreword", "Introduction") {
    include source

  } else if div-type in ("TableOfContents",) {
    context if target() == "paged" {
      pagebreak(to: "odd")
      heading(level: 1, numbering: none, div-title)
      outline(indent: 1em, depth: 4, title: none)
    }

  } else if div-type in ("Index",) {
    context if target() == "paged" [
      #heading(supplement: none, numbering: none, div-title) <chapter-title>
      #block(make-index())<book-index>
    ]
    
  } else if div-type in ("Part",) {
    [= #div-title <part-title>]

  } else {
    panic("Unrecognized node type: " + node.type)

  }

  for node in node.children { render-division(node) }
  
  if div-type in ("Frontmatter",) {
    set page(header: none, footer: none)
    counter(heading).update(0)
    pagebreak(to: "odd")
  }
}

// Assemble book from outline
#let outline = parse-kdl-typeless(read("HypermediaSystems.kdl", encoding: "utf8"))
#let book = outline.at(0)

#let book-title = value(book, 0)
#let authors = properties(book, "author")

#show: hypermedia-systems-book(book-title, authors: authors)
#for node in book.children { render-division(node) }
