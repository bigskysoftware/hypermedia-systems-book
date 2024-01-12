
build: build-pdf build-html

format:
  typstfmt *.typ

clean:
  rm -rf *.pdf

build-pdf:
  typst compile HypermediaSystems.typ

build-html:
  find . -name 'ch*.typ' -or -name '-*.typ' | \
    xargs just build-chapter-html

[private]
build-chapter-html chapter:
  mkdir -p "_site/$(dirname {{ chapter }})"
  pandoc -f typst -t html $chapter | tool/layout-chapter.sh > "_site/$(dirname {{ chapter }})/index.html"

build-toc:
  mkdir -p _site
  pandoc -f typst -t html toc.typ | tool/layout-toc.sh > _site/toc.html
