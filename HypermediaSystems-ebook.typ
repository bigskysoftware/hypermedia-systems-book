
#import "lib/definitions.typ": *

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
      text(style: "oblique", heading(level: 1, outlined: false, [Hypermedia Systems])),
    ),
  )
  #box(height: 1em)
  #set text(font: secondary-font)
  #grid(gutter: 1em, columns: 3 * (auto,),
    [Carson Gross],
    [Adam Stepinski],
    [Deniz Akşimşek],
  )
]

#include "-1-copy-ack.typ"

#pagebreak()

= Dedications

#include "-2-dedication.typ"

#pagebreak()

#counter(page).update(0)

#include "-3-foreword.typ"

= Hypermedia Concepts

#include "ch00-introduction.typ"
#include "ch01-hypermedia-a-reintroduction.typ"
#include "ch02-components-of-a-hypermedia-system.typ"
#include "ch03-a-web-1-0-application.typ"

= Hypermedia-Driven Web Applications With Htmx

#include "ch04-extending-html-as-hypermedia.typ"
#include "ch05-htmx-patterns.typ"
#include "ch06-more-htmx-patterns.typ"
#include "ch07-a-dynamic-archive-ui.typ"
#include "ch08-tricks-of-the-htmx-masters.typ"
#include "ch09-client-side-scripting.typ"
#include "ch10-json-data-apis.typ"

= Bringing Hypermedia To Mobile

#include "ch11-hyperview-a-mobile-hypermedia.typ"
#include "ch12-building-a-contacts-app-with-hyperview.typ"
#include "ch13-extending-the-hyperview-client.typ"

= Conclusion

#include "ch14-conclusion.typ"
