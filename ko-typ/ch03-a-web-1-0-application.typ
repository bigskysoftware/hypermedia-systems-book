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

==== 검색 가능한 연락처 목록 표시하기 <_showing_a_searchable_list_of_contacts>
우리의 첫 번째 실제 기능, 즉 앱의 모든 연락처를 목록(사실은 표)으로 보여주는 기능을 추가합시다.

이 기능은 이전 경로가 리다이렉션되는 `/contacts` 경로에 위치할 것입니다.

Flask를 사용하여 `/contacts` 경로를 핸들러 함수인 `contacts()`로 라우팅할 것입니다. 이 함수에는 두 가지 일이 일어날 것입니다:
- 요청에서 검색어가 발견되면 해당 용어와 일치하는 연락처만 필터링합니다.
- 그렇지 않으면 모든 연락처를 나열합니다.

이는 웹 1.0 스타일 애플리케이션에서 흔한 접근 방식입니다: 어떤 리소스의 모든 인스턴스를 표시하는 동일한 URL는 해당 리소스에 대한 검색 결과 페이지로도 작동합니다. 이러한 접근 방식을 취하면 두 유형의 요청에 공통된 목록 표시를 쉽게 재사용할 수 있습니다.

다음은 이 핸들러의 코드입니다:

#figure(caption: [서버 측 검색을 위한 핸들러],
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

1. `q`라는 이름의 쿼리 매개변수를 찾습니다.
2. 매개변수가 존재하면 이를 사용하여 `Contact.search()` 함수를 호출합니다.
3. 그렇지 않으면 `Contact.all()` 함수를 호출합니다.
4. 결과를 `index.html` 템플릿에 전달하여 클라이언트에게 렌더링합니다.

#index[query strings]
우리는 처음 예제에서 본 것과 동일한 종류의 라우팅 코드를 보았지만, 더 정교한 핸들러 함수가 있습니다. 먼저 요청의 일부로 쿼리 매개변수인 `q`가 있는지 확인합니다.

/ 쿼리 문자열: #[
  "쿼리 문자열"은 URL 규격의 일부입니다. 다음은 쿼리 문자열이 포함된 예제 URL입니다: `https://example.com/contacts?q=joe`. 쿼리 문자열은 `?` 이후의 모든 것이며, 이름-값 쌍 형식을 가지고 있습니다. 이 URL에서 쿼리 매개변수 `q`는 문자열 값 `joe`로 설정됩니다. 일반 HTML에서는 쿼리 문자열이 하드코딩된 앵커 태그에 포함되거나, 더 동적으로 `GET` 요청이 있는 양식 태그를 사용하여 포함될 수 있습니다.
]

Flask 경로로 돌아가서, 쿼리 매개변수 `q`가 발견되면, `Contact` 모델 객체의 `search()` 메서드를 호출하여 실제 연락처 검색을 수행하고 모든 일치하는 연락처를 반환합니다.

쿼리 매개변수가 _발견되지 않으면_, `Contact` 객체에서 `all()` 메서드를 호출하면 됩니다.

마지막으로, 주어진 연락처를 표시하는 템플릿인 `index.html`을 렌더링하며, 우리가 호출하게 될 두 개 함수 중 하나의 결과를 전달합니다.

#sidebar[연락처 클래스에 대한 참고 사항][
우리가 사용하는 `Contact` 파이썬 클래스는 우리의 애플리케이션에 대한 "도메인 모델" 또는 단순히 "모델" 클래스이며, 연락처 관리를 위한 "비즈니스 논리"를 제공합니다.

#index[Contact.app][model]
이 클래스는 데이터베이스와 작업할 수도 있지만(현재는 아닙니다) 간단한 평면 파일과 작업할 수도 있습니다(현재는 그렇습니다). 그러나 우리는 모델의 내부 세부 사항은 건너뛰겠습니다. 이를 "정상" 도메인 모델 클래스로 생각하고, 그것에 대해 "정상" 방식으로 작동하는 메서드로 생각하십시오.

우리는 `Contact`를 _리소스_로 취급하고 하이퍼미디어 표현을 클라이언트에게 효과적으로 제공하는 방법에 집중할 것입니다.
]

===== 목록 및 검색 템플릿 <_the_list_search_templates>
이제 핸들러 로직이 작성되었으므로, 클라이언트에 대한 응답으로 HTML을 렌더링할 템플릿을 만들겠습니다. 전반적으로 우리의 HTML 응답은 다음 요소가 필요합니다:
- 일치하거나 모든 연락처의 목록.
- 사용자가 검색 문자를 입력하고 제출할 수 있는 검색 상자.
- 웹사이트에 대한 약간의 주위 "크롬": 현재 페이지와 관계없이 동일한 헤더 및 바닥글.

#index[Templates]
#index[Jinja2][about]
우리는 다음과 같은 기능을 가진 Jinja2 템플릿 언어를 사용하고 있습니다:
- 중괄호 두 개, `{{ }}`를 사용하여 템플릿에 표현식 값을 삽입할 수 있습니다.
- 중괄호 퍼센트 기호, `{% %}`를 사용하여반복 또는 다른 콘텐츠 포함과 같은 지시문을 사용합니다.

이 기본 구문을 넘어 Jinja2는 콘텐츠 생성을 위해 사용되는 다른 템플릿 언어와 매우 유사하며, 대부분의 웹 개발자들이 따라 읽기 쉬운 언어입니다.

다음은 `index.html` 템플릿의 처음 몇 줄 코드입니다:

#figure(caption: [index.html의 초반],
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

1. 이 템플릿의 레이아웃 템플릿을 설정합니다.
2. 레이아웃에 삽입될 내용을 한정합니다.
3. `/contacts`에 대한 HTTP `GET`을 발행할 검색 양식을 생성합니다.
4. 사용자가 검색 쿼리를 입력할 수 있는 입력 필드 생성.

코드의 첫 번째 줄은 `extends` 지시어로 기본 템플릿인 `layout.html`을 참조합니다. 이 레이아웃 템플릿은 페이지의 레이아웃을 제공합니다(다시 말해 때때로 "크롬"이라고도 불립니다): 템플릿 콘텐츠를 `<html>` 태그로 감싸고, `<head>` 요소에 필요한 CSS 및 JavaScript를 포함하며, `<body>` 태그로 주요 콘텐츠를 감싼다 등등. 전체 애플리케이션의 "정상" 콘텐츠를 둘러싼 모든 공통 콘텐츠는 이 파일에 위치합니다.

다음 줄은 이 템플릿의 `content` 섹션을 선언합니다. 이 콘텐츠 블록은 `layout.html` 템플릿이 `index.html`의 내용을 HTML 내에 삽입하는 데 사용됩니다.

다음은 Jinja 지시문이 아닌 실제 HTML의 첫 번째 내용입니다. 우리는 연락처를 검색하기 위해 `/contacts` 경로로 `GET` 요청을 발행하는 간단한 HTML 양식을 가지고 있습니다. 양식 자체에는 레이블과 이름이 "q"인 입력이 포함되어 있습니다. 이 입력값은 `GET` 요청과 함께 `/contacts` 경로로 제출되며, 쿼리 문자열로 전달됩니다(이것은 `GET` 요청이기 때문에).

이 입력값의 값은 Jinja 표현 `{{ request.args.get('q') or '' }}`로 설정되어 있습니다. 이 표현은 Jinja에 의해 평가되며, 존재한다면 입력의 값으로 "q"의 요청 값을 삽입할 것입니다. 이렇게 하면 사용자가 검색을 수행할 때 검색 값을 "보존"할 수 있으므로, 검색 결과가 렌더링될 때 텍스트 입력에는 검색했던 용어가 포함됩니다. 이렇게 하면 사용자 경험이 향상됩니다. 사용자는 현재 결과가 무엇과 일치하는지를 정확히 볼 수 있으며, 화면의 상단에 빈 텍스트 상자가 있는 것보다 좋습니다.

마지막으로, 제출 유형의 입력이 있습니다. 이는 버튼으로 렌더링되며, 클릭되면 양식이 HTTP 요청을 발행하도록 트리거합니다.

#index[Contact.app][table]
이 검색 인터페이스는 연락처 페이지의 상단을 형성합니다. 그 아래에는 검색이 수행된 경우 모든 연락처 또는 검색과 일치하는 연락처 목록이 있는 표가 있습니다.

다음은 연락처 표의 템플릿 코드입니다:

#figure(caption: [연락처 테이블],
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
- 테이블 제목을 출력합니다.
- 템플릿에 전달된 연락처를 반복합니다.
- 현재 연락처의 값을 출력합니다(이름, 성 등).
- 연락처 세부정보를 편집하거나 보기에 대한 링크가 있는 "작업" 열.

이것은 페이지의 핵심입니다: 우리는 각 연락처에 대해 보여 줄 데이터에 맞춤 제목을 가진 표를 구성합니다. 우리는 Jinja2의 `for` 루프 지시문을 사용하여 핸들러 메서드에서 템플릿에 전달된 연락처 목록을 반복합니다. 이후 우리는 각 연락처에 대한 행을 구성하며, 그 행에서 연락처의 이름, 성, 전화번호 및 이메일을 표 셀로 렌더링합니다.

또한 두 개의 링크가 포함된 표 셀도 있습니다:
- 연락처의 "편집" 페이지로 가는 링크: `/contacts/{{ contact.id }}/edit`에 위치합니다(예를 들어, id가 42인 연락처의 경우 편집 링크는 `/contacts/42/edit`를 가리킵니다).
- 연락처의 "보기" 페이지로 가는 링크: `/contacts/{{ contact.id }}`(이전 연락처 예시를 사용하면, 보기 페이지는 `/contacts/42`에 위치할 것입니다).

마지막으로, 새로운 연락처를 추가하기 위한 링크와 `content` 블록을 종료하는 Jinja2 지시문이 있습니다:

#figure(caption: [새 연락처 추가 링크],
```html
  <p>
    <a href="/contacts/new">Add Contact</a> <1>
  </p>

{% endblock %} <2>
```)
1. 새 연락처를 생성할 수 있는 페이지로의 링크.
2. `content` 블록의 닫는 요소.

이렇게 해서 우리의 완전한 템플릿이 완성되었습니다. 이 간단한 서버 측 템플릿과 핸들러 메서드를 결합하여 요청한 모든 연락처에 대한 HTML _표현_으로 응답할 수 있습니다. 현재까지는 하이퍼미디어입니다.

@fig-contactapp는 연락처 정보의 일부가 렌더링된 템플릿이 어떻게 보이는지를 보여줍니다.

#figure(image("images/figure_2-2_table_etc.png"), caption: [Contact.app])<fig-contactapp>

이제, 애플리케이션은 디자인 상을 받을 수준은 아니지만, 렌더링된 템플릿은 모든 연락처를 보고 검색할 수 있는 기능을 제공하고, 수정하거나 세부정보를 보거나 새로운 연락처를 생성할 수 있는 링크를 제공합니다.

그리고 클라이언트(즉, 브라우저)는 연락처가 무엇인지를 모르고 이 작업을 수행합니다. 모든 것이 하이퍼미디어 _안에_ 인코딩되어 있습니다. 이 애플리케이션에 접근하는 웹 브라우저는 HTTP 요청을 발행하고 HTML을 렌더링하는 방법만 알고 있습니다. 애플리케이션 엔드포인트 또는 기본 도메인 모델의 세부 사항에 대해서는 아무것도 알지 못합니다.

이 시점에서 우리의 애플리케이션은 매우 단순하지만, 철저히 RESTful합니다.

==== 새로운 연락처 추가하기 <_adding_a_new_contact>
애플리케이션에 추가할 다음 기능은 새로운 연락처를 추가하는 기능입니다. 이를 위해 우리는 위의 "연락처 추가" 링크에서 참조된 `/contacts/new` URL을 처리해야 합니다. 사용자가 해당 링크를 클릭하면 브라우저는 `/contacts/new` URL에 대한 `GET` 요청을 발행하게 됩니다.

여태까지의 다른 경로는 모두 `GET`을 사용했지만, 우리는 이 기능을 위해 두 가지 다른 HTTP 메서드를 사용할 것입니다: 새로운 연락처 추가를 위한 양식을 렌더링하는 `GET`과, 실제로 연락처를 생성하기 위한 `POST`입니다. 따라서 이 경로를 선언할 때 우리가 처리하고 싶은 HTTP 메서드를 명시적으로 지정할 것입니다.

다음은 코드입니다:

#figure(caption: [새 연락처를 위한 GET 경로],
```python
@app.route("/contacts/new", methods=['GET']) <1>
def contacts_new_get():
    return render_template("new.html", contact=Contact()) <2>
```)

1. 이 경로에 대해 `GET` 요청을 명시적으로 처리하는 경로를 선언합니다.
2. 새 연락처 객체를 전달하여 `new.html` 템플릿을 렌더링합니다.

간단한 코드입니다. 새 Contact와 함께 `new.html` 템플릿을 렌더링합니다. (`Contact()`는 Python에서 새 `Contact` 클래스의 인스턴스를 생성하는 방법입니다. 익숙하지 않다면 이 점은 언급할 필요 없습니다.)

이 경로의 핸들러 코드는 매우 간단하지만, `new.html` 템플릿은 더 복잡합니다.

#sidebar[][나머지 템플릿의 경우 레이아웃 지시어와 콘텐츠 블록 선언은 생략하겠습니다. 다르다고 언급하지 않는 한 그들은 동일하다고 가정할 수 있습니다. 이를 통해 템플릿의 "주요 내용"에 집중할 수 있습니다.]

HTML에 익숙하다면 여기서 양식 요소를 기대할 것입니다. 실망하지 않으셔도 됩니다. 연락처 정보를 수집하고 서버에 제출하기 위해 표준 양식 하이퍼미디어 제어를 사용할 것입니다.

다음은 우리의 HTML입니다:

#figure(caption: [새 연락처 양식],
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

1. HTTP `POST`를 사용하여 `/contacts/new` 경로로 제출하는 양식입니다.
2. 첫 번째 입력에 대한 레이블입니다.
3. 첫 번째 이메일 입력입니다.
4. 이 필드와 관련된 오류 메시지입니다.

코드의 첫 번째 줄에서 우리는 우리가 처리하고 있는 동일한 경로인 `/contacts/new`로 제출하는 양식을 생성합니다. 하지만 HTTP `GET`을 이 경로에 발행하는 대신, 우리는 여기에 HTTP `POST`를 발행할 것입니다. 이렇게 `POST`를 사용하면 서버에 새 연락처를 만들고자 한다는 신호를 보냅니다. 양식을 만드는 것이라는 것이 아닙니다.

그 다음에는 연락처를 위한 다른 필드에 대한 입력이 이어집니다:

#figure(caption: [새 연락처 양식을 위한 입력 및 레이블],
```
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

마지막으로, 제출 버튼과 양식 태그의 끝, 연락처 테이블로 돌아갈 링크가 있습니다:

#figure(caption: [새 연락처 양식을 위한 제출 버튼],
```html
    <button>Save</button>
  </fieldset>
</form>

<p>
  <a href="/contacts">Back</a>
</p>
```)

이 간단한 예시에서 간과하기 쉬운 점은 하이퍼미디어의 유연성이 실현되고 있다는 것입니다.

새 필드를 추가하거나 필드를 제거하거나 필드의 유효성을 검사하는 방법이나 서로 어떻게 작동하는지 변경하면, 이러한 새로운 상태의 하이퍼미디어 표현이 사용자에게 반영됩니다. 사용자는 업데이트된 새로운 양식을 보고 이러한 새로운 기능을 사용할 수 있으며, 소프트웨어 업데이트는 필요하지 않습니다.

===== /contacts/new에 대한 POST 처리 <_handling_the_post_to_contactsnew>
애플리케이션의 다음 단계는 이 양식이 `/contacts/new`에 생성하는 `POST`를 처리하는 것입니다.

이를 위해 우리는 `/contacts/new` 경로를 처리하는 애플리케이션에 또 다른 경로를 추가해야 합니다. 이 새로운 경로는 HTTP `GET` 대신에 HTTP `POST` 메서드를 처리하며, 제출된 양식 값을 사용하여 새 Contact을 생성하려고 합니다.

Contact을 생성하는 데 성공하면 사용자를 연락처 목록으로 리디렉션하고 성공 메시지를 표시합니다. 성공하지 않으면 사용자가 입력한 값을 포함하여 새 연락처 양식을 다시 렌더링하고 어떤 문제를 해결해야 하는지에 대한 오류 메시지를 렌더링할 것입니다.

여기 우리의 새 요청 핸들러가 있습니다:

#figure(caption: [새 연락처 컨트롤러 코드],
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
1. 양식의 값을 사용하여 새 연락처 객체를 만듭니다.
2. 이를 저장하려고 시도합니다.
3. 성공하면 성공 메시지를 "플래시" 해주고 `/contacts` 페이지로 리다이렉션합니다.
4. 실패하면 양식을 다시 렌더링하고 사용자에게 오류를 보여줍니다.

이 핸들러의 논리는 우리가 본 다른 메서드의 논리보다 약간 더 복잡합니다. 가장 먼저 하는 일은 제출된 값을 사용하여 새 Contact을 생성하는 것입니다. 여기서도 Python에서 객체를 구성하기 위해 `Contact()` 문법을 사용합니다. 우리는 양식에서 입력된 값을 `request.form` 객체를 통해 전달합니다. 이는 Flask가 제공하는 기능입니다.

이 `request.form`은 여러 입력과 관련된 동일한 이름을 전달하는 방식으로 제출된 양식 값을 쉽고 편리하게 접근할 수 있도록 해줍니다.

`Contact` 생성자에 대해 첫 번째 값으로 `None`을 전달합니다. 이는 "id" 매개변수로, `None`을 전달함으로써 새로운 연락처라는 신호를 줍니다. 이는 ID가 생성되어야 한다는 것입니다. (다시 말하지만, 이 모델 객체가 어떻게 구현되어 있는지에 대한 세부 사항에 대해서는 언급하지 않겠습니다. 우리의 관심사는 하이퍼미디어 응답을 생성하는 것이기 때문입니다.)

그 다음, Contact 객체에서 `save()` 메서드를 호출합니다. 이 메서드는 저장이 성공하면 `true`를 반환하고, 실패하면 `false`를 반환합니다(예: 사용자가 잘못된 이메일을 제출한 경우).

만약 연락처를 저장할 수 있다면(즉, 유효성 검사 오류가 없다면), 성공을 나타내는 _플래시_ 메시지를 만들고 브라우저를 목록 페이지로 리다이렉트합니다. "플래시"는 웹 프레임워크에서 사용되는 일반적인 기능으로, 보통 쿠키나 세션 저장소에 저장된 메시지를 다음 요청에서 사용할 수 있게 합니다.

마지막으로 연락처를 저장할 수 없는 경우, `new.html` 템플릿을 연락처와 함께 다시 렌더링합니다. 이는 위와 동일한 템플릿을 보여주겠지만, 입력 필드는 제출된 값으로 채워지고, 모든 필드와 관련된 오류는 사용자에게 무엇이 잘못되었는지 피드백을 렌더링할 것입니다.

#sidebar[POST/리디렉션/GET 패턴][
#index[Post/Redirect/Get (PRG)]
이 핸들러는 웹 1.0 스타일 개발에서 일반적인 전략인 #link("https://en.wikipedia.org/wiki/Post/Redirect/Get")[POST/리디렉션/GET] 또는 PRG 패턴을 구현합니다. 연락처가 생성된 후 HTTP 리디렉션을 발행하고 브라우저를 다른 위치로 리디렉션하여 `POST`가 브라우저의 요청 캐시에 저장되지 않도록 합니다.

즉, 사용자가 실수로(또는 의도적으로) 페이지를 새로 고침하면 브라우저가 또 다른 `POST`를 제출하지 않고, 리디렉션된 `GET`을 발행하게 되어 부작용이 없어야 합니다.

이 책의 여러 곳에서 PRG 패턴을 사용할 것입니다.
]

좋습니다. 우리는 연락처를 저장하기 위한 서버 측 논리를 설정했습니다. 믿거나 말거나, 이것이 우리의 핸들러 논리가 복잡해지는 거의 모든 것입니다. 더 정교한 htmx 기반 행동을 추가할 때도 마찬가지입니다.

==== 연락처 세부정보 보기 <_viewing_the_details_of_a_contact>
다음으로 구현할 기능은 연락처에 대한 상세 페이지입니다. 사용자는 연락처 목록의 한 행에서 "보기" 링크를 클릭하여 이 페이지로 이동할 것입니다. 그러면 경로 `/contact/<contact id>`(예: `/contacts/42`)로 이동하게 됩니다.

이는 웹 개발에서 일반적인 패턴입니다: 연락처는 리소스로 취급되며 이러한 리소스에 대한 URL이 일관성 있게 구성됩니다.
- 모든 연락처를 보려면 `/contacts`에 `GET` 요청을 발행합니다.
- 새 연락처를 생성할 수 있는 하이퍼미디어 표현이 필요하면 `/contacts/new`에 `GET` 요청을 발행합니다.
- 특정 연락처를 보려면(예를 들어, id가 #raw("42")인 경우) `/contacts/42`에 `GET` 요청을 발행합니다.

#sidebar[URL 설계의 영원한 자전거 샤벽][
애플리케이션에 대한 경로 체계의 세부 사항에 대해 쉽게 논쟁을 벌일 수 있습니다:

"우리가 `/contacts/new`에 `POST`해야 할까, 아니면 `/contacts`에 해야 할까?"

우리는 하나의 접근 방식에 대해 다른 접근 방식보다 강력하게 주장하는 많은 논쟁을 온라인과 직접 보았습니다. 우리는 URL 디자인의 더 작은 세부 사항에 대해 걱정하기보다는 _리소스_와 _하이퍼미디어 표현_의 포괄적인 개념을 이해하는 것이 더 중요하다고 생각합니다.

우리는 여러분이 좋아하는 실용적이고 리소스 지향적인 URL 레이아웃을 선택한 후에 일관성을 유지하기를 권장합니다. 하이퍼미디어 시스템에서는 endpoints를 나중에 변경할 수 있으므로 하이퍼미디어를 애플리케이션 상태의 엔진으로 사용할 수 있습니다!
]

세부 경로에 대한 우리의 핸들러 논리는 _매우_ 간단합니다. 우리는 연락처의 ID를 조회할 뿐이며, 이 ID는 경로의 URL에 포함되어 있습니다. 이 ID를 추출하기 위해 Flask의 마지막 기능인 경로의 일부를 호출하여 자동으로 추출한 후 핸들러 함수에 전달하는 기능을 도입해야 합니다.

다음은 몇 줄의 간단한 Python 코드입니다:

#figure(```python
@app.route("/contacts/<contact_id>") <1>
def contacts_view(contact_id=0): <2>
    contact = Contact.find(contact_id) <3>
    return render_template("show.html", contact=contact) <4>
```)

1. `contact_id`라는 경로 변수를 가진 경로를 매핑합니다.
2. 핸들러는 이 경로 매개변수의 값을 사용합니다.
3. 해당 연락처를 조회합니다.
4. `show.html` 템플릿을 렌더링합니다.

코드의 첫 번째 줄에서 경로에서 값을 추출하는 구문을 볼 수 있습니다: 원하는 경로의 일부를 `<>`로 감싸고 이름을 지정합니다. 이 경로의 구성요소는 추출되어 동일한 이름을 가진 매개변수를 통해 핸들러 함수에 전달됩니다.

따라서 `/contacts/42` 경로로 이동하게 되면, 값 `42`가 `contacts_view()` 함수에서 `contact_id`의 값으로 전달됩니다.

우리가 조회하고자 하는 연락처의 ID를 얻은 후, 우리는 `Contact` 객체에서 `find` 메서드를 사용하여 이를 로드합니다. 그런 다음 해당 연락처를 `show.html` 템플릿에 전달하고 응답을 렌더링합니다.

==== 연락처 상세 템플릿 <_the_contact_detail_template>
우리의 `show.html` 템플릿은 상대적으로 간단하며, 표와 같은 정보를 약간 다른 형식으로 보여줍니다(아마도 인쇄용). 나중에 애플리케이션에 "메모"와 같은 기능을 추가하는 경우, 이곳이 적절한 장소가 될 것입니다.

다시 한 번, 템플릿의 "크롬"을 생략하고 주요 내용에 집중하겠습니다:

#figure(caption: [연락처 세부정보 템플릿],
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

우리는 간단히 이름과 성의 헤더를 렌더링하며, 그 아래에 추가 연락처 정보를 표시하고, 두 개의 링크(연락처를 편집하기 위한 링크와 모든 연락처 목록으로 돌아가기 위한 링크)를 포함합니다.

==== 연락처 편집 및 삭제 <_editing_and_deleting_a_contact>
다음으로 "편집" 링크의 다른 측면에 대한 기능을 다루겠습니다. 연락처 편집은 새로운 연락처를 추가하는 것과 매우 유사할 것입니다. 새로운 연락처를 추가하는 것과 마찬가지로, 우리는 동일한 경로를 처리하는 두 개의 경로가 필요할 것입니다. 그러나 다른 HTTP 방법을 사용하는: `GET`은 `/contacts/<contact_id>/edit`로 요청하면 연락처를 편집할 수 있는 양식을 반환하고, 해당 경로에 `POST` 요청을 보내면 편집한 내용을 업데이트합니다.

우리는 또한 이 편집 기능과 함께 연락처 삭제 기능을 추가할 것입니다. 이를 위해 `/contacts/<contact_id>/delete`에 대한 `POST`를 처리해야 합니다.

다음은 `GET`을 처리하는 코드를 살펴봅시다. 이 코드는 주어진 리소스에 대한 편집 인터페이스의 HTML 표현을 반환하게 됩니다:

#figure(caption: [연락처 편집 컨트롤러 코드],
```python
@app.route("/contacts/<contact_id>/edit", methods=["GET"])
def contacts_edit_get(contact_id=0):
    contact = Contact.find(contact_id)
    return render_template("edit.html", contact=contact)
```)

보시다시피, 이는 "연락처 보기" 기능과 매우 유사합니다. 사실, 템플릿이 다를 뿐 거의 동일합니다: 여기서는 `show.html`이 아니라 `edit.html`을 렌더링합니다.

우리 핸들러 코드는 "연락처 보기" 기능과 유사해 보이지만, `edit.html` 템플릿은 "새 연락처" 기능의 템플릿과 매우 유사합니다. 즉, 우리는 연락처의 모든 필드를 입력하기 위한 입력 필드를 포함하여 업데이트된 연락처 값을 제출하는 양식을 가집니다. 오류 메시지도 포함되어 있습니다.

다음은 양식의 첫 번째 부분입니다:

#figure(caption: [연락처 편집 양식 시작],
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

1. `/contacts/{{ contact.id }}/edit` 경로로 `POST` 요청을 발행합니다.
2. `new.html` 페이지와 유사하게 이 입력은 연락처의 이메일에 연결됩니다.

이 HTML은 우리의 `new.html` 양식과 거의 동일합니다. 그러나 이 양식은 업데이트 할 연락처의 ID를 기반으로 다른 경로에 `POST`를 제출할 것입니다. (여기에서 언급할 가치가 있는 것은, `POST` 대신에 `PUT`이나 `PATCH`를 선호할 수 있지만, 이는 일반 HTML에서는 불가능합니다.)

앞서 작성한 `new.html` 템플릿과 매우 유사한 양식의 나머지 부분과 양식을 제출하는 버튼이 다음과 같이 나옵니다:

#figure(caption: [연락처 편집 양식 본문],
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

템플릿의 마지막 부분에는 `new.html`과 `edit.html` 간에 약간의 차이가 있습니다. 주요 편집 양식 하단에 연락처를 삭제할 수 있는 두 번째 양식이 포함됩니다. 이는 `/contacts/<contact id>/delete` 경로로 `POST`를 발행합니다. 연락처를 업데이트하기 위해 `PUT`을 사용하고 싶지만, 이것도 일반 HTML에서는 불가능합니다.

페이지를 마무리하기 위해 연락처 목록으로 돌아가는 간단한 하이퍼링크가 있습니다.

#figure(caption: [연락처 편집 양식 바닥글],
```html
<form action="/contacts/{{ contact.id }}/delete" method="post">
  <button>Delete Contact</button>
</form>

<p>
  <a href="/contacts/">Back</a>
</p>
```)

new.html`과 `edit.html` 템플릿 간의 유사성을 모두 고려할 때, 우리는 이 두 템플릿을 _리팩터링_하여 서로 간에 로직을 공유하지 않는 이유가 궁금해질 수 있습니다. 이는 좋은 관찰이며, 프로덕션 시스템에서는 아마 그렇게 할 것입니다.

그러나 우리의 목적상 우리의 애플리케이션이 작고 단순하므로 각 템플릿을 별도로 두겠습니다.

#sidebar[애플리케이션 리팩터링에 대한 사항][
  #index[factoring]
  하이퍼미디어 애플리케이션에 대한 JavaScript 배경에서 오는 사람들을 혼란스럽게 하는 한 가지는 "컴포넌트"라는 개념입니다. JavaScript 지향 애플리케이션에서 애플리케이션을 작은 클라이언트 측 컴포넌트로 나누고 이를 함께 구성하는 것이 일반적입니다. 이러한 컴포넌트는 종종 격리된 상태에서 개발되고 테스트됩니다. 이러한 방식은 개발자가 테스트 가능한 코드를 작성하는 데 유용한 추상화를 제공합니다.

  그러나 하이퍼미디어 기반 애플리케이션의 경우, 서버 측에서 애플리케이션을 리팩터링합니다. 위의 양식은 편집 및 생성 템플릿 간의 공유 템플릿으로 리팩터링할 수 있으며, 재사용 가능하고 DRY(중복 제거) 구현을 달성할 수 있습니다.

  서버 측 리팩터링은 클라이언트 측 리팩터링보다 더욱 공동으로 이루어지는 경향이 있습니다: 일반적으로 개별 컴포넌트를 만드는 것보다 공통 _섹션_을 나누는 경향이 있습니다. 이점(단순해 보이긴 하나)과 단점(클라이언트 측 컴포넌트처럼 완전히 고립되지 않을 수 있음)이 있습니다.

  전반적으로 적절하게 리팩터링 된 서버 측 하이퍼미디어 애플리케이션은 매우 DRY 할 수 있습니다.
]

===== /contacts/\<contact\_id\>/edit에 대한 POST 처리 <_handling_the_post_to_contactscontact_id>
이제 `edit.html` 템플릿의 양식이 제출하는 HTTP `POST` 요청을 처리해야 합니다. 위의 `GET`와 동일한 경로를 처리하는 또 다른 경로를 선언할 것입니다.

다음은 새로운 핸들러 코드입니다:

#index[POST 요청]
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

1. `/contacts/<contact_id>/edit`에 대한 `POST`를 처리합니다.
2. ID로 연락처를 조회합니다.
3. 양식에서 입력된 새 정보로 연락처를 업데이트합니다.
4. 저장을 시도합니다.
5. 성공하면 성공 메시지를 플래시하고 세부 페이지로 리다이렉션합니다.
6. 실패하면 빈렌더링합니다, 그때의 오류를 사용자에게 보여줍니다.

이 핸들러의 논리는 새로운 연락처를 추가하는 핸들러의 논리와 매우 유사합니다. 실제 차이점은 새 Contact을 생성하는 대신 ID로 연락처를 조회하고 이후에 양식에서 입력된 값으로 업데이트 메서드를 호출한다는 점입니다.

다시 말하지만, CRUD 작업 간의 일관성은 전통적인 CRUD 웹 애플리케이션의 좋은 측면 중 하나입니다.

==== 연락처 삭제하기 <_deleting_a_contact>

#index[Post/Redirect/Get (PRG)]
우리는 연락처 삭제 기능을 연락처 편집 템플릿과 함께 추가했습니다. 이 두 번째 양식은 `/contacts/<contact_id>/delete` 경로에 대한 HTTP `POST`를 발행하며, 해당 경로에 대한 핸들러도 만들어야 합니다.

컨트롤러는 다음과 같이 생겼습니다:

#figure(caption: [연락처 삭제 컨트롤러 코드],
```python
@app.route("/contacts/<contact_id>/delete", methods=["POST"]) <3>
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete() <2>
    flash("Deleted Contact!")
    return redirect("/contacts") <3>
```)

1. `/contacts/<contact_id>/delete` 경로에 대한 `POST`를 처리합니다.
2. 연락처를 조회한 후 그 연락처에서 `delete()` 메서드를 호출합니다.
3. 성공 메시지를 플래시하고 연락처 목록으로 리다이렉션합니다.

핸들러 코드는 매우 단순합니다. 검증이나 조건부 로직이 필요하지 않기 때문에 실제로는 연락처를 조회하는 방법을 동일하게 수행하여 이를 `delete()` 메서드로 호출한 다음, 성공 플래시 메시지를 따르며 연락처 목록으로 리디렉션합니다.

이 경우 템플릿이 필요하지 않으며, 연락처는 삭제됩니다.

==== Contact.app... 구현 완료! <_contact_app_implemented>
그리고, 믿거나 말거나, 이것이 전체 연락처 애플리케이션입니다!

지금까지의 코드 부분에서 어려움이 있었다면 걱정하지 마세요: 우리는 여러분이 파이썬이나 Flask 전문가가 되기를 기대하지 않습니다(우리는 그렇지 않습니다!). 여러분이 이 책의 나머지 부분에서 이들 언어가 어떻게 작동하는지에 대한 기본적인 이해만 필요합니다.

이것은 작고 간단한 애플리케이션이지만, 전통적인 웹 1.0 애플리케이션의 많은 측면을 보여줍니다: CRUD, Post/Redirect/Get 패턴, 컨트롤러에서 도메인 논리 작업하기, 일관성 있는 리소스 지향적 방식으로 URL 구성하기.

게다가, 이는 깊이 있는 _하이퍼미디어 기반_ 웹 애플리케이션입니다. 우리가 이에 대해 많은 고민 없이 하이퍼미디어처럼 REST, HATEOAS 및 앞서 논의했던 모든 하이퍼미디어 개념을 사용해 왔습니다. 우리는 이 간단한 연락처 앱이 지금까지 만들어진 99% 이상의 JSON API보다 더 RESTful이라고 장담할 수 있습니다!

하이퍼미디어인 HTML을 사용하기 때문에, 우리는 자연스럽게 RESTful 네트워크 아키텍처에 얽히게 됩니다.

그래서 그거 굉장하군요. 그런데 이 작은 웹 애플리케이션의 문제는 무엇일까요? 왜 여기서 끝내고 웹 1.0 스타일 애플리케이션을 개발하러 떠나지 않습니까?

어떤 측면에서는 아무런 문제가 없다. 특히 이처럼 단순한 애플리케이션의 경우, 이전 방식으로 웹 앱을 구축하는 것이 전적으로 허용 가능할 수 있습니다.

그러나 우리의 애플리케이션은 앞서 언급한 "무거움"을 겪고 있습니다: 모든 요청이 전체 화면을 교체하여 페이지 간 탐색 시 눈에 띄는 깜박임을 유발합니다. 스크롤 상태를 잃게 되며, 더 정교한 웹 애플리케이션에서는 클릭해야 할 횟수가 더 많아집니다.

이 시점에서 Contact.app은 "현대" 웹 애플리케이션처럼 느껴지지 않습니다.

자바스크립트 프레임워크와 JSON API에 손을 뻗쳐서 연락처 애플리케이션을 더 상호작용적으로 만드는 것이 좋을까요?

아니요. 그렇지 않습니다.

사실 우리가 기본 하이퍼미디어 아키텍처를 유지하면서도 사용자 경험을 개선할 수 있습니다.

다음 몇 장에서는 #link("https://htmx.org")[htmx]라는 하이퍼미디어 중심 라이브러리를 살펴보며, 지금까지 사용한 하이퍼미디어 기반 접근 방식을 유지하면서 연락처 애플리케이션을 개선할 것입니다.

#html-note[프레임워크 수프][
#index[components]
컴포넌트는 페이지의 섹션과 그 동적 동작을 캡슐화합니다. 동작을 캡슐화하는 것은 코드를 구성하는 좋은 방법이지만, 주변 맥락과 요소를 분리스럽게 이해의 어려움과 잘못된 또는 부적절한 관계를 초래할 수 있습니다. 결과적으로 사람들이 _컴포넌트 수프_라고 부를 수 있는 상황이 될 수 있으며, 여기서는 정보가 컴포넌트 상태에 숨겨져 있고, 구성 요소가 없는 HTML는 이제 이해할 수 없게 됩니다.

재사용을 위해 컴포넌트를 사용하기 전에 선택 사항을 고려하십시오. 낮은 수준의 메커니즘은 종종 더 나은 HTML을 생성할 수 있습니다. 경우에 따라 컴포넌트는 실제로 HTML의 명확성을 _개선_할 수 있습니다.

#blockquote(
  attribution:[Manuel Matuzović, #link(
      "https://www.matuzo.at/blog/2023/single-page-applications-criticism",
    )[왜 나는 단일 페이지 애플리케이션의 최대 팬이 아닌가]],
)[
  HTML 문서는 여러분이 거의 만지지 않는 것입니다. 필요한 모든 내용이 JavaScript를 통해 주입되기 때문에 문서와 페이지 구조가 초점에서 벗어납니다.
]

`<div>` 수프(혹은 마크다운 수프, 컴포넌트 수프)를 피하기 위해, 생성 중인 마크업을 인식하고 변경할 수 있어야 합니다.

일부 SPA 프레임워크와 웹 구성 요소는 개발자가 작성한 코드와 생성된 마크업 사이에 여러 추상화를 배치하여 이를 더 어렵게 만들 수 있습니다.

이러한 추상화는 개발자가 더욱 풍부한 UI를 만들거나 더 빠르게 작업할 수 있도록 할 수 있지만, 그들의 확산성 때문에 개발자는 클라이언트에게 전송되는 실제 HTML(및 JavaScript)를 잃어버릴 수 있습니다. 근본적인 테스트가 없으면 이는 접근 불가능성과 열악한 SEO, 불필요한 대량을 초래할 수 있습니다.
]
