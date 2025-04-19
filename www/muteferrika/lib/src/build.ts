import { DependencyGraph } from "./dependency-graph.ts";
import Division from "./division.ts";
import * as path from "https://deno.land/std@0.201.0/path/mod.ts";

const build = async (book: Division) => {
  const divisions = Array.from(book.allSubdivisions());

  console.log(`Building dependency graph: ${divisions}`);

  const dg = new DependencyGraph<Division>(divisions, (division) => {
    return Object.fromEntries(
      Object.entries(division.dependencies)
        .map(([name, query]) => [
          name,
          [...query.in(book)],
        ]),
    );
  });

  console.log(`Built dependency graph: ${dg.topologicalSort()}`);

  console.log("Building divisions");

  await dg.parallelComplete(
    async (division: Division, deps: Record<string, Division[]>) => {
      console.log(`Building ${division} (stage 1)`);
      await division.buildPhase1(deps, book);
      return division;
    },
  );

  await dg.parallelComplete(
    async (division: Division, deps: Record<string, Division[]>) => {
      console.log(`Building ${division} (stage 2)`);
      await division.buildPhase2(deps, book);
      return division;
    },
  );

  return divisions;
};

const write = (results: Division[], { directory = "_site" } = {}) => {
  for (const division of results) {
    if (division.builtContent !== undefined) {
      const content = division.builtContent;

      let outUrl = division.getUrl();
      if (!outUrl) continue;
      if (outUrl.startsWith("/")) outUrl = outUrl.slice(1);
      let outPath = path.join(directory, outUrl);
      if (outPath.endsWith("/") || outUrl === "") {
        outPath = path.join(outPath, "index.html");
      }
      console.log("Writing", division.toString(), "into", outPath);
      try {
        Deno.mkdirSync(path.dirname(outPath), { recursive: true });
      } catch {
        // no way to make it not throw if the directory already exists
      }
      Deno.writeTextFileSync(outPath, content);
    }
  }
};

export { build, write };
