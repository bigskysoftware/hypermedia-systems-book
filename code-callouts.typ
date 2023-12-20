#import "definitions.typ": *

#let default-callout(number /*: int */) /*: content*/ = {
  text(
    font: secondary-font,
    number-type: "old-style",
    size: 1em,
    weight: "bold",
    fill: luma(120),
    "[" + num + "]",
  )
}

#let unicode-circle-callout(number /*: int */) /*: content*/ = {
  str.from-unicode(
    if      number ==  0 { 0x24EA }
    else if number <= 20 { 0x245F + number }
    else if number <= 35 { 0x3250 + (number - 20) } 
    else if number <= 50 { 0x32B0 + (number - 35) } else                 { number }
  )
}

#let callout-pat = regex("<(\\d+)>(?:\\n|$)")

#let parse-callouts(
  code-text /*: str */
) /*: (callouts: array(array(int)), text: str) */ = {
  let callouts /*: array(array(int)) */ = ()
  let new-text = ""
  for text-line in code-text.split("\n") {
    let match = text-line.match(callout-pat)
    if match != none {
      callouts.push((int(match.captures.at(0)),))
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
  callout-display: default-callout /*: function(str, content) */
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
