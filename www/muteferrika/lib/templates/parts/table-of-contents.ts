/*
  Table of contents.
*/
export default /* html */`
{{ function toc(sect) }}
  {{ if sect.children.length > 0 }}
  <ul>
    {{ for child of sect.children }}
      <li>
        <a href="{{ url }}#{{ child.id }}">{{ child.title }}</a>
        {{ toc(child) }}
    {{ /for }}
  </ul>
  {{ /if }}
{{ /function }}
{{ set outline = self.dom |> htmlOutline }}
{{ set outline = outline?.[0]?.children?.[0] }}
{{ if outline }}
  {{ toc(outline) }}
{{ /if }}
`
