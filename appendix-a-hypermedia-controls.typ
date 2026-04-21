#import "lib/definitions.typ": *

#heading(level: 2, numbering: none, outlined: true)[
  Appendix A: Hypermedia Controls: From Feral to Formal
] <appendix-a>

// Embed the original ACM paper at its native letter-size layout, one page per book page.
#for p in range(1, 14) [
  #page(
    width: 8.5in, height: 11in, margin: 0in,
    header: none, footer: none,
    image("pdfs/3648188.3675127.pdf", page: p, width: 100%, height: 100%)
  )
]
