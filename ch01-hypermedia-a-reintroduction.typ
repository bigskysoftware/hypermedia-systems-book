#import "lib/definitions.typ": *

== Hypermedia: A Reintroduction

Hypermedia is a universal technology today, almost as common as electricity.

Billions of people use hypermedia-based systems every day, mainly by interacting
with the _Hypertext Markup Language (HTML)_ being exchanged via the _Hypertext Transfer Protocol (HTTP)_ by
using a web browser connected to the World Wide Web.

People use these systems to get their news, check in on friends, buy things
online, play games, send emails and so forth: the variety and sheer number of
online services being delivered by hypermedia is truly astonishing.

And yet, despite this ubiquity, the topic of hypermedia itself is a strangely
under-explored concept today, left mainly to specialists. Yes, you can find a
lot of tutorials on how to author HTML, create links and forms, etc. But it is
rare to see a discussion of HTML _as a hypermedia_ and, more broadly, on how an
entire hypermedia _system_
fits together.

This is in contrast with the early web development era when concepts like _Representational State Transfer (REST)_ and _Hypermedia As The Engine of Application State (HATEOAS)_ were
discussed frequently, refined and debated among web developers.

In a sad turn of events, today, the world’s most popular hypermedia, HTML, is
often viewed resentfully: it is an awkward, legacy markup language that must be
grudgingly used to build user interfaces in what are increasingly entirely
JavaScript-based web applications.

HTML happens to be there, in the browser, and so we have to use it.

This is a shame and we hope to convince you that hypermedia is
_not_ simply a piece of legacy technology that we have to accept and deal with.
Instead, we aim to show you that hypermedia is a tremendously innovative, simple
and _flexible_ way to build robust applications: _Hypermedia-Driven Applications_.

We hope that by the end of this book you will feel, as we do, that the
hypermedia approach deserves a seat at the table when you, a web developer, are
considering the architecture of your next application. Creating a
Hypermedia-Driven Application on top of a _hypermedia system_ like the web is a
viable and, indeed, often excellent choice for
_modern_ web applications.

(And, as the section on Hyperview will show, not just web applications.)

=== What Is Hypermedia? <_what_is_hypermedia>

#blockquote(
  attribution: [Ted Nelson, https:\/\/archive.org/details/SelectedPapers1977/page/n7/mode/2up],
)[
  Hypertexts: new forms of writing, appearing on computer screens, that will
  branch or perform at the reader’s command. A hypertext is a non-sequential piece
  of writing; only the computer display makes it practical.
]

Let us begin at the beginning: what is hypermedia?

#index[hypermedia]
Hypermedia is a media, for example a text, that includes
_non-linear branching_ from one location in the media to another, via, for
example, hyperlinks embedded in the media. The prefix "hyper-" derives from the
Greek prefix "ὑπερ-" which means "beyond" or "over", indicating that hypermedia _goes beyond_ normal,
passively consumed media like magazines and newspapers.

Hyperlinks are a canonical example of what is called a _#indexed[hypermedia control]_:

/ Hypermedia Control: #[
    A #indexed[hypermedia control] is an element in a hypermedia that describes (or
    controls) some sort of interaction, often with a remote server, by encoding
    information about that interaction directly and completely within itself.
  ]

Hypermedia controls are what differentiate hypermedia from other sorts of media.

You may be more familiar with the term _#indexed[hypertext]_, from whose
Wikipedia page the above quote is taken. Hypertext is a sub-category of
hypermedia and much of this book is going to discuss how to build modern
applications using hypertexts such as HTML, the Hypertext Markup Language, or
HXML, a hypertext used by the Hyperview mobile hypermedia system.

Hypertexts like HTML function alongside other technologies crucial for making an
entire hypermedia system work: network protocols like HTTP, other media types
such as images and videos, hypermedia servers (i.e., servers providing
hypermedia APIs), sophisticated hypermedia clients (e.g., web browsers), and so
on.

Because of this, we prefer the broader term _#indexed[hypermedia system]s_
when describing the underlying architecture of applications built using
hypertext, to emphasize the system architecture over the particular hypermedia
being used.

It is the entire hypermedia _system architecture_ that is underappreciated and
ignored by many modern web developers.

=== A Brief History of Hypermedia <_a_brief_history_of_hypermedia>
Where did the idea of hypermedia come from?

#index[Bush, Vannevar]
#index[Memex]
While there were many precursors to the modern idea of hypertext and the more
general hypermedia, many people point to the 1945 article _As We May Think_ written
by Vannevar Bush in _The Atlantic_ as a starting point for looking at what has
become modern hypermedia.

In this article Bush described a device called a #indexed[Memex], which, using a
complex mechanical system of reels and microfilm, along with an encoding system,
would allow users to jump between related frames of content. The Memex was never
actually implemented, but it was an inspiration for later work on the idea of
hypermedia.

#index[Nelson, Ted]
The terms "hypertext" and "hypermedia" were coined in 1963 by Ted Nelson, who
would go on to work on the _Hypertext Editing System_
at Brown University and who later created the _File Retrieval and Editing System (#indexed[FRESS])_,
a shockingly advanced hypermedia system for its time. (This was perhaps the
first digital system to have a notion of
"undo".)

#index[Engelbart, Douglas]
While Nelson was working on his ideas, Douglas Engelbart was busy at work at the
Stanford Research Institute, explicitly attempting to make Vannevar Bush’s Memex
a reality. In 1968, Englebart gave "The Mother of All Demos" in San Francisco,
California.

Englebart demonstrated an unbelievable amount of technology:

- Remote, collaborative text editing with his peers in Menlo Park
- Video and audio chat
- An integrated windowing system, with window resizing, etc
- A recognizable hypertext, whereby clicking on underlined text navigated to new
  content.

Despite receiving a standing ovation from a shocked audience after his talk, it
was decades before the technologies Englebart demonstrated became mainstream.

==== Modern Implementation <_modern_implementation>

#index[Berners-Lee, Tim]
#index[World Wide Web][creation]
In 1990, Tim Berners-Lee, working at CERN, published the first website. He had
been working on the idea of hypertext for a decade and had finally, out of
desperation at the fact it was so hard for researchers to share their research,
found the right moment and institutional support to create the World Wide Web:

#blockquote(
  attribution: [Tim Berners-Lee,
    https:\/\/britishheritage.org/tim-berners-lee-the-world-wide-web],
)[
  Creating the web was really an act of desperation, because the situation without
  it was very difficult when I was working at CERN later. Most of the technology
  involved in the web, like the hypertext, like the Internet, multifont text
  objects, had all been designed already. I just had to put them together. It was
  a step of generalising, going to a higher level of abstraction, thinking about
  all the documentation systems out there as being possibly part of a larger
  imaginary documentation system.
]

By 1994 his creation was taking off so quickly that Berners-Lee founded the W3C,
a working group of companies and researchers tasked with improving the web. All
standards created by the W3C were royalty-free and could be adopted and
implemented by anyone, cementing the open, collaborative nature of the web.

#index[Fielding, Roy]
In 2000, Roy Fielding, then at U.C. Irvine, published a seminal PhD dissertation
on the web: "Architectural Styles and the Design of Network-based Software
Architectures." Fielding had been working on the open source Apache HTTP Server
and his thesis was a description of what he felt was a _new and distinct networking architecture_ that
had emerged in the early web. Fielding had worked on the initial HTTP
specifications and, in the paper, defined the web’s hypermedia network model
using the term _REpresentational State Transfer (#indexed[REST])_.

Fielding’s work became a major touchstone for early web developers, giving them
a language to discuss the new technical medium they were building applications
in.

We will discuss Fielding’s key ideas in depth in Chapter 2, and try to correct
the record with respect to REST, HATEOAS and hypermedia.

=== The World’s Most Successful Hypertext: HTML <_the_worlds_most_successful_hypertext_html>
#blockquote(
  attribution: [Rescuing REST From the API Winter,
    https:\/\/intercoolerjs.org/2016/01/18/rescuing-rest.html],
)[
  In the beginning was the hyperlink, and the hyperlink was with the web, and the
  hyperlink was the web. And it was good.
]

#index[HTML][history]
The system that Berners-Lee, Fielding and many others had created revolved
around a hypermedia: HTML. HTML started as a read-only hypermedia, used to
publish (at first) academic documents. These documents were linked together via
anchor tags which created
_hyperlinks_ between them, allowing users to quickly navigate between documents.

When #index[HTML][2.0] HTML 2.0 was released, it introduced the notion of the `form` tag,
joining the anchor tag (i.e., hyperlink) as a second hypermedia control. The
introduction of the form tag made building _applications_ on the web viable by
providing a mechanism for _updating_ resources, rather than just reading them.

It was at this point that the web transitioned from an interesting
document-oriented system to a compelling _application architecture_.

Today HTML is the most widely used hypermedia in existence and this book
naturally assumes that the reader has a reasonable familiarity with it. You do
not need to be an HTML (or CSS) expert to understand the code in this book, but
the better you understand the core tags and concepts of HTML, the more you will
get out of it.

==== The Essence of HTML as a Hypermedia <_the_essence_of_html_as_a_hypermedia>
Let us consider these two defining hypermedia elements (that is the two defining _hypermedia controls_)
of HTML, the anchor tag and the form tag, in a bit of detail.

===== Anchor tags <_anchor_tags>

#index[hyperlink]
#index[anchor tag]
Anchor tags are so familiar as to be boring but, as the original hypermedia
control, it is worth reviewing the mechanics of hyperlinks to get our minds in
the right place for developing a deeper understanding of hypermedia.

Consider a simple anchor tag, embedded within a larger HTML document:

#figure(caption: [A simple hyperlink],
```html
<a href="https://hypermedia.systems/">
  Hypermedia Systems
</a>
```)

An anchor tag consists of the tag itself, `<a></a>`, as well as the attributes
and content within the tag. Of particular interest is the
`href` attribute, which specifies a _hypertext reference_ to another document or
document fragment. It is this attribute that makes the anchor tag a hypermedia
control.

In a typical web browser, this anchor tag would be interpreted to mean:

- Show the text "Hypermedia Systems" in a manner indicating that it is clickable
- When the user clicks on that text, issue an HTTP `GET` request to the URL
  `https://hypermedia.systems/`
- Take the HTML content in the body of the HTTP response to this request and
  replace the entire screen in the browser as a new document, updating the
  navigation bar to this new URL.

Anchors provide the main mechanism we use to navigate around the web today, by
selecting links to navigate from document to document, or from resource to
resource. @fig-get-in-action shows what a user interaction with an anchor tag/hyperlink looks like in
visual form.

#asciiart(
  read("images/diagram/http-get-in-action.txt"), caption: [An HTTP GET In Action],
  placement: "bottom", // hack: this figure breaks a code block in this build
)<fig-get-in-action>

#index[GET request]
When the link is clicked the browser (or, as we sometimes refer to it, the _hypermedia client_)
initiates an HTTP `GET` request to the URL encoded in the link’s `href` attribute.

Note that the HTTP request includes additional data (i.e.,
_metadata_) on what, exactly, the browser wants from the server, in the form of
headers. We will discuss these headers, and HTTP in more depth in Chapter 2.

The _hypermedia server_ then responds to this request with a
_hypermedia response_ --- the HTML --- for the new page. This may seem like a
small and obvious point, but it is an absolutely crucial aspect of a truly
RESTful _hypermedia system_: the client and server must communicate via
hypermedia!

===== Form tags <_form_tags>

Anchor tags provide _navigation_ between documents or resources, but don’t allow
you to update those resources. That functionality falls to the #indexed[form tag].

Here is a simple example of a form in HTML:

#figure(caption: [A simple form],
```html
<form action="/signup" method="post">
  <input type="text" name="email" placeholder="Enter Email To Sign Up">
  <button>Sign Up</button>
</form>
```)

Like an anchor tag, a form tag consists of the tag itself,
`<form></form>`, combined with the attributes and content within the tag. Note
that the form tag does not have an `href` attribute, but rather has an `action` attribute
that specifies where to issue an HTTP request.

#index[POST request]
Furthermore, it also has a `method` attribute, which specifies exactly which
HTTP "method" to use. In this example the form is asking the browser to issue a `POST` request.

In contrast with anchor tags, the content and tags _within_ a form can have an
effect on the hypermedia interaction that the form makes with a server. The _values_ of `input` tags
and other tags such as
`select` tags will be included with the HTTP request when the form is submitted,
as URL parameters in the case of a `GET` and as part of the request body in the
case of a `POST`. This allows a form to include an arbitrary amount of
information collected from a user in a request, unlike the anchor tag.

In a typical browser this form tag and its contents would be interpreted by the
browser roughly as follows:

- Show a text input and a "Sign Up" button to the user
- When the user submits the form by clicking the "Sign Up" button or by hitting
  the enter key while the input element is focused, issue an HTTP `POST` request
  to the path `/signup` on the "current" server
- Take the HTML content in the body of the HTTP response body and replace the
  entire screen in the browser as a new document, updating the navigation bar to
  this new URL.

This mechanism allows the user to issue requests to _update the state_ of
resources on the server. Note that despite this new type of request the
communication between client and server is still done entirely with _hypermedia_.

It is the form tag that makes Hypermedia-Driven Applications possible.

If you are an experienced web developer you probably recognize that we are
omitting a few details and complications here. For example, the response to a
form submission often _redirects_ the client to a different URL.

This is true, and we will get down into the muck with forms in more detail in
later chapters but, for now, this simple example suffices to demonstrate the
core mechanism for updating system state purely within hypermedia. @fig-post-in-action is a diagram of the interaction.

#asciiart(
  read("images/diagram/http-post-in-action.txt"), caption: [An HTTP POST In Action],
)<fig-post-in-action>

===== Web 1.0 applications <_web_1_0_applications>
As someone interested in web development, the above diagrams and discussion are
probably very familiar to you. You may even find this content boring. But take a
step back and consider the fact that these two hypermedia controls, anchors and
forms, are the _only_ native ways for a user to interact with a server in plain
HTML.

Only two tags!

And yet, armed with only these two tags, the early web was able to grow
exponentially and offer a staggeringly large amount of online, dynamic
functionality to billions of people.

This is strong evidence of the power of hypermedia. Even today, in a web
development world increasingly dominated by large JavaScript-centric front end
frameworks, many people choose to use simple vanilla HTML to achieve their
application goals and are often perfectly happy with the results.

These two tags give a tremendous amount of expressive power to HTML.

==== So What Isn’t Hypermedia? <_so_what_isnt_hypermedia>
So links and forms are the two main hypermedia-based mechanisms for interacting
with a server available in HTML.

#index[Fetch API]
Now let’s consider a different approach: let’s interact with a server by issuing
an HTTP request via #index[JavaScript] JavaScript. To do this, we will use the
#link(
  "https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API",
)[`fetch()`]
API, a popular API for issuing an "Asynchronous JavaScript and XML," or AJAX #index[AJAX] request,
available in all modern web browsers:

#figure(caption: [JavaScript],
```html
<button onclick="fetch('/api/v1/contacts/1') <1>
                .then(response => response.json()) <2>
                .then(data => updateUI(data)) "> <3>
    Fetch Contact
</button>
```)
1. Issue the request.
2. Convert the response to a JavaScript object.
3. Invoke the `updateUI()` function with the object.

This button has an `onclick` attribute that specifies some JavaScript to run
when the button is clicked.

The JavaScript will issue an AJAX HTTP `GET` request to
`/api/v1/contacts/1` using `fetch()`. An AJAX request is like a "normal" HTTP
request, but it is issued "behind the scenes" by the browser. The user does not
see a request indicator from the browser as they would with normal links and
forms. Additionally, unlike requests issued by those hypermedia controls, it is
up to the JavaScript code to handle the response from the server.

Despite AJAX having XML as part of its acronym, today the HTTP response to this
request would almost certainly be in the JavaScript Object Notation (JSON) #index[JSON] format
rather than XML.

An HTTP response to this request might look something like this:

#figure(caption: [JSON],
```json
{ <1>
  "id": 42, <2>
  "email" : "json-example@example.org" <3>
}
```)

1. The start of a JSON object.
2. A property, in this case with the name `id` and the value `42`.
3. Another property, the email of the contact with this id.

The JavaScript code above converts the JSON text received from the server into a
JavaScript object by calling the `json()` method on it. This new JavaScript
object is then handed off to the #index[updateUI method] `updateUI()`
method.

The `updateUI()` method is responsible for updating the UI based on the data
encoded in the JavaScript Object, perhaps by displaying the contact in a bit of
HTML generated via a client-side template in the JavaScript application.

The details of exactly what the `updateUI()` function does aren’t important for
our discussion.

What _is_ important, what is the _crucial_ aspect of this JSON-based server
interaction is that it is _not_ using hypermedia. The #indexed[JSON API] being
used here does not return a hypermedia response. There are no _hyperlinks_ or
other hypermedia-style controls in it.

This JSON API is, rather, a _#indexed[Data API]_.

Because the response is in JSON and is _not_ hypermedia, the JavaScript `updateUI()` method
must understand how to turn this contact data into HTML.

In particular, the code in `updateUI()` needs to know about the
_internal structure_ and meaning of the data.

It needs to know:

- Exactly how the fields in the JSON data object are structured and named.
- How they relate to one another.
- How to update the local data this new data corresponds with.
- How to render this data to the browser.
- What additional actions/API end points can be called with this data.

In short, the logic in `updateUI()` needs to have intimate knowledge of the API
endpoint at `/api/v1/contact/1`, knowledge provided via some side-channel beyond
the response itself. As a result, the `updateUI()`
code and the API have a strong relationship, known as _#indexed[tight coupling]_:
if the format of the JSON response changes, then the code for
`updateUI()` will almost certainly also need to be changed as well.

===== Single Page Applications <_single_page_applications>
This bit of JavaScript, while very modest, is the organic beginnings of a much
larger conceptual approach to building web applications. This is the beginning
of a _#indexed[Single Page Application (SPA)]_. The web application is no longer
navigating _between_ pages using hypermedia controls as was the case with links
and forms.

Instead, the application is exchanging _plain data_ with the server and then
updating the content _within_ a single page.

When this strategy or architecture is adopted for an entire application,
everything happens on a "Single Page" and, thus the application becomes a "Single
Page Application."

The Single Page Application architecture is extremely popular today and has been
the dominant approach to building web applications for the last decade. This can
be observed by the high level of mind-share and discussion it has received in
the industry.

Today the vast majority of Single Page Applications adopt far more sophisticated
frameworks for managing their user interface than this simple example shows.
Popular libraries such as #indexed[React], #indexed[Angular], #indexed[Vue.js],
etc. are now the common --- indeed, the standard --- way to build web
applications.

With these more complex frameworks developers typically work with an elaborate
client-side model --- that is, with JavaScript objects stored locally in the
browser’s memory that represent the "model" or "domain" of your application.
These JavaScript objects are updated via JavaScript code and the framework then "reacts"
to these changes, updating the user interface.

When the user interface is updated by a user these changes also flow
_into_ the model objects, establishing a "two-way" binding mechanism: the model
can update the UI, and the UI can update the model.

This is a much more sophisticated approach to a web client than hypermedia, and
it typically does away almost entirely with the underlying hypermedia
infrastructure available in the browser.

HTML is still used to build user interfaces, but the _hypermedia_
aspect of the two major hypermedia controls, anchors and forms, are unused.
Neither tag interacts with a server via their native
_hypermedia_ mechanism. Rather, they become user interface elements that drive
local interactions with the in-memory domain model via JavaScript, which is then
synchronized with the server using plain data JSON APIs.

So, as with our simple button above, the Single Page Application approach
foregoes the hypermedia architecture. It leaves aside the advantages of the
existing RESTful architecture of the web and the built-in functionality found in
HTML’s native hypermedia controls in favor of JavaScript driven behaviors.

SPAs are much more like _#indexed[thick client application]s_, that is, like the
client-server applications of the 1980s --- an architecture popular
_before_ the web came along and that the web was, in many ways, a reaction to.

This approach isn’t necessarily wrong, of course: there are times when a thick
client approach is the appropriate choice for an application. But it is worth
thinking about _why_ web developers so frequently make this choice without
considering other alternatives, and if there are reasons _not_ to go down this
path.

=== Why Use Hypermedia? <_why_use_hypermedia>

#blockquote(
  attribution: [Tom MacWright, https://macwright.com/2020/05/10/spa-fatigue.html],
)[
  #index[MacWright, Tom]
  The emerging norm for web development is to build a React single-page
  application, with server rendering. The two key elements of this architecture
  are something like:

  1. The main UI is built & updated in JavaScript using React or something similar.

  2. The backend is an API that that application makes requests against.

  This idea has really swept the internet. It started with a few major popular
  websites and has crept into corners like marketing sites and blogs.
]

The JavaScript-based Single Page Application approach has taken the web
development world by storm, and if there was one single reason for its wild
success it was this: The Single Page Application offers a far more interactive
and immersive experience than the old, gronky, Web 1.0 hypermedia-based
applications could. SPAs had the ability to smoothly update elements inline on a
page without a dramatic reload of the entire document, they had the ability to
use CSS transitions to create nice visual effects, and the ability to hook into
arbitrary events like mouse movements.

All of these abilities give JavaScript-based applications a huge advantage in
building sophisticated user experiences.

Given the popularity, power and success of this modern approach to building web
applications, why on earth would you consider an older, clunkier and less
popular approach like hypermedia?

==== JavaScript Fatigue <_javascript_fatigue>
We are glad you asked!

#index[hypermedia][advantages]
It turns out that the hypermedia architecture, even in its original Web 1.0
form, has a number of advantages when compared with the Single Page Application + JSON Data API approach. Three of the biggest are:

- It is an extremely _simple_ approach to building web applications.
- It is extremely tolerant of content and API changes. In fact, it thrives on
  them!
- It leverages tried and true features of web browsers, such as caching.

#index[JavaScript Fatigue]
#index[JSON][API churn]
The first two advantages, in particular, address major pain points in modern web
development:

- Single Page Application infrastructure has become extremely complex, often
  requiring an entire team to manage.
- JSON API churn --- constant changes made to JSON APIs to support application
  needs --- has become a major pain point for many application teams.

The combination of these two problems, along with other issues such as
JavaScript library churn, has led to a phenomenon known as "JavaScript Fatigue."
This refers to a general sense of exhaustion with all the hoops that are
necessary to jump through to get anything done in modern-day web applications.

We believe that a hypermedia architecture can help cure JavaScript Fatigue for
many developers and teams.

But if hypermedia is so great, and if it addresses so many of the problems that
beset the web development industry, why was it set aside in the first place?
After all, hypermedia was there first. Why didn’t web developers just stick with
it?

There are two major reasons hypermedia hasn’t made a comeback in web
development.

The first is this: the expressiveness of HTML _as a hypermedia_
hasn’t changed much, if at all, since HTML 2.0, which was released
_in the mid 1990s_. Many new _features_ have been added to HTML, of course, but
there haven’t been _any_ major new ways to interact with a server in HTML in
almost three decades.

HTML developers still only have anchor tags and forms available as hypermedia
controls, and those hypermedia controls can still only issue
`GET` and `POST` requests.

This baffling lack of progress by HTML leads immediately to the second, and
perhaps more practical reason that HTML-as-hypermedia has fallen on hard times:
as the interactivity and expressiveness of HTML has remained frozen, the demands
of web users have continued to increase, calling for more and more interactive
web applications.

JavaScript-based applications coupled to data-oriented JSON APIs have stepped in
as a way to provide these more sophisticated user interfaces. It was the _user experience_ that
you could achieve in JavaScript, and that you couldn’t achieve in plain HTML,
that drove the web development community to the JavaScript-based Single Page
Application approach. The shift was not driven by any inherent superiority of
the Single Page Application as a system architecture.

It didn’t have to be this way. There is nothing _intrinsic_ to the idea of
hypermedia that prevents it from having a richer, more expressive interactivity
model than vanilla HTML. Rather than moving away from a hypermedia-based
approach, the industry could have demanded more interactivity from HTML.

Instead, building thick-client style applications within web browsers became the
standard, in an understandable move to a more familiar model for building rich
applications.

Not everyone set aside hypermedia, of course. There have been heroic efforts to
continue to advance hypermedia outside of HTML, efforts like
#indexed[HyTime], #indexed[VoiceXML], and #indexed[HAL].

But HTML, the most widely used hypermedia in the world, stopped making progress
as a hypermedia. The web development world moved on, solving the interactivity
problems with HTML by adopting JavaScript-based SPAs and, mostly inadvertently,
a completely different system architecture.

=== A Hypermedia Resurgence? <_a_hypermedia_resurgence>
It is interesting to think about how HTML _could_ have advanced. Instead of
stalling as a hypermedia, how could HTML have continued to develop? Could it
have kept adding new hypermedia controls and increasing the expressiveness of
existing ones? Would it have been possible to build modern web applications
within this original, hypermedia-oriented and RESTful model that made the early
web so powerful, so flexible, so much fun?

This might seem like idle speculation, but we have some good news on this score:
in the last decade a few idiosyncratic, alternative front end libraries have
arisen that attempt to get HTML moving again. Ironically, these libraries are
written in JavaScript, the technology that supplanted HTML as the center of web
development.

However, these libraries use JavaScript not as a _replacement_ for the
fundamental hypermedia system of the web.

Instead, they use JavaScript to augment HTML itself _as a hypermedia_.

These _hypermedia-oriented_ libraries re-center hypermedia as the core
technology in web applications.

==== Hypermedia-Oriented JavaScript Libraries <_hypermedia_oriented_javascript_libraries>

#index[Multi-Page Application (MPA)]
In the web development world there is an ongoing debate between the Single Page
Application (SPA) approach and what is now being called the
"Multi-Page Application" (MPA) approach. MPA is a modern name for the old, Web
1.0 way of building web applications, using links and forms located on multiple
web pages, submitting HTTP requests and getting HTML responses.

MPA applications, by their nature, are Hypermedia-Driven Applications: after
all, they are exactly what Roy Fielding was describing in his dissertation.

These applications tend to be clunky, but they work reasonably well. Many web
developers and teams choose to accept the limitations of plain HTML in the
interest of simplicity and reliability.

Rich Harris, creator of Svelte.js, a popular SPA library, and a thought-leader
on the SPA side of the debate, has proposed a mix of this older MPA style and
the newer SPA style. Harris calls this approach to building web applications "transitional,"
in that it attempts to blend the MPA approach and the newer SPA approach into a
coherent whole. (This is somewhat similar to the "transitional" trend in
architecture, which combines traditional and modern architectural styles.)

"Transitional" is a fitting term for mixed-style applications, and it offers a
reasonable compromise between the two approaches, using either one as
appropriate on a case-by-case basis.

But this compromise still feels unsatisfactory.

Must we default to having these two very different architectural models in our
applications?

Recall that the crux of the trade-off between SPAs and MPAs is the
_user experience_, or interactivity of the application. This typically drives
the decision to choose one approach versus the other for an application or ---
in the case of a "transitional" application --- for a particular feature.

It turns out that by adopting a hypermedia-oriented library, the interactivity
gap between the MPA and the SPA approach closes dramatically. You can use the
MPA approach, that is, the hypermedia approach, for much more of your
application without compromising your user interface. You might even be able to
use the hypermedia approach for _all_ your application needs.

Rather than having an SPA with a bit of hypermedia around the edges, or some mix
of the two approaches, you can often create a web application that is _primarily_ or _entirely_ hypermedia-driven,
and that still satisfies the interactivity that your users require.

This can _tremendously_ simplify your web application and produce a much more
coherent and understandable piece of software. While there are still times and
places for the more complex SPA approach, which we will discuss later in the
book, by adopting a hypermedia-first approach and using a hypermedia-oriented
library to push HTML as far as possible, your web application can be powerful,
interactive _and_ simple.

One such hypermedia oriented library is #link("https://htmx.org")[htmx]. Htmx
will be the focus of Part Two of this book. We show that you can, in fact,
create many common "modern" UI features found in sophisticated Single Page
Applications by instead using the hypermedia model.

And, it is refreshingly fun and simple to do so.

==== Hypermedia-Driven Applications <_hypermedia_driven_applications>
When building a web application with htmx the term Multi-Page Application
applies _roughly_, but it doesn’t fully characterize the core of the application
architecture. As you will see, htmx doesn’t
_need_ to replace entire pages, and, in fact, an htmx-based application can
reside entirely within a single page. We don’t recommend this practice, but it
is possible!

So it isn’t quite right to call web applications built with htmx
"Multi-Page Applications." What the older Web 1.0 MPA approach and the newer
hypermedia-oriented library powered applications have in common is their use of _hypermedia_ as
their core technology and architecture.

Therefore, we use the term _Hypermedia-Driven Applications (HDAs)_
to describe both.

This clarifies that the core distinction between these two approaches and the
SPA approach _isn’t_ the number of pages in the application, but rather the
underlying _system_ architecture.

/ Hypermedia-Driven Application (HDA): #[
    A web application that uses _hypermedia_ and _hypermedia exchanges_ as its
    primary mechanism for communicating with a server.
  ]

So, what does an HDA look like up close?

Let’s look at an htmx-powered implementation of the simple JavaScript-powered
button above:

#figure(caption: [An htmx implementation],
```html
<button hx-get="/contacts/1" hx-target="#contact-ui"> <1>
    Fetch Contact
</button>
```)

1. issues a `GET` request to `/contacts/1`, replacing the `contact-ui`.

As with the JavaScript powered button, this button has been annotated with some
attributes. However, in this case we do not have any (explicit) JavaScript
scripting.

Instead, we have _declarative_ attributes much like the `href`
attribute on anchor tags and the `action` attribute on form tags. The
`hx-get` attribute tells htmx: "When the user clicks this button, issue a `GET` request
to `/contacts/1`." The `hx-target` attribute tells htmx:
"When the response returns, take the resulting HTML and place it into the
element with the id `contact-ui`."

Here we get to the crux of htmx and how it allows you to build Hypermedia-Driven
Applications:

_The HTTP response from the server is expected to be in HTML format, not JSON_.

An HTTP response to this htmx-driven request might look something like this:

#figure(caption: [HTML],
```html
<details>
  <div>
    Contact: HTML Example
  </div>
  <div>
    <a href="mailto:html-example@example.com">Email</a>
  </div>
</details>
```)

This small bit of HTML would be placed into the element in the DOM with the id `contact-ui`.

Thus, this htmx-powered button is exchanging _hypermedia_ with the server, just
like an anchor tag or form might, and thus the interaction is still using the
basic hypermedia model of the web. Htmx _is_
adding functionality to this button (via JavaScript), but that functionality is _augmenting_ HTML
as a hypermedia. Htmx extends the hypermedia system of the web, rather than _replacing_ that
hypermedia system with a totally different architecture.

Despite looking superficially similar to one another it turns out that this
htmx-powered button and the JavaScript-based button are using extremely
different system architectures and, thus, approaches to web development.

As we walk through building a Hypermedia-Driven Application in this book, the
differences between the two approaches will become more and more apparent.

=== When Should You Use Hypermedia? <_when_should_you_use_hypermedia>

#index[hypermedia][when to use]
Hypermedia is often, though _not always_, a great choice for a web application.

Perhaps you are building a website or application that simply doesn’t
_need_ a huge amount of user-interactivity. There are many useful web
applications like this, and there is no shame in it! Applications like Amazon,
eBay, any number of news sites, shopping sites, message boards and so on don’t
need a massive amount of interactivity to be effective: they are mainly text and
images, which is exactly what the web was designed for.

Perhaps your application adds most of its value on the _server side_, by
coordinating users or by applying sophisticated data analysis and then
presenting it to a user. Perhaps your application adds value by simply sitting
in front of a well-designed database, with simple Create-Read-Update-Delete
(CRUD) operations. Again, there is no shame in this!

In any of these cases, using a hypermedia approach would likely be a great
choice: the interactivity needs of these applications are not dramatic, and much
of the value of these applications lives on the server side, rather than on the
client side.

All of these applications are amenable to what Roy Fielding called
"large-grain hypermedia data transfers": you can simply use anchor tags and
forms, with responses that return entire HTML documents from requests, and
things will work just fine. This is exactly what the web was designed to do!

By adopting the hypermedia approach for these applications, you will save
yourself a huge amount of client-side complexity that comes with adopting the
Single Page Application approach: there is no need for client-side routing, for
managing a client-side model, for hand-wiring in JavaScript logic, and so forth.
The back button will "just work." Deep linking will "just work." You will be
able to focus your efforts on your server, where your application is actually
adding value.

And, by layering htmx or another hypermedia-oriented library on top of this
approach, you can address many of the usability issues that come with vanilla
HTML and take advantage of finer-grained hypermedia transfers. This opens up a
whole slew of new user interface and experience possibilities, making the set of
applications that can be built using hypermedia _much_ larger.

But more on that later.

=== When Shouldn’t You Use Hypermedia? <_when_shouldnt_you_use_hypermedia>

#index[hypermedia][limitations]
So, what about that _not always_? When isn’t hypermedia going to work well for
an application?

One example that springs immediately to mind is an online spreadsheet
application. In the case of a spreadsheet, updating one cell could have a large
number of cascading changes that need to be made across the entire sheet. Worse,
this might need to happen _on every keystroke_.

In this case we have a highly dynamic user interface without clear boundaries as
to what might need to be updated given a particular change. Introducing a
hypermedia-style server round-trip on every cell change would hurt performance
tremendously.

This is simply not a situation amenable to the "large-grain hypermedia data
transfer" approach of the web. For an application like this we would certainly
recommend looking into using a sophisticated client-side JavaScript approach.

_However_ even in the case of an online spreadsheet there are likely areas where
the hypermedia approach might help.

The spreadsheet application likely also has a settings page. And perhaps that
settings page _is_ amenable to the hypermedia approach. If it is simply a set of
relatively straight-forward forms that need to be persisted to the server, the
chances are good that hypermedia would, in fact, work great for this part of the
app.

And, by adopting hypermedia for that part of your application, you might be able
to simplify that part of the application quite a bit. You could then save more
of your application’s _complexity budget_ for the core, complicated spreadsheet
logic, keeping the simple stuff simple.

Why waste all the complexity associated with a heavy JavaScript framework on
something as simple as a settings page?

#sidebar[A Complexity Budget][
  Any software project has a complexity budget, explicit or not: there is only so
  much complexity a given development team can tolerate and every new feature and
  implementation choice adds at least a bit more to the overall complexity of the
  system.

  #index[complexity budget]
  What is particularly nasty about complexity is that it tends to grow
  exponentially: one day you can keep the entire system in your head and
  understand the ramifications of a particular change, and a week later the whole
  system seems intractable. Even worse, efforts to help control complexity, such
  as introducing abstractions or infrastructure to manage the complexity, often
  end up making things even more complex. Truly, the job of the good software
  engineer is to keep complexity under control.

  The sure-fire way to keep complexity down is also the hardest: say no. Pushing
  back on feature requests is an art and, if you can learn to do it well, making
  people feel like _they_ said no, you will go far.

  Sadly this is not always possible: some features will need to be built. At this
  point the question becomes: "what is the simplest thing that could possibly
  work?" Understanding the possibilities available in the hypermedia approach will
  give you another tool in your "simplest thing" tool chest.
]

=== Hypermedia: A Sophisticated, Modern System Architecture <_hypermedia_a_sophisticated_modern_system_architecture>
Hypermedia is often regarded as an old and antiquated technology in web
development circles, useful perhaps for static websites but certainly not a
realistic choice for modern, sophisticated web applications.

Seriously? Are we claiming that modern web applications can be built using it?

Yes, seriously.

Contrary to current popular opinion, hypermedia is an _innovative_
and _modern_ system architecture for building applications, in some ways _more modern_ than
the prevailing Single Page Application approaches. In the remainder of this book
we will reintroduce you to the core, practical concepts of hypermedia and then
demonstrate exactly how you can take advantage of this system architecture in
your own software.

In the coming chapters you will develop a firm understanding of all the benefits
and techniques enabled by this approach. We hope that, in addition, you will
also become as passionate about it as we are. <_html_notes_div_soup>

#html-note[\<div\> Soup][

The best-known kind of messy HTML is `<div>` soup.

When developers fall back on the generic `<div>` and `<span>` elements instead
of more meaningful tags, we either degrade the quality of our websites or create
more work for ourselves --- probably both.

For example, instead of adding a button using the dedicated `<button>`
element, a `<div>` element might have a `click` event listener added to it.

#figure(
```html
<div class="bg-accent padding-4 rounded-2" onclick="doStuff()">
  Do stuff
</div>
```)

There are two main issues with this button:

- It’s not focusable --- the Tab key won’t get you to it.

- There’s no way for assistive tools to tell that it’s a button.

Yes, we can fix that by adding `role="button"` and
`tabindex="0"`:

#figure(
```html
<div class="bg-accent padding-4 rounded-2"
  role="button"
  tabindex="0"
  onclick="doStuff()">Do stuff</div>
```)

These are easy fixes, but they’re things you have to _remember_. It’s also not
obvious from the HTML source that this is a button, making the source harder to
read and the absence of these attributes harder to spot. The source code of
pages with div soup is difficult to edit and debug.

To avoid div soup, become friendly with the HTML spec of available tags, and
consider each tag another tool in your tool chest. There might be things there
you don’t remember from before! (With the 113 elements currently defined in the
spec, it’s more of a tool _shed_).

Of course, not every UI pattern has a designated HTML element. We often need to
compose elements and augment them with attributes. Before you do, though,
rummage through the HTML tool chest. Sometimes you might be surprised by how
much is available. ]
