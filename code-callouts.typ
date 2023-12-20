#import "definitions.typ": *

#let code-callout(num) = {
  text(
    font: secondary-font,
    number-type: "old-style",
    size: 1em,
    weight: "bold",
    fill: luma(120),
    "[" + num + "]",
  )
}

#let code-with-callouts = it => if it.at("label", default: none) == <TypstCodeCallout-was-processed> {
  it
} else {
  let props = it.fields()
  let _ = props.remove("text")
  let _ = props.remove("lines")

  let text = it.text.replace(
    regex("<(\\d+)>(?:\\n|$)"),
    mat => "TypstCodeCallout" + mat.captures.at(0) + "\n"
  )

  show regex("TypstCodeCallout(\d+)$"): it => {
    let digit = it.text.slice("TypstCodeCallout".len())
    code-callout(digit)
  }

  [#raw(..props, text)<TypstCodeCallout-was-processed>]
}

#let code-with-callouts = it => if (
  it.at("label", default: none) == <TypstCodeCallout-was-processed>
) {
  it
} else {
  let props = it.fields()
  let _ = props.remove("text")
  let _ = props.remove("lines")

  let callout-pat = regex("<(\\d+)>(?:\\n|$)")
  let callouts = ()
  let new-text = ""
  for text-line in it.text.split("\n") {
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

  show raw.line: it => {
    let callouts-of-line = callouts.at(it.number - 1, default: ())
    it
    for callout in callouts-of-line {
      code-callout(callout)
    }
  }

  [#raw(..props, new-text)<TypstCodeCallout-was-processed>]
}
