You can define your own content types by subclassing an existing type.
`Division` is the base content type.

```ts
ìmport { Division } from "müteferrika";

class Intermission extends Division {
  static htmlClass = "intermission";
  static template = "intermission.html";
}
```
