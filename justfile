
build: build-pdf build-html

format:
  typstfmt *.typ

clean:
  find  . -name '*.pdf' | xargs rm -rf

build-pdf:
  typst compile HypermediaSystems.typ

build-html:
  find . -name 'ch*.typ' -or -name '-*.typ' | \
    xargs -I% just build-chapter-html %

[private]
build-chapter-html chapter:
  mkdir -p "_site/$(basename {{ chapter }})"
  pandoc -f typst -t html {{ chapter }} | tool/layout-chapter.sh > "_site/$(basename {{ chapter }})/index.html"

build-toc:
  mkdir -p _site
  pandoc -f typst -t html toc.typ | tool/layout-toc.sh > _site/toc.html
