import { assertEquals } from "https://deno.land/std@0.194.0/testing/asserts.ts";
import { DependencyGraph } from "../lib/src/dependency-graph.ts";

Deno.test("getting adjacency list", () => {
  const dg = new DependencyGraph(
    [3, 0, 2, 1],
    (v) => ({ dep: v == 3 ? [] : [v + 1] }),
  );
  assertEquals([...dg.adjacency(0)], [1]);
  assertEquals([...dg.adjacency(1)], [2]);
  assertEquals([...dg.adjacency(2)], [3]);
  assertEquals([...dg.adjacency(3)], []);
});

Deno.test("ignores self loops", () => {
  const dg = new DependencyGraph(
    [3, 0, 2, 1],
    (v) => ({ dep: v == 3 ? [v] : [v, v + 1] }),
  );
  assertEquals([...dg.adjacency(0)], [1]);
  assertEquals([...dg.adjacency(1)], [2]);
  assertEquals([...dg.adjacency(2)], [3]);
  assertEquals([...dg.adjacency(3)], []);
});

Deno.test("topologically sorts", () => {
  const dg = new DependencyGraph(
    [3, 0, 2, 1],
    (v) => ({ dep: v == 3 ? [] : [v + 1] }),
  );
  assertEquals(dg.topologicalSort(), [0, 1, 2, 3]);

  const dg2 = new DependencyGraph(
    [3, 0, 2, 1],
    (v) => ({}),
  );
  assertEquals(dg2.topologicalSort(), [1, 2, 0, 3]);
});
