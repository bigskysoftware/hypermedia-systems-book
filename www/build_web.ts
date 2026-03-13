#!/usr/bin/env -S deno run -A --unstable
import * as kdl from "npm:kdljs"

import { build, Book, write } from "./muteferrika/lib/muteferrika.ts";
import * as contentTypes from "./muteferrika/lib/src/content-types.ts";

const typstJsonToString = (json) => {
  if (json.func === "sequence")
    return json.children.map(typstJsonToString).join("")
  else if (json.func === "space")
    return " "
  else if (json.func === "text")
    return json.text
}

const typst = async (...args) => {
  const cmd = new Deno.Command("typst", { args })
  const output = await cmd.output();
  if (!output.success) {
    console.error("typst:", new TextDecoder().decode(output.stderr));
    Deno.exit(output.code);
  }
  return new TextDecoder().decode(output.stdout);
}

const compile = (path: string) => {
  return {
    file: path,
    url: path.replace(/\.typ$/, "/").replace(/ch\d\d-|-\d-/, "/"),
    async compile(this: Division) {
      const compiled = await typst(
        "compile", "--format", "html",
        "--features", "html",
        "--input", "single_chapter=1",
        "--", this.file, "-",
      );
      
      const titleJson = await typst(
        "query", "--field", "value",
        "--features", "html",
        "--", this.file, "<title-metadata>",
      );
      if (titleJson) {
        const titleData = JSON.parse(titleJson)
        if (titleData.length) {
          const title = typstJsonToString(titleData[0])
          this.title = title;
        }
      }
      return compiled
    },
  };
};

const shouldExclude = (child) => "if" in child.properties && !child.properties.if.includes("web")

const parseNode = (node) => {
  const constructor = contentTypes[node.name]
  if (!constructor) throw new Error("Unexpected node " + node.name)
  
  let div = new constructor(...node.values)
  
  const props = node.properties
  
  if ('compile' in node.properties) {
    div = div.with(compile(node.properties.compile))
    delete node.properties.compile
  }
  delete props.if
  
  for (const [prop, tag] of Object.entries(node.tags.properties)) {
    if (tag === "file") props[prop] = Deno.readTextFileSync(props[prop])
  }
  
  div = div.with(node.properties)
  
  if (node.children) {
    div = div.with(
      ...node.children
      .filter(child => !shouldExclude(child))
      .map(parseNode)
    )
  }
  return div
}

const outlineFile = "HypermediaSystems.kdl"
const outline = kdl.parse(Deno.readTextFileSync(outlineFile))

if (outline.errors.length) {
  outline.errors.forEach(er => console.error(
    "%cKDL error: %c%s:%d:%d: %c%s",
    "color: red; font-weight: bold;",
    "color: cyan",
    outlineFile,
    er.token.startLine,
    er.token.startColumn,
    "all: initial",
    er.message,
  ))
  Deno.exit(1)
}

const HypermediaSystems = parseNode(outline.output[0])

const built = await build(HypermediaSystems);
write(built, { directory: "out/www" });
