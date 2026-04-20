const makeSlug = (str: string) =>
  str
    .split(/[^\p{L}\p{N}]/u) // not letters and numbers
    .map(slugWord)
    .filter((s) => s.length > 0)
    .join("-");

// TODO might need to unspecial some characters?
const slugWord = (word: string) => word.toLowerCase();

export { makeSlug };
