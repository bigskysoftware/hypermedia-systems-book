export default `
<!doctype html>
<html lang="{{ self.language ?? "en" }}" class="{{ self.contentType?.htmlClass ?? "" }}">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>{{ self.title ?? self.book.title }}</title>

{{ self.book.htmlHead |> safe }}

<header class="division-header">
	{{ if self.title }}<h1 class="division-title">{{ self.title }}</h1>{{ /if }}
	<div class="italic division-byline">
		{{ if self.date }}<p class="division-date"><time>{{ self.date |> formatDate }}</time></p>{{ /if }}
		{{ if self.author }}<p class="division-author">{{ self.author }}</p>{{ /if }}
	</div>
</header>

<main>
  {{ self.compiledContent |> safe }}
  <ul role="list" class="part-children">
    {{ for i, child of self.downward() |> Array.from }}
      <li class="part-child">
        {{ if i == 0 }}<strong>{{ /if }}
        <a href="{{ child.url }}" class="part-child-link division-link"
          >{{ child.title }}</a></li>
        {{ if i == 0 }}</strong>{{ /if }}
    {{ /for }}
  </ul>
</main>

{{ self.book.htmlFooter |> safe }}
`
