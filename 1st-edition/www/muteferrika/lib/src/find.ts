import Division from "./division.ts";
import type { ContentType } from "./division.ts";

export type Query = {
  in(book: Division): Iterable<Division>;
  [rest: string]: unknown;
};

export const ofType = (...types: ContentType[]): Query => {
  return {
    type: "ofType",
    contentTypes: types,
    *in(book) {
      for (const div of book.allSubdivisions()) {
        if (types.some((type) => div instanceof type)) {
          yield div;
        }
      }
    },
  };
};

export const all = (): Query => ofType(Division);

export const none = (): Query => {
  return {
    type: "none",
    in: () => [],
  };
};

export const childrenOf = (parent: Division): Query => {
  return {
    type: "children",
    of: parent,
    in: () => parent.downward(),
  };
};
