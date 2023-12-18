// Based on in-dexter by Rolf Bremer, Jutta Klebe

#let index(content) = locate(loc =>
  [#metadata((content: content, location: loc))<jkrb_index>])

#let indexed(content) = [#index(content)#content]

#let make-index() = {
    let content-to-string(content) = {
        let ct = ""
        if content.has("text") {
            ct = content.text
        }
        else {
            for cc in content.children {
                if cc.has("text") {
                    ct += cc.text
                }
            }
        }
        return ct
    }

    locate(loc => {
        let index-terms = query(<jkrb_index>, loc)
        let terms-to-pages = (:)
        for el in index-terms {
            let ct = content-to-string(el.value.content)

            if terms-to-pages.keys().contains(ct) != true {
                terms-to-pages.insert(ct, ())
            }

            // Add the new page entry to the list.
            // let ent = el.value.location.page
            let page-no = counter(page).at(el.value.location).last()
            if not terms-to-pages.at(ct).contains(page-no) {
                terms-to-pages.at(ct).push(page-no)
            }
        }

        // Sort the entries.
        let sorted-keys = terms-to-pages.keys().sorted()

        // Output.
        for term in sorted-keys [
            #term
            #box(width: 1fr)
            #box[
              #terms-to-pages.at(term).map(page =>
                link((page: page, x:0pt, y:0pt))[#str(page)]
              ).join(", ")
            ]
            #parbreak()
        ]
    })
}
