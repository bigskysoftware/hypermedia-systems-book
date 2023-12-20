
#import "definitions.typ": *
#import "code-callouts.typ": code-with-callouts

#let inside-cover(title, authors) = page(
  header: none,
)[
  #set align(start + horizon)
  #set par(leading: 5pt, justify: false)
  #skew(
    -10deg, upper(
      text(style: "oblique", size: 3em, heading(level: 1, outlined: false, title)),
    ),
  )
  #box(height: 1em)
  #set text(font: secondary-font)
  #grid(gutter: 1em, columns: authors.len() * (auto,), ..authors)
]

#let page-header() = locate(
  loc => [
    #set text(font: secondary-font)
    #let h1 = query(heading.where(level: 1).or(heading.where(level: 2)), loc).any(h => counter(page).at(h.location()) == counter(page).at(loc))
    #if not h1 {
      let reference-title(title, numbering-style) = [
        #if title.numbering != none [
          #numbering(numbering-style, counter(heading).at(title.location()).last())
        ]
        #title.body
      ]
      if calc.even(counter(page).at(loc).at(0)) [
        // verso
        #set align(end)
        #let titles = query(heading.where(level: 1).or(heading.where(level: 2)).before(loc), loc)
        #if titles.len() > 0 [#reference-title(titles.last(), "1.") #sym.dot.c]
        #counter(page).display()
      ] else [
        // recto
        #counter(page).display()
        #let titles = query(heading.where(level: 1).before(loc), loc)
        #if titles.len() > 0 [#sym.dot.c #reference-title(titles.last(), "I.")]
      ]
    }
  ],
)

#let hypermedia-systems-book(title, authors: (), frontmatter: []) = content => [
  #set text(font: body-font, size: 12pt, lang: "en")
  #show raw: set text(font: mono-font)

  #show heading: set text(font: display-font)

  #set par(justify: true, first-line-indent: 1em, leading: leading)
  #show par: set block(spacing: leading)

  #set list(
    body-indent: .6em,
  )

  #set enum(
    numbering: (..args) => {
      set text(font: secondary-font, number-type: "old-style")
      box(width: 1em, {
        numbering("1", ..args)
        h(.5em)
      })
    },
    indent: 0pt,
    body-indent: 0pt,
    number-align: start,
  )

  #set terms(hanging-indent: 1em)
  #show terms: it => { set par(first-line-indent: 0pt); it }

  #set quote(block: true)
  #show quote: set block(spacing: 1em)
  #show quote: set text(style: "italic")
  // #show quote.attribution: set text(style: "normal")

  #set image(fit: "contain", width: 50%)

  #show figure: it => {
    show figure.caption: align.with(if it.kind == raw { start } else { center })
    it
  }
  #show figure.where(kind: raw): set figure.caption(position: top)
  #show figure.where(kind: raw): set par(justify: false)
  #show figure.where(kind: raw): it => {
    show raw.where(block: true): it => block(width: 100%, align(start, it))
    block(
      spacing: 1em + leading, inset: (left: 1em, right: 1em), align(start, box(it)),
    )
  }
  #show figure.caption: set text(font: secondary-font)

  // Code callouts
  // TODO: does not work consistently across languagea
  #show raw.where(block: true): code-with-callouts

  #set page(
    width: 8.25in, height: 11in, margin: (inside: 1.5in, outside: 1in, y: 1in), header: page-header(),
  )

  #set document(title: title, author: authors)

  // #region FRONTMATTER
  #[
    #inside-cover(title, authors)

    #frontmatter

    #pagebreak(to: "odd")

    = Contents
    #set par(first-line-indent: 0pt)
    #outline(indent: 1em, depth: 4, title: none)
  ]

  // #endregion FRONTMATTER

  // #region BODY

  #[
    // Chapter count
    #let chapter-counter = counter("chapter")
    #show heading.where(level: 2): it => [
      #if it.numbering != none { chapter-counter.step() }
      #chapter-heading(it)
    ]

    #show heading.where(level: 1): it => [
      #part-heading(it)
      // Override heading counter so chapter numbers don't reset with each part.
      // TODO: this doesn't work on the first heading in each part
      #locate(loc => counter(heading).update((..args) =>
      (args.pos().at(0), chapter-counter.at(loc).last())))
    ]

    #set heading(
      supplement: it => ([Part], [Chapter]).at(
        it.level - 1, default: [Section]),
      numbering: (..bits) => if bits.pos().len() < 2 {
        // Show part number only on parts.
        numbering("I.", ..bits)
      } else {
        // Discard part number otherwise.
        numbering("1.1.", ..bits.pos().slice(1))
      },
    )

    #content
  ]

  // #endregion BODY

  // #region BACKMATTER

  #[
    #show heading.where(level: 1): chapter-heading

    = Index

    #columns(2, gutter: 2em, {
      set text(font: secondary-font, size: .9em)
      set par(first-line-indent: 0pt)
      show heading: none
      make-index()
    })
  ]

  // #endregion BACKMATTER
]
