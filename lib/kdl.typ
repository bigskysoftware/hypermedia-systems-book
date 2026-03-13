#import "@preview/kuddle:0.1.0": *

// KDL helpers
#let properties(node, prop) = node.entries.filter(e => e.name == prop).map(e => e.value)
#let property(node, prop) = {
  let ent = node.entries.find(e => e.name == prop)
  if ent != none { ent.value } else { none }
}
#let value(node, idx, default: none) = {
  let ent = node.entries.filter(e => e.name == none)
  return ent.at(idx, default: (value: default)).value
}
