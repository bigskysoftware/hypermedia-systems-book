
import * as müteferrika from "./dist/müteferrika.js"
{ book, frontmatter, backmatter, part, chapter, content_type } = müteferrika

hypermedia_systems = book "Hypermedia Systems", {
	author: ["Carson Gross", "Adam Stepinski", "[Deniz Akşimşek]{lang=tr}"]
	lang: "en"
	publisher: "Big Sky Software"
	published: "2023",
	revision: $"git show --format=%T"
	front_cover: front_cover content: """
	With a foreword by [Mike Amundsen](https://training.amundsen.com)
	"""
	back_cover: back_cover file: "back_cover.md"
}, [
	frontmatter [
		copyright_page file: "copyright.md"
		dedication file: "dedication.md"
		table_of_contents "Contents"
		foreword "Foreword :sub-title[by Mike Amundsen]",
			file: "foreword.md"
	]
	part "Hypermedia Concepts", [
		chapter "Introduction"
		chapter "Hypermedia: A Reintroduction"
		chapter "Components of a Hypermedia System"
		chapter "A Web 1.0 Application"
	]
	part "Hypermedia-Driven Web Applications with Htmx", [
		chapter "Extending HTML as Hypermedia"
		chapter "Htmx Patterns"
		chapter "More Htmx Patterns"
		chapter "A Dynamic Archive UI"
		chapter "Tricks of the Htmx Masters"
		chapter "Client-Side Scripting"
		chapter "JSON Data APIs & Hypermedia-Driven Applications"
	]
	part "Bringing Hypermedia to Mobile", [
		chapter "Hyperview: A Mobile Hypermedia"
		chapter "Building a Contacts App with Hyperview"
		chapter "Extending the Hyperview Client"
	]
	chapter "Conclusion"
	backmatter [
		index
	]
]

müteferrika.build hypermedia_systems,
	out_dir: "dist"
	markdown: müteferrika.pandoc_markdown
