build:
  typst compile HypermediaSystems.typ

format:
  typstfmt *.typ

clean:
  rm -rf *.pdf
