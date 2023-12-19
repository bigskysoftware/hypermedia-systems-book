#import "definitions.typ": *

#let callout-circle(num) = {
  box(
    baseline: 15%,
    circle(
      radius: .5em,
      inset: 0pt,
      fill: black,
      stroke: none,
      align(
        center,
        text(
          fill: white,
          font: secondary-font,
          num,
        ),
      ),
    ),
  )
}

#let callout-circle(num) = {
  let number = int(num)
  text(
    font: secondary-font,
    str.from-unicode(
      if number == 0 {
        0x24EA
      } else if number <= 20 {
          0x245F + number
      } else if number <= 35 {
          0x3250 + (number - 20)
      } else if number <= 50 {
          0x32B0 + (number - 35)
      } else {
        number
      }
    ),
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
    callout-circle(digit)
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
      callout-circle(callout)
    }
  }

  [#raw(..props, new-text)<TypstCodeCallout-was-processed>]
}
