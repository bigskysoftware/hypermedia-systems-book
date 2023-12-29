
#import "definitions.typ": *
#import "style.typ": *

#show: hypermedia-systems-book(
  [Hypermedia Systems], authors: ("Carson Gross", "Adam Stepinski", "Deniz Akşimşek"),
  frontmatter: {
    page(include "-1-copy-ack.typ", header: none, numbering: none)
    page({
      include "-2-dedication.typ"
      counter(page).update(0)
    }, header: none, numbering: none)
    include "-3-foreword.typ"
  },
)

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
