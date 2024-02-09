
build: build-pdf build-html

format:
  typstfmt *.typ

clean:
  find  . -name '*.pdf' | xargs rm -rf
  rm -rf _site

build-pdf:
  typst compile HypermediaSystems.typ

build-html:
  www/build_web.ts

serve:
  (trap 'kill 0' SIGINT; \
  python3 -m http.server --directory _site & \
  watchexec -w . -i '_site/**/*' -r just build-html & \
  wait 0)
