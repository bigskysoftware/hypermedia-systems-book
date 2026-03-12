
#import "lib/definitions.typ": *
#import "content.typ": title, authors

#set document(
  title: [Hypermedia Systems],
)

#show figure.where(kind: "image"): box

#page[
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
  #grid(gutter: 1em, columns: 3 * (auto,),
    ..authors
  )
]

#include "-1-copy-ack.typ"

#pagebreak()

= Dedications

#include "-2-dedication.typ"

#pagebreak()

#counter(page).update(0)

#include "-3-foreword.typ"



#include "content.typ"
