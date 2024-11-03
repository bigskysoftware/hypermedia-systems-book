#import "lib/definitions.typ": *

== 웹 1.0 애플리케이션

Hypermedia-Driven Applications의 여정을 시작하기 위해 단순한 연락처 관리 웹 애플리케이션인 Contact.app을 만들 것입니다. 기본적인 "웹 1.0 스타일" 다중 페이지 애플리케이션(MPA)에서 시작할 것이며, 간단한 CRUD(생성, 읽기, 업데이트, 삭제) 관행을 따릅니다. 이 애플리케이션이 세상에서 최고의 연락처 관리 애플리케이션은 아니겠지만, 간단하고 그 일을 잘 수행할 것입니다.

이 애플리케이션은 또한 향후 장들에서 hypermedia 중심 라이브러리인 htmx를 활용하여 점진적으로 개선하기 쉽습니다.

애플리케이션을 구축하고 향상시킬 때쯤, 다음 몇 장이 지나면 대부분의 개발자들이 오늘날에 SPA 자바스크립트 프레임워크 사용이 필요하다고 가정할 만한 매우 매끄러운 기능이 포함될 것입니다.

=== "웹 스택" 선택하기 <_picking_a_web_stack>
웹 1.0 애플리케이션이 어떻게 작동하는지를 시연하기 위해, 서버측 언어와 HTTP 요청을 처리하는 라이브러리를 선택해야 합니다. 일반적으로 이를 "서버측" 또는 "웹" 스택이라고 하며, 선택할 수 있는 옵션이 수백 가지에 달하며, 각 옵션마다 열광적인 사용자 기반이 있습니다. 아마도 선호하는 웹 프레임워크가 있을 것이고, 이 책을 가능한 모든 스택에 대해 작성할 수 있기를 바라지만, 단순함과 (정신적) 안전성을 위해 하나만 선택할 수 있습니다.

이 책에서는 다음 스택을 사용할 것입니다:
- #link("https://www.python.org/")[파이썬]을 프로그래밍 언어로 사용합니다.
- #link("https://palletsprojects.com/p/flask/")[Flask]를 웹 프레임워크로 사용하여 HTTP 요청을 파이썬 논리에 연결합니다.
- #link("https://palletsprojects.com/p/jinja/")[Jinja2]를 서버 측 템플릿 언어로 사용하여 익숙하고 직관적인 구문으로 HTML 응답을 렌더링합니다.

왜 이 특정 스택인가요?

현재 이 글을 쓰는 시점에서, 파이썬은 #link("https://www.tiobe.com/tiobe-index/")[TIOBE 지수]에 따르면 세계에서 가장 인기 있는 프로그래밍 언어입니다. 더 중요한 것은, 파이썬은 익숙하지 않아도 읽기 쉽다는 점입니다.

Flask 웹 프레임워크를 선택한 이유는 간단하고 HTTP 요청 처리의 기반 위에 많은 구조를 강요하지 않기 때문입니다.

이 기본적인 접근방식은 우리의 필요에 잘 맞습니다: 경우에 따라, Flask보다 상자 밖에서 더 많은 기능을 제공하는 #link("https://www.djangoproject.com/")[장고]와 같은 더 완전한 파이썬 프레임워크를 고려할 수 있습니다.

이 책에서는 Flask를 사용함으로써 _하이퍼미디어 교환_에 코드를 집중할 수 있습니다.

Jinja2 템플릿을 선택한 이유는 Flask의 기본 템플릿 언어이기 때문입니다. 매우 간단하고 대부분의 다른 서버 측 템플릿 언어와 비슷하여, 모든 서버 측(또는 클라이언트 측) 템플릿 라이브러리를 익숙하게 다룰 수 있는 대부분의 사람들이 빠르고 쉽게 이해할 수 있습니다.

비록 이러한 기술 조합이 선호하는 스택이 아닐지라도 계속 읽어 주십시오: 우리는 다음 장에서 소개할 패턴으로부터 상당한 것을 배울 수 있으며, 이를 선호하는 언어와 프레임워크에 매핑하는 것이 그리 어렵지 않을 것입니다.

이 스택을 사용하여 클라이언트에게 반환하기 위해 HTML을 _서버 측_에서 렌더링할 것입니다. 이는 JSON을 생성하는 대신 전통적인 웹 애플리케이션 구축 접근 방식입니다. 그러나 SPA의 부상으로 인해, 이 접근 방식은 한때만큼 널리 사용되는 기술이 아닙니다. 현재 사람들이 이러한 스타일의 웹 애플리케이션을 재발견하고 있는 만큼, "서버 측 렌더링" 또는 SSR이라는 용어가 나타나고 있습니다. 이는 브라우저에서 JSON 형식으로 데이터가 검색되는 템플릿을 렌더링하는 "클라이언트 측 렌더링"과 대조됩니다. 이는 SPA 라이브러리에서 흔히 사용됩니다.

Contact.app에서는 최대한 간단하게 유지하여 우리의 코드의 교육 가치를 극대화할 것입니다: 코드가 완벽하게 분리될 수는 없지만, Python 경험이 적은 독자도 쉽게 따라 할 수 있도록 이해하기 쉽게 만들 것입니다. 또한 애플리케이션과 시연된 기술을 선호하는 프로그래밍 환경으로 쉽게 번역할 수 있어야 합니다.

=== Python <_python>
이 책은 하이퍼미디어를 효과적으로 사용하는 방법을 배우기 위한 것이므로, 우리는 하이퍼미디어 주위에서 사용하는 다양한 기술을 간단히 소개하겠습니다. 이는 몇 가지 뚜렷한 단점이 있습니다: 예를 들어, 파이썬에 익숙하지 않다면 책의 일부 예제 코드가 처음에는 다소 혼란스럽거나 신비하게 느껴질 수 있습니다.

코드에 뛰어들기 전에 언어에 대한 간단한 소개가 필요하다고 느끼면 다음 책과 웹사이트를 추천합니다:
- #link("https://nostarch.com/python-crash-course-3rd-edition")[파이썬 크래시 코스] 저자: No Starch Press
- #link("https://learnpythonthehardway.org/python3/")[파이썬을 힘겹게 배우기] 저자: Zed Shaw
- #link("https://www.py4e.com/")[모두를 위한 파이썬] 저자: Dr. Charles R. Severance

우리는 대부분의 웹 개발자, 심지어 파이썬에 익숙하지 않은 개발자들도 우리의 예제를 따라 할 수 있을 것이라 생각합니다. 이 책의 저자들 중 대부분은 이 책을 쓰기 전에 파이썬을 많이 작성하지 않았지만, 우리는 꽤 빨리 익혔습니다.

=== Flask 소개: 첫 번째 경로 <_introducing_flask_our_first_route>

#index[Flask][about]
Flask는 파이썬을 위한 간단하지만 유연한 웹 프레임워크입니다. 그 핵심 요소에 대해 다루며 스며들어 가겠습니다.

#index[Flask][routes]
#index[Flask][handlers]
#index[Flask][decorators]
Flask 애플리케이션은 주어진 경로에 HTTP 요청이 발생할 때 실행되는 함수와 연결된 일련의 _경로_로 구성됩니다. 경로를 선언하기 위해 "장식자"라는 파이썬 기능을 사용하여 처리될 경로를 선언하고, 이어서 해당 경로에 대한 요청을 처리할 함수를 정의합니다. 우리는 경로에 관련된 함수들을 "핸들러"라고 부를 것입니다.

이제 우리의 첫 번째 경로 정의, 간단한 "안녕하세요 세계" 경로를 만들어 보겠습니다. 다음 파이썬 코드에서 `@app` 기호를 볼 수 있습니다. 이것은 우리의 경로를 설정할 수 있게 해주는 Flask 장식자입니다. 파이썬에서 장식자가 어떻게 작동하는지를 너무 걱정하지 마십시오. 이 기능은 주어진 _경로_를 특정 함수(즉, 핸들러)에 매핑하도록 해줍니다. Flask 애플리케이션이 시작되면 HTTP요청을 가져와서 매칭되는 핸들러를 조회하고 그것을 호출합니다.

#figure(caption: [A simple "Hello World" route],
```python
@app.route("/") <1>
def index(): <2>
    return "Hello World!" <3>
```)

1. `/` 경로가 경로로 매핑되는 것을 설정합니다.
2. 다음 메서드는 해당 경로에 대한 핸들러입니다.
3. 클라이언트에게 문자열 "Hello World!"를 반환합니다.

Flask 어노테이션의 `route()` 메서드는 하나의 인자를 받습니다: 이 경로가 처리하길 원하는 경로입니다. 여기서는 루트 또는 `/` 경로를 문자열로 전달하여 루트 경로에 대한 요청을 처리하도록 합니다.

이 경로 선언 뒤에 간단한 함수 정의인 `index()`가 옵니다. 파이썬에서는 이처럼 호출된 장식자가 그 다음에 오는 함수에 적용됩니다. 따라서 이 함수는 해당 경로에 대한 "핸들러"가 되며, 특정 경로에 대한 HTTP 요청이 발생할 때 실행됩니다.

함수의 이름은 중요하지 않으며, 고유한 이름이라면 무엇이든지 사용할 수 있습니다. 여기서는 우리가 처리하고 있는 경로와 잘 맞기 때문에 `index()`를 선택했습니다: 웹 애플리케이션의 루트 "인덱스"입니다.

따라서 우리는 루트에 대한 경로 정의 바로 뒤에 오는 `index()` 함수가 있으며, 이 함수는 우리의 웹 애플리케이션에서 루트 URL에 대한 핸들러가 됩니다.

이 경우 핸들러는 정말 간단하며, 클라이언트에게 문자열 "Hello World!"를 반환합니다. 이는 아직 하이퍼미디어는 아니지만, @fig-helloworld에서 보듯이 브라우저는 이를 잘 렌더링할 것입니다.

#figure([#image("images/figure_2-1_hello_world.png")], caption: [
  Hello World!
])<fig-helloworld>

좋습니다, 우리의 첫 번째 Flask 단계로 HTTP 요청에 응답하기 위해 사용할 핵심 기술을 보여주었습니다: 핸들러에 매핑된 경로입니다.

Contact.app에서는 "Hello World!"를 루트 경로에서 렌더링하는 대신, 좀 더 세련되게 하겠습니다: 우리는 `/contacts` 경로로 리다이렉션할 것입니다. 리다이렉션은 클라이언트를 HTTP 응답으로 다른 위치로 리디렉션할 수 있게 해주는 HTTP의 기능입니다.

#index[Flask][redirect]
우리는 루트 페이지로 연락처 목록을 표시할 것이며, 아마도 이러한 정보를 표시하기 위해 `/contacts` 경로로 리다이렉션하는 것이 REST의 리소스 개념과 더 일치할 것입니다. 이는 우리의 판단으로, 그리 중요하다고 느끼지는 않지만, 애플리케이션에서 나중에 설정할 경로와 관련하여 이해할 수 있는 방법입니다.

이제 우리의 "Hello World" 경로를 리다이렉션으로 변경하려면 한 줄의 코드만 변경하면 됩니다:

#figure(caption: [Changing "Hello World" to a redirect],
```python
@app.route("/")
def index():
    return redirect("/contacts") <1>
```)
1. `redirect()`에 대한 호출로 업데이트합니다.

이제 `index()` 함수는 우리가 제공한 경로와 함께 Flask가 제공하는 `redirect()` 함수의 결과를 반환합니다. 이 경우 경로는 문자열 인수로 전달되는 `/contacts`입니다. 이제 루트 경로인 `/`로 이동하면, 우리의 Flask 애플리케이션이 `/contacts` 경로로 리디렉션할 것입니다.

=== Contact.app 기능 <_contact_app_functionality>

#index[Contact.app][specs]
이제 경로를 정의하는 방법에 대한 일부 이해가 생겼으므로, 우리의 웹 애플리케이션을 정의하고 구현하는 데 집중해 봅시다.

Contact.app은 무엇을 할까요?

처음에는 사용자가 다음을 허용할 것입니다:

- 이름, 성, 전화번호 및 이메일 주소를 포함한 연락처 목록 보기
- 연락처 검색
- 새 연락처 추가
- 연락처 세부 정보 보기
- 연락처 세부 정보 편집
- 연락처 삭제

보시다시피, Contact.app은 #indexed[CRUD] 애플리케이션이며, 구식 웹 1.0 접근 방식에 완벽한 애플리케이션입니다.

Contact.app의 소스 코드는 #link("https://github.com/bigskysoftware/contact-app")[GitHub]에서 확인할 수 있습니다.

==== Showing A Searchable List Of Contacts <_showing_a_searchable_list_of_contacts>
Let’s add our first real bit of functionality: the ability to show all the
contacts in our app in a list (really, in a table).

This functionality is going to be found at the `/contacts` path, which is the
path our previous route is redirecting to.

We will use Flask to route the `/contacts` path to a handler function,
`contacts()`. This function will do one of two things:
- If there is a search term found in the request, it will filter down to only
  contacts matching that term
- If not, it will simply list all contacts

This is a common approach in web 1.0 style applications: the same URL that
displays all instances of some resource also serves as the search results page
for those resources. Taking this approach makes it easy to reuse the list
display that is common to both types of request.

Here is what the code looks like for this handler:

#figure(caption: [A handler for server-side search],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q") <1>
    if search is not None:
        contacts_set = Contact.search(search) <2>
    else:
        contacts_set = Contact.all() <3>
    return render_template("index.html", contacts=contacts_set)
```)

1. Look for the query parameter named `q`, which stands for "query."
2. If the parameter exists, call the `Contact.search()` function with it.
3. If not, call the `Contact.all()` function.
4. Pass the result to the `index.html` template to render to the client.

#index[query strings]
We see the same sort of routing code we saw in our first example, but we have a
more elaborate handler function. First, we check to see if a search query
parameter named `q` is part of the request.

/ Query Strings: #[
  A "query string" is part of the URL specification. Here is an example URL with a
  query string in it: `https://example.com/contacts?q=joe`. The query string is
  everything after the `?`, and has a name-value pair format. In this URL, the
  query parameter `q` is set to the string value
  `joe`. In plain HTML, a query string can be included in a request either by
  being hardcoded in an anchor tag or, more dynamically, by using a form tag with
  a `GET` request.
  ]

To return to our Flask route, if a query parameter named `q` is found, we call
out to the `search()` method on a `Contact` model object to do the actual
contact search and return all the matching contacts.

If the query parameter is _not_ found, we simply get all contacts by invoking
the `all()` method on the `Contact` object.

Finally, we render a template, `index.html` that displays the given contacts,
passing in the results of whichever of these two functions we end up calling.

#sidebar[A Note On The Contact Class][
The `Contact` Python class we’re using is the "domain model" or just
"model" class for our application, providing the "business logic" around the
management of Contacts.

#index[Contact.app][model]
It could be working with a database (it isn’t) or a simple flat file (it is),
but we’re going to skip over the internal details of the model. Think of it as a "normal"
domain model class, with methods on it that act in a
"normal" manner.

We will treat `Contact` as a _resource_, and focus on how to effectively provide
hypermedia representations of that resource to clients.
]

===== The list & search templates <_the_list_search_templates>
Now that we have our handler logic written, we’ll create a template to render
HTML in our response to the client. At a high level, our HTML response needs to
have the following elements:
- A list of any matching or all contacts.
- A search box where a user may type and submit search terms.
- A bit of surrounding "chrome": a header and footer for the website that will be
  the same regardless of the page you are on.

#index[Templates]
#index[Jinja2][about]
We are using the Jinja2 templating language, which has the following features:
- We can use double-curly braces, `{{ }}`, to embed expression values in the
  template.
- we can use curly-percents, `{% %}`, for directives, like iteration or including
  other content.

Beyond this basic syntax, Jinja2 is very similar to other templating languages
used to generate content, and should be easy to follow for most web developers.

Let’s look at the first few lines of code in the `index.html` template:

#figure(caption: [Start of index.html],
```html
{% extends 'layout.html' %} <1>

{% block content %} <2>

  <form action="/contacts" method="get" class="tool-bar"> <3>
    <label for="search">Search Term</label>
    <input id="search" type="search" name="q"
      value="{{ request.args.get('q') or '' }}" /> <4>
    <input type="submit" value="Search"/>
  </form>
```)

1. Set the layout template for this template.
2. Delimit the content to be inserted into the layout.
3. Create a search form that will issue an HTTP `GET` to `/contacts`.
4. Create an input for a user to type search queries.

The first line of code references a base template, `layout.html`, with the `extends` directive.
This layout template provides the layout for the page (again, sometimes called "the
chrome"): it wraps the template content in an `<html>` tag, imports any
necessary CSS and JavaScript in a `<head>` element, places a `<body>` tag around
the main content and so forth. All the common content wrapped around the "normal"
content for the entire application is located in this file.

The next line of code declares the `content` section of this template. This
content block is used by the `layout.html` template to inject the content of `index.html` within
its HTML.

Next we have our first bit of actual HTML, rather than just Jinja directives. We
have a simple HTML form that allows you to search contacts by issuing a `GET` request
to the `/contacts` path. The form itself contains a label and an input with the
name "q." This input’s value will be submitted with the `GET` request to the `/contacts` path,
as a query string (since this is a `GET` request.)

Note that the value of this input is set to the Jinja expression
`{{ request.args.get('q') or '' }}`. This expression is evaluated by Jinja and
will insert the request value of "q" as the input’s value, if it exists. This
will "preserve" the search value when a user does a search, so that when the
results of a search are rendered the text input contains the term that was
searched for. This makes for a better user experience since the user can see
exactly what the current results match, rather than having a blank text box at
the top of the screen.

Finally, we have a submit-type input. This will render as a button and, when it
is clicked, it will trigger the form to issue an HTTP request.

#index[Contact.app][table]
This search interface forms the top of our contact page. Following it is a table
of contacts, either all contacts or the contacts that match the search, if a
search was done.

Here is what the template code for the contact table looks like:

#figure(caption: [The contacts table],
```html
<table>
  <thead>
  <tr>
    <th>First <th>Last <th>Phone <th>Email <th/> <1>
  </tr>
  </thead>
  <tbody>
  {% for contact in contacts %} <2>
    <tr>
      <td>{{ contact.first }}</td>
      <td>{{ contact.last }}</td>
      <td>{{ contact.phone }}</td>
      <td>{{ contact.email }}</td> <3>
      <td><a href="/contacts/{{ contact.id }}/edit">Edit</a>
        <a href="/contacts/{{ contact.id }}">View</a></td> <4>
    </tr>
  {% endfor %}
  </tbody>
</table>
```,
)
- Output some headers for our table.
- Iterate over the contacts that were passed in to the template.
- Output the values of the current contact, first name, last name, etc.
- An "operations" column, with links to edit or view the contact details.

This is the core of the page: we construct a table with appropriate headers
matching the data we are going to show for each contact. We iterate over the
contacts that were passed into the template by the handler method using the `for` loop
directive in Jinja2. We then construct a series of rows, one for each contact,
where we render the first and last name, phone and email of the contact as table
cells in the row.

Additionally, we have a table cell that includes two links:
- A link to the "Edit" page for the contact, located at
  `/contacts/{{ contact.id }}/edit` (e.g., For the contact with id 42, the edit
  link will point to `/contacts/42/edit`)
- A link to the "View" page for the contact
  `/contacts/{{ contact.id }}` (using our previous contact example, the view page
  would be at `/contacts/42`)

Finally, we have a bit of end-matter: a link to add a new contact and a Jinja2
directive to end the `content` block:

#figure(caption: [The "add contact" link],
```html
  <p>
    <a href="/contacts/new">Add Contact</a> <1>
  </p>

{% endblock %} <2>
```)
1. Link to the page that allows you to create a new contact.
2. The closing element of the `content` block.

And that’s our complete template. Using this simple server-side template, in
combination with our handler method, we can respond with an HTML _representation_ of
all the contacts requested. So far, so hypermedia.

@fig-contactapp is what the template looks like, rendered with a bit of contact
information.

#figure(image("images/figure_2-2_table_etc.png"), caption: [Contact.app])<fig-contactapp>

Now, our application won’t win any design awards at this point, but notice that
our template, when rendered, provides all the functionality necessary to see all
the contacts and search them, and also provides links to edit them, view details
of them or even create a new one.

And it does all this without the client (that is, the browser) knowing a thing
about what contacts are or how to work with them. Everything is encoded _in_ the
hypermedia. A web browser accessing this application just knows how to issue
HTTP requests and then render HTML, nothing more about the specifics of our
applications end points or underlying domain model.

As simple as our application is at this point, it is thoroughly RESTful.

==== Adding A New Contact <_adding_a_new_contact>
The next bit of functionality that we will add to our application is the ability
to add new contacts. To do this, we are going to need to handle that `/contacts/new` URL
referenced in the "Add Contact" link above. Note that when a user clicks on that
link, the browser will issue a
`GET` request to the `/contacts/new` URL.

All the other routes we have so far use `GET` as well, but we are actually going
to use two different HTTP methods for this bit of functionality: an HTTP `GET` to
render a form for adding a new contact, and then an HTTP `POST` _to the same path_ to
actually create the contact, so we are going to be explicit about the HTTP
method we want to handle when we declare this route.

Here is the code:

#figure(caption: [The "new contact" GET route],
```python
@app.route("/contacts/new", methods=['GET']) <1>
def contacts_new_get():
    return render_template("new.html", contact=Contact()) <2>
```)

1. Declare a route, explicitly handling `GET` requests to this path.
2. Render the `new.html` template, passing in a new contact object.

Simple enough. We just render a `new.html` template with a new Contact. (`Contact()` is
how you construct a new instance of the `Contact` class in Python, if you aren’t
familiar with it.)

While the handler code for this route is very simple, the `new.html`
template is more complicated.

#sidebar[][For the remaining templates we are going to omit the layout directive and the
  content block declaration, but you can assume they are the same unless we say
  otherwise. This will let us focus on the "meat" of the template.]

If you are familiar with HTML you are probably expecting a form element here,
and you will not be disappointed. We are going to use the standard form
hypermedia control for collecting contact information and submitting it to the
server.

Here is what our HTML looks like:

#figure(caption: [The "new contact" form],
```html
<form action="/contacts/new" method="post"> <1>
  <fieldset>
    <legend>Contact Values</legend>
    <p>
      <label for="email">Email</label> <2>
      <input name="email" id="email"
        type="email" placeholder="Email"
        value="{{ contact.email or '' }}"> <3>
      <span class="error">
        {{ contact.errors['email'] }} <4>
      </span>
    </p>
```)

1. A form that submits to the `/contacts/new` path, using an HTTP `POST`.
2. A label for the first form input.
3. The first form input, of type email.
4. Any error messages associated with this field.

In the first line of code we create a form that will submit back
_to the same path_ that we are handling: `/contacts/new`. Rather than issuing an
HTTP `GET` to this path, however, we will issue an HTTP
`POST` to it. Using a `POST` in this manner will signal to the server that we
want to create a new Contact, rather than get a form for creating one.

We then have a label (always a good practice!) and an input that captures the
email of the contact being created. The name of the input is `email` and, when
this form is submitted, the value of this input will be submitted in the `POST` request,
associated with the `email`
key.

Next we have inputs for the other fields for contacts:

#figure(caption: [Inputs and labels for the "new contact" form],
```html
<p>
  <label for="first_name">First Name</label>
  <input name="first_name" id="first_name" type="text"
    placeholder="First Name" value="{{ contact.first or '' }}">
  <span class="error">{{ contact.errors['first'] }}</span>
</p>
<p>
  <label for="last_name">Last Name</label>
  <input name="last_name" id="last_name" type="text"
    placeholder="Last Name" value="{{ contact.last or '' }}">
  <span class="error">{{ contact.errors['last'] }}</span>
</p>
<p>
  <label for="phone">Phone</label>
  <input name="phone" id="phone" type="text" placeholder="Phone"
    value="{{ contact.phone or '' }}">
  <span class="error">{{ contact.errors['phone'] }}</span>
</p>
```,
)

Finally, we have a button that will submit the form, the end of the form tag,
and a link back to the main contacts table:

#figure(caption: [The submit button for the "new contact" form],
```html
    <button>Save</button>
  </fieldset>
</form>

<p>
  <a href="/contacts">Back</a>
</p>
```)

It is easy to miss in this straight-forward example: we are seeing the
flexibility of hypermedia in action.

If we add a new field, remove a field, or change the logic around how fields are
validated or work with one another, this new state of affairs would be reflected
in the new hypermedia representation given to users. A user would see the
updated new form and be able to work with these new features, with no software
update required.

===== Handling the post to /contacts/new <_handling_the_post_to_contactsnew>
The next step in our application is to handle the `POST` that this form makes to `/contacts/new`.

To do so, we need to add another route to our application that handles the `/contacts/new` path.
The new route will handle an HTTP `POST`
method instead of an HTTP `GET`. We will use the submitted form values to
attempt to create a new Contact.

If we are successful in creating a Contact, we will redirect the user to the
list of contacts and show a success message. If we aren’t successful, then we
will render the new contact form again with whatever values the user entered and
render error messages about what issues need to be fixed so that the user can
correct them.

Here is our new request handler:

#figure(caption: [The "new contact" controller code],
```python
@app.route("/contacts/new", methods=['POST'])
def contacts_new():
    c = Contact(
      None,
      request.form['first_name'],
      request.form['last_name'],
      request.form['phone'],
      request.form['email']) <1>
    if c.save(): <2>
        flash("Created New Contact!")
        return redirect("/contacts") <3>
    else:
        return render_template("new.html", contact=c) <4>
```)
1. We construct a new contact object with the values from the form.
2. We try to save it.
3. On success, "flash" a success message & redirect to the `/contacts`
  page.
4. On failure, re-render the form, showing any errors to the user.

The logic in this handler is a bit more complex than other methods we have seen.
The first thing we do is create a new Contact, again using the `Contact()` syntax
in Python to construct the object. We pass in the values that the user submitted
in the form by using the `request.form`
object, a feature provided by Flask.

This `request.form` allows us to access submitted form values in an easy and
convenient way, by simply passing in the same name associated with the various
inputs.

We also pass in `None` as the first value to the `Contact` constructor. This is
the "id" parameter, and by passing in `None` we are signaling that it is a new
contact, and needs to have an ID generated for it. (Again, we are not going into
the details of how this model object is implemented, our only concern is using
it to generate hypermedia responses.)

Next, we call the `save()` method on the Contact object. This method returns `true` if
the save is successful, and `false` if the save is unsuccessful (for example, a
bad email was submitted by the user).

If we are able to save the contact (that is, there were no validation errors),
we create a _flash_ message indicating success, and redirect the browser back to
the list page. A "flash" is a common feature in web frameworks that allows you
to store a message that will be available on the _next_ request, typically in a
cookie or in a session store.

Finally, if we are unable to save the contact, we re-render the
`new.html` template with the contact. This will show the same template as above,
but the inputs will be filled in with the submitted values, and any errors
associated with the fields will be rendered to feedback to the user as to what
validation failed.

#sidebar[The Post/Redirect/Get Pattern][
#index[Post/Redirect/Get (PRG)]
This handler implements a common strategy in web 1.0-style development called
the
#link("https://en.wikipedia.org/wiki/Post/Redirect/Get")[Post/Redirect/Get]
or PRG pattern. By issuing an HTTP redirect once a contact has been created and
forwarding the browser on to another location, we ensure that the `POST` does
not end up in the browsers request cache.

This means that if the user accidentally (or intentionally) refreshes the page,
the browser will not submit another `POST`, potentially creating another
contact. Instead, it will issue the `GET` that we redirect to, which should be
side-effect free.

We will use the PRG pattern in a few different places in this book.
]

OK, so we have our server-side logic set up to save contacts. And, believe it or
not, this is about as complicated as our handler logic will get, even when we
look at adding more sophisticated htmx-driven behaviors.

==== Viewing The Details Of A Contact <_viewing_the_details_of_a_contact>
The next piece of functionality we will implement is the detail page for a
Contact. The user will navigate to this page by clicking the "View" link in one
of the rows in the list of contacts. This will take them to the path `/contact/<contact id>` (e.g., `/contacts/42`).

This is a common pattern in web development: contacts are treated as resources
and the URLs around these resources are organized in a coherent manner.
- If you wish to view all contacts, you issue a `GET` to `/contacts`.
- If you want a hypermedia representation allowing you to create a new contact,
  you issue a `GET` to `/contacts/new`.
- If you wish to view a specific contact (with, say, an id of
  #raw("42), you issue a `GET") to `/contacts/42`.

#sidebar[The Eternal Bike Shed of URL Design][
It is easy to quibble about the particulars of the path scheme you use for your
application:

"Should we `POST` to `/contacts/new` or to `/contacts`?"

We have seen many arguments online and in person advocating for one approach
versus another. We feel it is more important to understand the overarching idea
of _resources_ and _hypermedia representations_, rather than getting worked up
about the smaller details of your URL design.

We recommend you just pick a reasonable, resource-oriented URL layout you like
and then stay consistent. Remember, in a hypermedia system, you can always
change your endpoints later, because you are using hypermedia as the engine of
application state!
]

Our handler logic for the detail route is going to be _very_
simple: we just look the Contact up by id, which is embedded in the path of the
URL for the route. To extract this ID we are going to need to introduce a final
bit of Flask functionality: the ability to call out pieces of a path and have
them automatically extracted and passed in to a handler function.

Here is what the code looks like, just a few lines of simple Python:

#figure(```python
@app.route("/contacts/<contact_id>") <1>
def contacts_view(contact_id=0): <2>
    contact = Contact.find(contact_id) <3>
    return render_template("show.html", contact=contact) <4>
```)

1. Map the path, with a path variable named `contact_id`.
2. The handler takes the value of this path parameter.
3. Look up the corresponding contact.
4. Render the `show.html` template.

You can see the syntax for extracting values from the path in the first line of
code: you enclose the part of the path you wish to extract in
`<>` and give it a name. This component of the path will be extracted and then
passed into the handler function, via the parameter with the same name.

So, if you were to navigate to the path `/contacts/42`, the value `42`
would be passed into the `contacts_view()` function for the value of
`contact_id`.

Once we have the id of the contact we want to look up, we load it up using the `find` method
on the `Contact` object. We then pass this contact into the `show.html` template
and render a response.

==== The Contact Detail Template <_the_contact_detail_template>
Our `show.html` template is relatively simple, just showing the same information
as the table but in a slightly different format (perhaps for printing). If we
add functionality like "notes" to the application later on, this will give us a
good place to do so.

Again, we will omit the "chrome" of the template and focus on the meat:

#figure(caption: [The "contact details" template],
```html
<h1>{{contact.first}} {{contact.last}}</h1>

<div>
  <div>Phone: {{contact.phone}}</div>
  <div>Email: {{contact.email}}</div>
</div>

<p>
  <a href="/contacts/{{contact.id}}/edit">Edit</a>
  <a href="/contacts">Back</a>
</p>
```)

We simply render a First Name and Last Name header, with the additional contact
information below it, and a couple of links: a link to edit the contact and a
link to navigate back to the full list of contacts.

==== Editing And Deleting A Contact <_editing_and_deleting_a_contact>
Next up we will tackle the functionality on the other end of that "Edit" link.
Editing a contact is going to look very similar to creating a new contact. As
with adding a new contact, we are going to need two routes that handle the same
path, but using different HTTP methods: a `GET` to
`/contacts/<contact_id>/edit` will return a form allowing you to edit the
contact and a `POST` to that path will update it.

We are also going to piggyback the ability to delete a contact along with this
editing functionality. To do this we will need to handle a
`POST` to `/contacts/<contact_id>/delete`.

Let’s look at the code to handle the `GET`, which, again, will return an HTML
representation of an editing interface for the given resource:

#figure(caption: [The "edit contact" controller code],
```python
@app.route("/contacts/<contact_id>/edit", methods=["GET"])
def contacts_edit_get(contact_id=0):
    contact = Contact.find(contact_id)
    return render_template("edit.html", contact=contact)
```)

As you can see this looks a lot like our "Show Contact" functionality. In fact,
it is nearly identical except for the template: here we render
`edit.html` rather than `show.html`.

While our handler code looked similar to the "Show Contact" functionality, the `edit.html` template
is going to look very similar to the template for the "New Contact"
functionality: we will have a form that submits updated contact values to the
same "edit" URL and that presents all the fields of a contact as inputs for
editing, along with any error messages.

Here is the first bit of the form:

#figure(caption: [The "edit contact" form start],
```html
<form action="/contacts/{{ contact.id }}/edit" method="post"> <1>
  <fieldset>
    <legend>Contact Values</legend>
    <p>
      <label for="email">Email</label>
      <input name="email" id="email" type="text"
        placeholder="Email" value="{{ contact.email }}"> <2>
      <span class="error">{{ contact.errors['email'] }}</span>
    </p>
```)

1. Issue a `POST` to the `/contacts/{{ contact.id }}/edit` path.
2. As with the `new.html` page, the input is tied to the contact’s email.

This HTML is nearly identical to our `new.html` form, except that this form is
going to submit a `POST` to a different path, based on the id of the contact
that we want to update. (It’s worth mentioning here that, rather than `POST`, we
would prefer to use a `PUT` or `PATCH`, but those are not available in plain
HTML.)

Following this we have the remainder of our form, again very similar to the `new.html` template,
and our button to submit the form.

#figure(caption: [The "edit contact" form body],
```html
    <p>
      <label for="first_name">First Name</label>
      <input name="first_name" id="first_name" type="text"
        placeholder="First Name" value="{{ contact.first }}">
      <span class="error">{{ contact.errors['first'] }}</span>
    </p>
    <p>
      <label for="last_name">Last Name</label>
      <input name="last_name" id="last_name" type="text"
        placeholder="Last Name" value="{{ contact.last }}">
      <span class="error">{{ contact.errors['last'] }}</span>
    </p>
    <p>
      <label for="phone">Phone</label>
      <input name="phone" id="phone" type="text"
        placeholder="Phone" value="{{ contact.phone }}">
      <span class="error">{{ contact.errors['phone'] }}</span>
    </p>
    <button>Save</button>
  </fieldset>
</form>
```)

In the final part of our template we have a small difference between the
`new.html` and `edit.html`. Below the main editing form, we include a second
form that allows you to delete a contact. It does this by issuing a `POST` to
the `/contacts/<contact id>/delete` path. Just as we would prefer to use a `PUT` to
update a contact, we would much rather use an HTTP `DELETE` request to delete
one. Unfortunately that also isn’t possible in plain HTML.

To finish up the page, there is a simple hyperlink back to the list of contacts.

#figure(caption: [The "edit contact" form footer],
```html
<form action="/contacts/{{ contact.id }}/delete" method="post">
  <button>Delete Contact</button>
</form>

<p>
  <a href="/contacts/">Back</a>
</p>
```)

Given all the similarities between the `new.html` and `edit.html`
templates, you may be wondering why we are not _refactoring_ these two templates
to share logic between them. That’s a good observation and, in a production
system, we would probably do just that.

For our purposes, however, since our application is small and simple, we will
leave the templates separate.

#sidebar[Factoring Your Applications][
  #index[factoring]
  One thing that often trips people up who are coming to hypermedia applications
  from a JavaScript background is the notion of
  "components". In JavaScript-oriented applications it is common to break your app
  up into small client-side components that are then composed together. These
  components are often developed and tested in isolation and provide a nice
  abstraction for developers to create testable code.

  With Hypermedia-Driven Applications, in contrast, you factor your application on
  the server side. As we said, the above form could be refactored into a shared
  template between the edit and create templates, allowing you to achieve a
  reusable and DRY (Don’t Repeat Yourself) implementation.

  Note that factoring on the server-side tends to be coarser-grained than on the
  client-side: you tend to split out common _sections_ rather than create lots of
  individual components. This has benefits (it tends to be simple) as well as
  drawbacks (it is not nearly as isolated as client-side components).

  Overall, a properly factored server-side hypermedia application can be extremely
  DRY.
]

===== Handling the post to /contacts/\<contact\_id\>/edit <_handling_the_post_to_contactscontact_id>
Next we need to handle the HTTP `POST` request that the form in our
`edit.html` template submits. We will declare another route that handles the
same path as the `GET` above.

Here is the new handler code:

#index[POST request]
#figure(
```python
@app.route("/contacts/<contact_id>/edit", methods=["POST"]) <1>
def contacts_edit_post(contact_id=0):
    c = Contact.find(contact_id) <2>
    c.update(
      request.form['first_name'],
      request.form['last_name'],
      request.form['phone'],
      request.form['email']) <3>
    if c.save(): <4>
        flash("Updated Contact!")
        return redirect("/contacts/" + str(contact_id)) <5>
    else:
        return render_template("edit.html", contact=c) <6>
```)

1. Handle a `POST` to `/contacts/<contact_id>/edit`.
2. Look the contact up by id.
3. Update the contact with the new information from the form.
4. Attempt to save it.
5. On success, flash a success message & redirect to the detail page.
6. On failure, re-render the edit template, showing any errors.

The logic in this handler is very similar to the logic in the handler for adding
a new contact. The only real difference is that, rather than creating a new
Contact, we look the contact up by id and then call the
`update()` method on it with the values that were entered in the form.

Once again, this consistency between our CRUD operations is one of the nice and
simplifying aspects of traditional CRUD web applications.

==== Deleting A Contact <_deleting_a_contact>

#index[Post/Redirect/Get (PRG)]
We piggybacked contact delete functionality into the same template used to edit
a contact. This second form will issue an HTTP `POST` to
`/contacts/<contact_id>/delete`, and we will need to create a handler for that
path as well.

Here is what the controller looks like:

#figure(caption: [The "delete contact" controller code],
```python
@app.route("/contacts/<contact_id>/delete", methods=["POST"]) <3>
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete() <2>
    flash("Deleted Contact!")
    return redirect("/contacts") <3>
```)

1. Handle a `POST` the `/contacts/<contact_id>/delete` path.
2. Look up and then invoke the `delete()` method on the contact.
3. Flash a success message and redirect to the main list of contacts.

The handler code is very simple since we don’t need to do any validation or
conditional logic: we simply look up the contact the same way we have been doing
in our other handlers and invoke the `delete()` method on it, then redirect back
to the list of contacts with a success flash message.

No need for a template in this case, the contact is gone.

==== Contact.app…​ Implemented! <_contact_app_implemented>
And, well…​ believe it or not, that’s our entire contact application!

If you’ve struggled with parts of the code so far, don’t worry: we don’t expect
you to be a Python or Flask expert (we aren’t!). You just need a basic
understanding of how they work to benefit from the remainder of the book.

This is a small and simple application, but it does demonstrate many of the
aspects of traditional, web 1.0 applications: CRUD, the Post/Redirect/Get
pattern, working with domain logic in a controller, organizing our URLs in a
coherent, resource-oriented manner.

And, furthermore, this is a deeply _Hypermedia-Driven_ web application. Without
thinking about it very much, we have been using REST, HATEOAS and all the other
hypermedia concepts we discussed earlier. We would bet that this simple little
contact app of ours is more RESTful than 99% of all JSON APIs ever built!

Just by virtue of using a _hypermedia_, HTML, we naturally fall into the RESTful
network architecture.

So that’s great. But what’s the matter with this little web app? Why not end
here and go off to develop web 1.0 style applications?

Well, at some level, nothing is wrong with it. Particularly for an application
as simple as this one, the older way of building web apps might be a perfectly
acceptable approach.

However, our application does suffer from that "clunkiness" that we mentioned
earlier when discussing web 1.0 applications: every request replaces the entire
screen, introducing a noticeable flicker when navigating between pages. You lose
your scroll state. You have to click around a bit more than you might in a more
sophisticated web application.

Contact.app, at this point, just doesn’t feel like a "modern" web application.

Is it time to reach for a JavaScript framework and JSON APIs to make our contact
application more interactive?

No. No it isn’t.

It turns out that we can improve the user experience of this application while
retaining its fundamental hypermedia architecture.

In the next few chapters we will look at
#link("https://htmx.org")[htmx], a hypermedia-oriented library that will let us
improve our contact application while retaining the hypermedia-based approach we
have used so far.

#html-note[Framework Soup][
#index[components]
Components encapsulate a section of a page along with its dynamic behavior.
While encapsulating behavior is a good way to organize code, it can also
separate elements from their surrounding context, which can lead to wrong or
inadequate relationships between elements. The result is what one might call _component soup_,
where information is hidden in component state, rather than being present in the
HTML, which is now incomprehensible due to missing context.

Before you reach for components for reuse, consider your options. Lower-level
mechanisms often (allow you to) produce better HTML. In some cases, components
can actually _improve_ the clarity of your HTML.

#blockquote(
  attribution: [Manuel Matuzović, #link(
      "https://www.matuzo.at/blog/2023/single-page-applications-criticism",
    )[Why I’m not the biggest fan of Single Page Applications]],
)[
  The fact that the HTML document is something that you barely touch, because
  everything you need in there will be injected via JavaScript, puts the document
  and the page structure out of focus.
]

In order to avoid `<div>` soup (or Markdown soup, or Component soup), you need
to be aware of the markup you’re producing and be able to change it.

Some SPA frameworks, and some web components, make this more difficult by
putting layers of abstraction between the code the developer writes and the
generated markup.

While these abstractions can allow developers to create richer UI or work
faster, their pervasiveness means that developers can lose sight of the actual
HTML (and JavaScript) being sent to clients. Without diligent testing, this
leads to inaccessibility, poor SEO, and bloat.
]
