// Based on in-dexter by Rolf Bremer, Jutta Klebe

#let index(..content) = locate(loc =>
[#metadata((content: content.pos(), location: loc))<jkrb_index>])

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

  locate(
    loc => {
      let index-terms = query(<jkrb_index>, loc)
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
      set par(justify: false)

      let last-term = ("",)
      for key in sorted-keys {
        let entry = terms-dict.at(key)
        show grid: set block(inset: 0pt, spacing: 0pt)
        grid(
          columns:(1fr, auto),
          if entry.term.len() > 1 {
            if last-term.at(0) != entry.term.at(0) {
              entry.term.at(0)
              h(1fr)
              parbreak()
            }
            h(1em)
            entry.term.slice(1).join(", ")
          } else {
            entry.term.at(0)
          },
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
    },
  )
}
