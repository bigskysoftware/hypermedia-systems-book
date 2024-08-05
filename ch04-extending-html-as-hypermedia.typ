#import "lib/definitions.typ": *

== Extending HTML As Hypermedia

In the previous chapter we introduced a simple Web 1.0-style hypermedia
application to manage contacts. Our application supported the normal CRUD
operations for contacts, as well as a simple mechanism for searching contacts.
Our application was built using nothing but forms and anchor tags, the
traditional hypermedia controls used to interact with servers. The application
exchanges hypermedia (HTML) with the server over HTTP, issuing `GET` and `POST` HTTP
requests and receiving back full HTML documents in response.

It is a basic web application, but it is also definitely a Hypermedia-Driven
Application. It is robust, it leverages the web’s native technologies, and it is
simple to understand.

So what’s not to like about the application?

Unfortunately, our application has a few issues common to web 1.0 style
applications:
- From a user experience perspective: there is a noticeable refresh when you move
  between pages of the application, or when you create, update or delete a
  contact. This is because every user interaction (link click or form submission)
  requires a full page refresh, with a whole new HTML document to process after
  each action.
- From a technical perspective, all the updates are done with the `POST`
  HTTP method. This, despite the fact that more logical actions and HTTP request
  types like `PUT` and `DELETE` exist and would make more sense for some of the
  operations we implemented. After all, if we wanted to delete a resource,
  wouldn’t it make more sense to use an HTTP `DELETE`
  request to do so? Somewhat ironically, since we have used pure HTML, we are
  unable to access the full expressive power of HTTP, which was designed
  specifically _for_ HTML.

The first point, in particular, is noticeable in Web 1.0 style applications like
ours and is what is responsible for giving them the reputation for being "clunky"
when compared with their more sophisticated JavaScript-based Single Page
Application cousins.

We could address this issue by adopting a Single Page Application framework, and
updating our server-side to provide JSON-based responses. Single Page
Applications eliminate the clunkiness of web 1.0 applications by updating a web
page without refreshing it: they can mutate parts of the Document Object Model
(DOM) of the existing page without needing to replace (and re-render) the entire
page.

#sidebar[The DOM][
  #index[Document Object Model (DOM)]
  The DOM is the internal model that a browser builds up when it processes HTML,
  forming a tree of "nodes" for the tags and other content in the HTML. The DOM
  provides a programmatic JavaScript API that allows you to update the nodes in a
  page directly, without the use of hypermedia. Using this API, JavaScript code
  can insert new content, or remove or update existing content, entirely outside
  the normal browser request mechanism.
]

There are a few different styles of SPA, but, as we discussed in Chapter 1, the
most common approach today is to tie the DOM to a JavaScript model and then let
an SPA framework like
#link("https://reactjs.org/")[React] or #link("https://vuejs.org/")[Vue]
_reactively_ update the DOM when a JavaScript model is updated: you make a
change to a JavaScript object that is stored locally in memory in the browser,
and the web page "magically" updates its state to reflect the change in the
model.

In this style of application, communication with the server is typically done
via a JSON Data API, with the application sacrificing the advantages of
hypermedia in order to provide a better, smoother user experience.

Many web developers today would not even consider the hypermedia approach due to
the perceived "legacy" feel of these web 1.0 style applications.

Now, the second more technical issue we mentioned may strike you as a bit
pedantic, and we are the first to admit that conversations around REST and which
HTTP Action is right for a given operation can become very tedious. But still,
it’s odd that, when using plain HTML, it is impossible to use all the
functionality of HTTP!

Just seems wrong, doesn’t it?

=== A Close Look At A Hyperlink <_a_close_look_at_a_hyperlink>
It turns out that we can boost the interactivity of our application and address
both of these issues _without_ resorting to the SPA approach. We can do so by
using a _hypermedia-oriented_ JavaScript library, #link("https://htmx.org")[htmx].
The authors of this book built htmx specifically to extend HTML as a hypermedia
and address the issues with legacy HTML applications we mentioned above (as well
as a few others.)

Before we get into how htmx allows us to improve the UX of our Web 1.0 style
application, let’s revisit the hyperlink/anchor tag from Chapter 1. Recall, a
hyperlink is what is known as a _hypermedia control_, a mechanism that describes
some sort of interaction with a server by encoding information about that
interaction directly and completely within the control itself.

Consider again this simple #indexed[anchor tag] which, when interpreted by a
browser, creates a #indexed[hyperlink] to the website for this book:

#figure(caption: [A simple hyperlink, revisited],
```html
<a href="https://hypermedia.systems/">
  Hypermedia Systems
</a>
```)

Let’s break down exactly what happens with this link:
- The browser will render the text "Hypermedia Systems" to the screen, likely with
  a decoration indicating it is clickable.
- Then, when a user clicks on the text…​
- The browser will issue an HTTP `GET` to `https://hypermedia.systems`…​
- The browser will load the HTML body of the HTTP response into the browser
  window, replacing the current document.

So we have four aspects of a simple hypermedia link like this, with the last
three aspects supplying the mechanism that distinguishes a hyperlink from "normal"
text and, thus, makes this a hypermedia control.

Now, let’s take a moment and think about how we can _generalize_
these last three aspects of a hyperlink.

==== Why Only Anchors & Forms? <_why_only_anchors_forms>
Consider: what makes anchor tags (and forms) so special?

Why can’t other elements issue HTTP requests as well?

For example, why shouldn’t `button` elements be able to issue HTTP requests? It
seems arbitrary to have to wrap a form tag around a button just to make deleting
contacts work in our application, for example.

Maybe: other elements should be able to issue HTTP requests as well. Maybe other
elements should be able to act as hypermedia controls on their own.

This is our first opportunity to generalize HTML as a hypermedia.

#important[Opportunity 1][
  HTML could be extended to allow _any_ element to issue a request to the server
  and act as a hypermedia control.
]

==== Why Only Click & Submit Events? <_why_only_click_submit_events>
Next, let’s consider the event that triggers the request to the server on our
link: a click event.

#index[events][click]
#index[events][submit]
Well, what’s so special about clicking (in the case of anchors) or submitting
(in the case of forms) things? Those are just two of many, many events that are
fired by the DOM, after all. Events like mouse down, or key up, or blur are all
events you might want to use to issue an HTTP request.

Why shouldn’t these other events be able to trigger requests as well?

This gives us our second opportunity to expand the expressiveness of HTML:

#important[Opportunity 2][
  HTML could be extended to allow _any_ event --- not just a click, as in the case
  of hyperlinks --- to trigger HTTP requests.
]

==== Why Only GET & POST? <_why_only_get_post>

#index[HTTP methods]
Getting a bit more technical in our thinking leads us to the problem we noted
earlier: plain HTML only give us access to the `GET` and `POST`
actions of HTTP.

HTTP _stands_ for Hypertext Transfer Protocol, and yet the format it was
explicitly designed for, HTML, only supports two of the five developer-facing
request types. You _have_ to use JavaScript and issue an AJAX request to get at
the other three: `DELETE`, `PUT` and
`PATCH`.

Let’s recall what these different HTTP request types are designed to represent:
- `GET` corresponds with "getting" a representation for a resource from a URL: it
  is a pure read, with no mutation of the resource.
- `POST` submits an entity (or data) to the given resource, often creating or
  mutating the resource and causing a state change.
- `PUT` submits an entity (or data) to the given resource for update or
  replacement, again likely causing a state change.
- `PATCH` is similar to `PUT` but implies a partial update and state change rather
  than a complete replacement of the entity.
- `DELETE` deletes the given resource.

These operations correspond closely to the CRUD operations we discussed in
Chapter 2. By giving us access to only two of the five, HTML hamstrings our
ability to take full advantage of HTTP.

This gives us our third opportunity to expand the expressiveness of HTML:

#important[Opportunity 3][
HTML could be extended so that it allows access to the missing three HTTP
methods, `PUT`, `PATCH` and `DELETE`.
]

==== Why Only Replace The Entire Screen? <_why_only_replace_the_entire_screen>

#index[transclusion]
#index[DOM][partial updates]
As a final observation, consider the last aspect of a hyperlink: it replaces the _entire_ screen
when a user clicks on it.

It turns out that this technical detail is the primary culprit for poor user
experience in Web 1.0 Applications. A full page refresh can cause a flash of
unstyled content, where content "jumps" on the screen as it transitions from its
initial to its styled final form. It also destroys the scroll state of the user
by scrolling to the top of the page, removes focus from a focused element and so
forth.

But, if you think about it, there is no rule saying that hypermedia exchanges _must_ replace
the entire document.

This gives us our fourth, final and perhaps most important opportunity to
generalize HTML:

#important[Opportunity 4][
  HTML could be extended to allow the responses to requests to replace elements _within_ the
  current document, rather than requiring that they replace the _entire_ document.
]

This is actually a very old concept in hypermedia. Ted Nelson, in his 1980 book "Literary
Machines" coined the term _transclusion_ to capture this idea: the inclusion of
content into an existing document via a hypermedia reference. If HTML supported
this style of "dynamic transclusion," then Hypermedia-Driven Applications could
function much more like a Single Page Application, where only part of the DOM is
updated by a given user interaction or network request.

=== Extending HTML as a Hypermedia with Htmx <_extending_html_as_a_hypermedia_with_htmx>
These four opportunities present us a way to extend HTML well beyond its current
abilities, but in a way that is _entirely within_ the hypermedia model of the
web. The fundamentals of HTML, HTTP, the browser, and so on, won’t be changed
dramatically. Rather, these generalizations of _existing functionality_ already
found within HTML would simply let us accomplish _more_ using HTML.

#index[htmx][about]
Htmx is a JavaScript library that extends HTML in exactly this manner, and it
will be the focus of the next few chapters of this book. Again, htmx is not the
only JavaScript library that takes this hypermedia-oriented approach (other
excellent examples are
#link("https://unpoly.com")[Unpoly] and
#link("https://hotwire.dev")[Hotwire]), but htmx is the purest in its pursuit of
extending HTML as a hypermedia.

==== Installing and Using Htmx <_installing_and_using_htmx>
From a practical "getting started" perspective, htmx is a simple,
dependency-free and stand-alone JavaScript library that can be added to a web
application by simply including it via a `script` tag in your
`head` element.

#index[htmx][installing]
Because of this simple installation model, you can take advantage of tools like
public CDNs to install the library.

Below is an example using the popular #link("https://unpkg.com")[unpkg]
Content Delivery Network (CDN) to install version `1.9.2` of the library. We use
an integrity hash to ensure that the delivered JavaScript content matches what
we expect. This SHA can be found on the htmx website.

We also mark the script as `crossorigin="anonymous"` so no credentials will be
sent to the CDN.

#figure(caption: [Installing htmx],
```html
<head>
<script src="https://unpkg.com/htmx.org@1.9.2"
  integrity="sha384-L6OqL9pRWyyFU3+/bjdSri+iIphTN/
    bvYyM37tICVyOJkWZLpP2vGn6VUEXgzg6h"
  crossorigin="anonymous"></script>
</head>
```)

If you are used to modern JavaScript development, with complex build systems and
large numbers of dependencies, it may be a pleasant surprise to find that that’s
all it takes to install htmx.

This is in the spirit of the early web, when you could simply include a script
tag and things would "just work."

If you don’t want to use a CDN, you can download htmx to your local system and
adjust the script tag to point to wherever you keep your static assets. Or, you
may have a build system that automatically installs dependencies. In this case
you can use the Node Package Manager (npm) name for the library: `htmx.org` and
install it in the usual manner that your build system supports.

Once htmx has been installed, you can begin using it immediately.

==== No JavaScript Required…​ <_no_javascript_required>
And here we get to the interesting part of htmx: htmx does not require you, the
user of htmx, to actually write any JavaScript.

#index[htmx][attributes]
Instead, you will use _attributes_ placed directly on elements in your HTML to
drive more dynamic behavior. Htmx extends HTML as a hypermedia, and it is
designed to make that extension feel as natural and consistent as possible with
existing HTML concepts. Just as an anchor tag uses an `href` attribute to
specify the URL to retrieve, and forms use an `action` attribute to specify the
URL to submit the form to, htmx uses HTML _attributes_ to specify the URL that
an HTTP request should be issued to.

=== Triggering HTTP Requests <_triggering_http_requests>

#index[hx-get][about]
#index[hx-post][about]
#index[hx-put][about]
#index[hx-patch][about]
#index[hx-delete][about]
Let’s look at the first feature of htmx: the ability for any element in a web
page to issue HTTP requests. This is the core functionality provided by htmx,
and it consists of five attributes that can be used to issue the five different
developer-facing types of HTTP requests:
- `hx-get` - issues an HTTP `GET` request.
- `hx-post` - issues an HTTP `POST` request.
- `hx-put` - issues an HTTP `PUT` request.
- `hx-patch` - issues an HTTP `PATCH` request.
- `hx-delete` - issues an HTTP `DELETE` request.

Each of these attributes, when placed on an element, tells the htmx library: "When
a user clicks (or whatever) this element, issue an HTTP request of the specified
type."

The values of these attributes are similar to the values of both `href`
on anchors and `action` on forms: you specify the URL you wish to issue the
given HTTP request type to. Typically, this is done via a server-relative path.

#index[hx-get][example]
For example, if we wanted a button to issue a `GET` request to
`/contacts` then we would write the following HTML:

#figure(caption: [A simple htmx-powered button],
```html
<button hx-get="/contacts"> <1>
  Get The Contacts
</button>
```)
1. A simple button that issues an HTTP `GET` to `/contacts`.

The htmx library will see the `hx-get` attribute on this button, and hook up
some JavaScript logic to issue an HTTP `GET` AJAX request to the
`/contacts` path when the user clicks on it.

Very easy to understand and very consistent with the rest of HTML.

==== It’s All Just HTML <_its_all_just_html>

#index[htmx][HTML based]
With the request issued by the button above, we get to perhaps the most
important thing to understand about htmx: it expects the response to this AJAX
request _to be HTML_. Htmx is an extension of HTML. A native hypermedia control
like an anchor tag will typically get an HTML response to an HTTP request it
creates. Similarly, htmx expects the server to respond to the requests that _it_ makes
with HTML.

This may surprise web developers who are used to responding to an AJAX request
with JSON, which is far and away the most common response format for such
requests. But AJAX requests are just HTTP requests and there is no rule saying
they must use JSON. Recall again that AJAX stands for Asynchronous JavaScript &
XML, so JSON is already a step away from the format originally envisioned for
this API: XML.

Htmx simply goes another direction and expects HTML.

==== Htmx vs. "Plain" HTML Responses <_htmx_vs_plain_html_responses>
There is an important difference between the HTTP responses to "normal" anchor
or form driven HTTP requests and to htmx-powered requests: in the case of htmx
triggered requests, responses can be _partial_ bits of HTML.

#index[htmx][transclusion]
#index[htmx][partial updates]
In htmx-powered interactions, as you will see, we are often not replacing the
entire document. Rather we are using "transclusion" to include content _within_ an
existing document. Because of this, it is often not necessary or desirable to
transfer an entire HTML document from the server to the browser.

This fact can be used to save bandwidth as well as resource loading time. Less
overall content is transferred from the server to the client, and it isn’t
necessary to reprocess a `head` tag with style sheets, script tags, and so
forth.

When the "Get Contacts" button is clicked, a _partial_ HTML response might look
something like this:

#figure(caption: [A partial HTML response to an htmx request],
```html
<ul>
  <li><a href="mailto:joe@example.com">Joe</a></li>
  <li><a href="mailto:sarah@example.com">Sarah</a></li>
  <li><a href="mailto:fred@example.com">Fred</a></li>
</ul>
```)

This is just an unordered list of contacts with some clickable elements in it.
Note that there is no opening `html` tag, no `head` tag, and so forth: it is a _raw_ HTML
list, without any decoration around it. A response in a real application might
contain more sophisticated HTML than this simple list, but even if it were more
complicated it wouldn’t need to be an entire page of HTML: it could just be the "inner"
content of the HTML representation for this resource.

Now, this simple list response is perfect for htmx. Htmx will simply take the
returned content and then swap it in to the DOM in place of some element in the
page. (More on exactly where it will be placed in the DOM in a moment.) Swapping
in HTML content in this manner is fast and efficient because it leverages the
existing native HTML parser in the browser, rather than requiring a significant
amount of client-side JavaScript to be executed.

This small HTML response shows how htmx stays within the hypermedia paradigm:
just like a "normal" hypermedia control in a "normal" web application, we see
hypermedia being transferred to the client in a stateless and uniform manner.

This button just gives us a slightly more sophisticated mechanism for building a
web application using hypermedia.

=== Targeting Other Elements <_targeting_other_elements>
Now, given that htmx has issued a request and gotten back some HTML as a
response, and that we are going to swap this content into the existing page
(rather than replacing the entire page), the question becomes: where should this
new content be placed?

It turns out that the default htmx behavior is to simply put the returned
content inside the element that triggered the request. That’s
_not_ a good thing in the case of our button: we will end up with a list of
contacts awkwardly embedded within the button element. That will look pretty
silly and is obviously not what we want.

#index[hx-target][about]
Fortunately htmx provides another attribute, `hx-target` which can be used to
specify exactly _where_ in the DOM the new content should be placed. The value
of the `hx-target` attribute is a Cascading Style Sheet (CSS) _selector_ that
allows you to specify the element to put the new hypermedia content into.

Let’s add a `div` tag that encloses the button with the id `main`. We will then
target this `div` with the response:

#index[hx-target][example]
#figure(caption: [A simple htmx-powered button],
```html
<div id="main"> <1>

  <button hx-get="/contacts" hx-target="#main"> <2>
    Get The Contacts
  </button>

</div>
```)

1. A `div` element that wraps the button.
2. The `hx-target` attribute that specifies the target of the response.

We have added `hx-target="#main"` to our button, where `#main` is a CSS selector
that says "The thing with the ID 'main'."

By using CSS selectors, htmx builds on top of familiar and standard HTML
concepts. This keeps the additional conceptual load for working with htmx to a
minimum.

Given this new configuration, what would the HTML on the client look like after
a user clicks on this button and a response has been received and processed?

It would look something like this:

#figure(caption: [Our HTML after the htmx request finishes],
```html
<div id="main">
  <ul>
    <li><a href="mailto:joe@example.com">Joe</a></li>
    <li><a href="mailto:sarah@example.com">Sarah</a></li>
    <li><a href="mailto:fred@example.com">Fred</a></li>
  </ul>
</div>
```)

The response HTML has been swapped into the `div`, replacing the button that
triggered the request. Transclusion! And this has happened "in the background"
via AJAX, without a clunky page refresh.

=== Swap Styles <_swap_styles>
Now, perhaps we don’t want to load the content from the server response
_into_ the div, as child elements. Perhaps, for whatever reason, we wish to _replace_ the
entire div with the response. To handle this, htmx provides another attribute, `hx-swap`,
that allows you to specify exactly _how_ the content should be swapped into the
DOM.

#index[htmx][swap model]
#index[hx-swap][about]
#index[hx-swap][innerHTML]
#index[hx-swap][outerHTML]
#index[hx-swap][beforebegin]
#index[hx-swap][afterbegin]
#index[hx-swap][beforeend]
#index[hx-swap][afterend]
#index[hx-swap][delete]
#index[hx-swap][none]
The `hx-swap` attribute supports the following values:
- `innerHTML` - The default, replace the inner html of the target element.
- `outerHTML` - Replace the entire target element with the response.
- `beforebegin` - Insert the response before the target element.
- `afterbegin` - Insert the response before the first child of the target element.
- `beforeend` - Insert the response after the last child of the target element.
- `afterend` - Insert the response after the target element.
- `delete` - Deletes the target element regardless of the response.
- `none` - No swap will be performed.

The first two values, `innerHTML` and `outerHTML`, are taken from the standard
DOM properties that allow you to replace content within an element or in place
of an entire element respectively.

The next four values are taken from the `Element.insertAdjacentHTML()`
DOM API, which allow you to place an element or elements around a given element
in various ways.

The last two values, `delete` and `none` are specific to htmx. The first option
will remove the target element from the DOM, while the second option will do
nothing (you may want to only work with response headers, an advanced technique
we will look at later in the book.)

Again, you can see htmx stays as close as possible to existing web standards in
order to minimize the conceptual load necessary for its use.

So let’s consider that case where, rather than replacing the `innerHTML`
content of the main div above, we want to replace the _entire div_
with the HTML response.

To do so would require only a small change to our button, adding a new
`hx-swap` attribute:

#figure(caption: [Replacing the entire div])[ ```html
<div id="main">

  <button hx-get="/contacts" hx-target="#main" hx-swap="outerHTML"> <1>
    Get The Contacts
  </button>

</div>
``` ]
1. The `hx-swap` attribute specifies how to swap in new content.

Now, when a response is received, the _entire_ div will be replaced with the
hypermedia content:

#figure(caption: [Our HTML after the htmx request finishes],
```html
<ul>
  <li><a href="mailto:joe@example.com">Joe</a></li>
  <li><a href="mailto:sarah@example.com">Sarah</a></li>
  <li><a href="mailto:fred@example.com">Fred</a></li>
</ul>
```)

You can see that, with this change, the target div has been entirely removed
from the DOM, and the list that was returned as the response has replaced it.

Later in the book we will see additional uses for `hx-swap`, for example when we
implement infinite scrolling in our contact management application.

Note that with the `hx-get`, `hx-post`, `hx-put`, `hx-patch` and
`hx-delete` attributes, we have addressed two of the four opportunities for
improvement that we enumerated regarding plain HTML:
- Opportunity 1: We can now issue an HTTP request with _any_
  element (in this case we are using a button).
- Opportunity 3: We can issue _any sort_ of HTTP request we want,
  `PUT`, `PATCH` and `DELETE`, in particular.

And, with `hx-target` and `hx-swap` we have addressed a third shortcoming: the
requirement that the entire page be replaced.
- Opportunity 4: We can now replace any element we want in our page via
  transclusion, and we can do so in any manner we want.

So, with only seven relatively simple additional attributes, we have addressed
most of the shortcomings of HTML as a hypermedia that we identified earlier.

What’s next? Recall the one other opportunity we noted: the fact that only a `click` event
(on an anchor) or a `submit` event (on a form) can trigger an HTTP request.
Let’s look at how we can address that limitation.

=== Using Events <_using_events>
Thus far we have been using a button to issue a request with htmx. You have
probably intuitively understood that the button would issue its request when you
clicked on the button since, well, that’s what you do with buttons: you click on
them.

And, yes, by default when an `hx-get` or another request-driving annotation from
htmx is placed on a button, the request will be issued when the button is
clicked.

#index[hx-trigger][about]
However, htmx generalizes this notion of an event triggering a request by using,
you guessed it, another attribute: `hx-trigger`. The
`hx-trigger` attribute allows you to specify one or more events that will cause
the element to trigger an HTTP request.

Often you don’t need to use `hx-trigger` because the default triggering event
will be what you want. The default triggering event depends on the element type,
and should be fairly intuitive:
- Requests on `input`, `textarea` & `select` elements are triggered by the `change` event.
- Requests on `form` elements are triggered on the `submit` event.
- Requests on all other elements are triggered by the `click` event.

To demonstrate how `hx-trigger` works, consider the following situation: we want
to trigger the request on our button when the mouse enters it. Now, this is
certainly not a _good_ UX pattern, but bear with us: we are just using this as an
example.

To respond to a mouse entering the button, we would add the following attribute
to our button:

#figure(caption: [A (bad?) button that triggers on mouse entry],
```html
<div id="main">

  <button hx-get="/contacts" hx-target="#main" hx-swap="outerHTML"
    hx-trigger="mouseenter"> <1>
    Get The Contacts
  </button>

</div>
```)
1. Issue a request on the... `mouseenter` event.

Now, with this `hx-trigger` attribute in place, whenever the mouse enters this
button, a request will be triggered. Silly, but it works.

Let’s try something a bit more realistic and potentially useful: let’s add
support for a keyboard shortcut for loading the contacts, `Ctrl-L`
(for "Load"). To do this we will need to take advantage of additional syntax
that the `hx-trigger` attribute supports: event filters and additional
arguments.

#index[hx-trigger][event filters]
Event filters are a mechanism for determining if a given event should trigger a
request or not. They are applied to an event by adding square brackets after it: `someEvent[someFilter]`.
The filter itself is a JavaScript expression that will be evaluated when the
given event occurs. If the result is truthy, in the JavaScript sense, it will
trigger the request. If not, the request will not be triggered.

#index[event][keyup]
In the case of keyboard shortcuts, we want to catch the `keyup` event in
addition to the click event:

#figure(caption: [A start, trigger on keyup],
```html
<div id="main">

  <button hx-get="/contacts" hx-target="#main" hx-swap="outerHTML"
    hx-trigger="click, keyup"> <1>
    Get The Contacts
  </button>

</div>
```)
1. A trigger with two events.

#index[hx-trigger][multiple events]
Note that we have a comma separated list of events that can trigger this
element, allowing us to respond to more than one potential triggering event. We
still want to respond to the `click` event and load the contacts, in addition to
handling the `Ctrl-L` keyboard shortcut.

Unfortunately there are two problems with our `keyup` addition: As it stands, it
will trigger requests on _any_ keyup event that occurs. And, worse, it will only
trigger when a keyup occurs _within_ this button. The user would need to tab
onto the button to make it active and then begin typing.

Let’s fix these two issues. To fix the first one, we will use a trigger filter
to test that Control key and the "L" key are pressed together:

#index[event filter][example]
#figure(caption: [Getting better with filter on keyup],
```html
<div id="main">

  <button hx-get="/contacts" hx-target="#main" hx-swap="outerHTML"
    hx-trigger="click, keyup[ctrlKey && key == 'l']"> <1>
    Get The Contacts
  </button>

</div>
```)
1. `keyup` now has a filter, so the control key and L must be pressed.

The trigger filter in this case is `ctrlKey && key == 'l'`. This can be read as "A
key up event, where the ctrlKey property is true and the key property is equal
to l." Note that the properties `ctrlKey` and `key`
are resolved against the event rather than the global name space, so you can
easily filter on the properties of a given event. You can use any expression you
like for a filter, however: calling a global JavaScript function, for example,
is perfectly acceptable.

OK, so this filter limits the keyup events that will trigger the request to only `Ctrl-L` presses.
However, we still have the problem that, as it stands, only `keyup` events _within_ the
button will trigger the request.

#index[event bubbling]
If you are not familiar with the JavaScript event bubbling model: events
typically "bubble" up to parent elements. So an event like `keyup` will be
triggered first on the focused element, and then on its parent (enclosing)
element, and so on, until it reaches the top level
`document` object that is the root of all other elements.

#index[hx-trigger][from:]
#index[keyboard shortcut]
To support a global keyboard shortcut that works regardless of what element has
focus, we will take advantage of event bubbling and a feature that the `hx-trigger` attribute
supports: the ability to listen to _other elements_ for events. The syntax for
doing this is the
`from:` modifier, which is added after an event name and that allows you to
specify a specific element to listen for the given event on using a CSS
selector.

#index[events][listener]
In this case, we want to listen to the `body` element, which is the parent
element of all visible elements on the page.

Here is what our updated `hx-trigger` attribute looks like:

#figure(caption: [Even better, listen for keyup on the body],
```html
<div id="main">

  <button hx-get="/contacts" hx-target="#main" hx-swap="outerHTML"
    hx-trigger="click, keyup[ctrlKey && key == 'l'] from:body"> <1>
    Get The Contacts
  </button>

</div>
```)
1. Listen to the 'keyup' event on the `body` tag.

Now, in addition to clicks, the button will listen for `keyup` events on the
body of the page. So it will issue a request when it is clicked on and also
whenever someone hits `Ctrl-L` within the body of the page.

And now we have a nice keyboard shortcut for our Hypermedia-Driven Application.

#index[hx-trigger][about]
The `hx-trigger` attribute supports many more modifiers, and it is more
elaborate than other htmx attributes. This is because events, in general, are
complicated and require a lot of details to get just right. The default trigger
will often suffice, however, and you typically don’t need to reach for
complicated `hx-trigger` features when using htmx.

Even with more sophisticated trigger specifications like the keyboard shortcut
we just added, the overall feel of htmx is _declarative_
rather than _imperative_. That keeps htmx-powered applications
"feeling like" standard web 1.0 applications in a way that adding significant
amounts of JavaScript does not.

=== Htmx: HTML eXtended <_htmx_html_extended>
And hey, check it out! With `hx-trigger` we have addressed the final opportunity
for improvement of HTML that we outlined at the start of this chapter:
- Opportunity 2: We can use _any_ event to trigger an HTTP request.

That’s a grand total of eight, count 'em, _eight_ attributes that all fall
squarely within the same conceptual model as normal HTML and that, by extending
HTML as a hypermedia, open up a whole new world of user interaction
possibilities within it.

#index[HTML][opportunities]
Here is a table summarizing those opportunities and which htmx attributes
address them:

/ Any element should be able to make HTTP requests: #[
  `hx-get`, `hx-post`, `hx-put`, `hx-patch`, `hx-delete`
  ]

/ Any event should be able to trigger an HTTP request: #[
  `hx-trigger`
  ]

/ Any HTTP Action should be available: #[
  `hx-put`, `hx-patch`, `hx-delete`
  ]

/ Any place on the page should be replaceable (transclusion): #[
  `hx-target`, `hx-swap`
  ]

=== Passing Request Parameters <_passing_request_parameters>

So far we have just looked at a situation where a button makes a simple
`GET` request. This is conceptually very close to what an anchor tag might do.
But there is that other native hypermedia control in HTML-based applications: #indexed[forms].
Forms are used to pass additional information beyond just a URL up to the server
in a request.

This information is captured via input and input-like elements within the form
via the various types of input tags available in HTML.

Htmx allows you include this additional information in a way that mirrors HTML
itself.

==== Enclosing Forms <_enclosing_forms>
The simplest way to pass input values with a request in htmx is to enclose the
element making a request within a form tag.

Let’s take our original #indexed[search] form and convert it to use htmx instead:

#figure(caption: [An htmx-powered search button],
```html
<form action="/contacts" method="get" class="tool-bar"> <1>
  <label for="search">Search Term</label>
  <input id="search" type="search" name="q" 
    value="{{ request.args.get('q') or '' }}"
    placeholder="Search Contacts"/>
  <button hx-post="/contacts" hx-target="#main"> <2>
    Search
  </button>
</form>
```)

1. When an htmx-powered element is withing an ancestor form tag, all input values within that
   form will be submitted for non-`GET` requests
2. We have switched from an `input` of type `submit` to a `button` and added the `hx-post` attribute

#index[htmx][form values]
Now, when a user clicks on this button, the value of the input with the id `search` will
be included in the request. This is by virtue of the fact that there is a form
tag enclosing both the button and the input: when an htmx-driven request is
triggered, htmx will look up the DOM hierarchy for an enclosing form, and, if
one is found, it will include all values from within that form. (This is
sometimes referred to as
"serializing" the form.)

You might have noticed that the button was switched from a `GET` request to a `POST` request.
This is because, by default, htmx does _not_
include the closest enclosing form for `GET` requests, but it
_does_ include the form for all other types of requests.

This may seem a little strange, but it avoids junking up URLs that are used
within forms when dealing with history entries, which we will discuss in a bit.
You can always include an enclosing form’s values with an element that uses
a `GET` by using the `hx-include` attribute, which we will discuss next.

Note also that we could have added the `hx-post` attribute to the form, rather than to the button
but that would create a somewhat awkward duplication of the search URL in the `action` and `hx-post`
attributes.  This can be avoided by using the `hx-boost` attribute, which we discuss in the next
chapter.

==== Including Inputs <_including_inputs>

#index[form tag][in tables]
While enclosing all the inputs you want included in a request within a form is the most common
approach for serializing inputs for htmx requests, it isn’t always possible or desirable:
form tags can have layout consequences and simply cannot be placed in some spots
in HTML documents. A good example of the latter situation is in table row (`tr`)
elements: the `form` tag is not a valid child or parent of table rows, so you
can’t place a form within or around a row of data in a table.

#index[hx-include][about]
#index[hx-include][example]
To address this issue, htmx provides a mechanism for including input values in
requests: the `hx-include` attribute. The `hx-include`
attribute allows you to select input values that you wish to include in a
request via CSS selectors.

Here is the above example reworked to include the input, dropping the form:

#figure(caption: [An htmx-powered search button with `hx-include`],
```html
<div id="main">

  <label for="search">Search Contacts:</label>
  <input id="search" name="q"  type="search" 
    value="{{ request.args.get('q') or '' }}"
    placeholder="Search Contacts"/>
  <button hx-post="/contacts" hx-target="#main" hx-include="#search"> <1>
    Search
  </button>

</div>
```)
1. `hx-include` can be used to include values directly in a request.

The `hx-include` attribute takes a CSS selector value and allows you to specify
exactly which values to send along with the request. This can be useful if it is
difficult to colocate an element issuing a request with all the desired inputs.

It is also useful when you do, in fact, want to submit values with a
`GET` request and overcome the default behavior of htmx.

===== Relative CSS selectors <_relative_css_selectors>

#index[relative CSS selectors][about]
The `hx-include` attribute and, in fact, most attributes that take a CSS
selector, also support _relative_ CSS selectors. These allow you to specify a
CSS selector _relative_ to the element it is declared on. Here are some
examples:

/ `closest`: #index[relative CSS selectors][closest] Find the closest parent
element matching the given selector, e.g., `closest form`.

/ `next`: #index[relative CSS selectors][next] Find the next element (scanning
forward) matching the given selector, e.g., `next input`.

/ `previous`: #index[relative CSS selectors][previous] Find the previous element
(scanning backwards) matching the given selector, e.g., `previous input`.

/ `find`: #index[relative CSS selectors][find] Find the next element within this
element matching the given selector, e.g., `find input`.

/ `this`: #index[relative CSS selectors][this] The current element.

Using relative CSS selectors often allows you to avoid generating ids for
elements, since you can take advantage of their local structural layout instead.

==== Inline Values <_inline_values>

#index[hx-vals][about]
A final way to include values in htmx-driven requests is to use the
`hx-vals` attribute, which allows you to include "static" values in the request.
This can be useful if you have additional information that you want to include
in requests, but you don’t want to have this information embedded in, for
example, hidden inputs (which would be the standard mechanism for including
additional, hidden information in HTML.)

#index[hx-vals][example]
#index[hx-vals][JSON]
#index[query strings]
Here is an example of `hx-vals`:

#figure(caption: [An htmx-powered button with `hx-vals`],
```html
<button hx-get="/contacts" hx-vals='{"state":"MT"}'> <1>
  Get The Contacts In Montana
</button>
```)
1. `hx-vals`, a JSON value to include in the request.

The parameter `state` with the value `MT` will be included in the `GET`
request, resulting in a path and parameters that looks like this:
`/contacts?state=MT`. Note that we switched the `hx-vals` attribute to use
single quotes around its value. This is because JSON strictly requires double
quotes and, therefore, to avoid escaping we needed to use the single-quote form
for the attribute value.

#index[hx-vals][js: prefix]
You can also prefix `hx-vals` with a `js:` and pass values evaluated at the time
of the request, which can be useful for including things like a dynamically
maintained variable, or value from a third party JavaScript library.

For example, if the `state` variable were maintained dynamically, via some
JavaScript, and there existed a JavaScript function,
`getCurrentState()`, that returned the currently selected state, it could be
included dynamically in htmx requests like so:

#figure(caption: [A dynamic value],
```html
<button hx-get="/contacts"
  hx-vals='js:{"state":getCurrentState()}'> <1>
  Get The Contacts In The Selected State
</button>
```)
1. With the `js:` prefix, this expression will evaluate at submit time.

These three mechanisms, using `form` tags, using the `hx-include`
attribute and using the `hx-vals` attribute, allow you to include values in your
hypermedia requests with htmx in a manner that should feel very familiar and in
keeping with the spirit of HTML, while also giving you the flexibility to
achieve what you want.

=== History Support <_history_support>
We have a final piece of functionality to close out our overview of htmx:
browser history support. When you use normal HTML links and forms, your browser
will keep track of all the pages that you have visited. You can then use the
back button to navigate back to a previous page and, once you have done this,
you can use a forward button to go forward to the original page you were on.

#index[browser history]
This notion of history was one of the killer features of the early web.
Unfortunately it turns out that history becomes tricky when you move to the
Single Page Application paradigm. An AJAX request does not, by itself, register
a web page in your browser’s history, which is a good thing: an AJAX request may
have nothing to do with the state of the web page (perhaps it is just recording
some activity in the browser), so it wouldn’t be appropriate to create a new
history entry for the interaction.

However, there are likely to be a lot of AJAX driven interactions in a Single
Page Application where it _is_ appropriate to create a history entry. There is a
JavaScript API to work with browser history, but this API is deeply annoying and
difficult to work with, and thus often ignored by JavaScript developers.

If you have ever used a Single Page Application and accidentally clicked the
back button, only to lose your entire application state and have to start over,
you have seen this problem in action.

In htmx, as with Single Page Application frameworks, you will often need to
explicitly work with the history API. Fortunately, since htmx sticks so close to
the native model of the web and since it is declarative, getting web history
right is typically much easier to do in an htmx-based application.

Consider the button we have been looking at to load contacts:

#figure(caption: [Our trusty button],
```html
<button hx-get="/contacts" hx-target="#main">
  Get The Contacts
</button>
```)

As it stands, if you click this button it will retrieve the content from
`/contacts` and load it into the element with the id `main`, but it will
_not_ create a new history entry.

#index[hx-push-url]
#index[back button]
If we wanted it to create a history entry when this request happened, we would
add a new attribute to the button, the `hx-push-url` attribute:

#figure(caption: [Our trusty button, now with history!],
```html
<button hx-get="/contacts" hx-target="#main" hx-push-url="true"> <1>
  Get The Contacts
</button>
```)
1. `hx-push-url` will create an entry in history when the button is clicked.

Now, when the button is clicked, the `/contacts` path will be put into the
browser’s navigation bar and a history entry will be created for it.
Furthermore, if the user clicks the back button, the original content for the
page will be restored, along with the original URL.

#index[htmx][browser history]
Now, the name `hx-push-url` for this attribute might sound a little obscure, but
it is based on the JavaScript API, `history.pushState()`. This notion of "pushing"
derives from the fact that history entries are modeled as a stack, and so you
are "pushing" new entries onto the top of the stack of history entries.

With this relatively simple, declarative mechanism, htmx allows you to integrate
with the back button in a way that mimics the "normal" behavior of HTML.

Now, there is one additional thing we need to handle to get history
"just right": we have "pushed" the `/contacts` path into the browsers location
bar successfully, and the back button works. But what if someone refreshes their
browser while on the `/contacts` page?

In this case, you will need to handle the htmx-based "partial" response as well
as the non-htmx "full page" response. You can do this using HTTP headers, a
topic we will go into in detail later in the book.

=== Conclusion <_conclusion>
So that’s our whirlwind introduction to htmx. We’ve only seen about ten
attributes from the library, but you can see a hint of just how powerful these
attributes can be. Htmx enables a much more sophisticated web application than
is possible in plain HTML, with minimal additional conceptual load compared to
most JavaScript-based approaches.

Htmx aims to incrementally improve HTML as a hypermedia in a manner that is
conceptually coherent with the underlying markup language. Like any technical
choice, this is not without trade-offs: by staying so close to HTML, htmx does
not give developers a lot of infrastructure that many might feel should be there "by
default".

By staying closer to the native model of the web, htmx aims to strike a balance
between simplicity and functionality, deferring to other libraries for more
elaborate frontend extensions on top of the existing web platform. The good news
is that htmx plays well with others, so when these needs arise it is often easy
enough to bring in another library to handle them.

#html-note[Budgeting For HTML][
  The close relationship between content and markup means that good HTML is
  labor-intensive. Most sites have a separation between the authors, who are
  rarely familiar with HTML, and the developers, who need to develop a generic
  system able to handle any content that’s thrown at it --- this separation
  usually taking the form of a CMS. As a result, having markup tailored to
  content, which is often necessary for advanced HTML, is rarely feasible.

  Furthermore, for internationalized sites, content in different languages being
  injected into the same elements can degrade markup quality as stylistic
  conventions differ between languages. It’s an expense few organizations can
  spare.

  Thus, we don’t expect every site to contain perfectly conformant HTML. What’s
  most important is to avoid _wrong_ HTML --- it can be better to fall back on a
  more generic element than to be precisely incorrect.

  If you have the resources, however, putting more care in your HTML will produce
  a more polished site.
]
