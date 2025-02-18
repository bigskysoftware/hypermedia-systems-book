#import "lib/definitions.typ": *

== More Htmx Patterns

=== Active Search <_active_search>
So far so good with Contact.app: we have a nice little web application with some
significant improvements over a plain HTML-based application. We’ve added a
proper "Delete Contact" button, done some dynamic validation of input and looked
at different approaches to add paging to the application. As we have said, many
web developers would expect that a lot of JavaScript-based scripting would be
required to get these features, but we’ve done it all in relatively pure HTML,
using only htmx attributes.

We _will_ eventually add some client-side scripting to our application:
hypermedia is powerful, but it isn’t _all powerful_
and sometimes scripting might be the best (or only) way to achieve a given goal.
For now, however, let’s see what we can accomplish with hypermedia.

The first advanced htmx feature we will create is known as the "Active Search"
pattern. Active Search is when, as a user types text into a search box, the
results of that search are dynamically shown. This pattern was made popular when
Google adopted it for search results, and many applications now implement it.

To implement Active Search, we are going to use techniques closely related to
the way we did email validation in the previous chapter. If you think about it,
the two features are similar in many ways: in both cases we want to issue a
request as the user types into an input and then update some other element with
a response. The server-side implementations will, of course, be very different,
but the frontend code will look fairly similar due to htmx’s general approach of "issue
a request on an event and replace something on the screen."

==== Our Current Search UI <_our_current_search_ui>
Let’s recall what the search field in our application currently looks like:

#figure(caption: [Our search form],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">Search Term</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}"> <1>
  <input type="submit" value="Search"/>
</form>
```)
1. The `q` or "query" parameter our client-side code uses to search.

Recall that we have some server-side code that looks for the `q`
parameter and, if it is present, searches the contacts for that term.

As it stands right now, the user must hit enter when the search input is
focused, or click the "Search" button. Both of these events will trigger a `submit` event
on the form, causing it to issue an HTTP `GET` and re-rendering the whole page.

Currently, thanks to `hx-boost`, the form will use an AJAX request for this `GET`,
but we don’t yet get that nice search-as-you-type behavior we want.

==== Adding Active Search <_adding_active_search>

#index[htmx patterns][active search]
To add active search behavior, we will attach a few htmx attributes to the
search input. We will leave the current form as it is, with an
`action` and `method`, so that the normal search behavior works even if a user
does not have JavaScript enabled. This will make our "Active Search" improvement
a nice "progressive enhancement."

So, in addition to the regular form behavior, we _also_ want to issue an HTTP `GET` request
when a key up occurs. We want to issue this request to the same URL as the
normal form submission. Finally, we only want to do this after a small pause in
typing has occurred.

As we said, this functionality is very similar to what we needed for email
validation. In fact, we can copy the `hx-trigger` attribute directly from our
email validation example, with its small 200-millisecond delay, to wait for a user
to stop typing before a request is triggered.

This is another example of how common patterns come up again and again when
using htmx.

#figure(caption: [Adding active search behavior],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">Search Term</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}" <1>
    hx-get="/contacts" <2>
    hx-trigger="search, keyup delay:200ms changed"/> <3>
  <input type="submit" value="Search"/>
</form>
```)
1. Keep the original attributes, so search will work if JavaScript is not
  available.
2. Issue a `GET` to the same URL as the form.
3. Nearly the same `hx-trigger` specification as for the email input validation.

We made a small change to the `hx-trigger` attribute: we switched out the `change` event
for the `search` event. The `search` event is triggered when someone clears the
search or hits the enter key. It is a non-standard event, but it doesn’t hurt to
include here. The main functionality of the feature is provided by the second
triggering event, the `keyup`. As in the email example, this trigger is delayed
with the
`delay:200ms` modifier to "debounce" the input requests and avoid hammering our
server with requests on every keyup.

==== Targeting The Correct Element <_targeting_the_correct_element>
What we have is close to what we want, but we need to set up the correct target.
Recall that the default target for an element is itself. As things currently
stand, an HTTP `GET` request will be issued to the
`/contacts` path, which will, as of now, return an entire HTML document of
search results, and then this whole document will be inserted into the _inner_ HTML
of the search input.

This is, in fact, nonsense: `input` elements aren’t allowed to have any HTML
inside of them. The browser will, sensibly, just ignore the htmx request to put
the response HTML inside the input. So, at this point, when a user types
anything into our input, a request will be issued (you can see it in your
browser development console if you try it out) but, unfortunately, it will
appear to the user as if nothing has happened at all.

To fix this issue, what do we want to target with the update instead? Ideally
we’d like to just target the actual results: there is no reason to update the
header or search input, and that could cause an annoying flash as focus jumps
around.

The `hx-target` attribute allows us to do exactly that. Let’s use it to target
the results body, the `tbody` element in the table of contacts:

#figure(caption: [Adding active search behavior],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">Search Term</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}"
    hx-get="/contacts"
    hx-trigger="search, keyup delay:200ms changed"
    hx-target="tbody"/> <1>
  <input type="submit" value="Search"/>
</form>
<table>
  ...
  <tbody>
    ...
  </tbody>
</table>
```)
1. Target the `tbody` tag on the page.

Because there is only one `tbody` on the page, we can use the general CSS
selector `tbody` and htmx will target the body of the table on the page.

Now if you try typing something into the search box, we’ll see some results: a
request is made and the results are inserted into the document within the `tbody`.
Unfortunately, the content that is coming back is still an entire HTML document.

Here we end up with a "double render" situation, where an entire document has
been inserted _inside_ another element, with all the navigation, headers and
footers and so forth re-rendered within that element. This is an example of one
of those mis-targeting issues we mentioned earlier.

Thankfully, it is pretty easy to fix.

==== Paring Down Our Content <_paring_down_our_content>
Now, we could use the same trick we reached for in the "Click To Load" and "Infinite
Scroll" features: the `hx-select` attribute. Recall that the `hx-select` attribute
allows us to pick out the part of the response we are interested in using a CSS
selector.

So we could add this to our input:

#figure(caption: [Using "hx-select" for active search],
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="change, keyup delay:200ms changed"
  hx-target="tbody"
  hx-select="tbody tr"/> <1>
```)
1. Adding an `hx-select` that picks out the table rows in the `tbody` of the
  response.

However, that isn’t the only fix for this problem, and, in this case, it isn’t
the most efficient one. Instead, let’s change the
_server-side_ of our Hypermedia-Driven Application to serve
_only the HTML content needed_.

==== HTTP Request Headers In Htmx <_http_request_headers_in_htmx>
In this section, we’ll look at another, more advanced technique for dealing with
a situation where we only want a _partial bit_ of HTML, rather than a full
document. Currently, we are letting the server create the full HTML document as
response and then, on the client side, we filter the HTML down to the bits that
we want. This is easy to do, and, in fact, might be necessary if we don’t
control the server side or can’t easily modify responses.

In our application, however, since we are doing "Full Stack" development (that
is: we control both frontend _and_ backend code, and can easily modify either)
we have another option: we can modify our server responses to return only the
content necessary, and remove the need to do client-side filtering.

This turns out to be more efficient, since we aren’t returning all the content
surrounding the bit we are interested in, saving bandwidth as well as CPU and
memory on the server side. So let’s explore returning different HTML content
based on the context information that htmx provides with the HTTP requests it
makes.

Here’s a look again at the current server-side code for our search logic:

#figure(caption: [Server-side search],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    if search is not None:
        contacts_set = Contact.search(search) <1>
    else:
        contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set) <2>
```)
1. This is where the search logic happens.
2. We simply re-render the `index.html` template every time, no matter what.

How do we want to change this? We want to render two different bits of HTML
content _conditionally_:
- If this is a "normal" request for the entire page, we want to render the `index.html` template
  in the current manner. In fact, we don’t want anything to change if this is a "normal"
  request.
- However, if this is an "Active Search" request, we only want to render the
  content that is within the `tbody`, that is, just the table rows of the page.

So we need some way to determine exactly which of these two different types of
requests to the `/contact` URL is being made, in order to know exactly which
content we want to render.

It turns out that htmx helps us distinguish between these two cases by including
a number of HTTP _Request Headers_ when it makes requests. Request Headers are a
feature of HTTP, allowing clients (e.g., web browsers) to include name/value
pairs of metadata associated with requests to help the server understand what
the client is requesting.

Here is an example of (some of) the headers the FireFox browser issues when
requesting `https://hypermedia.systems`:

#figure(caption: [HTTP headers],
```http
GET / HTTP/2
Host: hypermedia.systems
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:103.0) Gecko/20100101 Firefox/103.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.5
Cache-Control: no-cache
Connection: keep-alive
DNT: 1
Pragma: no-cache
```)

Htmx takes advantage of this feature of HTTP and adds additional headers and,
therefore, additional _context_ to the HTTP requests that it makes. This allows
you to inspect those headers and choose what logic to execute on the server, and
what sort of HTML response you want to send to the client.

Here is a table of the HTTP headers that htmx includes in HTTP requests:

/ `HX-Boosted`: #[
    This will be the string "true" if the request is made via an element using
    hx-boost
  ]

/ `HX-Current-URL`: #[
    This will be the current URL of the browser
  ]

/ `HX-History-Restore-Request`: #[
    This will be the string "true" if the request is for history restoration after a
    miss in the local history cache
  ]

/ `HX-Prompt`: #[
    This will contain the user response to an hx-prompt
  ]

/ `HX-Request`: #[
    This value is always "true" for htmx-based requests
  ]

/ `HX-Target`: #[
    This value will be the id of the target element if it exists
  ]

/ `HX-Trigger-Name`: #[
    This value will be the name of the triggered element if it exists
  ]

/ `HX-Trigger`: #[
    This value will be the id of the triggered element if it exists
  ]

Looking through this list of headers, the last one stands out: we have an id, `search` on
our search input. So the value of the `HX-Trigger`
header should be set to `search` when the request is coming from the search
input, which has the id `search`.

Let’s add some conditional logic to our controller to look for that header and,
if the value is `search`, we render only the rows rather than the whole `index.html` template:

#figure(caption: [Updating our server-side search],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search': <1>
          # TODO: render only the rows here <2>
    else:
        contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set)
```)
1. If the request header `HX-Trigger` is equal to "search" we want to do something
  different.
2. We need to learn how to render just the table rows.

OK, so how do we render only the result rows?

==== Factoring Your Templates <_factoring_your_templates>
Now we come to a common pattern in htmx: we want to _factor_ our server-side
templates. This means that we want to break our templates up a bit so that they
can be called from multiple contexts. In this case, we want to break the rows of
the results table out to a separate template we will call `rows.html`. We will
include it from the original
`index.html` template, and also use it in our controller to render it by itself
when we want to respond with only the rows for Active Search requests.

Here’s what the table in our `index.html` file currently looks like:

#figure(caption: [The contacts table],
```html
<table>
  <thead>
  <tr>
    <th>First <th>Last <th>Phone <th>Email <th/>
  </tr>
  </thead>
  <tbody>
  {% for contact in contacts %}
    <tr>
      <td>{{ contact.first }}</td>
      <td>{{ contact.last }}</td>
      <td>{{ contact.phone }}</td>
      <td>{{ contact.email }}</td>
      <td><a href="/contacts/{{ contact.id }}/edit">Edit</a>
        <a href="/contacts/{{ contact.id }}">View</a></td>
    </tr>
  {% endfor %}
  </tbody>
</table>
```)

The `for` loop in this template is what produces all the rows in the final
content generated by `index.html`. What we want to do is to move the `for` loop
and, therefore, the rows it creates out to a
_separate template file_ so that only that small bit of HTML can be rendered
independently from `index.html`.

Again, let’s call this new template `rows.html`:

#figure(caption: [Our new `rows.html` file],
```html
{% for contact in contacts %}
  <tr>
    <td>{{ contact.first }}</td>
    <td>{{ contact.last }}</td>
    <td>{{ contact.phone }}</td>
    <td>{{ contact.email }}</td>
    <td><a href="/contacts/{{ contact.id }}/edit">Edit</a>
      <a href="/contacts/{{ contact.id }}">View</a></td>
  </tr>
{% endfor %}
```)

Using this template we can render only the `tr` elements for a given collection
of contacts.

Of course, we still want to include this content in the `index.html`
template: we are _sometimes_ going to be rendering the entire page, and
sometimes only rendering the rows. In order to keep the `index.html`
template rendering properly, we can include the `rows.html` template by using
the jinja `include` directive at the position we want the content from `rows.html` inserted:

#figure(caption: [Including the new file],
```html
<table>
  <thead>
  <tr>
    <th>First</th>
    <th>Last</th>
    <th>Phone</th>
    <th>Email</th>
    <th></th>
  </tr>
  </thead>
  <tbody>
  {% include 'rows.html' %} <1>
  </tbody>
</table>
```)
1. This directive "includes" the `rows.html` file, inserting its content into the
  current template.

So far, so good: our `/contacts` page is still rendering properly, just as it
did before we split the rows out of the `index.html` template.

==== Using Our New Template <_using_our_new_template>
The last step in factoring our templates is to modify our web controller to take
advantage of the new `rows.html` template file when it responds to an active
search request.

Since `rows.html` is just another template, just like `index.html`, all we need
to do is call the `render_template` function with `rows.html`
rather than `index.html`. This will render _only_ the row content rather than
the entire page:

#figure(caption: [Updating our server-side search],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search':
          return render_template("rows.html", contacts=contacts_set) <1>
    else:
        contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set)
```)
1. Render the new template in the case of an active search.

Now, when an Active Search request is made, rather than getting an entire HTML
document back, we only get a partial bit of HTML, the table rows for the
contacts that match the search. These rows are then inserted into the `tbody` on
the index page, without any need for
`hx-select` or other client-side processing.

And, as a bonus, the old form-based search _still works_. We conditionally
render the rows only when the `search` input issues the HTTP request via htmx.
Again, this is a progressive enhancement to our application.

#sidebar[HTTP Headers & Caching][One subtle aspect of the approach we are taking here, using headers to determine
the content of what we return, is a feature baked into HTTP: caching. In our
request handler, we are now returning different content depending on the value
of the `HX-Trigger` header. If we were to use HTTP Caching, we might get into a
situation where someone makes a
_non-htmx_ request (e.g., refreshing a page) and yet the
_htmx_ content is returned from the HTTP cache, resulting in a partial page of
content for the user.

The solution to this problem is to use the HTTP Response `Vary` header and call
out the htmx headers that you are using to determine what content you are
returning. A full explanation of HTTP Caching is beyond the scope of this book,
but the
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching",
)[MDN article on the topic]
is quite good, and the
#link("https://htmx.org/docs/#caching")[htmx documentation] discusses this issue
as well.]

==== Updating the Navigation Bar With "hx-push-url" <_updating_the_navigation_bar_with_hx_push_url>
One shortcoming of our current Active Search implementation, when compared with
the normal form submission, is that when you submit the form version it updates
the navigation bar of the browser to include the search term. So, for example,
if you search for "joe" in the search box, you will end up with a url that looks
like this in your browser’s nav bar:

#figure(caption: [The updated location after a form search],
```
https://example.com/contacts?q=joe
```)

This is a nice feature of browsers: it allows you to bookmark this search or to
copy the URL and send it to someone else. All they have to do is to click on the
link, and they will repeat the exact same search. This is also tied in with the
browser’s notion of history: if you click the back button it will take you to
the previous URL that you came from. If you submit two searches and want to go
back to the first one, you can simply hit back and the browser will "return" to
that search.

#index[htmx patterns][back button support]
As it stands right now, during our Active Search, we are not updating the
browser’s navigation bar. So, users aren’t getting links that can be copied and
pasted, and you aren’t getting history entries either, which means no back
button support. Fortunately, we’ve already seen how to fix this: with the `hx-push-url` attribute.

The `hx-push-url` attribute lets you tell htmx "Please push the URL of this
request into the browser’s navigation bar." Push might seem like an odd verb to
use here, but that’s the term that the underlying browser history API uses,
which stems from the fact that it models browser history as a "stack" of
locations: when you go to a new location, that location is "pushed" onto the
stack of history elements, and when you click "back", that location is "popped"
off the history stack.

So, to get proper history support for our Active Search, all we need to do is to
set the `hx-push-url` attribute to `true`.

#figure(caption: [Updating the URL during active search],
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="change, keyup delay:200ms changed"
  hx-target="tbody"
  hx-push-url="true"/> <1>
```)
1. By adding the `hx-push-url` attribute with the value `true`, htmx will update
  the URL when it makes a request.

Now, as Active Search requests are sent, the URL in the browser’s navigation bar
is updated to have the proper query in it, just like when the form is submitted.

You might not _want_ this behavior. You might feel it would be confusing to
users to see the navigation bar updated and have history entries for every
Active Search made, for example. Which is fine: you can simply omit the `hx-push-url` attribute
and it will go back to the behavior you want. The goal with htmx is to be
flexible enough to achieve the UX that _you_ want, while staying within the
declarative HTML model.

==== Adding A Request Indicator <_adding_a_request_indicator>
A final touch for our Active Search pattern is to add a request indicator to let
the user know that a search is in progress. As it stands the user has no
explicit signal that the active search functionality is handling a request. If
the search takes a bit, a user may end up thinking that the feature isn’t
working. By adding a request indicator we let the user know that the hypermedia
application is busy and they should wait (hopefully not too long!) for the
request to complete.

Htmx provides support for request indicators via the `hx-indicator`
attribute. This attribute takes, you guessed it, a CSS selector that points to
the indicator for a given element. The indicator can be anything, but it is
typically some sort of animated image, such as a gif or svg file, that spins or
otherwise communicates visually that
"something is happening."

#index[htmx patterns][request indicator]
#index[hx-indicator]
Let’s add a spinner after our search input:

#figure(caption: [Adding a request indicator to search],
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="change, keyup delay:200ms changed"
  hx-target="tbody"
  hx-push-url="true"
  hx-indicator="#spinner"/> <1>
<img id="spinner" class="htmx-indicator"
  src="/static/img/spinning-circles.svg"
  alt="Request In Flight..."/> <2>
```)
1. The `hx-indicator` attribute points to the indicator image after the input.
2. The indicator is a spinning circle svg file, and has the
  `htmx-indicator` class on it.

We have added the spinner right after the input. This visually co-locates the
request indicator with the element making the request, and makes it easy for a
user to see that something is in fact happening.

It just works, but how does htmx make the spinner appear and disappear? Note
that the indicator `img` tag has the `htmx-indicator` class on it.
`htmx-indicator` is a CSS class that is automatically injected into the page by
htmx. This class sets the default `opacity` of an element to
`0`, which hides the element from view, while at the same time not disrupting
the layout of the page.

When an htmx request is triggered that points to this indicator, another class, `htmx-request` is
added to the indicator which transitions its opacity to 1. So you can use just
about anything as an indicator, and it will be hidden by default. Then, when a
request is in flight, it will be shown. This is all done via standard CSS
classes, allowing you to control the transitions and even the mechanism by which
the indicator is shown (e.g., you might use `display` rather than `opacity`).

#sidebar[Use Request Indicators!][Request indicators are an important UX aspect of any distributed application. It
  is unfortunate that browsers have de-emphasized their native request indicators
  over time, and it is doubly unfortunate that request indicators are not part of
  the JavaScript ajax APIs.

  Be sure not to neglect this significant aspect of your application. Requests
  might seem instant when you are working on your application locally, but in the
  real world they can take quite a bit longer due to network latency. It’s often a
  good idea to take advantage of browser developer tools that allow you to
  throttle your local browser’s response times. This will give you a better idea
  of what real world users are seeing, and show you where indicators might help
  users understand exactly what is going on.]

With this request indicator, we now have a pretty sophisticated user experience
when compared with plain HTML, but we’ve built it all as a hypermedia-driven
feature. No JSON or JavaScript to be seen. And our implementation has the
benefit of being a progressive enhancement; the application will continue to
work for clients that don’t have JavaScript enabled.

=== Lazy Loading <_lazy_loading>

#index[htmx patterns][lazy loading]
With Active Search behind us, let’s move on to a very different sort of
enhancement: lazy loading. Lazy loading is when the loading of a particular bit
of content is deferred until later, when needed. This is commonly used as a
performance enhancement: you avoid the processing resources necessary to produce
some data until that data is actually needed.

Let’s add a count of the total number of contacts to Contact.app, just below the
bottom of our contacts table. This will give us a potentially expensive
operation that we can use to demonstrate how to add lazy loading with htmx.

First let’s update our server code in the `/contacts` request handler to get a
count of the total number of contacts. We will pass that count through to the
template to render some new HTML.

#figure(caption: [Adding a count to the UI],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    page = int(request.args.get("page", 1))
    count = Contact.count() <1>
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search':
            return render_template("rows.html",
              contacts=contacts_set, page=page, count=count) <2>
    else:
        contacts_set = Contact.all(page)
    return render_template("index.html",
      contacts=contacts_set, page=page, count=count)
```)
1. Get the total count of contacts from the Contact model.
2. Pass the count out to the `index.html` template to use when rendering.

As with the rest of the application, in the interest of staying focused on the _hypermedia_ part
of Contact.app, we’ll skip over the details of how `Contact.count()` works. We
just need to know that:
- It returns the total count of contacts in the contact database.
- It may be slow (for the sake of our example).

Next lets add some HTML to our `index.html` that takes advantage of this new bit
of data, showing a message next to the "Add Contact" link with the total count
of users. Here is what our HTML looks like:

#figure(caption: [Adding a contact count element to the application],
```html
<p>
  <a href="/contacts/new">Add Contact</a
  > <span>({{ count }} total Contacts)</span> <1>
</p>
```)
1. A simple span with some text showing the total number of contacts.

Well that was easy, wasn’t it? Now our users will see the total number of
contacts next to the link to add new contacts, to give them a sense of how large
the contact database is. This sort of rapid development is one of the joys of
developing web applications the old way.

@fig-totalcontacts is what the feature looks like in our application. Beautiful.

#figure(image("images/screenshot_total_contacts.png"),
  caption: [Total contact count display])<fig-totalcontacts>

Of course, as you probably suspected, all is not perfect. Unfortunately, upon
shipping this feature to production, we start getting complaints from users that
the application "feels slow." Like all good developers faced with a performance
issue, rather than guessing what the issue might be, we try to get a performance
profile of the application to see what exactly is causing the problem.

It turns out, surprisingly, that the problem is that innocent looking
`Contacts.count()` call, which is taking up to a second and a half to complete.
Unfortunately, for reasons beyond the scope of this book, it is not possible to
improve that load time, nor is possible to cache the result.

This leaves us with two options:
- Remove the feature.
- Come up with some other way to mitigate the performance issue.

Let’s assume that we can’t remove the feature, and therefore look at how we can
mitigate this performance issue by using htmx instead.

==== Pulling Out The Expensive Code <_pulling_out_the_expensive_code>
The first step in implementing the Lazy Load pattern is to pull the expensive
code --- that is, the call to `Contacts.count()` --- out of the request handler
for the `/contacts` endpoint.

Let’s put this function call into its own HTTP request handler as a new HTTP
endpoint that we will put at `/contacts/count`. For this new endpoint, we won’t
need to render a template at all: its sole job is going to be to render that
small bit of text that is in the span, "(22 total Contacts)."

Here is what the new code will look like:

#figure(caption: [Pulling the expensive code out],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    page = int(request.args.get("page", 1)) <1>
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search':
            return render_template("rows.html",
              contacts=contacts_set, page=page)
    else:
        contacts_set = Contact.all(page)
    return render_template("index.html",
      contacts=contacts_set, page=page) <2>

@app.route("/contacts/count")
def contacts_count():
    count = Contact.count() <3>
    return "(" + str(count) + " total Contacts)" <4>
```)
1. We no longer call `Contacts.count()` in this handler.
2. `Count` is no longer passed out to the template to render in the
  `/contacts` handler.
3. We create a new handler at the `/contacts/count` path that does the expensive
  calculation.
4. Return the string with the total number of contacts.

So now we have moved the performance issue out of the `/contacts`
handler code, which renders the main contacts table, and created a new HTTP
endpoint that will produce this expensive-to-create count string for us.

Now we need to get the content from this new handler _into_ the span, somehow.
As we said earlier, the default behavior of htmx is to place any content it
receives for a given request into the `innerHTML`
of an element, and that turns out to be exactly what we want here: we want to
retrieve this text and put it into the `span`. So we can simply place an `hx-get` attribute
on the span, pointing to this new path, and do exactly that.

However, recall that the default _event_ that will trigger a request for a `span` element
in htmx is the `click` event. Well, that’s not what we want! Instead, we want
this request to trigger immediately, when the page loads.

To do this, we can add the `hx-trigger` attribute to update the trigger of the
requests for the element, and use the `load` event.

The `load` event is a special event that htmx triggers on all content when it is
loaded into the DOM. By setting `hx-trigger` to `load`, we will cause htmx to
issue the `GET` request when the `span` element is loaded into the page.

Here is our updated template code:

#figure(caption: [Adding a contact count element to the application],
```html
<p>
  <a href="/contacts/new">Add Contact</a
  > <span hx-get="/contacts/count" hx-trigger="load"></span> <1>
</p>
```)
1. Issue a `GET` to `/contacts/count` when the `load` event occurs.

Note that the `span` starts empty: we have removed the content from it, and we
are allowing the request to `/contacts/count` to populate it instead.

And, check it out, our `/contacts` page is fast again! When you navigate to the
page it feels very snappy and profiling shows that yes, indeed, the page is
loading much more quickly. Why is that? Well, we’ve deferred the expensive
calculation to a secondary request, allowing the initial request to finish
loading faster.

You might say "OK, great, but it’s still taking a second or two to get the total
count on the page." True, but often the user may not be particularly interested
in the total count. They may just want to come to the page and search for an
existing user, or perhaps they may want to edit or add a user. The total count
of contacts is just a "nice to have" bit of information in these cases.

By deferring the calculation of the count in this manner we let users get on
with their use of the application while we perform the expensive calculation.

Yes, the total time to get all the information on the screen takes just as long.
It actually will be a bit longer, since we now need two HTTP requests to get all
the information for the page. But the
_perceived performance_ for the end user will be much better: they can do what
they want nearly immediately, even if some information isn’t available
instantaneously.

Lazy Loading is a great tool to have in your belt when optimizing web
application performance.

==== Adding An Indicator <_adding_an_indicator>

#index[htmx patterns][request indicator]
A shortcoming of the current implementation is that currently there is no
indication that the count request is in flight, it just appears at some point
when the request finishes.

This isn’t ideal. What we want here is an indicator, just like we added in our
Active Search example. And, in fact, we can simply reuse that same exact spinner
image, copy-and-pasted into the new HTML we have created.

Now, in this case, we have a one-time request and, once the request is over, we
are not going to need the spinner anymore. So it doesn’t make sense to use the
exact same approach we did with the active search example. Recall that in that
case we placed a spinner _after_ the span and using the `hx-indicator` attribute
to point to it.

In this case, since the spinner is only used once, we can put it
_inside_ the content of the span. When the request completes the content in the
response will be placed inside the span, replacing the spinner with the computed
contact count. It turns out that htmx allows you to place indicators with the `htmx-indicator` class
on them inside of elements that issue htmx-powered requests. In the absence of
an
`hx-indicator` attribute, these internal indicators will be shown when a request
is in flight.

So let’s add that spinner from the active search example as the initial content
in our span:

#figure(caption: [Adding an indicator to our lazily loaded content],
```html
<span hx-get="/contacts/count" hx-trigger="load">
  <img id="spinner" class="htmx-indicator"
    src="/static/img/spinning-circles.svg"/> <1>
</span>
```)
1. Yep, that’s it.

Now when the user loads the page, rather than having the total contact count
magically appear, there is a nice spinner indicating that something is coming.
Much better.

Note that all we had to do was copy and paste our indicator from the active
search example into the `span`. Once again we see how htmx provides flexible,
composable features and building blocks. Implementing a new feature is often
just copy-and-paste, maybe a tweak or two, and you are done.

==== But That’s Not Lazy! <_but_thats_not_lazy>

#index[htmx patterns][lazy loading]
You might say "OK, but that’s not really lazy. We are still loading the count
immediately when the page is loaded, we are just doing it in a second request.
You aren’t really waiting until the value is actually needed."

Fine. Let’s make it _lazy_ lazy: we’ll only issue the request when the `span` scrolls
into view.

To do that, let’s recall how we set up the infinite scroll example: we used the `revealed` event
for our trigger. That’s all we want here, right? When the element is revealed we
issue the request?

Yep, that’s it. Once again, we can mix and match concepts across various UX
patterns to come up with solutions to new problems in htmx.

#figure(caption: [Making it truly lazy],
```html
<span hx-get="/contacts/count" hx-trigger="revealed"> <1>
  <img id="spinner" class="htmx-indicator"
    src="/static/img/spinning-circles.svg"/>
</span>
```)
1. Change the `hx-trigger` to `revealed`.

Now we have a truly lazy implementation, deferring the expensive computation
until we are absolutely sure we need it. A pretty cool trick, and, again, a
simple one-attribute change demonstrates the flexibility of both htmx and the
hypermedia approach.

=== Inline Delete <_inline_delete>

#index[htmx patterns][inline delete]
For our next hypermedia trick, we are going to implement the "Inline Delete"
pattern. With this feature, a contact can be deleted directly from the table of
all contacts, rather than requiring the user to navigate all the way to the edit
view of particular contact, in order to access the "Delete Contact" button we
added in the last chapter.

Recall that we already have "Edit" and "View" links for each row, in the
`rows.html` template:

#figure(caption: [The existing row actions],
```html
<td>
    <a href="/contacts/{{ contact.id }}/edit">Edit</a>
    <a href="/contacts/{{ contact.id }}">View</a>
</td>
```)

Now we want to add a "Delete" link as well. And, thinking on it, we want that
link to act an awful lot like the "Delete Contact" button from
`edit.html`, don’t we? We’d like to issue an HTTP `DELETE` to the URL for the
given contact and we want a confirmation dialog to ensure the user doesn’t
accidentally delete a contact.

Here is the "Delete Contact" button html:

#figure(caption: [The existing row actions],
```html
<button
  hx-delete="/contacts/{{ contact.id }}"
  hx-push-url="true"
  hx-confirm="Are you sure you want to delete this contact?"
  hx-target="body">
  Delete Contact
</button>
```)

As you may suspect by now, this is going to be another copy-and-paste job.

One thing to note is that, in the case of the "Delete Contact" button, we wanted
to re-render the whole screen and update the URL, since we are going to be
returning from the edit view for the contact to the list view of all contacts.
In the case of this link, however, we are already on the list of contacts, so
there is no need to update the URL, and we can omit the `hx-push-url` attribute.

#index[hx-delete][example]
Here is the code for our inline "Delete" link:

#figure(caption: [The existing row actions],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">Edit</a>
  <a href="/contacts/{{ contact.id }}">View</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-confirm="Are you sure you want to delete this contact?"
    hx-target="body">Delete</a> <1>
</td>
```)
1. Almost a straight copy of the "Delete Contact" button.

As you can see, we have added a new anchor tag and given it a blank target (the `#` value
in its `href` attribute) to retain the correct mouse-over styling behavior of
the link. We’ve also copied the
`hx-delete`, `hx-confirm` and `hx-target` attributes from the "Delete Contact"
button, but omitted the `hx-push-url` attributes since we don’t want to update
the URL of the browser.

We now have inline delete working, even with a confirmation dialog. A user can
click on the "Delete" link and the row will disappear from the UI as the entire
page is re-rendered.

#sidebar[A Style Sidebar][One side effect of adding this delete link is that we are starting to pile up
  the actions in a contact row:

  #figure(
    image("images/screenshot_stacked_actions.png"),
    caption: [That’s a lot of actions],
    placement: none,
  )<fig-stacked-actions>

  It would be nice if we didn’t show the actions all in a row, and, additionally,
  it would be nice if we only showed the actions when the user indicated interest
  in a given row. We will return to this problem after we look at the relationship
  between scripting and a Hypermedia-Driven Application in a later chapter.

  For now, let’s just tolerate this less-than-ideal user interface, knowing that
  we will fix it later.]

==== Narrowing Our Target <_narrowing_our_target>
We can get even fancier here, however. What if, rather than re-rendering the
whole page, we just removed the row for the contact? The user is looking at the
row anyway, so is there really a need to re-render the whole page?

To do this, we’ll need to do a couple of things:
- We’ll need to update this link to target the row that it is in.
- We’ll need to change the swap to `outerHTML`, since we want to replace (really,
  remove) the entire row.
- We’ll need to update the server side to render empty content when the
  `DELETE` is issued from a "Delete" link rather than from the "Delete Contact"
  button on the contact edit page.

First things first, update the target of our "Delete" link to be the row that
the link is in, rather than the entire body. We can once again take advantage of
the relative positional `closest` feature to target the closest `tr`, like we
did in our "Click To Load" and "Infinite Scroll" features:

#figure(caption: [The existing row actions],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">Edit</a>
  <a href="/contacts/{{ contact.id }}">View</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-swap="outerHTML"
    hx-confirm="Are you sure you want to delete this contact?"
    hx-target="closest tr">Delete</a> <1>
</td>
```)
1. Updated to target the closest enclosing `tr` (table row) of the link.

==== Updating The Server Side <_updating_the_server_side>
Now we need to update the server side. We want to keep the "Delete Contact"
button working as well, and in that case the current logic is correct. So we’ll
need some way to differentiate between `DELETE`
requests that are triggered by the button and `DELETE` requests that come from
this anchor.

The cleanest way to do this is to add an `id` attribute to the "Delete Contact"
button, so that we can inspect the `HX-Trigger` HTTP Request header to determine
if the delete button was the cause of the request. This is a simple change to
the existing HTML:

#figure(caption: [Adding an `id` to the "delete contact" button],
```html
<button id="delete-btn" <1>
  hx-delete="/contacts/{{ contact.id }}"
  hx-push-url="true"
  hx-confirm="Are you sure you want to delete this contact?"
  hx-target="body">
  Delete Contact
</button>
```)
1. An `id` attribute has been added to the button.

By giving this button an id attribute, we now have a mechanism for
differentiating between the delete button in the `edit.html` template and the
delete links in the `rows.html` template. When this button issues a request, it
will look something like this:

#figure[```http
DELETE http://example.org/contacts/42 HTTP/1.1
Accept: text/html,*/*
Host: example.org
...
HX-Trigger: delete-btn
...
```]

You can see that the request now includes the `id` of the button. This allows us
to write code very similar to what we did for the active search pattern, using a
conditional on the `HX-Trigger` header to determine what we want to do. If that
header has the value `delete-btn`, then we know the request came from the button
on the edit page, and we can do what we are currently doing: delete the contact
and redirect to
`/contacts` page.

If it _does not_ have that value, then we can simply delete the contact and
return an empty string. This empty string will replace the target, in this case
the row for the given contact, thereby removing the row from the UI.

Let’s refactor our server-side code to do this:

#figure(caption: [Updating our server code to handle two different delete) patterns],
```python
@app.route("/contacts/<contact_id>", methods=["DELETE"])
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete()
    if request.headers.get('HX-Trigger') == 'delete-btn': <1>
        flash("Deleted Contact!")
        return redirect("/contacts", 303)
    else:
        return "" <2>
```)
1. If the delete button on the edit page submitted this request, then continue to
  do the previous logic.
2. If not, simply return an empty string, which will delete the row.

And that’s our server-side implementation: when a user clicks "Delete" on a
contact row and confirms the delete, the row will disappear from the UI. Once
again, we have a situation where just changing a few lines of simple code gives
us a dramatically different behavior. Hypermedia is powerful in this manner.

==== The Htmx Swapping Model <_the_htmx_swapping_model>

#index[htmx][swap model]
This is pretty cool, but there is another improvement we can make if we take
some time to understand the htmx content swapping model: it would be nice if,
rather than just instantly deleting the row, we faded it out before we removed
it. The fade would make it clear that the row is being removed, giving the user
some nice visual feedback on the deletion.

It turns out we can do this pretty easily with htmx, but to do so we’ll need to
dig in to exactly how htmx swaps content.

You might think that htmx simply puts the new content into the DOM, but that’s
not in fact how it works. Instead, content goes through a series of steps as it
is added to the DOM:
- When content is received and about to be swapped into the DOM, the
  `htmx-swapping` CSS class is added to the target element.
- A small delay then occurs (we will discuss why this delay exists in a moment).
- Next, the `htmx-swapping` class is removed from the target and the
  `htmx-settling` class is added.
- The new content is swapped into the DOM.
- Another small delay occurs.
- Finally, the `htmx-settling` class is removed from the target.

There is more to the swap mechanic (settling, for example, is a more advanced
topic that we will discuss in a later chapter) but this is enough for now.

Now, there are small delays in the process here, typically on the order of a few
milliseconds. Why so? It turns out that these small delays allow _CSS transitions_ to
occur.

#sidebar[CSS Transitions][
  #indexed[CSS transitions] are a technology that allow you to animate a
  transition from one style to another. So, for example, if you changed the height
  of something from 10 pixels to 20 pixels, by using a CSS transition you can make
  the element smoothly animate to the new height. These sorts of animations are
  fun, often increase application usability, and are a great mechanism to add
  polish to your web application.
]

Unfortunately, CSS transitions are difficult to access in plain HTML: you
usually have to use JavaScript and add or remove classes to get them to trigger.
This is why the htmx swap model is more complicated than you might initially
think. By swapping in classes and adding small delays, you can access CSS
transitions purely within HTML, without needing to write any JavaScript!

==== Taking Advantage of "htmx-swapping" <_taking_advantage_of_htmx_swapping>
OK, so, let’s go back and look at our inline delete mechanic: we click an
htmx-enhanced link which deletes the contact and then swaps some empty content
in for the row. We know that before the `tr` element is removed, it will have
the `htmx-swapping` class added to it. We can take advantage of that to write a
CSS transition that fades the opacity of the row to 0. Here is what that CSS
looks like:

#figure(caption: [Adding a fade out transition],
```css
tr.htmx-swapping { <1>
  opacity: 0; <2>
  transition: opacity 1s ease-out; <3>
}
```)
1. We want this style to apply to `tr` elements with the `htmx-swapping`
  class on them.
2. The `opacity` will be 0, making it invisible.
3. The `opacity` will transition to 0 over a 1 second time period, using the `ease-out` function.

Again, this is not a CSS book and we are not going to go deeply into the details
of CSS transitions, but hopefully the above makes sense to you, even if this is
the first time you’ve seen CSS transitions.

So, think about what this means from the htmx swapping model: when htmx gets
content back to swap into the row it will put the `htmx-swapping`
class on the row and wait a bit. This will allow the transition to a zero
opacity to occur, fading the row out. Then the new (empty) content will be
swapped in, which will effectively remove the row.

Sounds good, and we are nearly there. There is one more thing we need to do: the
default "swap delay" for htmx is very short, a few milliseconds. That makes
sense in most cases: you don’t want to have much of a delay before you put the
new content into the DOM. But, in this case, we want to give the CSS animation
time to complete before we do the swap, we want to give it a second, in fact.

#index[hx-swap][delay]
Fortunately htmx has an option for the `hx-swap` annotation that allows you to
set the swap delay: following the swap type you can add `swap:`
followed by a timing value to tell htmx to wait a specific amount of time before
it swaps. Let’s update our HTML to allow a one second delay before the swap is
done for the delete action:

#figure(caption: [The existing row actions],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">Edit</a>
  <a href="/contacts/{{ contact.id }}">View</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-swap="outerHTML swap:1s" <1>
    hx-confirm="Are you sure you want to delete this contact?"
    hx-target="closest tr">Delete</a>
</td>
```)
1. A swap delay changes how long htmx waits before it swaps in new content.

With this modification, the existing row will stay in the DOM for an additional
second, with the `htmx-swapping` class on it. This will give the row time to
transition to an opacity of zero, giving the fade out effect we want.

Now, when a user clicks on a "Delete" link and confirms the delete, the row will
slowly fade out and then, once it has faded to a 0 opacity, it will be removed.
Pretty fancy, and all done in a declarative, hypermedia-oriented manner, no
JavaScript required. (Well, obviously htmx is written in JavaScript, but you
know what we mean: we didn’t have to write any JavaScript to implement the
feature.)

=== Bulk Delete <_bulk_delete>

#index[htmx patterns][bulk delete]
The final feature we are going to implement in this chapter is a "Bulk Delete."
The current mechanism for deleting users is nice, but it would be annoying if a
user wanted to delete five or ten contacts at a time, wouldn’t it? For the bulk
delete feature, we want to add the ability to select rows via a checkbox input
and delete them all in a single go by clicking a "Delete Selected Contacts"
button.

To get started with this feature, we’ll need to add a checkbox input to each row
in the `rows.html` template. This input will have the name
`selected_contact_ids` and its value will be the `id` of the contact for the
current row.

Here is what the updated code for `rows.html` looks like:

#figure(caption: [Adding a checkbox to each row],
```html
{% for contact in contacts %}
<tr>
  <td><input type="checkbox" name="selected_contact_ids"
    value="{{ contact.id }}"></td> <1>
  <td>{{ contact.first }}</td>
  ... omitted
</tr>
{% endfor %}
```)
1. A new cell with the checkbox input whose value is set to the current contact’s
  id.

We’ll also need to add an empty column in the header for the table to
accommodate the checkbox column. With that done we now get a series of check
boxes, one for each row, a pattern no doubt familiar to you from the web (@fig-checkboxes).

#figure(image("images/screenshot_checkboxes.png"), caption: [
  Checkboxes for our contact rows
])<fig-checkboxes>

If you are not familiar with or have forgotten the way checkboxes work in HTML:
a checkbox will submit its value associated with the name of the input if and
only if it is checked. So if, for example, you checked the contacts with the ids
3, 7 and 9, then those three values would all be submitted to the server. Since
all the checkboxes in this case have the same name, `selected_contact_ids`, all
three values would be submitted with the name `selected_contact_ids`.

==== The "Delete Selected Contacts" Button <_the_delete_selected_contacts_button>
The next step is to add a button below the table that will delete all the
selected contacts. We want this button, like our delete links in each row, to
issue an HTTP `DELETE`, but rather than issuing it to the URL for a given
contact, like we do with the inline delete links and with the delete button on
the edit page, here we want to issue the
`DELETE` to the `/contacts` URL.

As with the other delete elements, we want to confirm that the user wishes to
delete the contacts, and, for this case, we are going to target the body of
page, since we are going to re-render the whole table.

Here is what the button code looks like:

#figure(caption: [The "delete selected contacts" button],
```html
<button
  hx-delete="/contacts" <1>
  hx-confirm="Are you sure you want to delete these contacts?" <2>
  hx-target="body"> <3>
  Delete Selected Contacts
</button>
```)
1. Issue a `DELETE` to `/contacts`.
2. Confirm that the user wants to delete the selected contacts.
3. Target the body.

Pretty easy. One question though: how are we going to include the values of all
the selected checkboxes in the request? As it stands right now, this is just a
stand-alone button, and it doesn’t have any information indicating that it
should include any other information in the `DELETE`
request it makes.

#index[input values]
Fortunately, htmx has a few different ways to include values of inputs with a
request.

One way would be to use the `hx-include` attribute, which allows you to use a
CSS selector to specify the elements you want to include in the request. That
would work fine here, but we are going to use another approach that is a bit
simpler in this case.

#index[forms]
By default, if an element is a child of a `form` element and makes a non-`GET` request,
htmx will include all the values of inputs within that form. In situations like
this, where there is a bulk operation for a table, it is common to enclose the
whole table in a form tag, so that it is easy to add buttons that operate on the
selected items.

Let’s add that form tag around the table, and be sure to enclose the button in
it as well:

#figure(caption: [The "delete selected contacts" button],
```html
<form> <1>
  <table>
    ... omitted
  </table>
  <button
    hx-delete="/contacts"
    hx-confirm="Are you sure you want to delete these contacts?"
    hx-target="body">
    Delete Selected Contacts
  </button>
</form> <2>
```)
1. The form tag encloses the entire table.
2. The form tag also encloses the button.

Now, when the button issues a `DELETE`, it will include all the contact ids that
have been selected as the `selected_contact_ids` request variable.

==== The Server Side for Delete Selected Contacts <_the_server_side_for_delete_selected_contacts>
The server-side implementation is going to look like our original server-side
code for deleting a contact. In fact, once again, we can just copy and paste,
and make a few fixes:
- We want to change the URL to `/contacts`.
- We want the handler to get _all_ the ids submitted as
  `selected_contact_ids` and iterate over each one, deleting the given contact.

Those are the only changes we need to make! Here is what the server-side code
looks like:

#figure(caption: [The "delete selected contacts" button],
```python
@app.route("/contacts/", methods=["DELETE"]) <1>
def contacts_delete_all():
    contact_ids =  [
      int(id)
      for id in request.form.getlist("selected_contact_ids")
    ] <2>
    for contact_id in contact_ids: <3>
        contact = Contact.find(contact_id)
        contact.delete() <4>
    flash("Deleted Contacts!") <5>
    contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set)
```)
1. We handle a `DELETE` request to the `/contacts/` path.
2. Convert the `selected_contact_ids` values submitted to the server from a list of
  strings to a list integers.
3. Iterate over all of the ids.
4. Delete the given contact with each id.
5. Beyond that, it’s the same code as our original delete handler: flash a message
  and render the `index.html` template.

So, we took the original delete logic and slightly modified it to deal with an
array of ids, rather than a single id.

You might notice one other small change: we did away with the redirect that was
in the original delete code. We did so because we are already on the page we
want to re-render, so there is no reason to redirect and have the URL update to
something new. We can just re-render the page, and the new list of contacts
(sans the contacts that were deleted) will be re-rendered.

And there we go, we now have a bulk delete feature for our application. Once
again, not a huge amount of code, and we are implementing these features
entirely by exchanging hypermedia with a server in the traditional, RESTful
manner of the web.

#html-note[Accessible by Default?][
#index[ARIA]
#index[accessibility]
Accessibility problems can arise when we try to implement controls that aren’t
built into HTML.

Earlier, in Chapter 1, we looked at the example of a \<div\> improvised to
work like a button. Let’s look at a different example: what if you make
something that looks like a set of tabs, but you use radio buttons and CSS hacks
to build it? It’s a neat hack that makes the rounds in web development
communities from time to time.

The problem here is that tabs have requirements beyond clicking to change
content. Your improvised tabs may be missing features that will lead to user
confusion and frustration, as well as some undesirable behaviors. From the
#link(
  "https://www.w3.org/WAI/ARIA/apg/patterns/tabs/",
)[ARIA Authoring Practices Guide on tabs]:

- Keyboard interaction

  - Can the tabs be focused with the Tab key?

- ARIA roles, states, and properties

  - "\[The element that contains the tabs\] has role `tablist`."

  - "Each \[tab\] has role `tab` \[…​\]"

  - "Each element that contains the content panel for a `tab` has role
    `tabpanel`."

  - "Each \[tab\] has the property `aria-controls` referring to its associated
    tabpanel element."

  - "The active `tab` element has the state `aria-selected` set to
    `true` and all other `tab` elements have it set to `false`."

  - "Each element with role `tabpanel` has the property
    `aria-labelledby` referring to its associated `tab` element."

You would need to write a lot of code to make your improvised tabs fulfill all
of these requirements. Some of the ARIA attributes can be added directly in
HTML, but they are repetitive and others (like
`aria-selected`) need to be set through JavaScript since they are dynamic. The
keyboard interactions can be error-prone too.

It’s not impossible, not even that hard, to make your own tab set
implementation. However, it’s difficult to trust that a new implementation will
work for all users in all environments, since most of us have limited resources
for testing.

_Stick with established libraries_ for UI interactions. If a use case requires a
bespoke solution, _test exhaustively_ for keyboard interaction and
accessibility. Test manually. Test automatically. Test with screen readers, test
with a keyboard, test on different browsers and hardware, and run linters (while
coding and/or in CI). Testing is critical to ensure machine readability, or
human readability, or page weight.

#index[HTML][\<details\>]
Also consider: Does the information need to be presented as tabs? Sometimes the
answer is yes, but if not, a sequence of details and disclosures fulfills a very
similar purpose.

#figure(```html
<details><summary>Disclosure 1</summary>
  Disclosure 1 contents
</details>
<details><summary>Disclosure 2</summary>
  Disclosure 2 contents
</details>
```)

Compromising UX just to avoid JavaScript is bad development. But sometimes it’s
possible to achieve an equal (or better!) quality of UX while allowing for a
simpler and more robust implementation by changing the design.
]
