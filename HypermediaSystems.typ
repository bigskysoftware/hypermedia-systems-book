
#import "definitions.typ": *
#import "style.typ": *

#show: hypermedia-systems-book(
  [Hypermedia Systems], authors: ("Carson Gross", "Adam Stepinski", "Deniz Akşimşek"),
  frontmatter: [
    #page(include "copy-ack.typ", header: none, numbering: none)
    #page([
      #include "dedication.typ"
      #counter(page).update(0)
    ], header: none, numbering: none)
    #include "Foreword.typ"
  ],
)

= Hypermedia Concepts

#include "0-Introduction.typ"
#include "CH01_HypermediaAReintroduction.typ"
#include "CH02_ComponentsOfAHypermediaSystem.typ"
#include "CH03_BuildingASimpleWebApplication.typ"

= Hypermedia-Driven Web Applications With Htmx

#include "CH04_ExtendingHTMLAsHypermedia.typ"
#include "CH05_htmxPatterns.typ"
#include "CH06_MorehtmxPatterns.typ"
#include "CH07_ADynamicArchiveUIWithhtmx.typ"
#include "CH08_TricksOfThehtmxMasters.typ"
#include "CH09_ScriptingInAHypermediaApplication.typ"
#include "CH10_JSONDataAPIs.typ"

= Bringing Hypermedia To Mobile

#include "CH11_HyperviewAMobileHypermedia.typ"
#include "CH12_BuildingAContactsAppWithHyperview.typ"
#include "CH13_ExtendingTheHyperviewClient.typ"

= Conclusion

#include "CH14_Conclusion.typ"
