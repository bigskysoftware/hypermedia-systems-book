export default `
<!doctype html>
<html lang="{{ self.language ?? "en" }}" class="{{ self.contentType?.htmlClass ?? "" }}">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>{{ self.title ?? self.book.title }}</title>

{{ self.book.htmlHead |> safe }}

{{ set navigation }}
<footer class="navigation-footer">
  <nav class="navigation">
		{{ set prev = self.backward() }}
		{{ set next = self.forward() }}
		{{ if prev }}
		<p><a
			href="{{ prev.url }}"
			class="{{ prev.htmlClass }}"
			rel="previous">Previous: {{ prev.title }}</a>
		{{ /if }}
		{{ if next }}
		<p><a href="{{ next.url }}"
			class="{{ next.htmlClass }}"
			rel="next">Next: {{ next.title }}</a>
		{{ /if }}
	</nav>
</footer>
{{ /set }}

{{ navigation }}

<header  class="division-header">
	{{ if self.title }}<h1>{{ self.title }}</h1>{{ /if }}
	<div class="italic">
		{{ if self.date }}<p><time>{{ self.date |> formatDate }}</time></p>{{ /if }}
		{{ if self.author }}<p>{{ self.author }}</p>{{ /if }}
	</div>
</header>
  
<main>
  {{ self.compiledContent |> safe }}
</main>

{{ navigation }}

{{ self.book.htmlFooter |> safe }}
`
