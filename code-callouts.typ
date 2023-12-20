#import "definitions.typ": *

#let code-callout(num /*: str */) /*: content*/ = {
  text(
    font: secondary-font,
    number-type: "old-style",
    size: 1em,
    weight: "bold",
    fill: luma(120),
    "[" + num + "]",
  )
}

#let callout-pat = regex("<(\\d+)>(?:\\n|$)")

#let parse-callouts(
  code-text /*: str */
) /*: (callouts: array(array(str)), text: str) */ = {
  let callouts /*: array(array(str)) */ = ()
  let new-text = ""
  for text-line in code-text.split("\n") {
    let match = text-line.match(callout-pat)
    if match != none {
      callouts.push((match.captures.at(0),))
      new-text += text-line.slice(0, match.start)
    } else {
      callouts.push(())
      new-text += text-line
    }
    new-text += "\n"
  }
  (callouts: callouts, text: new-text)
}

#let processed-label = <TypstCodeCallout-was-processed>

#let code-with-callouts = (
  it /*: content(raw) */,
  callout-display: code-callout /*: function(str, content) */
) => {
  if it.at("label", default: none) == processed-label {
    it
  } else {
    let (callouts, text: new-text) = parse-callouts(it.text)

    show raw.line: it => {
      it
      let callouts-of-line = callouts.at(it.number - 1, default: ())
      for callout in callouts-of-line {
        callout-display(callout)
      }
    }

    let fields = it.fields()
    let _ = fields.remove("text")
    let _ = fields.remove("lines")
    [#raw(..fields, new-text)#processed-label]
  }
}
