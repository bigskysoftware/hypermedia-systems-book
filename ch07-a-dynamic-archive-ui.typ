#import "lib/definitions.typ": *

== A Dynamic Archive UI

Contact.app has come a long way from a traditional web 1.0-style web
application: we’ve added active search, bulk delete, some nice animations, and a
slew of other features. We have reached a level of interactivity that most web
developers would assume requires some sort of Single-Page Application JavaScript
framework, but we’ve done it using htmx-powered hypermedia instead.

#index[htmx patterns][download archive]
Let’s look at how we can add a final significant feature to Contact.app:
downloading an archive of all the contacts.

From a hypermedia perspective, downloading a file isn’t exactly rocket science:
using the HTTP `Content-Disposition` response header, we can easily tell the
browser to download and save a file to the local computer.

However, let’s make this problem more interesting: let’s add in the fact that
the export can take a bit of time, from five to ten seconds, or sometimes even
longer, to complete.

This means that if we implemented the download as a "normal" HTTP request,
driven by a link or a button, the user might sit with very little visual
feedback, wondering if the download is actually happening, while the export is
being completed. They might even give up in frustration and click the download
hypermedia control again, causing a
_second_ archive request. Not good.

This turns out to be a classic problem in web app development. When faced with
potentially long-running process like this, we ultimately have two options:
- When the user triggers the action, block until it is complete and then respond
  with the result.
- Begin the action and return immediately, showing some sort of UI indicating that
  things are in progress.

Blocking and waiting for the action to complete is certainly the simpler way to
handle it, but it can be a bad user experience, especially if the action takes a
while to complete. If you’ve ever clicked on something in a web 1.0-style
application and then had to sit there for what seems like an eternity before
anything happens, you’ve seen the practical results of this choice.

The second option, starting the action asynchronously (say, by creating a
thread, or submitting it to a job runner system) is much nicer from a user
experience perspective: the server can respond immediately and the user doesn’t
need to sit there wondering what’s going on.

But the question is, what do you respond _with_? The job probably isn’t complete
yet, so you can’t provide a link to the results.

We have seen a few different "simple" approaches in this scenario in various web
applications:
- Let the user know that the process has started and that they will be emailed a
  link to the completed process results when it is finished.
- Let the user know that the process has started and recommend that they should
  manually refresh the page to see the status of the process.
- Let the user know that the process has started and automatically refresh the
  page every few seconds using some JavaScript.

All of these will work, but none of them is a great user experience.

What we’d _really_ like in this scenario is something more like what you see
when, for example, you download a large file via the browser: a nice progress
bar indicating where in the process you are, and, when the process is complete,
a link to click immediately to view the result of the process.

This may sound like something impossible to implement with hypermedia, and, to
be honest, we’ll need to push htmx pretty hard to make this all work, but, when
it is done, it won’t be _that_ much code, and we will be able to achieve the
user experience we want for this archiving feature.

=== UI Requirements <_ui_requirements>
Before we dive into the implementation, let’s discuss in broad terms what our
new UI should look like: we want a button in the application labeled "Download
Contact Archive." When a user clicks on that button, we want to replace that
button with a UI that shows the progress of the archiving process, ideally with
a progress bar. As the archive job makes progress, we want to move the progress
bar along towards completion. Then, when the archive job is done, we want to
show a link to the user to download the contact archive file.

#index[Archiver]
In order to actually do the archiving, we are going to use a python class, `Archiver`,
that implements all the functionality that we need. As with the `Contact` class,
we aren’t going to go into the implementation details of `Archiver`, because
that’s beyond the scope of this book. For now you just need to know is that it
provides all the server-side behavior necessary to start a contact archive
process and get the results when that process is done.

`Archiver` gives us the following methods to work with:
- `status()` - A string representing the status of the download, either
  `Waiting`, `Running` or `Complete`
- `progress()` - A number between 0 and 1, indicating how much progress the
  archive job has made
- `run()` - Starts a new archive job (if the current status is
  `Waiting`)
- `reset()` - Cancels the current archive job, if any, and resets to the
  "Waiting" state
- `archive_file()` - The path to the archive file that has been created on the
  server, so we can send it to the client
- `get()` - A class method that lets us get the Archiver for the current user

A fairly uncomplicated API.

The only somewhat tricky aspect to the whole API is that the `run()`
method is _non-blocking_. This means that it does not
_immediately_ create the archive file, but rather it starts a background job (as
a thread) to do the actual archiving. This can be confusing if you aren’t used
to multithreading in code: you might be expecting the `run()` method to "block",
that is, to actually execute the entire export and only return when it is
finished. But, if it did that, we wouldn’t be able to start the archive process
and immediately render our desired archive progress UI.

=== Beginning Our Implementation <_beginning_our_implementation>
We now have everything we need to begin implementing our UI: a reasonable
outline of what it is going to look like, and the domain logic to support it.

So, to start, note that this UI is largely self-contained: we want to replace
the button with the download progress bar, and then the progress bar with a link
to download the results of the completed archive process.

The fact that our archive user interface is all going to be within a specific
part of the UI is a strong hint that we will want to create a new template to
handle it. Let’s call this template `archive_ui.html`.

Also note that we are going to want to replace the entire download UI in
multiple cases:
- When we start the download, we will want to replace the button with a progress
  bar.
- As the archive process proceeds, we will want to replace/update the progress
  bar.
- When the archive process completes, we will want to replace the progress bar
  with a download link.

To update the UI in this way, we need to set a good target for the updates. So,
let’s wrap the entire UI in a `div` tag, and then use that
`div` as the target for all our operations.

Here is the start of the template for our new archive user interface:

#figure(caption: [Our initial archive UI template],
```html
<div id="archive-ui"
  hx-target="this" <1>
  hx-swap="outerHTML"> <2>
</div>
```)
1. This div will be the target for all elements within it.
2. Replace the entire div every time using `outerHTML`.

Next, lets add the "Download Contact Archive" button to the `div` that will kick
off the archive-then-download process. We’ll use a `POST` to the path `/contacts/archive` to
trigger the start of the archiving process:

#figure(caption: [Adding the archive button],
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  <button hx-post="/contacts/archive"> <1>
    Download Contact Archive
  </button>
</div>
```)
1. This button will issue a `POST` to `/contacts/archive`.

Finally, let’s include this new template in our main `index.html`
template, above the contacts table:

#figure(caption: [Our initial archive UI template],
```html
{% block content %}
  {% include 'archive_ui.html' %} <1>

  <form action="/contacts" method="get" class="tool-bar">
```)
1. This template will now be included in the main template.

With that done, we now have a button showing up in our web application to get
the download going. Since the enclosing `div` has an
`hx-target="this"` on it, the button will inherit that target and replace that
enclosing `div` with whatever HTML comes back from the
`POST` to `/contacts/archive`.

=== Adding the Archiving Endpoint <_adding_the_archiving_endpoint>
Our next step is to handle the `POST` that our button is making. We want to get
the `Archiver` for the current user and invoke the `run()` method on it. This
will start the archive process running. Then we will render some new content
indicating that the process is running.

To do that, we want to reuse the `archive_ui` template to handle rendering the
archive UI for both states, when the archiver is "Waiting" and when it is "Running."
(We will handle the "Complete" state in a bit).

This is a very common pattern: we put all the different potential UIs for a
given chunk of the user interface into a single template, and conditionally
render the appropriate interface. By keeping everything in one file, it makes it
much easier for other developers (or for us, if we come back after a while!) to
understand exactly how the UI works on the client side.

Since we are going to conditionally render different user interfaces based on
the state of the archiver, we will need to pass the archiver out to the template
as a parameter. So, again: we need to invoke `run()`
on the archiver in our controller and then pass the archiver along to the
template, so it can render the UI appropriate for the current status of the
archive process.

Here is what the code looks like:

#figure(caption: [Server-side code to start the archive process],
```python
@app.route("/contacts/archive", methods=["POST"]) <1>
def start_archive():
    archiver = Archiver.get() <2>
    archiver.run() <3>
    return render_template("archive_ui.html", archiver=archiver) <4>
```)
1. Handle `POST` to `/contacts/archive`.
2. Look up the Archiver.
3. Invoke the non-blocking `run()` method on it.
4. Render the `archive_ui.html` template, passing in the archiver.

=== Conditionally Rendering A Progress UI <_conditionally_rendering_a_progress_ui>

#index[conditional rendering]
Now let’s turn our attention to updating our archiving UI by setting
`archive_ui.html` to conditionally render different content depending on the
state of the archive process.

Recall that the archiver has a `status()` method. When we pass the archiver
through as a variable to the template, we can consult this
`status()` method to see the status of the archive process.

If the archiver has the status `Waiting`, we want to render the
"Download Contact Archive" button. If the status is `Running`, we want to render
a message indicating that progress is happening. Let’s update our template code
to do just that:

#figure(caption: [Adding conditional rendering],
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  {% if archiver.status() == "Waiting" %} <1>
    <button hx-post="/contacts/archive">
      Download Contact Archive
    </button>
  {% elif archiver.status() == "Running" %} <2>
    Running... <3>
  {% endif %}
</div>
```)
1. Only render the archive button if the status is "Waiting."
2. Render different content when status is "Running."
3. For now, just some text saying the process is running.

OK, great, we have some conditional logic in our template view, and the
server-side logic to support kicking off the archive process. We don’t have a
progress bar yet, but we’ll get there! Let’s see how this works as it stands,
and refresh the main page of our application…​

#figure(caption: [Something Went Wrong],
```
UndefinedError
jinja2.exceptions.UndefinedError: 'archiver' is undefined
```)

Ouch!

We get an error message right out of the box. Why? Ah, we are including the `archive_ui.html` in
the `index.html` template, but now the
`archive_ui.html` template expects the archiver to be passed through to it, so
it can conditionally render the correct UI.

That’s an easy fix: we just need to pass the archiver through when we render the `index.html` template
as well:

#figure(caption: [Including the archiver when we render index.html],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search':
            return render_template("rows.html", contacts=contacts_set)
    else:
        contacts_set = Contact.all()
    return render_template("index.html",
      contacts=contacts_set, archiver=Archiver.get()) <1>
```)
1. Pass through archiver to the main template

Now with that done, we can load up the page. And, sure enough, we can see the "Download
Contact Archive" button.

When we click on it, the button is replaced with the content "Running…​", and we
can see in our development console on the server-side that the job is indeed
getting kicked off properly.

=== Polling <_polling>

#index[polling]
That’s definitely progress, but we don’t exactly have the best progress
indicator here: just some static text telling the user that the process is
running.

We want to make the content update as the process makes progress and, ideally,
show a progress bar indicating how far along it is. How can we do that in htmx
using plain old hypermedia?

The technique we want to use here is called "polling", where we issue a request
on an interval and update the UI based on the new state of the server.

#sidebar[Polling? Really?][Polling has a bit of a bad rap, and it isn’t the sexiest technique in the world:
  today developers might look at a more advanced technique like WebSockets or
  Server Sent Events (SSE) to address this situation.

  But, say what one will, polling _works_ and it is drop-dead simple. You need to
  be careful not to overwhelm your system with polling requests, but, with a bit
  of care, you can create a reliable, passively updated component in your UI using
  it.]

Htmx offers two types of polling. The first is "fixed rate polling", which uses
a special `hx-trigger` syntax to indicate that something should be polled on a
fixed interval.

Here is an example:

#figure(caption: [Fixed interval polling],
```html
<div hx-get="/messages" hx-trigger="every 3s"> <1>
</div>
```)
1. Trigger a `GET` to `/messages` every three seconds.

This works great in situations when you want to poll indefinitely, for example
if you want to constantly poll for new messages to display to the user. However,
fixed rate polling isn’t ideal when you have a definite process after which you
want to stop polling: it keeps polling forever, until the element it is on is
removed from the DOM.

In our case, we have a definite process with an ending to it. So, it will be
better to use the second polling technique, known as "load polling." In load
polling, we take advantage of the fact that htmx triggers a `load` event when
content is loaded into the DOM. We can create a trigger on this `load` event,
and add a bit of a delay so that the request doesn’t trigger immediately.

With this, we can conditionally render the `hx-trigger` on every request: when a
process has completed we simply do not include the
`load` trigger, and the load polling stops. This offers a nice and simple way to
poll until a definite process finishes.

==== Using Polling To Update The Archive UI <_using_polling_to_update_the_archive_ui>
Let’s use load polling to update our UI as the archiver makes progress. To show
the progress, let’s use a CSS-based progress bar, taking advantage of the `progress()` method
which returns a number between 0 and 1 indicating how close the archive process
is to completion.

Here is the snippet of HTML we will use:

#figure(caption: [A CSS-based progress bar],
```html
<div class="progress">
    <div class="progress-bar"
         style="width:{{ archiver.progress() * 100 }}%"></div> <1>
</div>
```)
1. The width of the inner element corresponds to the progress.

This CSS-based progress bar has two components: an outer `div` that provides the
wire frame for the progress bar, and an inner `div` that is the actual progress
bar indicator. We set the width of the inner progress bar to some percentage
(note we need to multiply the
`progress()` result by 100 to get a percentage) and that will make the progress
indicator the appropriate width within the parent div.

#sidebar[What About The <progress> Element?][We are perhaps dipping our toes into the "div soup" here, using a
`div` tag when there is a perfectly good HTML5 tag, the
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/progress",
)[`progress`]
element, that is designed specifically for showing, well, progress.

We decided not to use the `progress` element for this example because we want
our progress bar to update smoothly, and we will need to use a CSS technique not
available for the `progress` element to make that happen. That’s unfortunate,
but sometimes we have to play with the cards we are dealt.

We will, however, use the proper
#link(
  "https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/roles/progressbar_role",
)[progress bar roles]
to make our `div`-based progress bar play well with assistive technologies.]

Let’s update our #indexed[progress bar] to have the proper ARIA roles and
values:

#figure(caption: [A CSS-based progress bar])[
```html
<div class="progress">
  <div class="progress-bar"
    role="progressbar" <1>
    aria-valuenow="{{ archiver.progress() * 100 }}" <2>
    style="width:{{ archiver.progress() * 100 }}%"></div>
</div>
``` ]
1. This element will act as a progress bar
2. The progress will be the percentage completeness of the archiver, with 100
  indicating fully complete

Finally, for completeness, here is the CSS we’ll use for this progress bar:

#figure(caption: [The CSS for our progress bar])[
```css
.progress {
    height: 20px;
    margin-bottom: 20px;
    overflow: hidden;
    background-color: #f5f5f5;
    border-radius: 4px;
    box-shadow: inset 0 1px 2px rgba(0,0,0,.1);
}

.progress-bar {
    float: left;
    width: 0%;
    height: 100%;
    font-size: 12px;
    line-height: 20px;
    color: #fff;
    text-align: center;
    background-color: #337ab7;
    box-shadow: inset 0 -1px 0 rgba(0,0,0,.15);
    transition: width .6s ease;
}
```]<lst:progress-bar-css>

#figure(image("images/screenshot_progress_bar.png"), caption: [
  Our CSS-Based Progress Bar, as implemented in @lst:progress-bar-css
])

===== Adding The Progress Bar UI <_adding_the_progress_bar_ui>
Let’s add the code for our progress bar into our `archive_ui.html`
template for the case when the archiver is running, and let’s update the copy to
say "Creating Archive…​":

#figure(caption: [Adding the progress bar])[
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  {% if archiver.status() == "Waiting" %}
    <button hx-post="/contacts/archive">
      Download Contact Archive
    </button>
  {% elif archiver.status() == "Running" %}
    <div>
      Creating Archive...
      <div class="progress"> <1>
        <div class="progress-bar" role="progressbar"
          aria-valuenow="{{ archiver.progress() * 100}}"
          style="width:{{ archiver.progress() * 100 }}%"></div>
      </div>
    </div>
  {% endif %}
</div>
``` ]
1. Our shiny new progress bar

Now when we click the "Download Contact Archive" button, we get the progress
bar. But it still doesn’t update because we haven’t implemented load polling
yet: it just sits there, at zero.

To get the progress bar updating dynamically, we’ll need to implement load
polling using `hx-trigger`. We can add this to pretty much any element inside
the conditional block for when the archiver is running, so let’s add it to that `div` that
is wrapping around the "Creating Archive…​" text and the progress bar.

Let’s make it poll by issuing an HTTP `GET` to the same path as the
`POST`: `/contacts/archive`.

#figure(caption: [Implementing load polling])[
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  {% if archiver.status() == "Waiting" %}
    <button hx-post="/contacts/archive">
      Download Contact Archive
    </button>
  {% elif archiver.status() == "Running" %}
    <div hx-get="/contacts/archive" hx-trigger="load delay:500ms"> <1>
      Creating Archive...
      <div class="progress" >
        <div class="progress-bar" role="progressbar"
          aria-valuenow="{{ archiver.progress() * 100}}"
          style="width:{{ archiver.progress() * 100 }}%"></div>
      </div>
    </div>
  {% endif %}
</div>
``` ]
1. Issue a `GET` to `/contacts/archive` 500 milliseconds after the content loads.

When this `GET` is issued to `/contacts/archive`, it is going to replace the `div` with
the id `archive-ui`, not just itself. The `hx-target`
attribute on the `div` with the id `archive-ui` is _inherited_ by all child
elements within that `div`, so the children will all target that outermost `div` in
the `archive_ui.html` file.

Now we need to handle the `GET` to `/contacts/archive` on the server.
Thankfully, this is quite easy: all we want to do is re-render
`archive_ui.html` with the archiver:

#figure(caption: [Handling progress updates])[
```python
@app.route("/contacts/archive", methods=["GET"]) <1>
def archive_status():
    archiver = Archiver.get()
    return render_template("archive_ui.html", archiver=archiver) <2>
``` ]
1. handle `GET` to the `/contacts/archive` path
2. just re-render the `archive_ui.html` template

Like so much else with hypermedia, the code is very readable and not
complicated.

Now, when we click the "Download Contact Archive", sure enough, we get a
progress bar that updates every 500 milliseconds. As the result of the call to `archiver.progress()` incrementally
updates from 0 to 1, the progress bar moves across the screen for us. Very cool!

==== Downloading The Result <_downloading_the_result>
We have one final state to handle, the case when `archiver.status()` is set to "Complete",
and there is a JSON archive of the data ready to download. When the archiver is
complete, we can get the local JSON file on the server from the archiver via the `archive_file()` call.

Let’s add another case to our if statement to handle the "Complete" state, and,
when the archive job is complete, lets render a link to a new path, `/contacts/archive/file`,
which will respond with the archived JSON file. Here is the new code:

#figure(caption: [Rendering A Download Link When Archiving Completes])[
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  {% if archiver.status() == "Waiting" %}
    <button hx-post="/contacts/archive">
      Download Contact Archive
    </button>
  {% elif archiver.status() == "Running" %}
    <div hx-get="/contacts/archive" hx-trigger="load delay:500ms">
      Creating Archive...
      <div class="progress" >
        <div class="progress-bar" role="progressbar"
          aria-valuenow="{{ archiver.progress() * 100}}"
          style="width:{{ archiver.progress() * 100 }}%"></div>
      </div>
    </div>
  {% elif archiver.status() == "Complete" %} <1>
    <a hx-boost="false" href="/contacts/archive/file">
      Archive Ready! Click here to download. &downarrow;
    </a> <2>
  {% endif %}
</div>
``` ]
1. If the status is "Complete", render a download link.
2. The link will issue a `GET` to `/contacts/archive/file`.

Note that the link has `hx-boost` set to `false`. It has this so that the link
will not inherit the boost behavior that is present for other links and, thus,
will not be issued via AJAX. We want this "normal" link behavior because an AJAX
request cannot download a file directly, whereas a plain anchor tag can.

==== Downloading The Completed Archive <_downloading_the_completed_archive>
The final step is to handle the `GET` request to
`/contacts/archive/file`. We want to send the file that the archiver created
down to the client. We are in luck: Flask has a mechanism for sending a file as
a downloaded response, the `send_file()` method.

As you see in the code that follows, we pass three arguments to
`send_file()`: the path to the archive file that the archiver created, the name
of the file that we want the browser to create, and if we want it sent "as an
attachment." This last argument tells Flask to set the HTTP response header `Content-Disposition` to `attachment` with
the given filename; this is what triggers the browser’s file-downloading
behavior.

#figure(caption: [Sending A File To The Client])[
```python
@app.route("/contacts/archive/file", methods=["GET"])
def archive_content():
    manager = Archiver.get()
    return send_file(
      manager.archive_file(), "archive.json", as_attachment=True) <1>
``` ]
1. Send the file to the client via Flask’s `send_file()` method.

Perfect. Now we have an archive UI that is very slick. You click the
"Download Contacts Archive" button and a progress bar appears. When the progress
bar reaches 100%, it disappears and a link to download the archive file appears.
The user can then click on that link and download their archive.

We’re offering a user experience that is much more user-friendly than the common
click-and-wait experience of many websites.

=== Smoothing Things Out: Animations in Htmx <_smoothing_things_out_animations_in_htmx>
As nice as this UI is, there is one minor annoyance: as the progress bar updates
it "jumps" from one position to the next. This feels a bit like a full page
refresh in web 1.0 style applications. Is there a way we can fix this?
(Obviously there is, this why we went with a `div` rather than a `progress` element!)

Let’s walk through the cause of this visual problem and how we might fix it. (If
you’re in a hurry to get to an answer, feel free to jump ahead to "our
solution.")

#index[CSS transitions]
It turns out that there is a native HTML technology for smoothing out changes on
an element from one state to another: the CSS Transitions API, the same one that
we discussed in Chapter 4. Using CSS Transitions, you can smoothly animate an
element between different styling by using the `transition` property.

If you look back at our CSS definition of the `.progress-bar` class, you will
see the following transition definition:
`transition: width .6s ease;`. This means that when the width of the progress
bar is changed from, say 20% to 30%, the browser will animate over a period of
.6 seconds using the "ease" function (which has a nice accelerate/decelerate
effect).

So why isn’t that transition being applied in our current UI? The reason is
that, in our example, htmx is _replacing_ the progress bar with a new one every
time it polls. It isn’t updating the width of an
_existing_ element. CSS transitions, unfortunately, only apply when the
properties of an existing element change inline, not when the element is
replaced.

This is a reason why pure HTML-based applications can feel jerky and unpolished
when compared with their SPA counterparts: it is hard to use CSS transitions
without some JavaScript.

But there is some good news: htmx has a way to utilize CSS transitions even when
it replaces content in the DOM.

==== The "Settling" Step in Htmx <_the_settling_step_in_htmx>

#index[htmx][swap model]
#index[htmx][settling]
When we discussed the htmx swap model in Chapter 4, we focused on the classes
that htmx adds and removes, but we skipped over the process of
"settling." In htmx, settling involves several steps: when htmx is about to
replace a chunk of content, it looks through the new content and finds all
elements with an `id` on it. It then looks in the
_existing_ content for elements with the same `id`.

If there is one, it does the following somewhat elaborate shuffle:
- The _new_ content gets the attributes of the _old_ content temporarily.
- The new content is inserted.
- After a small delay, the new content has its attributes reverted to their actual
  values.

So, what is this strange little dance supposed to achieve?

Well, if an element has a stable id between swaps, you can now write CSS
transitions between various states. Since the _new_ content briefly has the _old_ attributes,
the normal CSS transition mechanism will kick in when the actual values are
restored.

==== Our Smoothing Solution <_our_smoothing_solution>
So, we arrive at our fix.

All we need to do is add a stable ID to our `progress-bar` element.

#figure(caption: [Smoothing things out])[
```html
<div class="progress" >
    <div id="archive-progress" class="progress-bar" role="progressbar"
         aria-valuenow="{{ archiver.progress() * 100 }}"
         style="width:{{ archiver.progress() * 100 }}%"></div> <1>
</div>
``` ]
1. The progress bar div now has a stable id across requests.

Despite the complicated mechanics going on behind the scenes in htmx, the
solution is as simple as adding a stable `id` attribute to the element we want
to animate.

Now, rather than jumping on every update, the progress bar should smoothly move
across the screen as it is updating, using the CSS transition defined in our
style sheet. The htmx swapping model allows us to achieve this even though we
are replacing the content with new HTML.

And voila: we have a nice, smoothly animated progress bar for our contact
archiving feature. The result has the look and feel of a JavaScript-based
solution, but we did it with the simplicity of an HTML-based approach.

Now that, dear reader, does spark joy.

=== Dismissing The Download UI <_dismissing_the_download_ui>
Some users may change their mind, and decide not to download the archive. They
may never witness our glorious progress bar, but that’s OK. We’re going to give
these users a button to dismiss the download link and return to the original
export UI state.

To do this, we’ll add a button that issues a `DELETE` to the path
`/contacts/archive`, indicating that the current archive can be removed or
cleaned up.

We’ll add it after the download link, like so:

#figure(caption: [Clearing the download])[
```html
<a hx-boost="false" href="/contacts/archive/file">
 Archive Ready! Click here to download. &downarrow;
</a>
<button hx-delete="/contacts/archive">Clear Download</button> <1>
``` ]
1. A simple button that issues a `DELETE` to `/contacts/archive`.

Now the user has a button that they can click on to dismiss the archive download
link. But we will need to hook it up on the server side. As usual, this is
pretty straightforward: we create a new handler for the
`DELETE` HTTP Action, invoke the `reset()` method on the archiver, and re-render
the `archive_ui.html` template.

Since this button is picking up the same `hx-target` and `hx-swap`
configuration as everything else, it "just works."

Here is the server-side code:

#figure(caption: [The handler to reset the download])[
```python
@app.route("/contacts/archive", methods=["DELETE"])
def reset_archive():
    archiver = Archiver.get()
    archiver.reset() <1>
    return render_template("archive_ui.html", archiver=archiver)
``` ]
1. Call `reset()` on the archiver

This looks pretty similar to our other handlers, doesn’t it?

Sure does! That’s the idea!

=== An Alternative UX: Auto-Download <_an_alternative_ux_auto_download>

#index[auto-download]
While we prefer the current user experience for archiving contacts, there are
other alternatives. Currently, a progress bar shows the progress of the process
and, when it completes, the user is presented with a link to actually download
the file. Another pattern that we see on the web is "auto-downloading", where
the file downloads immediately without the user needing to click a link.

We can add this functionality quite easily to our application with just a bit of
scripting. We will discuss scripting in a Hypermedia-Driven Application in more
depth in Chapter 9, but, put briefly: scripting is perfectly acceptable in a
HDA, as long as it doesn’t replace the core hypermedia mechanics of the
application.

For our auto-download feature we will use
#link("https://hyperscript.org")[\_hyperscript], our preferred scripting option.
JavaScript would also work here, and would be nearly as simple; again, we’ll
discuss scripting options in detail in Chapter 9.

All we need to do to implement the auto-download feature is the following: when
the download link renders, automatically click on the link for the user.

The \_hyperscript code reads almost the same as the previous sentence (which is
a major reason why we love hyperscript):

#figure(caption: [Auto-downloading])[
```html
<a hx-boost="false" href="/contacts/archive/file"
  _="on load click() me"> <1>
  Archive Downloading! Click here if the download does not start.
</a>
``` ]
1. A bit of \_hyperscript to make the file auto-download.

Crucially, the scripting here is simply _enhancing_ the existing hypermedia,
rather than replacing it with a non-hypermedia request. This is
hypermedia-friendly scripting, as we will cover in more depth in a bit.

=== A Dynamic Archive UI: Complete <_a_dynamic_archive_ui_complete>
In this chapter we’ve managed to create a dynamic UI for our contact archive
functionality, with a progress bar and auto-downloading, and we’ve done nearly
all of it --- with the exception of a small bit of scripting for auto-download
--- in pure hypermedia. It took about 16 lines of front end code and 16 lines of
backend code to build the whole thing.

HTML, with a bit of help from a hypermedia-oriented JavaScript library such as
htmx, can in fact be extremely powerful and expressive.

#html-note[Markdown soup][
#index[Markdown]
_Markdown soup_ is the lesser known sibling of `<div>` soup. This is the result
of web developers limiting themselves to the set of elements that the Markdown
language provides shorthand for, even when these elements are incorrect. More
seriously, it’s important to be aware of the full power of our tools, including
HTML. Consider the following example of an IEEE-style citation:

#figure(
```markdown
[1] C.H. Gross, A. Stepinski, and D. Akşimşek, <1>
  _Hypermedia Systems_, <2>
  Bozeman, MT, USA: Big Sky Software.
  Available: <https://hypermedia.systems/>
```)
1. The reference number is written in brackets.
2. Underscores around the book title creates an \<em\> element.

Here, \<em\> is used because it’s the only Markdown element that is presented in
italics by default. This indicates that the book title is being stressed, but
the purpose is to mark it as the title of a work. HTML has the `<cite>` element
that’s intended for this exact purpose.

Furthermore, even though this is a numbered list perfect for the `<ol>`
element, which Markdown supports, plain text is used for the reference numbers
instead. Why could this be? The IEEE citation style requires that these numbers
are presented in square brackets. This could be achieved on an `<ol>` with CSS,
but Markdown doesn’t have a way to add a class to elements meaning the square
brackets would apply to all ordered lists.

Don’t shy away from using embedded HTML in Markdown. For larger sites, also
consider Markdown extensions.

#figure(
```markdown
{.ieee-reference-list} <1>
1. C.H. Gross, A. Stepinski, and D. Akşimşek, <2>
  <cite>Hypermedia Systems</cite>, <3>
  Bozeman, MT, USA: Big Sky Software.
  Available: <https://hypermedia.systems/>
```)

1. Many Markdown dialects let us add ids, classes and attributes using curly
  braces.
2. We can now use the \<ol\> element, and create the brackets in CSS.
3. We use `<cite>` to mark the title of the work being cited (not the whole
  citation!)

You can also use custom processors to produce extra-detailed HTML instead of
writing it by hand:

#figure(
```markdown
{% reference_list %} <1>
[hypers2023]: <2>
  C.H. Gross, A. Stepinski, and D. Akşimşek, _Hypermedia Systems_,
  Bozeman, MT, USA: Big Sky Software, 2023.
  Available: <https://hypermedia.systems/>
{% end %}
```)

1. `reference_list` is a macro that will transform the plain text to
  highly-detailed HTML.
2. A processor can also resolve identifiers, so we don’t have to manually keep the
  reference list in order and the in-text citations in sync.
]
