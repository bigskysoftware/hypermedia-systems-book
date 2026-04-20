set dotenv-load := true

typst            := env_var_or_default("TYPST", "typst")
typstfmt         := env_var_or_default("TYPSTFMT", "typstfmt")
pandoc           := env_var_or_default("PANDOC", "pandoc")
deno             := env_var_or_default("DENO", "deno")
kindle_previewer := env_var_or_default("KINDLE_PREVIEWER", "/Applications/Kindle Previewer 3.app/Contents/MacOS/Kindle Previewer 3")

typst_flags := "--font-path fonts"
out_dir := "out"

build: build-pdf build-epub build-kindle

format:
  {{ typstfmt }} *.typ

clean:
  rm -rf {{ out_dir }} _site

open-pdf:
  mkdir -p {{ out_dir }}
  {{ typst }} compile {{ typst_flags }} --open HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

build-pdf:
  mkdir -p {{ out_dir }}
  {{ typst }} compile {{ typst_flags }} HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

watch-pdf:
  mkdir -p {{ out_dir }}
  {{ typst }} watch {{ typst_flags }} HypermediaSystems.typ {{ out_dir }}/HypermediaSystems.pdf

build-epub:
  mkdir -p {{ out_dir }}
  {{ pandoc }} HypermediaSystems-ebook.typ -o {{ out_dir }}/HypermediaSystems.epub -M title="Hypermedia Systems" --css lib/epub.css --metadata-file lib/epub.yaml --epub-cover-image=images/cover.png

build-md:
  mkdir -p {{ out_dir }}/md
  cp -r images {{ out_dir }}/md/images
  {{ pandoc }} HypermediaSystems-ebook.typ -o {{ out_dir }}/md/HypermediaSystems.md -t markdown -M title="Hypermedia Systems"

build-kindle: build-epub
  "{{ kindle_previewer }}" {{ out_dir }}/HypermediaSystems.epub -convert -output {{ out_dir }}/

typst-fonts:
  {{ typst }} fonts {{ typst_flags }}

build-html:
  rm -rf _site
  {{ deno }} run -A --unstable www/build_web.ts
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

# Verify that all required build tools are installed. Tool paths come from .env
# (falling back to PATH). Reports missing tools and how to install them.
verify-env:
  #!/usr/bin/env bash
  set -u
  missing=0
  check() {
    local name=$1 bin=$2 install=$3
    local ok=0
    if [[ "$bin" == */* ]]; then
      [[ -x "$bin" ]] && ok=1
    else
      command -v "$bin" >/dev/null 2>&1 && ok=1
    fi
    if [[ $ok -eq 1 ]]; then
      printf "  [ok]      %-18s %s\n" "$name" "$bin"
    else
      printf "  [missing] %-18s install: %s\n" "$name" "$install"
      missing=$((missing+1))
    fi
  }
  echo "Checking build tools (override paths in .env):"
  check "just"             "just"                    "brew install just"
  check "typst"            "{{ typst }}"             "brew install typst"
  check "typstfmt"         "{{ typstfmt }}"          "cargo install typstfmt  (optional, for 'just format')"
  check "pandoc"           "{{ pandoc }}"            "brew install pandoc"
  check "deno"             "{{ deno }}"              "brew install deno"
  check "Kindle Previewer" "{{ kindle_previewer }}"  "download from https://www.amazon.com/Kindle-Previewer/b?node=21381691011"
  if [[ $missing -gt 0 ]]; then
    echo
    echo "$missing tool(s) missing. Install them and re-run 'just verify-env'."
    exit 1
  fi
  echo
  echo "All tools installed."

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
