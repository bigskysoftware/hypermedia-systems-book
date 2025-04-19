import Division, { type TableOfContentsOptions } from "./division.ts";
import * as find from "./find.ts";
import * as template from "./template.ts";

import { Element } from "../deps/deno-dom.ts";

export { Division };

export class Book extends Division {
  static tableOfContents = {
    include: false,
    includeChildren: true,
  };

  declare htmlHead?: string;

  declare htmlFooter?: string;
}

export class FrontCover extends Division {
  static htmlClass = "front-cover";
}

export class BackCover extends Division {
  static htmlClass = "back-cover";
}

export class LandingPage extends Division {
  static tableOfContents = {
    include: false,
    includeChildren: false,
    includeContent: false,
  };

  static template = "landing-page.html";

  url = "/";

  async compile(content: string, deps: Record<string, Division[]>, book: Division) {
    return content;
  }

  async postprocess(content: string, _: unknown, book: Book) {
    this.document!.head.innerHTML += book.htmlHead;
    return this.content!;
  }
}

export class Frontmatter extends Division {
  static tableOfContents = {
    include: false,
    includeChildren: true,
  };
}

export class Frontispiece extends Division {
  static template = "frontispiece.html";
}

export class TitlePage extends Division {
  static template = "title-page.html";
}

export class Copyright extends Division {
  static htmlClass = "copyright";
  static template = "copy-ack.html";
}

export class Dedication extends Division {
  static htmlClass = "dedication";
  static template = "dedication.html";
}

export class TableOfContents extends Division {
  static tableOfContents = {
    include: false,
  };
  static htmlClass = "table-of-contents";
  static template = "table-of-contents.html";

  dependencies = {
    chapters: find.all(),
  };

  async compile(content: string, deps: Record<string, Division[]>, book: Division) {
    return "";
  }
}

export class Part extends Division {
  static htmlClass = "part";
  static template = "part.html";
  static tableOfContents = {
    include: true,
    includeChildren: true,
    includeContent: false,
    numbering: {
      restart: false,
    },
  };
  dependencies = {
    children: find.childrenOf(this),
  };
}

export class Chapter extends Division {
  static htmlClass = "chapter";
  static tableOfContents: Partial<TableOfContentsOptions> = {
    include: true,
    includeContent: true,
    numbering: {
      restart: false,
    },
  };

  async postprocess() {
    this.document!.querySelectorAll("em").forEach((em) =>
      (em as Element).classList.add("test")
    );
    return "";
  }
}

export class Foreword extends Chapter {
  static htmlClass = "foreword";
  static tableOfContents = {
    numbering: false,
  };
}

export class Preface extends Chapter {
  static htmlClass = "preface";
  static tableOfContents = {
    numbering: false,
  };
}

export class Epigraph extends Chapter {
  static htmlClass = "epigraph";
  static template = "epigraph.html";
  static tableOfContents = {
    numbering: false,
  };
}

export class Introduction extends Chapter {
  static htmlClass = "chapter introduction";
  static tableOfContents = {
    numbering: false,
  };
}

export class Prologue extends Chapter {
  static htmlClass = "chapter prologue";
  static tableOfContents = {
    numbering: false,
  };
}

export class Conclusion extends Chapter {
  static htmlClass = "chapter conclusion";
  static tableOfContents = {
    numbering: false,
  };
}

export class Afterword extends Chapter {
  static htmlClass = "afterword";
  static tableOfContents = {
    numbering: false,
  };
}

export class Postscript extends Chapter {
  static htmlClass = "postscript";
  static tableOfContents = {
    numbering: false,
  };
}

export class Backmatter extends Division {
  static htmlClass = "backmatter";
  static tableOfContents = {
    include: false,
    includeChildren: true,
  };
}

export class Addendum extends Division {
  static htmlClass = "addendum";
}

export const Appendix = Addendum;

export class Bibliography extends Division {
  static htmlClass = "bibliography";
  dependencies = {
    chapters: find.ofType(Chapter),
  };
  build(): Promise<string> {
    throw new Error("TODO: build bibliography");   
  }
}

export const ReferenceList = Bibliography;

export class Endnotes extends Division {
  static htmlClass = "endnotes";
  dependencies = {
    chapters: find.ofType(Chapter),
  };
  build(): Promise<string> {
    throw new Error("TODO: build endnotes");
  }
}

export class Glossary extends Division {
  static htmlClass = "glossary";
}

export class Index extends Division {
  static htmlClass = "index";
  dependencies = {
    chapters: find.ofType(Chapter),
  };
  build(): Promise<string> {
    throw new Error("TODO: build index");
  }
}

export class Teaser extends Division {
  static htmlClass = "teaser";
}

export class AboutTheAuthor extends Division {
  static htmlClass = "about-the-author";
}
