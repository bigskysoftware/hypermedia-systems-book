#let leading = 0.6em
#let body-font = "Libertinus Serif"
#let secondary-font = "Libertinus Sans"
#let display-font = "Jaro"
#let mono-font = "Berkeley Mono"

#import "./indexing.typ": *

#let part-heading(it) = [
  #set page(header: none, footer: none)
  #pagebreak(to: "odd")

  #align(horizon)[
    #set par(leading: 5pt, justify: false)
    #set text(size: 32pt, font: display-font)
    #text(fill: luma(140))[
      #it.at("supplement", default: none)
      #counter(heading).display("I")
    ]
    #linebreak()
    #it.body
    #metadata("")<heading-here>
  ]
]

#let chapter-heading(it) = [
  #{
    pagebreak()
    set page(header: none, footer: none)
    pagebreak(to: "odd", weak: true)
  }

  #v(3in)
  #set par(justify: false)
  #set text(size: 22pt, font: display-font)
  #block({
    if it.at("numbering") != none {
      text(fill: luma(140), {
        it.supplement
        [ ]
        str(counter(heading).get().at(1))
      })
      linebreak()
    }
    it.body
    [#metadata("")<heading-here>]
  })
]

#let asciiart(..args, source) = figure({
  set text(size: .8em)
  set par(leading: .5em)
  block(breakable: false, align(start, raw(source, block: true)))
}, kind: image, ..args)

#let blockquote = quote.with(block: true)

#let sidebar(title, body) = [#block(
  spacing: 1em, block(
    width: 100%,
    inset: 1em,
    stroke: (top: 1pt, bottom: 1pt),
    fill: luma(237),
    breakable: true,
  )[
    #set text(.8em, font: secondary-font)
    #if title != [] {
      block(
        breakable: false,
        strong(title)
      )
    }
    #block(spacing: 1em, body)
  ],
)<sidebar>]

#let important(title, body) = [#block(
  spacing: 1em, block(
    width: 100%,
    inset: 1em,
    stroke: (
      top: (thickness: 1pt, paint: blue), bottom: (thickness: 1pt, paint: blue),
    ),
    fill: rgb("#def"),
    breakable: true,
  )[
    #set text(.8em, font: secondary-font)
    #block(
      breakable: false,
      strong(title) + v(4em)
    )
    #v(-4em)
    #block(spacing: 1em, body)
  ],
)<important>]

#let html-note(label: [HTML Notes], title, body) = [#block(
  spacing: 1em,
  block(
    width: 100%,
    inset: 1em,
    stroke: (top: 1pt, bottom: 1pt),
    fill: rgb("#f5f5ff"),
    breakable: true,
  )[
    #set text(.8em, font: secondary-font)
    #show heading: set text(1em)

    === #label: #title
    <html-note-title>

    #body
  ],
)<html-note>]

#let skew(angle, vscale: 1, body) = {
  let (a, b, c, d) = (1, vscale * calc.tan(angle), 0, vscale)
  let E = (a + d) / 2
  let F = (a - d) / 2
  let G = (b + c) / 2
  let H = (c - b) / 2
  let Q = calc.sqrt(E * E + H * H)
  let R = calc.sqrt(F * F + G * G)
  let sx = Q + R
  let sy = Q - R
  let a1 = calc.atan2(F, G)
  let a2 = calc.atan2(E, H)
  let theta = (a2 - a1) / 2
  let phi = (a2 + a1) / 2

  set rotate(origin: bottom + center)
  set scale(origin: bottom + center)

  rotate(phi, scale(x: sx * 100%, y: sy * 100%, rotate(theta, body)))
}
