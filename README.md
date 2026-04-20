# Hypermedia Systems

This is the source for the book [Hypermedia Systems](https://hypermedia.systems)

## Required tools

| Tool | Version | Install |
| ---- | ------- | ------- |
| [just](https://just.systems/) | latest | `brew install just` |
| [typst](https://typst.app/) | 0.14.2 | `brew install typst` |
| [pandoc](https://pandoc.org/) | 3.9 | `brew install pandoc` |
| [deno](https://deno.com/) | 2.6.10 | `brew install deno` |
| [Kindle Previewer 3](https://www.amazon.com/Kindle-Previewer/b?node=21381691011) | 3.72+ | download from Amazon (no brew formula) |
| [typstfmt](https://github.com/astrale-sharp/typstfmt) | latest | `cargo install typstfmt` (optional, for `just format`) |

Run `just verify-env` to check that everything is installed and wired up correctly.

If a tool is installed somewhere non-standard, copy `.env.example` to `.env`
and override the path there. `.env` is gitignored, so per-machine tweaks stay
local.

## Build targets

- `just build-pdf` — PDF via typst
- `just build-epub` — EPUB via pandoc
- `just build-kindle` — Kindle `.kpf` via Kindle Previewer 3 CLI (upload this to KDP)
- `just build-md` — Markdown via pandoc
- `just build-html` — static site via deno
- `just build` — all of the above
