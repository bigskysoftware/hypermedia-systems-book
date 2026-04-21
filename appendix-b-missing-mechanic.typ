#import "lib/definitions.typ": *

#heading(level: 2, numbering: none, outlined: true)[
  Appendix B: The Missing Mechanic: Behavioral Affordances as the Limiting Factor in Generalizing HTML Controls
] <appendix-b>

// Embed the original ACM paper at its native letter-size layout, one page per book page.
#for p in range(1, 10) [
  #page(
    width: 8.5in, height: 11in, margin: 0in,
    header: none, footer: none,
    image("pdfs/3720553.3746684.pdf", page: p, width: 100%, height: 100%)
  )
]
