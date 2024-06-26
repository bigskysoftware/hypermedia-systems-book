
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
  pandoc HypermediaSystems-ebook.typ -o HypermediaSystems.epub -M title="Hypermedia Systems" --css lib/epub.css --epub-metadata lib/epub.yaml --epub-cover-image=images/cover.png

typst-fonts:
  typst fonts {{ typst_flags }}

build-html:
  rm -rf _site
  www/build_web.ts
  cp -r images _site/images
  cp -r fonts _site/fonts

serve:
  (trap 'kill 0' SIGINT; \
  python3 -m http.server --directory _site & \
  watchexec -w . -i '_site/**/*' -r just build-html & \
  wait 0)

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
