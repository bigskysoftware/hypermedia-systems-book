#let leading = 0.6em
#let body-font = "Linux Libertine"
#let secondary-font = "Linux Biolinum"
#let display-font = "ChicagoFLF"
#let mono-font = "Berkeley Mono"

#import "indexing.typ": *

#let part-heading(it) = [
  #pagebreak(to: "even")
  #align(horizon)[
    #set par(leading: 5pt, justify: false)
    #set text(size: 32pt, font: display-font)
    #text(
      fill: luma(140),
    )[
      #it.supplement
      #counter(heading).display()
    ]
    #linebreak()
    #it.body
  ]
  #pagebreak()
]

#let chapter-heading(it) = [
  #pagebreak(to: "even")
  #v(3in)
  #set par(leading: 0pt, justify: false)
  #set text(size: 22pt, font: display-font)
  #block[
    #if it.numbering != none [
      #text(fill: luma(140))[
        #it.supplement
        #counter(heading).display()
      ]
      #linebreak()
    ]
    #it.body
  ]
]

#let asciiart(..args, source) = figure({
  set text(size: .8em)
  set par(leading: .5em)
  block(breakable: false, align(start, raw(read(source))))
}, kind: image, ..args)

#let sidebar(title, body) = block(
  spacing: 1em, rect(
    width: 100%, inset: 1em, stroke: (top: 1pt, bottom: 1pt), fill: luma(237),
  )[
    #set text(.8em, font: secondary-font)
    #strong(title)

    #block(spacing: 1em, body)
  ],
)

#let important(title, body) = block(
  spacing: 1em, rect(
    width: 100%, inset: 1em, stroke: (
      top: (thickness: 1pt, paint: blue), bottom: (thickness: 1pt, paint: blue),
    ), fill: rgb("#def"),
  )[
    #set text(.8em, font: secondary-font)
    #strong(title)

    #block(spacing: 1em, body)
  ],
)

#let html-note(label: [HTML Notes], title, body) = block(
  spacing: 1em, rect(
    width: 100%, inset: 1em, stroke: (top: 1pt, bottom: 1pt), fill: rgb("#f5f5ff"),
  )[
    #set text(.8em, font: secondary-font)
    #show heading: set text(.8em)

    === #label: #title
    #body
  ],
)

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
