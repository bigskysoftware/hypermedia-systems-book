// Based on in-dexter by Rolf Bremer, Jutta Klebe

#let index(..content) = context [#metadata((content: content.pos(), location: here()))<jkrb_index>]

#let indexed(content) = [#index(content)#content]

#let make-index() = {
  let content-to-string(content) = {
    if content.has("text") {
      content.text
    } else {
      let ct = ""
      for cc in content.children {
        if cc.has("text") {
          ct += cc.text
        }
      }
      ct
    }
  }

  context {
    let index-terms = query(<jkrb_index>)
    let terms-dict = (:)
    for el in index-terms {
      let ct = el.value.content.map(content-to-string)
      let key = ct.join(", ")

      if terms-dict.keys().contains(key) != true {
        terms-dict.insert(key, (term: ct, locations: ()))
      }

      // Add the new page entry to the list.
      // let ent = el.value.location.page
      if (
        terms-dict.at(key).locations.len() == 0 or terms-dict.at(key).locations.last().page() != el.value.location.page()
      ) {
        terms-dict.at(key).locations.push(el.value.location)
      }
    }

    // Sort the entries.
    let sorted-keys = terms-dict.keys().sorted()

    // Output.
    set par(justify: false, hanging-indent: 2em)

    let last-term = ("",)
    for key in sorted-keys {
      let entry = terms-dict.at(key)
      show grid: set block(inset: 0pt, spacing: 0pt)

      let term = none
      if entry.term.len() > 1 {
        if last-term.at(0) != entry.term.at(0) {
          grid(entry.term.at(0))
          v(5pt)
        }
        term = {
          h(1em)
          entry.term.slice(1).join(", ")
        }
      } else {
        term = entry.term.at(0)
      }

      grid(
        columns:(1fr, auto),
        term,
        box(
          entry.locations.map(location =>
            link(location.position(),
              text(
                number-width: "tabular",
                str(counter(page).at(location).last())
              )
            )
          ).join(", "),
        )
      )
      v(5pt)
      (last-term = entry.term)
    }
  }
}
