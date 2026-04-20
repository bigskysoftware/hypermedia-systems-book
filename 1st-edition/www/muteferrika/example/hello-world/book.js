import { Book, build, Chapter, Part, write } from "../../lib/muteferrika.ts";

const example = new Book("Example").with(
  { lang: "en" },
  new Part().with(
    new Chapter("Testing Chapter"),
  ),
);

write(await build(example));
