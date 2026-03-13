
typst_flags := "--features html --font-path fonts"
out_dir := "out"

build: build-pdf build-epub build-kindle

format:
  typstfmt *.typ

clean:
  rm -rf {{ out_dir }}

open-pdf: _out_dir
  typst compile {{ typst_flags }} --open HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

build-pdf: _out_dir
  typst compile {{ typst_flags }} HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

watch-pdf: _out_dir
  typst watch {{ typst_flags }} HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

build-epub: _out_dir
  typst compile {{ typst_flags }} --format html --input ebook=1 HypermediaSystems.typ - \
  | pandoc -f html -o {{ out_dir }}/HypermediaSystems.epub -M title="Hypermedia Systems" \
    --split-level 3 \
    --css lib/epub.css --metadata-file lib/epub.yaml --epub-cover-image=images/cover.png

build-kindle: build-epub
  ebook-convert {{ out_dir }}/HypermediaSystems.epub {{ out_dir }}/HypermediaSystems.azw3

typst-fonts:
  typst fonts {{ typst_flags }}

build-html:
  rm -rf out/www
  www/build_web.ts
  cp www/{style.css,cover.css,color-customizer.js} out/www
  cp -r images out/www/images
  cp -r fonts out/www/fonts
  test -z ${DEV+x} && npx subfont -ir out/www --no-fallbacks || true

_out_dir:
  mkdir -p {{ out_dir }}
  
serve:
  #!/bin/sh
  trap 'kill $py; kill $just' SIGINT
  python3 -m http.server --directory out/www & py=$!
  watchexec -w . -i 'out/www/**/*' -r DEV=1 just build-html & just=$!
  wait

deploy:
  netlify deploy -d out/www --prod

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

# Run the Web 1.0 contact app (chapters 1-3)
run-web10:
  cd code/ch03-web10 && uv run --with flask flask run

# Run the full htmx contact app (chapters 7-11)
run-full:
  cd code/ch10-full && uv run --with flask flask run
