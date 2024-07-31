
#import "./definitions.typ": *
#import "./code-callouts.typ": code-with-callouts

#let inside-cover(title, authors) = page(
  header: none,
)[
  #set align(start + horizon)
  #set par(leading: 10pt, justify: false)
  #show heading: set text(size: 3em, font: display-font)
  #skew(
    -0.174, // -10deg
    upper(
      text(style: "oblique", heading(level: 1, outlined: false, title)),
    ),
  )
  #box(height: 1em)
  #set text(font: secondary-font)
  #grid(gutter: 1em, columns: authors.len() * (auto,), ..authors)
]

#let page-header() = context {
  counter(footnote).update(0)

  set text(font: secondary-font, size: 10pt)

  let h1 = query(<heading-here>)
    .any(h => h.location().page() == here().page())
  if not h1 {
    let reference-title(title, numbering-style) = [
      #if title.numbering != none [
        #numbering(numbering-style, counter(heading).at(title.location()).last())
      ]
      #title.body
    ]
    if calc.odd(here().page()) [
      // verso
      #set align(end)
      #let titles = query(heading.where(level: 1).or(heading.where(level: 2)).before(here()))
      #if titles.len() > 0 [#reference-title(titles.last(), "1.") #sym.dot.c]
      #counter(page).display()
    ] else [
      // recto
      #counter(page).display()
      #let titles = query(heading.where(level: 1).before(here()))
      #if titles.len() > 0 [#sym.dot.c #reference-title(titles.last(), "I.")]
    ]
  }
}

#let hypermedia-systems-book(title, authors: (), frontmatter: []) = content => [
  #set text(font: body-font, size: 12pt, lang: "en")
  #set par(leading: .5em)
  #show raw: set text(font: mono-font)
  #show raw.where(block: false): set text(size: 11 * 1em / 12) // 11pt in 12pt body
  #show raw.where(block: true): set text(size: 9pt)

  #show heading.where(level: 1): set text(font: display-font, size: 24pt)
  #show heading.where(level: 2): set text(font: display-font, size: 20pt)
  #show heading.where(level: 3): set text(font: secondary-font)
  #show heading.where(level: 4): set text(font: secondary-font)
  #show heading.where(level: 5): set text(font: secondary-font)
  #show heading.where(level: 6): set text(font: secondary-font)

  #set par(justify: true, first-line-indent: 1em, leading: leading)
  #show par: set block(spacing: leading)

  #show list: set par(justify: false)
  #show list: set block(spacing: 0pt, inset: 0pt)

  #set list(
    indent: 1em,
    body-indent: .6em,
    spacing: 5pt,
  )

  #set enum(
    numbering: (..args) => {
      set text(font: secondary-font, number-type: "old-style")
      box(width: 1em, {
        numbering("1.", ..args)
        h(.5em)
      })
    },
    indent: 1em,
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
    show figure.caption: set text(font: secondary-font, size: 10pt)
    it
  }
  #show figure.where(kind: raw): it => {
    set figure.caption(position: top)
    show figure.caption: it => {
      set text(size: 11pt)
      pad(it, bottom: 1em)
      v(-1em)
    }
    set par(justify: false)
    set block(breakable: true, width: 100%)
    show raw.where(block: true): it => {
      set block(width: 100%, stroke: none)
      set align(start)
      it
    }
    block(
      spacing: 1em + leading,
      inset: (left: 1em, right: 1em),
      width: 100%,
      it
    )
  }
  
  #show raw.where(block: true): code-with-callouts

  #show link: it => {
    if type(it.dest) != str or it.body == text(it.dest) { it }
    else {
      it.body
      footnote(it.dest)
    }
  }

  #set page(
    width: 8.5in, height: 11in,
    margin: (inside: 1.75in, outside: 1in, top: 1in, bottom: 1.25in),
    header: page-header(),
  )

  #set document(title: title, author: authors)

  // #region FRONTMATTER
  #[
    #inside-cover(title, authors)

    #frontmatter

    #page([], header: none, footer: none)
    #pagebreak(to: "odd")

    = Contents
    #set par(first-line-indent: 0pt, justify: false)
    #show linebreak: []
    #show outline.entry: it => {
      show regex("\\d"): text.with(number-width: "tabular")
      show grid: set block(spacing: 0pt)
      box(
        inset: (left: (it.level - 1) * 1em),
        grid(
          columns: (1fr, auto),
          column-gutter: 1em,
          par(
            it.body,
            hanging-indent: (it.level) * 12pt + 3pt
          ),
          it.page,
        )
      )
    }
    #outline(indent: 1em, depth: 4, title: none)<table-of-contents>
  ]

  // #endregion FRONTMATTER

  // #region BODY

  #[
    // Chapter count
    #let chapter-counter = counter("chapter")
    #show heading.where(level: 2): it => [
      #if it.at("numbering") != none { chapter-counter.step() }
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
        it.at("depth", default: 2) - 1, default: [Section]),
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
