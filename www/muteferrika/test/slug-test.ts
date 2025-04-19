import { assertEquals } from "https://deno.land/std@0.194.0/testing/asserts.ts";
import { makeSlug } from "../lib/src/slug.ts";

Deno.test("slugifying single word leaves it alone", () => {
  assertEquals(makeSlug("card"), "card");
});

Deno.test("outputs lowercase", () => {
  assertEquals(makeSlug("Beatrice"), "beatrice");
});

Deno.test("Separates words with dashes", () => {
  assertEquals(makeSlug("nimi pona li lon"), "nimi-pona-li-lon");
});

Deno.test("Punctuation gets replaced with dashes", () => {
  assertEquals(
    makeSlug("Marianne Williamson will buy a bagel at Wynnsbury's"),
    "marianne-williamson-will-buy-a-bagel-at-wynnsbury-s",
  );
  assertEquals(
    makeSlug("colon:comma,dash-dot.bang!test"),
    "colon-comma-dash-dot-bang-test",
  );
});

Deno.test("Result does not have dashes at beginning or end", () => {
  assertEquals(makeSlug(" a!"), "a");
});

Deno.test("Multiple dashes in a row get collapsed", () => {
  assertEquals(
    makeSlug("Time flies like an arrow, fruit flies like banana"),
    "time-flies-like-an-arrow-fruit-flies-like-banana",
  );
});

Deno.test("Non-ASCII letters and numbers are not treated as punctuation", () => {
  assertEquals(
    makeSlug("Müteferrika sistemi Deniz Akşimşek tarafından yazılmıştır"),
    "müteferrika-sistemi-deniz-akşimşek-tarafından-yazılmıştır",
  );
});
