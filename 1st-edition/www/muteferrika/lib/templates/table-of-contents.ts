export default /* html */`
<!doctype html>
<html lang="{{ self.language ?? "en" }}" class="{{ self.contentType?.htmlClass }}">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>{{ self.title ?? intl("Contents") }}</title>

{{ self.book.htmlHead |> safe }}

<header>
  <h1>{{ self.title ?? intl("Contents") }}</h1>
</header>

{{ function recurse(div, level = 0) }}
  {{ set down = Array.from(div.downward()) }}
  {{ if div.tocIncludeContent }}
    {{ function toc(sect) }}
      {{ if sect.children.length > 0 }}
        <ul class="internal-contents">
          {{ for child of sect.children }}
            <li>
              <a href="{{ div.url }}#{{ child.id }}">{{ child.title }}</a>
              {{ toc(child) }}
          {{ /for }}
        </ul>
      {{ /if }}
    {{ /function }}
    {{ set outline = div.dom |> htmlOutline }}
    {{ set outline = outline?.[0]?.children?.[0] }}
    {{ if outline }}
      {{ toc(outline) }}
    {{ /if }}
  {{ /if }}
  {{ if down.length > 0 }}
    <ul role="list" class="{{ level ? "padding-inline-start" : "" }}">
      {{ for child of down }}
        <li class="{{ child.htmlClass }}">
          <a href="{{ child.getUrl() }}">{{ child.title ?? child.file ?? child.contentType.name }}</a>
          {{ recurse(child, level + 1) }}
      {{ /for }}
    </ul>
  {{ /if }}
{{ /function }}

<main>
  <div class="toc-content">
    {{ self.compiledContent |> safe }}
  </div>
  {{ recurse(self.book) }}
</main>

{{ self.book.htmlFooter |> safe }}
`
