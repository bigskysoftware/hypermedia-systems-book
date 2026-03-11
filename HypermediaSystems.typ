
#import "lib/definitions.typ": *
#import "lib/style.typ": *

#show: hypermedia-systems-book(
  [Hypermedia Systems], authors: ("Carson Gross", "Adam Stepinski", "Deniz Akşimşek"),
  frontmatter: {
    page(include "-1-copy-ack.typ", header: none, numbering: none)
    page({
      include "-2-dedication.typ"
    }, header: none, numbering: none)
    page(counter(page).update(0),
      header: none, numbering: none)
    include "-3-foreword.typ"
  },
)

#include "HypermediaSystems-content.typ"
