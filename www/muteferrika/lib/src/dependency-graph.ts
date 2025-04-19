/**
 * Dependency graph.
 * - Ignores when an element depends on itself
 * - `traverse` method to go through elements and complete them
 *    - accepts callback that takes vertex & results of its dependencies &
 *      returns result of vertex
 * - labeled edges
 *   - multiple edges can have the same label
 */
export class DependencyGraph<V> {
  vertices: V[];
  #getEdges: (v: V) => Record<string, Iterable<V>>;

  constructor(
    vertices: Iterable<V>,
    getEdges: (v: V) => Record<string, Iterable<V>>,
  ) {
    this.#getEdges = memoize(getEdges);
    this.vertices = Array.from(vertices);
  }

  size(): number {
    return this.vertices.length;
  }

  *adjacency(v: V): Iterable<V> {
    for (const ws of Object.values(this.#getEdges(v))) {
      for (const w of ws) {
        // nonstandard: ignore self loops
        if (w !== v) {
          yield w;
        }
      }
    }
  }

  async complete<T>(cb: (v: V, deps: Record<string, T[]>) => (T | Promise<T>)): Promise<Map<V, T>> {
    const results = new Map<V, T>();

    for (const v of this.depthFirstPostorder()) {
      const deps: Record<string, T[]> = {};

      for (const [key, ws] of Object.entries(this.#getEdges(v))) {
        deps[key] = Array.from(ws, (w) => results.get(w)!);
      }

      results.set(v, await cb(v, deps));
    }
    return results;
  }

  async parallelComplete<T>(cb: (v: V, deps: Record<string, T[]>) => (T | Promise<T>)): Promise<Map<V, T>> {
    const results = new Map<V, T>();

    for (const layer of this.parallelizedTopologicalSort()) {
      await Promise.all(layer.map(async (v) => {
        const deps: Record<string, T[]> = {};
  
        for (const [key, ws] of Object.entries(this.#getEdges(v))) {
          deps[key] = Array.from(ws, (w) => results.get(w)!);
        }
  
        results.set(v, await cb(v, deps));
      }))
    }
    
    return results;
  }

  topologicalSort(): V[] {
    const dfs = this.depthFirstPostorder();
    dfs.reverse();
    return dfs;
  }

  depthFirstPostorder(v = this.vertices[0]): V[] {
    const marked = new Set<V>();
    const output = [] as V[];

    const rec = (v: V) => {
      marked.add(v);
      for (const w of this.adjacency(v)) {
        if (!marked.has(w)) rec(w);
      }
      return output.push(v);
    };

    for (const v of this.vertices) {
      if (!marked.has(v)) rec(v);
    }
    return output;
  }

  /**
   * Sorts the tasks into "layers" -- all the tasks in each layer can be done 
   * in parallel.
   * 
   * See: M. C. Er, "A Parallel Computation Approach to Topological Sorting",
   * _The Computer Journal_, Volume 26, Issue 4, November 1983, Pages 293–295,
   * https://doi.org/10.1093/comjnl/26.4.293 
   */
  parallelizedTopologicalSort() {
    const marked = new Set<V>();

    // The value of a vertex is the layer a vertex should go in.
    const vertexValues = new Map<V, number>();

    // DFS.
    const rec = (v: V) => {
      marked.add(v);

      // Vertices without any dependencies go in layer 0.
      let myValue = 0;
      for (const w of this.adjacency(v)) {
        if (!marked.has(w)) {
          // The value of a vertex should be greater than all its dependencies' 
          // values.
          const dependencyValue = rec(w);
          if (dependencyValue >= myValue) myValue = dependencyValue + 1;
        }
      }
      vertexValues.set(v, myValue)
      return myValue
    };

    for (const v of this.vertices) {
      if (!marked.has(v)) rec(v);
    }

    // Create layers based on vertex values.
    const layers = [] as V[][];
    for (const [vertex, value] of vertexValues) {
      while (layers.length <= value) layers.push([]);
      layers[value].push(vertex)
    }

    return layers;
  }
}

const memoize = <T, U>(f: (t: T) => U): ((t: T) => U) => {
  const map = new Map<T, U>()
  return (t: T) => {
    if (map.has(t)) return map.get(t)!
    const u = f(t)
    map.set(t, u)
    return u
  }
}
