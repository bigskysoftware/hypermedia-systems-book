#import "lib/definitions.typ": *

== Hyperview: A Mobile Hypermedia

You may be forgiven for thinking the hypermedia architecture is synonymous with
the web, web browsers, and HTML. No doubt, the web is the largest hypermedia
system, and web browsers are the most popular hypermedia client. The dominance
of the web in discussions about hypermedia make it easy to forget that
hypermedia is a general concept, and can be applied to all types of platforms
and applications. In this chapter, we will see the hypermedia architecture
applied to a non-web platform: native mobile applications.

Mobile as a platform has different constraints than the web. It requires
different trade-offs and design decisions. Nonetheless, the concepts of
hypermedia, HATEOAS, and REST can be directly applied to build delightful mobile
applications.

In this chapter we will cover shortcomings with the current state of mobile app
development, and how a hypermedia architecture can address these problems. We
will then look at a path toward hypermedia on mobile: Hyperview, a mobile app
framework that uses the hypermedia architecture. We’ll conclude with an overview
of HXML, the hypermedia format used by Hyperview.

=== The State of Mobile App Development <_the_state_of_mobile_app_development>
Before we can discuss how to apply hypermedia to mobile platforms, we need to
understand how native mobile apps are commonly built. I’m using the word "native"
to refer to code written against an SDK provided by the phone’s operating system
(typically Android or iOS). This code is packaged into an executable binary, and
uploaded & approved through app stores controlled by Google and Apple. When
users install or update an app, they’re downloading this executable and running
the code directly on their device’s OS. In this way, mobile apps have a lot in
common with old-school desktop apps for Mac, Windows, or Linux. There is one
important difference between PC desktop apps of yesteryear and today’s mobile
apps. These days, almost all mobile apps are "networked". By networked, we mean
the app needs to read and write data over the Internet to deliver its core
functionality. In other words, a networked mobile app needs to implement the
client-server architecture.

When implementing the client-server architecture, the developer needs to make a
decision: Should the app be designed as a thin client or thick client? The
current mobile ecosystems strongly push developers towards a thick-client
approach. Why? Remember, Android and iOS require that a native mobile app be
packaged and distributed as an executable binary. There’s no way around it.
Since the developer needs to write code to package into an executable, it seems
logical to implement some of the app’s logic in that code. The code may as well
initiate HTTP calls to the server to retrieve data, and then render that data
using the platform’s UI libraries. Thus, developers are naturally led into a
thick-client pattern that looks something like this:
- The client contains code to make API requests to the server, and code to
  translate those responses to UI updates
- The server implements an HTTP API that speaks JSON, and knows little about the
  state of the client

Just like with SPAs on the web, this architecture has a big downside: the app’s
logic gets spread across the client and server. Sometimes, this means that logic
gets duplicated (like to validate form data). Other times, the client and server
each implement disjoint parts of the app’s overall logic. To understand what the
app does, a developer needs to trace interactions between two very different
codebases.

There’s another downside that affects mobile apps more than SPAs: API churn.
Remember, the app stores control how your app gets distributed and updated.
Users can even control if and when they get updated versions of your app. As a
mobile developer, you can’t assume that every user will be on the latest version
of your app. Your frontend code gets fragmented across many versions, and now
your backend needs to support all of them.

=== Hypermedia for Mobile Apps

#index[hypermedia][for mobile]
We’ve seen that the hypermedia architecture can address the shortcomings of SPAs
on the web. But can hypermedia work for mobile apps as well? The answer is yes!

Just like on the web, we can use hypermedia formats on mobile and let it serve
as the engine of application state. All of the logic is controlled from the
backend, rather than being spread between two codebases. Hypermedia architecture
also solves the annoying problem of API churn on mobile apps. Since the backend
serves a hypermedia response containing both data and actions, there’s no way
for the data and UI to get out of sync. No more worries about backwards
compatibility or maintaining multiple API versions.

So how can you use hypermedia for your mobile app? There are two approaches
employing hypermedia to build & ship native mobile apps today:
- Web views, which wraps the trusty web platform in a mobile app shell
- Hyperview, a new hypermedia system we designed specifically for mobile apps

==== Web Views <_web_views>
The simplest way to use hypermedia architecture on mobile is by leveraging web
technologies. Both Android and iOS SDKs provide "web views": chromeless web
browsers that can be embedded in native apps. Tools like Apache Cordova make it
easy to take the URL of a website, and spit out native iOS and Android apps
based on web views. If you already have a responsive web app, you can get a "native"
mobile HDA for free. Sounds too good to be true, right?

Of course, there is a fundamental limitation with this approach. The web
platform and mobile platforms have different capabilities and UX conventions.
HTML doesn’t natively support common UI patterns of mobile apps. One of the
biggest differences is around how each platform handles navigation. On the web,
navigation is page-based, with one page replacing another and the browser
providing back/forward buttons to navigate the page history. On mobile,
navigation is more complex, and tuned for the physicality of gesture-based
interactions.
- To drill down, screens slide on top of each other, forming stacks of screens.
- Tab bars at the top or bottom of the app allow switching between various stacks
  of screens.
- Modals slide up from the bottom of the app, covering the other stacks and tab
  bar.
- Unlike with web pages, all of these screens are still present in memory,
  rendered and updating based on app state.

The navigation architecture is a major difference between how mobile and web
apps function. But it’s not the only one. Many other UX patterns are present in
mobile apps, but are not natively supported on the web:
- pull-to-refresh to refresh content in a screen
- horizontal swipe on UI elements to reveal actions
- sectioned lists with sticky headers

While these interactions are not natively supported by web browsers, they can be
simulated with JS libraries. Of course, these libraries will never have the same
feel and performance as native gestures. And using them usually requires
embracing a JS-heavy SPA architecture like React. This puts us back at square 1!
To avoid using the typical thick-client architecture of native mobile apps, we
turned to a web view. The web view allows us to use good-old hypermedia-based
HTML. But to get the desired look & feel of a mobile app, we end up building a
SPA in JS, losing the benefits of Hypermedia in the process.

To build a mobile HDA that acts and feels like a native app, HTML isn’t going to
cut it. We need a format designed to represent the interactions and patterns of
native mobile apps. That’s exactly what Hyperview does.

==== Hyperview

#indexed[Hyperview] is an open-source hypermedia system that provides:
- A hypermedia format for defining mobile apps called HXML
- A hypermedia client for HXML that works on iOS and Android
- Extension points in HXML and the client to customize the framework for a given
  app

===== The format

#indexed[HXML] was designed to feel familiar to web developers, used to working
with HTML. Thus the choice of XML for the base format. In addition to familiar
ergonomics, XML is compatible with server-side rendering libraries. For example,
Jinja2 is perfectly suited as a templating library to render HXML. The
familiarity of XML and the ease of integration on the backend make it simple to
adopt in both new and existing codebases. Take a look at a "Hello World" app
written in HXML. The syntax should be familiar to anyone who’s worked with HTML:

#figure(caption: [Hello World])[
```xml
<doc xmlns="https://hyperview.org/hyperview">
  <screen>
    <styles />
    <body>
      <header>
        <text>My first app</text>
      </header>
      <view>
        <text>Hello World!</text>
      </view>
    </body>
  </screen>
</doc>
``` ]

But HXML is not just a straight port of HTML with differently named tags. In
previous chapters, we’ve seen how htmx enhances HTML with a handful of new
attributes. These additions maintain the declarative nature of HTML, while
giving developers the power to create rich web apps. In HXML, the concepts of
htmx are built into the spec. Specifically, HXML is not limited to "click a
link" and "submit a form" interactions like basic HTML. It supports a range of
triggers and actions for modifying the content on a screen. These interactions
are bundled together in a powerful concept of "behaviors." Developers can even
define new behavior actions to add new capabilities to their app, without the
need for scripting. We will learn more about behaviors later in this chapter.

===== The client

#index[hypermedia][client]
Hyperview provides an open-source HXML client library written in React Native.
With a little bit of configuration and a few steps on the command line, this
library compiles into native app binaries for iOS or Android. Users install the
app on their device via an app store. On launch, the app makes an HTTP request
to the configured URL, and renders the HXML response as the first screen.

It may seem a little strange that developing a HDA using Hyperview requires a
single-purpose client binary. After all, we don’t ask users to first download
and install a binary to view a web app. No, users just enter a URL in the
address bar of a general-purpose web browser. A single HTML client renders apps
from any HTML server (@fig-1clientmanyserver).

#asciiart(
  read("images/diagram/one-client-many-servers.txt"), caption: [One HTML client, multiple HTML servers],
)<fig-1clientmanyserver>

It is theoretically possible to build an equivalent general-purpose
"Hyperview browser." This HXML client would render apps from any HXML server,
and users would enter a URL to specify the app they want to use. But iOS and
Android are built around the concept of single-purpose apps. Users expect to
find and install apps from an app store, and launch them from the home screen of
their device. Hyperview embraces this app-centric paradigm of today’s popular
mobile platforms. That means that the HXML client (app binary) renders its UI
from a single pre-configured HXML server (@fig-1client1server).

#asciiart(
  read("images/diagram/one-server-one-hxml-client.txt"), caption: [One HXML client, one HXML server],
)<fig-1client1server>

Luckily, developers do not need to write a HXML client from scratch; the
open-source client library does 99% of the work. And as we will see in the next
section, there are major benefits to controlling both the client and server in a
HDA.

===== Extensibility <_extensibility>
To understand the benefits of Hyperview’s architecture, we need to first discuss
the drawbacks of the web architecture. On the web, any web browser can render
HTML from any web server. This level of compatibility can only happen with
well-defined standards such as HTML5. But defining and evolving standards is a
laborious process. For example, the W3C took over 7 years to go from first draft
to recommendation on the HTML5 spec. It’s not surprising, given the level of
thoughtfulness that needs to go into a change that impacts so many people. But
it means that progress happens slowly. As a web developer, you may need to wait
years for browsers to gain widespread support for the feature you need.

So what are the benefits of Hyperview’s architecture? In a Hyperview app, _your_ mobile
app only renders HXML from _your_ server. You don’t need to worry about
compatibility between your server and other mobile apps, or between your mobile
app and other servers. There is no standards body to consult. If you want to add
a blink feature to your mobile app, go ahead and implement a `<blink>` element
in the client, and start returning `<blink>` elements in the HXML responses from
your server. In fact, the Hyperview client library was built with this type of
extensibility in mind. There are extension points for custom UI elements and
custom behavior actions. We expect and encourage developers to use these
extensions to make HXML more expressive and customized to their app’s
functionality.

And by extending the HXML format and client itself, there’s no need for
Hyperview to include a scripting layer in HXML. Features that require
client-side logic get "built-in" to the client binary. HXML responses remain
pure, with UI and interactions represented in declarative XML.

==== Which Hypermedia Architecture Should You Use? <_which_hypermedia_architecture_should_you_use>
We’ve discussed two approaches for creating mobile apps using hypermedia
systems:
- create a backend that returns HTML, and serve it in a mobile app through a web
  view
- create a backend that returns HXML, and serve it in a mobile app with the
  Hyperview client

I purposefully described the two approaches in a way to highlight their
similarities. After all, they are both based on hypermedia systems, just with
different formats and clients. Both approaches solve the fundamental issues with
traditional, SPA-like mobile app development:
- The backend controls the full state of the app.
- Our app’s logic is all in one place.
- The app always runs the latest version, there’s no API churn to worry about.

So which approach should you use for a mobile HDA? Based on our experience
building both types of apps, we believe the Hyperview approach results in a
better user experience. The web-view will always feel out-of-place on iOS and
Android; there’s just no good way to replicate the patterns of navigation and
interaction that mobile users expect. Hyperview was created specifically to
address the limitations of thick-client and web view approaches. After the
initial investment to learn Hyperview, you’ll get all of the benefits of the
Hypermedia architecture, without the downsides of a degraded user experience.

Of course, if you already have a simple, mobile-friendly web app, then using a
web-view approach is sensible. You will certainly save time from not having to
serve your app as HXML in addition to HTML. But as we will show at the end of
this chapter, it doesn’t take a lot of work to convert an existing
Hypermedia-driven web app into a Hyperview mobile app. But before we get there,
we need to introduce the concepts of elements and behaviors in Hyperview. Then,
we’ll re-build our contacts app in Hyperview.

#sidebar[When Shouldn't You Use Hypermedia to Build a Mobile App?][ Hypermedia is not always the right choice to build a mobile app. Just like on
  the web, apps that require highly dynamic UIs (such as a spreadsheet
  application) are better implemented with client-side code. Additionally, some
  apps need to function while fully offline. Since HDAs require a server to render
  UI, offline-first mobile apps are not a good fit for this architecture. However,
  just like on the web, developers can use a hybrid approach to build their mobile
  app. The highly dynamic screens can be built with complex client-side logic,
  while the less dynamic screens can be built with web views or Hyperview. In this
  way, developers can spend their _complexity budget_ on the core of the
  application, and keep the simple screens simple. ]

=== Introduction to HXML

==== Hello World!

#index[HXML][Hello World!]
HXML was designed to feel natural to web developers coming from HTML. Let’s take
a closer look at the "Hello World" app defined in HXML:

#figure(caption: [Hello World, revisited])[ ```xml
<doc xmlns="https://hyperview.org/hyperview"> <1>
  <screen> <2>
    <styles />
    <body> <3>
      <header> <4>
        <text>My first app</text>
      </header>
      <view> <5>
        <text>Hello World!</text> <6>
      </view>
    </body>
  </screen>
</doc>
``` ]
1. The root element of the HXML app
2. The element representing a screen of the app
3. The element representing the UI of the screen
4. The element representing the top header of the screen
5. A wrapper element around the content shown on the screen
6. The text content shown on the screen

Nothing too strange here, right? Just like HTML, the syntax defines a tree of
elements using start tags (`<screen>`) and end tags (`</screen>`). Elements can
contain other elements (`<view>`) or text (`Hello World!`). Elements can also be
empty, represented with an empty tag (`<styles />`). However, you’ll notice that
the names of the HXML element are different from those in HTML. Let’s take a
closer look at each of those elements to understand what they do.

#index[HXML][\<doc\>]
`<doc>` is the root of the HXML app. Think of it as equivalent to the
`<html>` element in HTML. Note that the `<doc>` element contains an attribute `xmlns="https://hyperview.org/hyperview"`.
This defines the default namespace for the doc. Namespaces are a feature of XML
that allow one doc to contain elements defined by different developers. To
prevent conflicts when two developers use the same name for their element, each
developer defines a unique namespace. We will talk more about namespaces when we
discuss custom elements & behaviors later in this chapter. For now, it’s enough
to know that elements in a HXML doc without an explicit namespace are considered
to be part of the
`https://hyperview.org/hyperview` namespace.

#index[HXML][\<screen\>]
`<screen>` represents the UI that gets rendered on a single screen of a mobile
app. It’s possible for one `<doc>` to contain multiple `<screen>`
elements, but we won’t get into that now. Typically, a `<screen>`
element will contain elements that define the content and styling of the screen.

#index[HXML][\<styles\>]
`<styles>` defines the styles of the UI on the screen. We won’t get too much
into styling in Hyperview in this chapter. Suffice it to say, unlike HTML,
Hyperview does not use a separate language (CSS) to define styles. Instead,
styling rules such as colors, spacing, layout, and fonts are defined in HXML.
These rules are then explicitly referenced by UI elements, much like using
classes in CSS.

#index[HXML][\<body\>]
`<body>` defines the actual UI of the screen. The body includes all text,
images, buttons, forms, etc that will be shown to the user. This is equivalent
to the `<body>` element in HTML.

#index[HXML][\<header\>]
`<header>` defines the header of the screen. Typically in mobile apps, the
header includes some navigation (like a back button), and the title of the
screen. It’s useful to define the header separately from the rest of the body.
Some mobile OSes will use a different transition for the header than the rest of
the screen content.

#index[HXML][\<view\>]
`<view>` is the basic building block for layouts and structure within the
screen’s body. Think of it like a `<div>` in HTML. Note that unlike in HTML, a `<div>` cannot
directly contain text.

#index[HXML][\<text\>]
`<text>` elements are the only way to render text in the UI. In this example, "Hello
World" is contained within a `<text>` element.

That’s all there is to define a basic "Hello World" app in HXML. Of course, this
isn’t very exciting. Let’s cover some other built-in display elements.

==== UI Elements

===== Lists

#index[HXML][\<list\>]
#index[HXML][\<item\>]
A very common pattern in mobile apps is to scroll through a list of items. The
physical properties of a phone screen (long & vertical) and the intuitive
gesture of swiping a thumb up & down makes this a good choice for many screens.

HXML has dedicated elements for representing lists and items.

#figure(caption: [List element])[ ```xml
<list> <1>
  <item key="item1"> <2>
    <text>My first item</text> <3>
  </item>
  <item key="item2">
    <text>My second item</text>
  </item>
</list>
``` ]
1. Element representing a list
2. Element representing an item in the list, with a unique key
3. The content of the item in the list.

Lists are represented with two new elements. The `<list>` wraps all of the items
in the list. It can be styled like a generic `<view>` (width, height, etc). A `<list>` element
only contains `<item>` elements. Of course, these represent each unique item in
the list. Note that `<item>`
is required to have a `key` attribute, which is unique among all items in the
list.

You might be asking, "Why do we need a custom syntax for lists of items? Can’t
we just use a bunch of `<view>` elements?". Yes, for lists with a small number
of items, using nested `<views>` will work quite well. However, often the number
of items in a list can be long enough to require optimizations to support smooth
scrolling interactions. Consider browsing a feed of posts in a social media app.
As you keep scrolling through the feed, it’s not unusual for the app to show
hundreds if not thousands of posts. At any time, you can flick your finger to
scroll to almost any part of the feed. Mobile devices tend to be
memory-constrained. Keeping the fully-rendered list of items in memory could
consume more resources than available. That’s why both iOS and Android provide
APIs for optimized list UIs. These APIs know which part of the list is currently
on-screen. To save memory, they clear out the non-visible list items, and
recycle the item UI objects to conserve memory. By using explicit `<list>` and `<item>` elements
in HXML, the Hyperview client knows to use these optimized list APIs to make
your app more performant.

#index[HXML][\<section\>]
#index[HXML][\<section-list\>]
#index[HXML][\<section-title\>]
It’s also worth mentioning that HXML supports section lists. Section lists are
useful for building list-based UIs, where the items in the list can be grouped
for the user’s convenience. For example, a UI showing a restaurant menu could
group the offerings by dish type:

#figure(caption: [Section list element])[ ```xml
<section-list> <1>
  <section> <2>
    <section-title> <3>
      <text>Appetizers</text>
    </section-title>
    <item key="1"> <4>
      <text>French Fries</text>
    </item>
    <item key="2">
      <text>Onion Rings</text>
    </item>
  </section>

  <section> <5>
    <section-title>
      <text>Entrees</text>
    </section-title>
    <item key="3">
      <text>Burger</text>
    </item>
  </section>
</section-list>
``` ]
1. Element representing a list with sections
2. The first section of appetizer offerings
3. Element for the title of the section, rendering the text "Appetizers"
4. An item representing an appetizer
5. A section for entree offerings

You’ll notice a couple of differences between `<list>` and
`<section-list>`. The section list element only contains `<section>`
elements, representing a group of items. A section can contain a
`<section-title>` element. This is used to render some UI that acts as the
header of the section. This header is "sticky", meaning it stays on screen while
scrolling through items that belong to the corresponding section. Finally, `<item>` elements
act the same as in the regular list, but can only appear within a `<section>`.

===== Images

#index[HXML][\<image\>]
#index[Hyperview][images]
Showing images in Hyperview is pretty similar to HTML, but there are a few
differences.

#figure(caption: [Image element])[ ```xml
<image source="/profiles/1.jpg" style="avatar" />
``` ]

The `source` attribute specifies how to load the image. Like in HTML, the source
can be an absolute or relative URL. Additionally, the source can be an encoded
data URI, for example `data:image/png;base64,iVBORw`. However, the source can
also be a "local" URL, referring to an image that is bundled as an asset in the
mobile app. The local URL is prefixed with `./`:

#figure(caption: [Image element, pointing to local source])[ ```xml
<image source="./logo.png" style="logo" />
``` ]

Using Local URLs is an optimization. Since the images are on the mobile device,
they don’t require a network request and will appear quickly. However, bundling
the image with the mobile app binary increases the binary size. Using local
images is a good trade-off for images that are frequently accessed but rarely
change. Good examples include the app logo, or common button icons.

The other thing to note is the presence of the `style` attribute on the
`<image>` element. In HXML, images are required to have a style that has rules
for the image’s `width` and `height`. This is different from HTML, where `<img>` elements
do not need to explicitly set a width and height. web browsers will re-flow the
content of a web page once the image is fetched and the dimensions are known.
While re-flowing content is a reasonable behavior for web-based documents, users
do not expect mobile apps to re-flow as content loads. To maintain a static
layout, HXML requires the dimensions to be known before the image loads.

==== Inputs

#index[Hyperview][inputs]
There’s a lot to cover about inputs in Hyperview. Since this is meant to be an
introduction and not an exhaustive resource, I’ll highlight just a few types of
inputs. Let’s start with an example of the simplest type of input, a text field.

#figure(caption: [Text field element])[ ```xml
<text-field
  name="first_name" <1>
  style="input" <2>
  value="Adam" <3>
  placeholder="First name" <4>
/>
``` ]
1. The name used when serializing data from this input
2. The style class applied to the UI element
3. The current value set in the field
4. A placeholder to display when the value is empty

#index[HXML][\<text-field\>]
This element should feel familiar to anyone who’s created a text field in HTML.
One difference is that most inputs in HTML use the `<input>`
element with a `type` attribute, eg `<input type="text">`. In Hyperview, each
input has a unique name, in this case `<text-field>`. By using different names,
we can use more expressive XML to represent the input.

For example, let’s consider a case where we want to render a UI that lets the
user select one among several options. In HTML, we would use a radio button
input, something like
`<input type="radio" name="choice" value="option1" />`. Each choice is
represented as a unique input element. This never struck me as ideal. Most of
the time, radio buttons are grouped together to affect the same name. The HTML
approach leads to a lot of boilerplate (duplication of
`type="radio"` and `name="choice"` for each choice). Also, unlike radio buttons
on desktop, mobile OSes don’t provide a strong standard UI for selecting one
option. Most mobile apps use richer, custom UIs for these interactions. So in
HXML, we implement this UI using an element called
`<select-single>`:

#figure(caption: [Select-single element])[ ```xml
<select-single name="choice"> <1>
  <option value="option1"> <2>
    <text>Option 1</text> <3>
  </option>
  <option value="option2">
    <text>Option 2</text>
  </option>
</select-single>
``` ]
1. Element representing an input where a single choice is selected. The name of the
  selection is defined once here.
2. Element representing one of the choices. The choice value is defined here.
3. The UI of the selection. In this example, we use text, but we can use any UI
  elements.

#index[HXML][\<select-single\>]
The `<select-single>` element is the parent of the input for selecting one
choice out of many. This element contains the `name` attribute used when
serializing the selected choice. `<option>` elements within
`<select-single>` represent the available choices. Note that each
`<option>` element has a `value` attribute. When pressed, this will be the
selected value of the input. The `<option>` element can contain any other UI
elements within it. This means that we’re not hampered by rendering the input as
a list of radio buttons with labels. We can render the options as radios, tags,
images, or anything else that would be intuitive for our interface. HXML styling
supports modifiers for pressed and selected states, letting us customize the UI
to highlight the selected option.

Describing all features of inputs in HXML would take an entire chapter. Instead,
I’ll summarize a few other input elements and their features.

#index[HXML][\<select-multiple\>]
#index[HXML][\<switch\>]
#index[HXML][\<date-field\>]- `<select-multiple>` works like `<select-single>`,
but it supports toggling multiple options on & off. This replaces checkbox
inputs in HTML. - The `<switch>` element renders an on/off switch that is common
in mobile UIs - The `<date-field>` element supports entering in specific dates,
and comes with a wide range of customizations for formatting, settings ranges,
etc.

#index[HXML][\<form\>]
#index[HXML][custom elements]
Two more things to mention about inputs. First is the `<form>` element. The `<form>` element
is used to group together inputs for serialization. When a user takes an action
that triggers a backend request, the Hyperview client will serialize all inputs
in the surrounding `<form>`
and include them in the request. This is true for both `GET` and `POST`
requests. We will cover this in more detail when talking about behaviors later
in this chapter. Also later in this chapter, I’ll talk about support for custom
elements in HXML. With custom elements, you can also create your own input
elements. Custom input elements allow you to build incredible powerful
interactions with simple XML syntax that integrates well with the rest of HXML.

==== Styling

#index[HXML][styling]
So far, we haven’t mentioned how to apply styling to all of the HXML elements.
We’ve seen from the Hello World app that each `<screen>` can contain a `<styles>` element.
Let’s re-visit the Hello World app and fill out the `<styles>` element.

#figure(
  caption: [UI styling example],
)[ ```xml
<doc xmlns="https://hyperview.org/hyperview">
  <screen>
    <styles> <1>
      <style class="body" flex="1" flexDirection="column" /> <2>
      <style class="header"
        borderBottomWidth="1" borderBottomColor="#ccc" />
      <style class="main" margin="24" />
      <style class="h1" fontSize="32" />
      <style class="info" color="blue" />
    </styles>

    <body style="body"> <3>
      <header style="header">
        <text style="info">My first app</text>
      </header>
      <view style="main">
        <text style="h1 info">Hello World!</text> <4>
      </view>
    </body>
  </screen>
</doc>
``` ]
1. Element encapsulating all of the styling for the screen
2. Example of a definition of a style class for "body"
3. Applying the "body" style class to a UI element
4. Example of applying multiple style classes (h1 and info) to an element

You’ll note that in HXML, styling is part of the XML format, rather than using a
separate language like CSS. However, we can draw some parallels between CSS
rules and the `<style>` element. A CSS rule consists of a selector and
declarations. In the current version of HXML, the only available selector is a
class name, indicated by the `class` attribute. The rest of the attributes on
the `<style>` element are declarations, consisting of properties and property
values.

UI elements within the `<screen>` can reference the `<style>` rules by adding
the class names to their `<style>` property. Note the `<text>`
element around "Hello World!" references two style classes: `h1` and
`info`. The styles from the corresponding classes are merged together in the
order they appear on the element. It’s worth noting that styling properties are
similar to those in CSS (color, margins/padding, borders, etc). Currently, the
only available layout engine is based on flexbox.

Style rules can get quite verbose. For the sake of brevity, we won’t include the `<styles>` element
in the rest of the examples in this chapter unless necessary.

==== Custom elements

#index[HXML][custom elements]
The core UI elements that ship with Hyperview are quite basic. Most mobile apps
require richer elements to deliver a great user experience. Luckily, HXML can
easily accommodate custom elements in its syntax. This is because HXML is really
just XML, aka "Extensible Markup Language". Extensibility is already built into
the format! Developers are free to define new elements and attributes to
represent custom elements.

Let’s see this in action with a concrete example. Assume that we want to add a
map element to our Hello World app. We want the map to display a defined area,
and one or more markers at specific coordinates in that area. Let’s translate
these requirements into XML:
- An `<area>` element will represent the area displayed by the map. To specify the
  area, the element will include attributes for `latitude`
  and `longitude` for the center of the area, and a `latitude-delta` and
  `longitude-delta` indicating the +/- display area around the center.
- A `<marker>` element will represent a marker in the area. The coordinates of the
  marker will be defined by `latitude` and
  `longitude` attributes on the marker.

Using these custom XML elements, an instance of the map in our app might look
like this:

#figure(
  caption: [Custom elements in HXML],
)[ ```xml
<doc xmlns="https://hyperview.org/hyperview">
  <screen>
    <body>
      <view>
        <text>Hello World!</text>
        <area latitude="37.8270" longitude="122.4230"
          latitude-delta="0.1" longitude-delta="0.1"> <1>
          <marker latitude="37.8118" longitude="-122.4177" /> <2>
        </area>
      </view>
    </body>
  </screen>
</doc>
``` ]
1. Custom element representing the area rendered by the map
2. Custom element representing a marker rendered at specific coordinates on the map

The syntax feels right at home among the core HXML elements. However, there’s a
potential problem. "area" and "marker" are pretty generic names. I could see `<area>` and `<marker>` elements
being used by a customization to render charts & graphs. If our app renders both
maps and charts, the HXML markup would be ambiguous. What should the client
render when it sees `<area>` or `<marker>`?

#index[Hyperview][XML namespaces]
This is where XML namespaces come in. XML namespaces eliminate ambiguity and
collisions between elements and attributes used to represent different things.
Remember that the `<doc>` element declares that
`https://hyperview.org/hyperview` is the default namespace for the entire
document. Since no other elements define namespaces, every element in the
example above is part of the
`https://hyperview.org/hyperview` namespace.

Let’s define a new namespace for our map elements. Since this namespace will not
be the default for the document, we also need to assign the namespace to a
prefix we will add to our elements:

#figure[```xml
<doc xmlns="https://hyperview.org/hyperview"
  xmlns:map="https://mycompany.com/hyperview-map">
```]

This new attribute declares that the `map:` prefix is associated with the
namespace "https:\/\/mycompany.com/hyperview-map". This namespace could be
anything, but remember the goal is to use something unique that won’t have
collisions. Using your company/app domain is a good way to guarantee uniqueness.
Now that we have a namespace and prefix, we need to use it for our elements:

#figure(
  caption: [Namespacing the custom elements],
)[ ```xml
<doc xmlns="https://hyperview.org/hyperview"
  xmlns:map="https://mycompany.com/hyperview-map"> <1>
  <screen>
    <body>
      <view>
        <text>Hello World!</text>
        <map:area latitude="37.8270" longitude="122.4230"
          latitude-delta="0.1" longitude=delta="0.1"> <2>
          <map:marker latitude="37.8118" longitude="-122.4177" /> <3>
        </map:area> <4>
      </view>
    </body>
  </screen>
</doc>
``` ]
1. Definition of namespace aliased to "map"
2. Adding the namespace to the "area" start tag
3. Adding the namespace to the "marker" self-closing tag
4. Adding the namespace to the "area" end tag

That’s it! If we introduced a custom charting library with "area" and
"marker" elements, we would create a unique namespace for those elements as
well. Within the HXML doc, we could easily disambiguate `<map:area>`
from `<chart:area>`.

At this point you might be wondering, "how does the Hyperview client know to
render a map when my doc includes \<map:area\>?" It’s true, so far we only
defined the custom element format, but we haven’t implemented the element as a
feature in our app. We will get into the details of implementing custom elements
in the next chapter.

==== Behaviors <_behaviors>

As discussed in earlier chapters, HTML supports two basic types of interactions:
- Clicking a hyperlink: the client will make a GET request and render the response
  as a new web page.
- Submitting a form: the client will (typically) make a POST request with the
  serialized content of the form, and render the response as a new web page.

Clicking hyperlinks and submitting forms is enough to build simple web
applications. But relying on just these two interactions limits our ability to
build richer UIs. What if we want something to happen when the user mouses over
a certain element, or perhaps when they scroll some content into the viewport?
We can’t do that with basic HTML. Additionally, both clicks and form submits
result in loading a full new web page. What if we only want to update a small
part of the current page? This is a very common scenario in rich web
applications, where users expect to fetch and update content without navigating
to a new page.

So with basic HTML, interactions (clicks and submits) are limited and tightly
coupled to a single action (loading a new page). Of course, using JavaScript, we
can extend HTML and add some new syntax to support our desired interactions.
Htmx does exactly that with a new set of attributes:
- Interactions can be added to any element, not just links and forms.
- The interaction can be triggered via a click, submit, mouseover, or any other
  JavaScript event.
- The actions resulting from the trigger can modify the current page, not just
  request a new page.

By decoupling elements, triggers, and actions, htmx allows us to build rich
Hypermedia-driven applications in a way that feels very compatible with HTML
syntax and server-side web development.

#index[HXML][behaviors]
HXML takes the idea of defining interactions via triggers & actions and builds
them into the spec. We call these interactions "behaviors." We use a special `<behavior>` element
to define them. Here’s an example of a simple behavior that pushes a new mobile
screen onto the navigation stack:

#figure(caption: [Basic behavior])[ ```xml
<text>
  <behavior <1>
    trigger="press" <2>
    action="push" <3>
    href="/next-screen" <4>
  />
  Press me!
</text>
``` ]
1. The element encapsulating an interaction on the parent `<text>`
  element.
2. The trigger that will execute the interaction, in this case pressing the `<text>` element.
3. The action that will execute when triggered, in this case pushing a new screen
  onto the current stack.
4. The href to load on the new screen.

Let’s break down what’s happening in this example. First, we have a
`<text>` element with the content "Press me!". We’ve shown `<text>`
elements before in examples of HXML, so this is nothing new. But now, the `<text>` element
contains a new child element, `<behavior>`. This
`<behavior>` element defines an interaction on the parent `<text>`
element. It contains two attributes that are required for any behavior:
- `trigger`: defines the user action that triggers the behavior
- `action`: defines what happens when triggered

In this example, the `trigger` is set to `press`, meaning this interaction will
happen when the user presses the `<text>` element. The
`action` attribute is set to `push`. `push` is an action that will push a new
screen onto the navigation stack. Finally, Hyperview needs to know what content
to load on the newly pushed screen. This is where the
`href` attribute comes in. Notice we don’t need to define the full URL. Much
like in HTML, the `href` can be an absolute or relative URL.

So that’s a first example of behaviors in HXML. You may be thinking this syntax
seems quite verbose. Indeed, pressing elements to navigate to a new screen is
one of the most common interactions in a mobile app. It would be nice to have a
simpler syntax for the common case. Luckily,
`trigger` and `action` attributes have default values of `press` and
`push`, respectively. Therefore, they can be omitted to clean up the syntax:

#figure(caption: [Basic behavior with defaults])[ ```xml
<text>
  <behavior href="/next-screen" /> <1>
  Press me!
</text>
``` ]

1. When pressed, this behavior will open a new screen with the given URL.

This markup for the `<behavior>` will produce the same interaction as the
earlier example. With the default attributes, the `<behavior>`
element looks similar to an anchor `<a>` in HTML. But the full syntax achieves
our goals of decoupling elements, triggers, and actions:
- Behaviors can be added to any element, they are not limited to links and forms.
- Behaviors can specify an explicit `trigger`, not just clicks or form submits.
- Behaviors can specify an explicit `action`, not just a request for a new page.
- Extra attributes like `href` provide more context for the action.

Additionally, using a dedicated `<behavior>` element means a single element can
define multiple behaviors. This lets us execute several actions from the same
trigger. Or, we can execute different actions for different triggers on the same
element. We will show examples of the power of multiple behaviors at the end of
this chapter. First we need to show the variety of supported actions and
triggers.

===== Actions

#index[HXML][behavior actions]
Behavior actions in Hyperview fall into four general categories:
- Navigation actions, which load new screens and move between them
- Update actions, which modify the HXML of the current screen
- System actions, which interact with OS-level capabilities.
- Custom actions, which can execute any code you add to the client.

====== Navigation actions

#index[HXML][navigation actions]
We’ve already seen the simplest type of action, `push`. We classify
`push` as a "navigation action", since it’s related to navigating screens in the
mobile app. Pushing a screen onto the navigation stack is just one of several
navigation actions supported in Hyperview. Users also need to be able to go back
to previous screens, open and close modals, switch between tabs, or jump to
arbitrary screens. Each of these types of navigation is supported through a
different value for the
`action` attribute:
- `push`: Push a new screen into the current navigation stack. This looks like a
  screen sliding in from the right, on top of the current screen.
- `new`: Open a new navigation stack as a modal. This looks like a screen sliding
  in from the bottom, on top of the current screen.
- `back`: This is a complement to the `push` action. It pops the current screen
  off of the navigation stack (sliding it to the right).
- `close`: This is a complement to the `new` action. It closes the current
  navigation stack (sliding it down).
- `reload`: Similar to a browser’s "refresh" button, this will re-request the
  content of the current screen.
- `navigate`: This action will attempt to find a screen with the given
  `href` already loaded in the app. If the screen exists, the app will jump to
  that screen. If it doesn’t exist, it will act the same as
  `push`.

`push`, `new`, and `navigate` all load a new screen. Thus, they require an `href` attribute
so that Hyperview knows what content to request for the new screen. `back` and `close` do
not load new screens, and thus do not require the `href` attribute. `reload` is
an interesting case. By default, it will use the URL of the screen when
re-requesting the content for the screen. However, if you want to replace the
screen with a different one, you can provide an `href` attribute with `reload` on
the behavior element.

Let’s look at an example "widgets" app that uses several navigation actions on
one screen:

#figure(caption: [Navigation action examples])[ ```xml
<screen>
  <body>
    <header>
      <text>
        <behavior action="back" /> <1>
        Back
      </text>

      <text>
        <behavior action="new" href="/widgets/new" /> <2>
        New Widget
      </text>
    </header>
    <text>
      <behavior action="reload" /> <3>
      Check for new widgets
    </text>
    <list>
      <item key="widget1">
        <behavior action="push" href="/widgets/1" /> <4>
      </item>
    </list>
  </body>
</screen>
``` ]
1. Takes the user to the previous screen
2. Opens a new modal to add a widget
3. Reloads the content of the screen, showing new widgets from the backend
4. Pushes a new screen with details for a specific widget

Most screens in your app will need a way for the user to backtrack to the
previous screen. This is usually done with a button in the header that uses
either a "back" or "close" action, depending on how the screen was opened. In
this example, we’re assuming the widgets screen was pushed onto the navigation
stack, so the "back" action is appropriate. The header contains a second button
that allows the user to enter data for a new widget. Pressing this button will
open a modal with a "New Widget" screen. Since this "New Widget" screen will
open as a modal, it will need a corresponding "close" action to dismiss itself
and show our
"widgets" screen again. Finally, to see more details about a specific widget,
each `<item>` element contains a behavior with a "push" action. This action will
push a "Widget Detail" screen onto the current navigation stack. Like in the "Widgets"
screen, "Widget Detail" will need a button in the header that uses the "back"
action to let the user backtrack.

On the web, the browser handles basic navigation needs such as going
back/forward, reloading the current page, or jumping to a bookmark. iOS and
Android don’t provide this sort of universal navigation for native mobile apps.
It’s on the app developers to handle this themselves. Navigation actions in HXML
provide an easy but powerful way for developers to build an architecture that
makes sense for their app.

====== Update actions

#index[HXML][update actions]
Behavior actions are not just limited to navigating between screens. They can
also be used to change the content on the current screen. We call these "update
actions". Much like navigation actions, update actions make a request to the
backend. However, the response is not an entire HXML document, but a fragment of
HXML. This fragment is added to the HXML of the current screen, resulting in an
update to the UI. The
`action` attribute of the `<behavior>` determines how the fragment gets
incorporated into the HXML. We also need to introduce a new `target`
attribute on `<behavior>` to define where the fragment gets incorporated in the
existing doc. The `target` attribute is an ID reference to an existing element
on the screen.

Hyperview currently supports these update actions, representing different ways
to incorporate the fragment into the screen:
- `replace`: replaces the entire target element with the fragment
- `replace-inner`: replaces the children of the target element with the fragment
- `append`: adds the fragment after the last child of the target element
- `prepend`: adds the fragment before the first child of the target element.

Let’s look at some examples to make this more concrete. For these examples,
let’s assume our backend accepts `GET` requests to
`/fragment`, and the response is a fragment of HXML that looks like
`<text>My fragment</text>`.

#figure(
  caption: [Update action examples],
)[ ```xml
<screen>
  <body>
    <text>
      <behavior action="replace" href="/fragment" target="area1" /> <1>
      Replace
    </text>
    <view id="area1">
      <text>Existing content</text>
    </view>

    <text>
      <behavior action="replace-inner"
        href="/fragment" target="area2" /> <2>
      Replace-inner
    </text>
    <view id="area2">
      <text>Existing content</text>
    </view>

    <text>
      <behavior action="append" href="/fragment" target="area3" /> <3>
      Append
    </text>
    <view id="area3">
      <text>Existing content</text>
    </view>

    <text>
      <behavior action="prepend" href="/fragment" target="area4" /> <4>
      Prepend
    </text>
    <view id="area4">
      <text>Existing content</text>
    </view>

  </body>
</screen>
``` ]
1. Replaces the area1 element with fetched fragment
2. Replaces the child elements of area2 with fetched fragment
3. Appends the fetched fragment to area3
4. Prepends the fetched fragment to area4

In this example, we have a screen with four buttons corresponding to the four
update actions: `replace`, `replace-inner`, `append`, `prepend`. Below each
button, there’s a corresponding `<view>` containing some text. Note that the `id` of
each view matches the `target` on the behaviors of the corresponding button.

When the user presses the first button, the Hyperview client makes a request for `/fragment`.
Next, it looks for the target, ie the element with id "area1". Finally, it
replaces the `<view id="area1">` element with the fetched fragment, `<text>My fragment</text>`.
The existing view and text contained in that view will be replaced. To the user,
it will look like "Existing content" was changed to "My fragment". In the HXML,
the element `<view id="area1">` will also be gone.

The second button behaves in a similar way to the first one. However, the `replace-inner` action
does not remove the target element from the screen, it only replaces the
children. This means the resulting markup will look like `<view id="area2"><text>My fragment</text></view>`.

The third and fourth buttons do not remove any content from the screen. Instead,
the fragment will be added either after (in the case of
`append`) or before (`prepend`) the children of the target element.

For completeness, let’s look at the state of the screen after a user presses all
four buttons:

#figure(
  caption: [Update actions, after pressing buttons],
)[ ```xml
<screen>
  <body>
    <text>
      <behavior action="replace" href="/fragment" target="area1" /> <1>
      Replace
    </text>
    <text>My fragment</text>

    <text>
      <behavior action="replace-inner"
        href="/fragment" target="area2" /> <2>
      Replace-inner
    </text>
    <view id="area2">
      <text>My fragment</text>
    </view>

    <text>
      <behavior action="append" href="/fragment" target="area3" /> <3>
      Append
    </text>
    <view id="area3">
      <text>Existing content</text>
      <text>My fragment</text>
    </view>

    <text>
      <behavior action="prepend" href="/fragment" target="area4" /> <4>
      Prepend
    </text>
    <view id="area4">
      <text>My fragment</text>
      <text>Existing content</text>
    </view>

  </body>
</screen>
``` ]
1. Fragment completely replaced the target using `replace` action
2. Fragment replaced the children of the target using `replace-inner`
  action
3. Fragment added as last child of the target using `append` action
4. fragment added as the first child of the target using `prepend` action

The examples above show actions making `GET` requests to the backend. But these
actions can also make `POST` requests by setting `verb="post"`
on the `<behavior>` element. For both `GET` and `POST` requests, the data from
the parent `<form>` element will be serialized and included in the request. For `GET` requests,
the content will be URL-encoded and added as query params. For `POST` requests,
the content will be form-URL encoded and set on the request body. Since they
support `POST` and form data, update actions are often used to send data to the
backend.

So far, our example of update actions require getting new content from the
backend and adding it to the screen. But sometimes we just want to change the
state of existing elements. The most common state to change for an element is
its visibility. Hyperview has `hide`, `show`, and
`toggle` actions that do just that. Like the other update actions,
`hide`, `show`, and `toggle` use the `target` attribute to apply the action to
an element on the current screen.

#figure(caption: [Show, hide, and toggle actions])[ ```xml
<screen>
  <body>
    <text>
      <behavior action="hide" target="area" /> <1>
      Hide
    </text>

    <text>
      <behavior action="show" target="area" /> <2>
      Show
    </text>

    <text>
      <behavior action="toggle" target="area" /> <3>
      Toggle
    </text>

    <view id="area"> <4>
      <text>My fragment</text>
    </view>
  </body>
</screen>
``` ]
1. Hides the element with id "area".
2. Shows the element with id "area".
3. Toggles the visibility of the element with id "area".
4. The element targeted by the actions.

In this example, the three buttons labeled "Hide", "Show", and "Toggle" will
modify the display state of the `<view>` with ID "area". Pressing
"Hide" multiple times will have no affect once the view is hidden. Likewise,
pressing "Show" multiple times will have no affect once the view is showing.
Pressing "Toggle" will keep flipping the visibility status of the element
between showing and hidden.

Hyperview comes with other actions that modify the existing HXML. We won’t cover
them in detail, but I’ll mention them briefly here:
- `set-value`: this action can set the value of an input element such as
  `<text-field>`, `<switch>`, `<select-single>`, etc.
- `select-all` and `unselect-all` work with the `<select-multiple>`
  element to select/deselect all options.

====== System actions

#index[Hyperview][system actions]
Some standard Hyperview actions don’t interact with the HXML at all. Instead,
they expose functionality provided by the mobile OS. For example, both Android
and iOS support a system-level "Share" UI. This UI allows sharing URLs and
messages from one app to another app. Hyperview has a `share` action to support
this interaction. It involves a custom namespace, and share-specific attributes.

#figure(caption: [System share action])[ ```xml
<behavior
  xmlns:share="https://instawork.com/hyperview-share" <1>
  trigger="press"
  action="share" <2>
  share:url="https://www.instawork.com" <3>
  share:message="Check out this website!" <4>
/>
``` ]
1. Defines the namespace for the share action.
2. The action of this behavior will bring up the share sheet.
3. URL to be shared.
4. Message to be shared.

We’ve seen XML namespaces when talking about custom elements. Here, we are using
a namespace for the `url` and `message` attributes on the
`<behavior>`. These attribute names are generic and likely used by other
components and behaviors, so the namespace ensures there will be no ambiguity.
When pressed, the "share" action will trigger. The values of the `url` and `message` attributes
will be passed to the system Share UI. From there, the user will be able to
share the URL & message via SMS, email, or other communication apps.

The `share` action shows how a behavior action can use custom attributes to pass
along extra data needed for the interactions. But some actions require even more
structured data. This can be provided via child elements on the `<behavior>`.
Hyperview uses this to implement the
`alert` action. The `alert` action shows a customized system-level dialog box.
This dialog needs configuration for a title and message, but also for customized
buttons. Each button needs to then trigger another behavior when pressed. This
level of configuration cannot be done with just attributes, so we use custom
child elements to represent the behavior of each button.

#figure(
  caption: [System alert action],
)[ ```xml
<behavior
  xmlns:alert="https://hyperview.org/hyperview-alert" <1>
  trigger="press"
  action="alert" <2>
  alert:title="Continue to next screen?" <3>
  alert:message=
    "Are you sure you want to navigate to the next screen?" <4>
>
  <alert:option alert:label="Continue"> <5>
    <behavior action="push" href="/next" /> <6>
  </alert:option>
  <alert:option alert:label="Cancel" /> <7>
</behavior>
``` ]
1. Defines the namespace for the alert action.
2. The action of this behavior will bring up a system dialog box.
3. Title of the dialog box.
4. Content of the dialog box.
5. A "continue" option in the dialog box
6. When "continue" is pressed, push a new screen onto the navigation stack.
7. A "cancel" option that dismisses the dialog box.

Like the `share` behavior, `alert` uses a namespace to define some attributes
and elements. The `<behavior>` element itself contains the
`title` and `message` attributes for the dialog box. The button options for the
dialog are defined using a new `<option>` element nested in the
`<behavior>`. Notice that each `<option>` element has a label, and then
optionally contains a `<behavior>` itself! This structure of the HXML allows the
system dialog to trigger any interaction that can be defined as a `<behavior>`.
In the example above, pressing the "Continue" button will open a new screen. But
we could just as easily trigger an update action to change the current screen.
We could even open a share sheet, or a second dialog box. But please don’t do
that in a real app! With great power comes great responsibility.

====== Custom actions

#index[Hyperview][custom actions]
You can build a lot of mobile UIs with Hyperview’s standard navigation, update,
and system actions. But the standard set may not cover all interactions you will
need for your mobile app. Luckily, the action system is extensible. In the same
way you can add custom elements to Hyperview, you can also add custom behavior
actions. Custom actions have a similar syntax to the `share` and `alert` actions,
using namespaces for attributes that pass along extra data. Custom actions also
have full access to the HXML of the current screen, so they can modify the state
or add/remove elements from the current screen. In the next chapter, we will
create a custom behavior action to enhance our mobile contacts app.

===== Triggers

#index[Hyperview][triggers]
We’ve already seen the simplest type of trigger, a `press` on an element.
Hyperview supports many other common triggers used in mobile apps.

====== Long-press <_long_press>
Closely related to a press is a long-press. A behavior with
`trigger="longPress"` will trigger when the user presses and holds on the
element. "Long-press" interactions are often used for shortcuts and power
features. Sometimes, elements will support different actions for both a `press` and `longPress`.
This is done using multiple `<behavior>`
elements on the same UI element.

#figure(
  caption: [Long-press trigger example],
)[ ```xml
<text>
  <behavior trigger="press" action="push" href="/next-screen" /> <1>
  <behavior trigger="longPress" <2>
    action="push" href="/secret-screen" />
  Press (or long-press) me!
</text>
``` ]
1. Normal press will open the next screen.
2. Long press will open a different screen.

In this example, a normal press will open a new screen and request content from `/next-screen`.
However, a long press will open a new screen with content from `/secret-screen`.
This is a contrived example for the sake of brevity. A better UX would be for
the long-press to bring up a contextual menu of shortcuts and advanced options.
This could be achieved by using `action="alert"` and opening a system dialog box
with the shortcuts.

====== Load <_load>
Sometimes we want an action to trigger as soon as the screen loads.
`trigger="load"` does exactly this. One use case is to quickly load a shell of
the screen, and then fill in the main content on the screen with a second update
action.

#figure(
  caption: [Load trigger example],
)[ ```xml
<body>
  <view>
    <text>My app</text>
    <view id="container"> <1>
      <behavior trigger="load" action="replace" href="/content"
        target="container"> <2>
      <text>Loading...</text> <3>
    </view>
  </view>
</body>
``` ]
1. Container element without the actual content
2. Behavior that immediately fires off a request for /content to replace the
  container
3. Loading UI that appears until the content is fetched and replaced.

In this example, We load a screen with a heading ("My app") but no content.
Instead, we show a `<view>` with ID "container" and some
"Loading…​" text. As soon as this screen loads, the behavior with
`trigger=load` fires off the `replace` action. It requests content from the `/content` path
and replaces the container view with the response.

====== Visible <_visible>
Unlike `load`, the `visible` trigger will only execute the behavior when the
element with the behavior is scrolled into the viewport on the mobile device.
The `visible` action is commonly used to implement an infinite-scroll
interaction on a `<list>` of `<item>` elements. The last item in the list
includes a behavior with `trigger="visible"`. The
`append` action will fetch the next page of items and append them to the list.

====== Refresh <_refresh>
This trigger captures a "pull to refresh" action on `<list>` and
`<view>` items. This interaction is associated with fetching up-to-date content
from the backend. Thus, it’s typically paired with an update or reload action to
show the latest data on the screen.

#figure(caption: [Pull-to-refresh trigger example])[ ```xml
<body>
  <view scroll="true">
    <behavior trigger="refresh" action="reload" /> <1>
    <text>No items yet</text>
  </view>
</body>
``` ]
1. When the view is pulled down to refresh, reload the screen.

Note that adding a behavior with `trigger="refresh"` to a `<view>` or
`<list>` will add the pull-to-refresh interaction to the element, including
showing a spinner as the element is pulled down.

====== Focus, blur, and change <_focus_blur_and_change>
These triggers are related to interactions with input elements. Thus, they will
only trigger behaviors attached to elements like
`<text-field>`. `focus` and `blur` will trigger when the user focuses and blurs
the input element, respectively. `change` will trigger when the value of the
input element changes, like when the user types a letter in a text field. These
triggers are often used with behaviors that need to perform some server-side
validation on the form fields. For example, when the user types in a username
and then blurs the field, a behavior could trigger on `blur` to make a request
to the backend and check for uniqueness of the username. If the entered username
is not unique, the response could include an error message letting the user know
they need to pick a different username.

===== Using multiple behaviors

#index[HXML][multiple behaviors]
Most of the examples shown above attach a single `<behavior>` to an element. But
there’s no such limitation in Hyperview; elements can define multiple behaviors.
We already saw an example where a single element had different actions triggered
on `press` and `longPress`. But we can also trigger multiple actions on the same
trigger.

In this admittedly contrived example, we want to hide two elements on the screen
when pressing the "Hide" button. The two elements are far apart in the HXML, and
cannot be hidden by hiding a common ancestor element. But, we can trigger two
behaviors at the same time, each one executing a "hide" action but targeting
different elements.

#figure(caption: [Multiple behaviors triggering on press])[ ```xml
<screen>
  <body>
    <text id="area1">Area 1</text>

    <text>
      <behavior trigger="press" action="hide" target="area1" /> <1>
      <behavior trigger="press" action="hide" target="area2" /> <2>
      Hide
    </text>

    <text id="area2">Area 2</text>
  </body>
</screen>
``` ]
1. Hide element with ID "area1" when pressed.
2. Hide element with ID "area2" when pressed.

Hyperview processes behaviors in the order they appear in the markup. In this
case, the element with ID "area1" will be hidden first, followed by the element
with ID "area2". Since "hide" is an instantaneous action (ie, it doesn’t make an
HTTP request), both elements will appear to hide simultaneously. But what if we
triggered two actions that depend on responses from HTTP requests (like "replace-inner")?
In that case, each individual action is processed as soon as Hyperview receives
the HTTP response. Depending on network latency, the two actions could take
effect in any order, and they are not guaranteed to be applied simultaneously.

We’ve seen elements with multiple behaviors and different triggers. And we’ve
seen elements with multiple behaviors with the same trigger. These concepts can
be mixed together too. It’s not unusual for a production Hyperview app to
contain several behaviors, some triggering together and others triggering on
different interactions. Using multiple behaviors with custom actions keeps HXML
declarative, without sacrificing functionality.

==== Summary <_summary>
We’re covering a lot of new concepts here, and this introduction to HXML just
scratches the surface. To learn more about HXML, we recommend consulting the
#link(
  "https://hyperview.org/docs/reference_index",
)[official reference documentation]. For now, we hope you come away with a few
key takeaways.

First, HXML looks and feels similar to HTML. Web developers comfortable with
server-side rendering frameworks can use the same techniques to write HXML. In
addition to basic UI elements (`<view>`, `<text>`,
`<image>`), HXML specifies elements to implement mobile-specific UIs. This
includes layout patterns (`<screen>`, `<list>`, `<section-list>`) and input
elements (`<switch>`, `<select-single>`, `<select-multiple>`).

Second, interactions in HXML are defined using behaviors. Inspired by htmx, `<behavior>` elements
decouple user interactions (triggers) from the resulting actions. There are
three broad categories of behavior actions:
- Navigation actions (`push`, `back`) enable navigating between the screens of a
  mobile app
- Update actions (`replace`, `append`) enable updating a screen with new fragments
  of HXML requested from the server.
- System actions (`alert`, `share`) enable interacting with system-level
  functionality on iOS and Android.

Finally, HXML itself was designed for customization. Developers can define
custom elements and custom behavior actions to expand the possible user
interactions with their apps.

=== Hypermedia, for Mobile <_hypermedia_for_mobile>
There is a strong case for Hypermedia-Driven Applications on mobile. Mobile app
platforms push developers towards a thick-client architecture. But apps that use
a thick client suffer from the same problems as SPAs on the web. Using the
hypermedia architecture for mobile apps can solve these problems.

Hyperview, based on a new format called HXML, offers a path here. It provides an
open-source mobile thin client to render HXML. And HXML opens a toolkit of
elements and patterns that correspond to mobile UIs. Developers can evolve
Hyperview to suit their apps' requirements, while fully embracing the hypermedia
architecture. That’s a win.

Yes, hypermedia can work for mobile apps, too. In the next two chapters we’ll
show how by turning the Contact.app web application into a native mobile app
using Hyperview.

#html-note(
  label: [Hypermedia Notes],
)[Maximize Your Server-Side Strengths][
  In the Hyperview sections of the book, since we aren’t using HTML, we are going
  to make broader observations on hypermedia rather than offer HTML-specific
  advice and thoughts.

  A big advantage of the hypermedia-driven approach is that it makes the
  server-side environment far more important when building your web application.
  Rather than simply producing JSON, your back end is an integral component in the
  user experience of your hypermedia application.

  Because of this, it makes sense to look deeply into the functionality available
  there. Many older web frameworks, for example, have incredibly deep
  functionality available around producing HTML. Features like server-side caching
  can make the difference between an incredibly snappy web application and a
  sluggish user experience.

  Take time to learn all the tools available to you.

  A good rule of thumb is to shoot to have server responses in your
  hypermedia-driven application take less than 100ms to complete, and mature
  server-side frameworks have tools to help make this happen.

  Server-side environments often have extremely mature mechanisms for factoring
  (or organizing) your code properly. The Model/View/Controller pattern is
  well-developed in most environments, and tools like modules, packages, etc.
  provide an excellent way to organize your code.

  Whereas today’s SPA and mobile user interfaces are typically organized via
  components, hypermedia-driven applications are typically organized via template
  inclusion, where the server-side templates are broken up according to the
  hypermedia-rendering needs of the application, and then included in one another
  as needed. This tends to lead to fewer, chunkier files than you would find in a
  component-based application.

  Another technology to look for are Template Fragments, which allow you to render
  only part of a template file. This can reduce even further the number of
  template files required for your server-side application.

  A related tip is to take advantage of direct access to the data store. When an
  application is built using a thick client approach, the data store typically
  lives behind a data API (e.g. JSON). This level of indirection often prevents
  front end developers from being able to take full advantage of the tools
  available in the data store. GraphQL, for example, can help address this issue,
  but comes with security-related issues that do not appear to be well understood
  by many developers.

  When you produce your hypermedia on the server side, on the other hand, the
  developer creating that hypermedia can have full access to the data store and
  take advantage of, for example, joins and aggregation functions in SQL stores.

  This puts far more expressive power directly in the hands of the developer
  producing the final hypermedia. Because your hypermedia API can be structured
  around your UI needs, you can tune each endpoint to issue as few data store
  requests as possible.

  A good rule of thumb is that every request to your server should shoot to have
  three or fewer data-store accesses. If you follow this rule of thumb, your
  hypermedia-driven application should be extremely snappy.
]
