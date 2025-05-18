
typst_flags := "--font-path fonts"

build: build-pdf build-html

format:
  typstfmt *.typ

clean:
  find  . -name '*.pdf' | xargs rm -rf
  rm -rf _site

open-pdf:
  typst compile {{ typst_flags }} --open HypermediaSystems.typ

build-pdf:
  typst compile {{ typst_flags }} HypermediaSystems.typ

watch-pdf:
  typst watch {{ typst_flags }} HypermediaSystems.typ

build-epub:
  pandoc HypermediaSystems-ebook.typ -o HypermediaSystems.epub -M title="Hypermedia Systems" --css lib/epub.css --metadata-file lib/epub.yaml --epub-cover-image=images/cover.png

typst-fonts:
  typst fonts {{ typst_flags }}

build-html:
  rm -rf _site
  www/build_web.ts
  cp www/{style.css,cover.css,color-customizer.js} _site
  cp -r images _site/images
  cp -r fonts _site/fonts
  test -z ${DEV+x} && npx subfont -ir _site --no-fallbacks || true

serve:
  #!/bin/sh
  trap 'kill $py; kill $just' SIGINT
  python3 -m http.server --directory _site & py=$!
  watchexec -w . -i '_site/**/*' -r DEV=1 just build-html & just=$!
  wait

deploy:
  netlify deploy -d _site --prod

diff-with-old:
  #!/usr/bin/env bash
  for f in $(find asciidoc/ -type f)
  do
    diff -u $f ../hypermedia-systems/book/$(basename $f)
  done

find-overlong-code-lines:
  find . -name "ch*" | xargs -I% awk ' \
    /```/   { code = !code } \
    /.{74}/ { if (code) print FILENAME ":" NR " " $0 } \
  ' % | less
