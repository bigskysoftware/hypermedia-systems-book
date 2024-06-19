
build: build-pdf build-html

format:
  typstfmt *.typ

clean:
  find  . -name '*.pdf' | xargs rm -rf
  rm -rf _site

build-pdf:
  typst compile HypermediaSystems.typ

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
