== 더 많은 Htmx 패턴

=== 액티브 검색 <_active_search>
지금까지 Contact.app을 통해 적절한 "연락처 삭제" 버튼을 추가하고 입력에 대한 동적 유효성 검사를 수행하며, 애플리케이션에 페이지 기능을 추가하는 다양한 접근 방식에 대해 알아보았습니다. 많은 웹 개발자들은 이러한 기능을 구현하기 위해 많은 JavaScript 기반의 스크립팅이 필요할 것이라고 예상하겠지만, 우리는 모든 것을 상대적으로 순수한 HTML만으로, htmx 속성만 사용하여 수행했습니다.

결국 우리는 애플리케이션에 클라이언트 측 스크립팅을 추가할 것입니다: 하이퍼미디어는 강력하지만 _모든 것을 할 수 있는_ 것은 아니며 때로는 특정 목표를 달성하기 위해 스크립팅이 최선의 방법일 수 있습니다. 하지만 지금은 하이퍼미디어로 우리가 성취할 수 있는 것을 보겠습니다.

우리가 만들 첫 번째 고급 htmx 기능은 "액티브 검색" 패턴으로 알려져 있습니다. 액티브 검색은 사용자가 검색 상자에 텍스트를 입력할 때 그 검색 결과가 동적으로 표시되는 경우를 말합니다. 이 패턴은 Google이 검색 결과에 채택하면서 인기를 끌었으며, 많은 애플리케이션에서 구현하고 있습니다.

액티브 검색을 구현하기 위해 우리는 이전 장에서 이메일 유효성 검사를 수행한 방법과 밀접하게 관련된 기술을 사용할 것입니다. 생각해 보면, 두 기능은 여러 면에서 유사합니다: 두 경우 모두 사용자가 입력할 때 요청을 발행하고 응답으로 다른 요소를 업데이트하고자 합니다. 서버 측 구현은 물론 매우 다르지만, htmx의 일반적인 접근 방식인 "이벤트에서 요청을 발행하고 화면의 무언가를 교체하다" 덕분에 프런트엔드 코드는 상당히 비슷해 보일 것입니다.

==== 현재 검색 UI <_our_current_search_ui>
우리 애플리케이션의 검색 필드가 현재 어떻게 생겼는지 다시 한번 살펴보겠습니다:

#figure(caption: [우리의 검색 양식],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">검색어</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}"> <1>
  <input type="submit" value="검색"/>
</form>
```)
1. 클라이언트 측 코드가 사용하여 검색하기 위한 `q` 또는 "쿼리" 매개변수입니다.

서버 측에는 `q` 매개변수를 확인하고, 존재할 경우 해당 용어로 연락처를 검색하는 코드가 있습니다.

현재 사용자는 검색 입력란에 포커스가 있을 때 엔터를 입력하거나 "검색" 버튼을 클릭해야 합니다. 이 두 이벤트는 `submit` 이벤트를 트리거하여 HTTP `GET`을 발행하고 페이지 전체를 다시 렌더링하게 됩니다.

현재 `hx-boost` 덕분에 이 양식은 AJAX 요청을 사용하고 있습니다. 그러나 여전히 우리가 원하는 동작인 "입력하는 대로 검색" 기능은 얻지 못합니다.

==== 액티브 검색 추가하기 <_adding_active_search>

#index[htmx patterns][active search]
액티브 검색 기능을 추가하기 위해 우리는 검색 입력란에 몇 가지 htmx 속성을 부착할 것입니다. 현재 양식은 그대로 유지하면서 `action`과 `method` 속성을 남겨두어 사용자가 JavaScript를 사용하지 않더라도 정상적인 검색 기능이 작동하도록 할 것입니다. 이를 통해 우리의 "액티브 검색" 개선이 멋진 "점진적 향상"이 될 것입니다.

따라서 일반적인 양식 동작 외에도, 키가 올라갈 때 HTTP `GET` 요청을 발행하고자 합니다. 이 요청은 일반적인 양식 제출과 동일한 URL로 발행되어야 합니다. 마지막으로, 사용자가 입력을 멈춘 후에는 잠시 기다렸다가 이 요청을 발행하고 싶습니다.

우리가 말했듯이, 이 기능은 이메일 유효성 검사 시 필요했던 기능과 매우 유사합니다. 사실 우리는 200밀리초의 짧은 지연을 허용하여 사용자가 요청이 발행되기 전에 입력을 멈추게 하는 `hx-trigger` 속성을 이메일 유효성 검사 예제에서 그대로 복사할 수 있습니다.

이것은 htmx를 사용할 때 공통 패턴이 반복적으로 나타나는 또 다른 예입니다.

#figure(caption: [액티브 검색 동작 추가],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">검색어</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}" <1>
    hx-get="/contacts" <2>
    hx-trigger="search, keyup delay:200ms changed"/> <3>
  <input type="submit" value="검색"/>
</form>
```)
1. 검색이 JavaScript가 없더라도 작동할 수 있도록 원래 속성을 유지합니다.
2. 양식과 동일한 URL에 `GET` 요청을 발행합니다.
3. 이메일 입력 유효성 검사 시와 거의 동일한 `hx-trigger` 사양입니다.

우리는 `hx-trigger` 속성에 대해 약간의 변경을 했습니다: `change` 이벤트를 `search` 이벤트로 변경했습니다. `search` 이벤트는 누군가 검색을 지우거나 엔터 키를 누를 때 트리거됩니다. 비표준 이벤트지만, 여기 포함하는 데 손해는 없습니다. 이 기능의 주요 기능은 두 번째 트리거링 이벤트인 `keyup`에 의해 제공됩니다. 이메일 예제와 마찬가지로 이 트리거는 `delay:200ms` 수식어로 지연되어 입력 요청을 디바운스하여 서버에 요청을 과도하게 보내는 것을 방지합니다.

==== 올바른 요소 타겟팅하기 <_targeting_the_correct_element>
우리가 가진 것은 우리가 원하는 것에 가까워졌지만, 올바른 타겟을 설정해야 합니다. 기본적으로 요소의 기본 타겟은 자신입니다. 현재 상태로는 HTTP `GET` 요청이 `/contacts` 경로로 발행되며, 현재로서는 전체 HTML 문서의 검색 결과를 반환하게 됩니다. 그런 다음 이 전체 문서가 검색 입력의 _내부_ HTML에 삽입될 것입니다.

사실 이것은 말이 되지 않습니다: `input` 요소는 내부에 어떤 HTML도 포함할 수 없습니다. 브라우저는 반듯이 htmx 요청의 응답 HTML을 입력에 넣도록 무시할 것입니다. 따라서 현재 사용자가 입력에 무언가를 입력하더라도 요청이 발행되겠지만 (브라우저 개발 콘솔에서 확인할 수 있습니다), 불행히도 사용자에게는 아무 일도 일어나지 않은 것처럼 보일 것입니다.

이 문제를 해결하려면 업데이트할 항목을 무엇으로 설정할지를 결정해야 합니다. 이상적으로는 실제 결과만을 타겟으로 하고 싶습니다: 헤더나 검색 입력이 업데이트될 이유가 없으며, 사용자가 포커스를 전환할 때 불쾌한 플래시가 발생할 수 있습니다.

`hx-target` 속성을 사용하면 이를 정확하게 수행할 수 있습니다. 결과 본문인 연락처 테이블의 `tbody` 요소를 타겟으로 하겠습니다:

#figure(caption: [액티브 검색 동작 추가],
```html
<form action="/contacts" method="get" class="tool-bar">
  <label for="search">검색어</label>
  <input id="search" type="search" name="q"
    value="{{ request.args.get('q') or '' }}"
    hx-get="/contacts"
    hx-trigger="search, keyup delay:200ms changed"
    hx-target="tbody"/> <1>
  <input type="submit" value="검색"/>
</form>
<table>
  ...
  <tbody>
    ...
  </tbody>
</table>
```)
1. 페이지의 `tbody` 태그를 타겟으로 합니다.

페이지에 `tbody`가 하나뿐이므로, 일반 CSS 선택자인 `tbody`를 사용하고 htmx는 페이지의 테이블 본문을 타겟으로 할 것입니다.

이제 검색 상자에 무언가를 입력해보면 결과를 볼 수 있습니다: 요청이 발행되고 결과가 `tbody` 내의 문서에 삽입됩니다. 불행히도, 돌아오는 콘텐츠는 여전히 전체 HTML 문서입니다.

여기서 우리는 "이중 렌더링" 상황에 처하게 되며, 전체 문서가 _다른 요소 안에_ 삽입되고 모든 탐색, 헤더, 바닥글 등이 해당 요소 내에서 다시 렌더링됩니다. 이것은 우리가 앞서 언급한 잘못된 타겟팅 문제의 예입니다.

다행히도 이것을 수정하는 것은 매우 간단합니다.

==== 콘텐츠 간소화하기 <_paring_down_our_content>
이제 우리는 "클릭하여 로드" 및 "무한 스크롤" 기능에서 사용한 것과 같은 트릭을 사용할 수 있습니다: `hx-select` 속성입니다. `hx-select` 속성은 응답에서 우리가 관심 있는 부분을 CSS 선택기를 사용하여 선택할 수 있게 해줍니다.

따라서 다음과 같이 입력에 추가할 수 있습니다:

#figure(caption: [액티브 검색을 위한 "hx-select" 사용],
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="change, keyup delay:200ms changed"
  hx-target="tbody"
  hx-select="tbody tr"/> <1>
```)
1. 응답의 `tbody`에서 테이블 행을 선택하는 `hx-select` 추가.

하지만 이것이 이 문제에 대한 유일한 해결 방법은 아니며, 이 경우 가장 효율적인 방법도 아닙니다. 대신, 우리의 하이퍼미디어 기반 애플리케이션의 _서버 측_ 코드를 수정하여 _필요한 HTML 콘텐츠만_ 제공하는 것을 고려해 보겠습니다.

==== Htmx의 HTTP 요청 헤더 <_http_request_headers_in_htmx>
이 섹션에서는 전체 문서가 아닌 _부분적인_ HTML만 원하는 상황을 처리하기 위한 보다 발전된 기술을 살펴보겠습니다. 현재 우리는 서버가 전체 HTML 문서를 생성하여 응답하고, 클라이언트 측에서 우리가 원하는 부분만 필터링하도록 허용하고 있습니다. 이 작업은 쉽고, 사실 서버 측을 제어할 수 없거나 응답을 쉽게 수정할 수 없는 경우 필요할 수 있습니다.

그러나 애플리케이션에서 "풀 스택" 개발을 하고 있으므로 (즉, 프런트엔드와 백엔드 코드를 모두 제어하고 쉽게 수정할 수 있음), 서버 응답을 수정하여 필요한 내용만 반환하고 클라이언트 측에서 필터링할 필요성을 제거할 수 있는 또 다른 옵션이 있습니다.

이렇게 하면 우리는 관심 있는 부분에 대한 콘텐츠만 반환하며, 주변 콘텐츠를 반환하지 않기 때문에 대역폭 및 CPU와 메모리를 절약할 수 있습니다. 따라서 htmx가 제공하는 컨텍스트 정보를 기반으로 서로 다른 HTML 콘텐츠를 반환하는 방법을 살펴보겠습니다.

현재의 검색 로직에 대한 서버 측 코드를 다시 살펴보겠습니다:

#figure(caption: [서버 측 검색],
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
1. 여기서 검색 로직이 발생합니다.
2. 매번 `index.html` 템플릿을 다시 렌더링합니다. 무슨 경우라도 말입니다.

어떻게 바꾸고 싶습니까? 우리는 두 가지 다른 HTML 콘텐츠를 _조건부로_ 렌더링하고 싶습니다:
- 만약 이 요청이 전체 페이지에 대한 "정상" 요청이라면, 현재 방식으로 `index.html` 템플릿을 렌더링해야 합니다. 사실, "정상" 요청인 경우 아무것도 변경되지 않기를 원합니다.
- 그러나 만약 이것이 "액티브 검색" 요청이라면, 우리는 페이지의 `tbody` 안에 있는 내용만 렌더링하고자 합니다.

따라서 이 `/contact` URL에 대한 두 가지 유형의 요청 중 어느 것이 이루어지고 있는지 정확하게 확인할 방법이 있어야 합니다.

htmx는 요청할 때 여러 HTTP _요청 헤더_를 포함하여 이 두 경우를 구별하는 데 도움을 줍니다. 요청 헤더는 HTTP의 기능으로, 클라이언트(예: 웹 브라우저)가 요청과 관련된 메타데이터를 포함한 이름/값 쌍을 서버에 제공하여 요청하는 내용을 이해하는 데 도움을 줍니다.

다음은 FireFox 브라우저가 `https://hypermedia.systems`를 요청할 때 발행하는(일부) 헤더의 예입니다:

#figure(caption: [HTTP 헤더],
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
```

Htmx는 이 HTTP 기능을 활용하여 추가적인 헤더와 따라서 HTTP 요청에 대한 추가적인 _맥락_을 추가합니다. 이렇게 하면 이러한 헤더를 검사하고 서버에서 실행할 논리를 선택하며 클라이언트에 송신할 HTML 응답의 종류를 선택할 수 있습니다.

다음은 htmx가 HTTP 요청에 포함하는 HTTP 헤더의 목록입니다:

- `HX-Boosted`: #[
    요청이 hx-boost를 사용한 요소를 통해 발행되면 이 값은 "true"입니다.
]

- `HX-Current-URL`: #[ 
    브라우저의 현재 URL입니다.
]

- `HX-History-Restore-Request`: #[
    이 헤더는 요청이 로컬 히스토리 캐시에서 누락된 후에 기록 복원을 위한 경우 "true"입니다.
]

- `HX-Prompt`: #[ 
    이는 hx-prompt에 대한 사용자 응답을 포함합니다.
]

- `HX-Request`: #[
    이 값은 htmx 기반 요청에 대해 항상 "true"입니다.
]

- `HX-Target`: #[
    이 값은 타겟 요소의 ID가 존재할 경우 해당 ID입니다.
]

- `HX-Trigger-Name`: #[
    이 값은 트리거된 요소의 이름이 존재할 경우 해당 이름입니다.
]

- `HX-Trigger`: #[
    이 값은 트리거된 요소의 ID가 존재할 경우 해당 ID입니다.
]

이 헤더 목록을 살펴보면, 마지막 헤더가 두드러집니다: 검색 입력에 `search` 아이디가 있습니다. 따라서 요청이 검색 입력에서 발생할 경우 `HX-Trigger` 헤더의 값은 `search`로 설정됩니다.

이 헤더를 찾아보고 값이 `search`인 경우 테이블 행만 렌더링하도록 컨트롤러에 조건부 논리를 추가하겠습니다:

#figure(caption: [서버 측 검색 업데이트],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    if search is not None:
        contacts_set = Contact.search(search)
        if request.headers.get('HX-Trigger') == 'search': <1>
          # TODO: 여기에 행만 렌더링 <2>
    else:
  contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set)
```
1. 요청 헤더 `HX-Trigger`가 "search"인 경우 다른 작업을 수행합니다.
2. 행만 렌더링하는 방법을 배워야 합니다.

좋습니다. 그렇다면 결과 행만 렌더링하는 방법은 무엇일까요?

==== 템플릿 간소화하기 <_factoring_your_templates>
이제 htmx에서 일반적인 패턴 중 하나가 나타났습니다: 서버 측 템플릿을 _소분_해야 합니다. 이것은 템플릿을 약간 나누어 여러 상황에서 호출할 수 있도록 하려는 것입니다. 이 경우 결과 테이블의 행을 별도의 템플릿으로 분리하고, `rows.html`이라고 부르겠습니다. 우리는 `index.html` 템플릿에서 이 파일을 포함하고, 이 파일을 사용할 때는 액티브 검색 요청에 대한 응답으로 행만 렌더링하도록 컨트롤러에서 이 파일을 사용할 것입니다.

다음은 현재의 `index.html` 파일에서 테이블이 어떻게 생겼는지 보여줍니다:

#figure(caption: [연락처 테이블],
```html
<table>
  <thead>
  <tr>
    <th>이름 <th>성 <th>전화 <th>이메일 <th/>
  </tr>
  </thead>
  <tbody>
  {% for contact in contacts %}
    <tr>
      <td>{{ contact.first }}</td>
      <td>{{ contact.last }}</td>
      <td>{{ contact.phone }}</td>
      <td>{{ contact.email }}</td>
      <td><a href="/contacts/{{ contact.id }}/edit">수정</a>
        <a href="/contacts/{{ contact.id }}">보기</a></td>
    </tr>
  {% endfor %}
  </tbody>
</table>
```

이 템플릿의 `for` 루프는 `index.html`에 의해 생성된 최종 콘텐츠의 모든 행을 만들어냅니다. 우리가 하고 싶은 것은 `for` 루프, 따라서 그것이 만드는 행을 _별도의 템플릿 파일_로 이동하여 이 작은 HTML을 독립적으로 렌더링할 수 있도록 하는 것입니다.

다시 말해, 이 새로운 템플릿을 `rows.html`이라고 부르겠습니다:

#figure(caption: [우리의 새로운 `rows.html` 파일],
```html
{% for contact in contacts %}
  <tr>
    <td>{{ contact.first }}</td>
    <td>{{ contact.last }}</td>
    <td>{{ contact.phone }}</td>
    <td>{{ contact.email }}</td>
    <td><a href="/contacts/{{ contact.id }}/edit">수정</a>
      <a href="/contacts/{{ contact.id }}">보기</a></td>
  </tr>
{% endfor %}
```

이 템플릿을 사용하면 주어진 연락처 컬렉션에 대한 `tr` 요소만 렌더링할 수 있습니다.

물론 이 콘텐츠를 `index.html` 템플릿에 포함하고 싶습니다: 우리는 _때때로_ 전체 페이지를 렌더링할 것이고, 때때로 행만 렌더링할 것입니다. `index.html` 템플릿이 제대로 렌더링되도록 유지하려면, 우리가 삽입할 `rows.html` 콘텐츠의 위치에 `include` 지시어를 사용하여 삽입해야 합니다:

#figure(caption: [새 파일 포함],
```html
<table>
  <thead>
  <tr>
    <th>이름</th>
    <th>성</th>
    <th>전화</th>
    <th>이메일</th>
    <th></th>
  </tr>
  </thead>
  <tbody>
  {% include 'rows.html' %} <1>
  </tbody>
</table>
```
1. 이 지시어는 `rows.html` 파일을 "포함하여" 그 콘텐츠를 현재 템플릿에 삽입합니다.

지금까지 괜찮습니다: 우리의 `/contacts` 페이지는 여전히 이전과 같이 올바르게 렌더링됩니다. `index.html` 템플릿에서 행을 분리한 이후에도 말입니다.

==== 새로운 템플릿 사용하기 <_using_our_new_template>
템플릿을 분리하는 마지막 단계는, 액티브 검색 요청에 응답할 때 새로운 `rows.html` 템플릿 파일을 활용하도록 웹 컨트롤러를 수정하는 것입니다.

`rows.html`도 다른 템플릿이며, `index.html`과 마찬가지로 `render_template` 함수를 호출하여 `rows.html`을 사용하면 됩니다. 이는 _오직_ 연락처에 대한 행 콘텐츠만 렌더링합니다:

#figure(caption: [서버 측 검색 업데이트],
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
```
1. 액티브 검색의 경우 새로운 템플릿을 렌더링합니다.

이제 액티브 검색 요청이 오면, 전체 HTML 문서 대신에 검색과 일치하는 연락처의 테이블 행만 포함된 부분적인 HTML을 받게 됩니다. 그런 다음 이러한 행은 `index` 페이지의 `tbody`에 삽입되며, `hx-select`나 다른 클라이언트 측 처리 없이도 가능합니다.

그리고 추가로, 이전의 폼 기반 검색은 여전히 작동합니다. 우리는 `search` 입력이 htmx를 통해 HTTP 요청을 발행할 때만 행을 조건부로 렌더링합니다. 이 또한 애플리케이션에 대한 점진적 향상입니다.

#sidebar[HTTP 헤더 및 캐싱][여기서 우리가 추구하는 접근 방식의 한 미묘한 측면은, 반환하는 콘텐츠를 결정하기 위해 헤더를 사용하는 것입니다. 이는 HTTP의 내장된 기능: 캐싱입니다. 요청 처리기에서는 이제 `HX-Trigger` 헤더 값에 따라 서로 다른 콘텐츠를 반환하고 있습니다. 만약 HTTP 캐싱을 사용하게 되면, 사용자가 _비-htmx_ 요청을 만들고 (예: 페이지를 새로 고침) _htmx_ 콘텐츠가 HTTP 캐시에서 반환되어 사용자에게 부분 페이지 콘텐츠가 나타나는 상황에 처할 수 있습니다.

이 문제의 해결책은 요청하는 콘텐츠를 결정하기 위해 사용하는 htmx 헤더를 강조하는 HTTP 응답 `Vary` 헤더를 사용하는 것입니다. HTTP 캐싱에 대한 완전한 설명은 이 책의 범위를 넘지만, 
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching",
)[주제에 대한 MDN 기사]
가 매우 좋으며, 
#link("https://htmx.org/docs/#caching")[htmx 문서]는 이 문제에 대해 논의합니다.]

==== "hx-push-url"로 탐색 바 업데이트하기 <_updating_the_navigation_bar_with_hx_push_url>
현재의 액티브 검색 구현의 단점 중 하나는, 일반 폼 제출과 비교했을 때 사용자가 폼 버전을 제출하면 탐색 바가 검색어를 포함하도록 업데이트된다는 점입니다. 예를 들어, 검색 상자에서 "joe"를 검색하면 브라우저의 탐색 바에 다음과 같은 URL이 나타납니다:

#figure(caption: [폼 검색 후 업데이트된 위치],
```
https://example.com/contacts?q=joe
```

이는 브라우저의 멋진 기능입니다: 이를 통해 사용자는 검색을 북마크하거나 URL을 복사하여 다른 사람에게 보낼 수 있습니다. 그들이 링크를 클릭하기만 하면 정확히 동일한 검색이 반복됩니다. 이것은 브라우저의 히스토리 개념과도 연결됩니다: 사용자가 뒤로 버튼을 클릭하게 되면 그들이 이전에 오던 URL로 돌아갑니다. 두 번 검색을 제출한 후 처음으로 돌아가고 싶다면 단순히 뒤로 버튼을 눌러 브라우저가 그 검색으로 "되돌아가게" 할 수 있습니다.

#index[htmx patterns][뒤로 버튼 지원]
현재 상태로는 액티브 검색 중에 브라우저의 탐색 바를 업데이트하고 있지 않습니다. 따라서 사용자는 복사 및 붙여넣기할 수 있는 링크를 얻지 못하며, 히스토리 항목도 받지 못하므로 뒤로 버튼 지원이 없습니다. 다행히도 우리는 이를 해결하는 방법을 이미 알고 있습니다: `hx-push-url` 속성을 사용하여.

`hx-push-url` 속성은 htmx에 "이 요청의 URL을 브라우저의 탐색 바에 밀어넣으세요."라고 말할 수 있게 해줍니다. "푸시"라는 용어는 다소 이상하게 보일 수 있지만, 이는 기본 브라우저 히스토리 API의 용어에서 비롯된 것입니다. 히스토리를 "스택"으로 모델링하기 때문에 새로운 위치로 이동할 때 그 위치가 히스토리 요소의 스택에 "푸시"됩니다. 그리고 "뒤로"를 클릭할 때 해당 위치는 히스토리 스택에서 "팝"됩니다.

따라서 우리의 액티브 검색에 적절한 히스토리 지원을 얻기 위해서는 `hx-push-url` 속성을 `true`로 설정하면 됩니다.

#figure(caption: [액티브 검색 중 URL 업데이트,
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="change, keyup delay:200ms changed"
  hx-target="tbody"
  hx-push-url="true"/> <1>
```
1. `hx-push-url` 속성을 `true` 값으로 설정하면 htmx가 요청을 발행할 때 URL을 업데이트합니다.

이제 액티브 검색 요청이 발행될 때 브라우저의 탐색 바에서 URL이 올바른 쿼리를 가지도록 업데이트됩니다. 마치 폼이 제출된 것처럼요.

어쩌면 여러분은 이 동작이 _원치 않을 수 있습니다_. 예를 들어 사용자가 탐색 바 업데이트와 액티브 검색을 할 때마다 히스토리 항목을 만들면 혼란스러울 수 있다고 느낄 수도 있습니다. 이는 괜찮습니다: 단순히 `hx-push-url` 속성을 생략하면 여러분이 원하는 동작으로 돌아갈 것입니다. htmx의 목표는 선언적 HTML 모델 안에서 _여러분이 원하는_ UX를 달성할 수 있도록 충분히 유연하게 만드는 것입니다.

==== 요청 표시기 추가하기 <_adding_a_request_indicator>
액티브 검색 패턴에 대한 최종 손질은 사용자에게 검색이 진행 중임을 알리는 요청 표시기를 추가하는 것입니다. 현재 상태로는 사용자가 액티브 검색 기능이 요청을 처리하고 있다는 명시적인 신호가 없습니다. 검색에 시간이 걸리면 사용자는 기능이 작동하지 않는다고 생각할 수 있습니다. 요청 표시기를 추가함으로써 사용자에게 하이퍼미디어 애플리케이션이 사용 중이며 요청을 완료하기까지 기다려야 한다는 것을 알릴 수 있습니다 (희망적으로 너무 오래 기다리지 않기를!).

Htmx는 `hx-indicator` 속성을 통해 요청 표시기를 지원합니다. 이 속성은, 여러분이 추측했듯이, 주어진 요소에 대한 표시기를 가리킬 CSS 선택자를 수용합니다. 표시기는 무엇이든 될 수 있지만, 일반적으로 회전하는 gif나 svg 파일과 같은 애니메이션 이미지로 사용되며, "무언가가 진행 중이다"라는 시각적 신호를 전달합니다.

#index[htmx patterns][요청 표시기]
#index[hx-indicator]
검색 입력란 뒤에 스피너를 추가해봅시다:

#figure(caption: [검색에 요청 표시기 추가],
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
```
1. 요청 표시기 이미지를 입력 뒤에 지정하는 `hx-indicator` 속성.
2. 표시기는 회전하는 원형 svg 파일이며, `htmx-indicator` 클래스를 갖고 있습니다.

우리는 입력 뒤에 스피너를 추가했습니다. 이는 요청 표시기를 요청을 발행하는 요소와 시각적으로 동시 배치하게 해주며, 사용자가 실제로 무언가가 진행되고 있음을 쉽게 볼 수 있게 합니다.

그것은 작동하지만 htmx가 스피너를 어떻게 나타나게 하고 사라지게 하는지 궁금할 것입니다. 요청 표시기 이미지 태그는 `htmx-indicator` 클래스를 갖고 있는 것을 주목해보세요. `htmx-indicator`는 htmx가 페이지에 자동으로 삽입하는 CSS 클래스입니다. 이 클래스는 요소의 기본 `opacity`를 `0`으로 설정하여 해당 요소를 숨기면서도 페이지 레이아웃을 방해하지 않게 합니다.

요청이 해당 표시기에게 발행되면, 또 다른 클래스인 `htmx-request`가 표시기에 추가되어 `opacity`를 1로 전환합니다. 따라서 요청 표시기로는 거의 무엇이든 사용할 수 있으며, 기본적으로 숨겨져 있습니다. 그런 다음 요청이 진행 중일 때 표시됩니다. 이는 모두 표준 CSS 클래스들을 통해 진행되며, 전환 동작과 표시기가 표시되는 방식을 제어할 수 있습니다(예: `opacity` 대신 `display`를 사용할 수 있습니다).

#sidebar[요청 표시기를 사용하세요!][요청 표시기는 모든 분산 애플리케이션에서 중요한 UX 측면입니다. 시간이 지남에 따라 브라우저는 기본 제공 요청 표시기에 대한 강조를 줄였습니다. 그리고 요청 표시기는 JavaScript ajax API의 일부가 아니기 때문에 더욱 유감입니다.

이러한 애플리케이션의 중요한 측면을 놓치지 마세요. 요청은 로컬에서 애플리케이션을 작업할 때 instantaneous 같아 보일 수 있지만, 실제 세계에서는 네트워크 지연으로 인해 시간이 오래 걸릴 수 있습니다. 실제 사용자들이 보는 것을 더 잘 이해하게 하기 위해, 로컬 브라우저의 반응 시간을 제한할 수 있는 브라우저 개발 도구를 활용하는 것이 좋습니다. 이는 요청 표시기가 사용자가 무언가가 진행되고 있음을 이해하는 데 도울 수 있는 곳을 보여줄 것입니다.]

이 요청 표시기로 인해, 우리는 평범한 HTML에 비해 훨씬 정교한 사용자 경험을 갖게 되지만, 모든 것이 하이퍼미디어 주도 기능으로 구성되었습니다. JSON이나 JavaScript는 보이지 않습니다. 우리의 구현은 점진적 향상의 장점을 가지며, JavaScript가 활성화되지 않은 클라이언트에서도 애플리케이션이 계속 작동합니다.

===지연 로딩 <_lazy_loading>

#index[htmx patterns][지연 로딩]
액티브 검색을 마쳤으니, 이제 아주 다른 종류의 향상으로 이동해 보겠습니다: 지연 로딩. 지연 로딩은 특정 콘텐츠의 로딩이 필요할 때까지 지연되는 것을 의미합니다. 이는 일반적으로 성능 향상으로 사용되며, 실제로 필요한 데이터가 생성하는 데 필요한 처리 자원을 피하게 됩니다.

Contact.app에 연락처의 전체 수를 추가하여 연락처 테이블의 하단 바로 아래에 표시해보겠습니다. 이는 우리가 htmx로 지연 로딩을 추가하는 방법을 보여줄 수 있는 잠재적으로 비용이 많이 드는 작업이 될 것입니다.

먼저 `/contacts` 요청 처리기에서 서버 코드를 업데이트하여 연락처의 전체 수를 계산하도록 하겠습니다. 우리는 그 수를 템플릿으로 통과시켜 새로운 HTML을 렌더링할 것입니다.

#figure(caption: [UI에 카운트 추가],
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
```
1. Contact 모델에서 연락처의 전체 수를 가져옵니다.
2. 새 HTML을 렌더링할 때 사용할 수 있도록 카운트를 `index.html` 템플릿에 전달합니다.

애플리케이션의 나머지 부분과 마찬가지로, Contact.app의 하이퍼미디어 부분에 중점을 두기 위해 `Contact.count()`가 어떻게 작동하는지에 대한 세부 정보를 생략하겠습니다. 우리는 단지 다음과 같은 정보를 알아야 합니다:
- 연락처 데이터베이스의 총 수를 반환합니다.
- 느릴 수 있습니다(예시를 위해 좋게!).

다음으로, 이 새 데이터를 활용하여 `index.html`에 HTML을 추가하고 새로운 연락처를 추가하는 링크 옆에 총 사용자 수를 보여주는 메시지를 표시해 보겠습니다. 우리 HTML은 다음과 같습니다:

#figure(caption: [애플리케이션에 연락처 수 추가 요소],
```html
<p>
  <a href="/contacts/new">연락처 추가</a
  > <span>({{ count }}개의 총 연락처)</span> <1>
</p>
```
1. 총 연락처 수를 보여주는 간단한 span.

음, 그건 쉽지 않았나요? 이제 사용자는 새로운 연락처를 추가하는 링크 옆에 총 연락처 수를 보게 되어 연락처 데이터베이스의 크기를 알 수 있습니다. 이러한 급속한 개발은 구식 웹 애플리케이션 개발의 즐거움 중 하나입니다.

@fig-totalcontacts는 애플리케이션에서 기능이 어떻게 보일지 보여줍니다. 아름답습니다.

#figure(image("images/screenshot_total_contacts.png"),
  caption: [총 연락처 수 표시])<fig-totalcontacts>

물론, 여러분이 추측한 것처럼, 모든 것이 완벽하지는 않습니다. 불행히도 이 기능을 프로덕션에 배포하면서 사용자가 "애플리케이션이 느리게 느껴진다"는 불만이 접수되기 시작했습니다. 성능 문제에 직면한 모든 좋은 개발자들처럼, 우리는 문제를 일으키는 원인을 찾기 위해 애플리케이션의 성능 프로파일을 얻으려 합니다.

놀랍게도 문제는 겉보기에는 아무렇지도 않은 `Contacts.count()` 호출인데, 이는 1초에서 1.5초 정도 소요되는 것입니다. 안타깝게도 이 책의 범위를 넘어서는 이유로 인해 로드 시간을 개선하는 것이 불가능하며 결과를 캐시하는 것도 불가능합니다.

따라서 우리는 두 가지 옵션이 남습니다:
- 기능을 제거합니다.
- 성능 문제를 완화할 방법을 찾습니다.

기능을 제거할 수 없다고 가정하고 대신 htmx를 사용하여 성능 문제를 완화할 수 있는 방법을 살펴보겠습니다.

==== 비용이 많이 드는 코드 제거하기 <_pulling_out_the_expensive_code>
지연 로드 패턴을 구현하는 첫 번째 단계는 비용이 많이 드는 코드, 즉 `Contacts.count()` 호출을 `/contacts` 엔드포인트의 요청 처리기에서 분리하는 것입니다.

이 함수 호출을 새로운 HTTP 요청 처리기로 이동하고 `/contacts/count`에 새 HTTP 엔드포인트를 설정하겠습니다. 이 새 엔드포인트의 경우, 템플릿을 렌더링할 필요는 없습니다. 단지, 스팬에 있는 작은 텍스트 "(22개의 총 연락처)"를 렌더링하는 것이 업무의 유일한 역할이 될 것입니다.

다음은 새 코드가 어떻게 보일지입니다:

#figure(caption: [비용이 많이 드는 코드 제거하기],
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
    return "(" + str(count) + "개의 총 연락처)" <4>
```
1. 더 이상 이 핸들러에서 `Contacts.count()`를 호출하지 않습니다.
2. `/contacts` 핸들러에서 렌더링할 템플릿에 카운트를 더 이상 전달하지 않습니다.
3. 비용이 많이 드는 계산을 처리하는 새로운 핸들러를 `/contacts/count` 경로에 생성합니다.
4. 총 연락처 수가 포함된 문자열을 반환합니다.

이제 우리는 `/contacts` 핸들러 코드에서 성능 문제를 제거했으며, 이 새로운 HTTP 엔드포인트가 비싼 계산 문자열을 제공하도록 만들었습니다.

이제 이 새 핸들러의 콘텐츠를 밤에 _스팬_ 내에 넣어볼 차례입니다. 앞서 언급했듯이, htmx의 기본 동작은 요청에 대해 수신한 모든 콘텐츠를 요소의 `innerHTML`에 배치하는 것인데, 이것이 바로 여기에 필요한 것입니다: 이 텍스트를 검색하고 스팬에 넣고 싶습니다. 따라서 우리는 스팬에 이 새로운 경로를 가리키는 `hx-get` 속성을 간단하게 추가하면 됩니다.

하지만 현재로서는 스팬 요소에서 요청을 트리거하는 기본 _이벤트_는 `click` 이벤트임을 기억해야 합니다. 그렇습니다! 우리가 원하는 것은 바로 그 요청을 페이지가 로드될 때 즉시 트리거하는 것입니다.

이렇게 하려면, 요청이 발생하는 요소의 트리거를 업데이트하기 위해 `hx-trigger` 속성을 추가하고 `load` 이벤트를 사용할 수 있습니다.

`load` 이벤트는 htmx가 DOM에 콘텐츠를 로드할 때마다 전달하는 특별한 이벤트입니다. `hx-trigger`를 `load`로 설정하면, 페이지에서 스팬 요소가 로드되면 htmx가 `GET` 요청을 발행하게 됩니다.

여기 업데이트된 템플릿 코드입니다:

#figure(caption: [애플리케이션의 연락처 수 요소 추가],
```html
<p>
  <a href="/contacts/new">연락처 추가</a
  > <span hx-get="/contacts/count" hx-trigger="load"></span> <1>
</p>
```
1. `load` 이벤트가 발생할 때 `/contacts/count`에 `GET` 요청을 발행합니다.

스팬은 비어 있는 상태로 시작합니다: 우리는 그 안의 콘텐츠를 제거하고 요청을 통해 `contacts/count`의 콘텐츠로 채워질 것입니다.

그리고 확인해 보세요, 우리의 `/contacts` 페이지가 다시 빨라졌습니다! 페이지로 이동할 때 매우 빠르게 느껴지며, 프로파일링 결과 페이지 로드 속도가 실제로 훨씬 더 빨라졌음을 보여줍니다. 왜일까요? 비싼 계산을 부가 요청으로 미룸으로써 최초 요청을 더 빠르게 마칠 수 있도록 했습니다.

여러분은 "좋아, 그건 훌륭하지만 페이지에서 전체 카운트를 얻는 데 여전히 1-2초가 걸립니다."고 말할 수 있습니다. 맞습니다. 하지만사용자는 종종 전체 카운트에 특별히 관심이 없을 수 있습니다. 그들은 페이지에 와서 기존 사용자를 검색하거나 사용자를 수정하거나 추가하고자 할 수도 있습니다. 이 경우 총 연락처 수는 "가져야 할" 정보일 뿐입니다.

이 방식을 통해 카운트 계산을 미룸으로써 사용자가 애플리케이션 사용을 계속하도록 하면서 비싼 계산을 수행하게 됩니다.

예, 화면에서 모든 정보를 받는 데 소요되는 총 시간은 이전과 동일합니다. 실제로 페이지에 모든 정보를 얻기 위해 두 개의 HTTP 요청이 필요하므로 시간이 조금 더 걸릴 것입니다. 하지만 최종 사용자에게는 _인지된 성능_이 훨씬 더 나아질 것입니다: 사용자는 정보를 즉각적으로 사용할 수 있으며, 비록 일부 정보가 즉시 이용할 수 없더라도 좋습니다.

지연 로딩은 웹 애플리케이션 성능을 최적화할 때 유용한 도구입니다.

==== 표시기 추가하기 <_adding_an_indicator>

#index[htmx patterns][요청 표시기]
현재 구현의 단점은 현재 카운트 요청이 진행 중이라는 표시가 없어 찾아보면 요청이 완료되면 순간적으로 나타난다는 것입니다.

이것은 이상적이지 않습니다. 여기서 우리가 원하는 것은 액티브 검색 예제에서 추가한 것처럼 표시기입니다. 사실, 이 요청을 추가한 표시기를 방금 복사해서 새로운 HTML에 붙여넣기만 하면 됩니다.

이번 경우는 한 번만 요청을 하게 되고, 요청이 끝나면 더 이상 스피너를 필요하지 않으므로, 액티브 검색 예제에서 사용했던 것과 정확히 동일한 방법을 사용할 필요는 없습니다. 이 경우 스피너를 _스팬의 콘텐츠_ 내부에 두어야 합니다. 요청이 완료되면 응답의 콘텐츠가 스팬 내부로 들어가며, 스피너는 계산된 연락처 수로 교체됩니다. htmx는 `htmx-indicator` 클래스가 있는 표시기를 htmx로 강화된 요청을 하는 요소 내부에 놓을 수 있도록 지원합니다. `hx-indicator` 속성이 없는 경우, 이러한 내부 표시기들은 요청이 진행 중일 때 표시됩니다.

따라서 액티브 검색 예제의 스피너를 초기 콘텐츠로 스팬에 추가하겠습니다:

#figure(caption: [지연 로딩 콘텐츠에 표시기 추가],
```html
<span hx-get="/contacts/count" hx-trigger="load">
  <img id="spinner" class="htmx-indicator"
    src="/static/img/spinning-circles.svg"/> <1>
</span>
```
1. 네, 그게 전부입니다.

이제 사용자가 페이지를 로드할 때 총 연락처 수가 기적적으로 나타나기보다는, 무언가가 오는 것을 나타내는 멋진 스피너가 표시됩니다. 훨씬 낫습니다.

우리가 해야 할 일은 액티브 검색 예제에서 표시기를 복사하여 `span`에 붙여넣는 것뿐입니다. 다시 한번 우리는 htmx가 유연하고 조합 가능한 기능을 제공함을 보여줍니다. 새로운 기능을 구현하는 것은 종종 복사와 붙여넣기 몇 번에 불과하며, 약간의 조정을 하여 끝낼 수 있습니다.

==== 그러나 그것은 게으르지 않다! <_but_thats_not_lazy>

#index[htmx patterns][지연 로딩]
"좋아, 하지만 그건 실제로 게으른 것이 아닙니다. 우리는 페이지가 로드되는 즉시 카운트를 로드하고 있습니다. 단지 두 번째 요청을 통해 하고 있을 뿐입니다. 여러분은 실제로 값이 실제로 필요할 때까지 기다리고 있지 않습니까?"

좋습니다. 이제 _진정으로 게으르게_ 만들겠습니다: 우리가 필요로 할 때에만 요청을 발행하겠습니다. 

그렇게 하려면 무한 스크롤 예제를 설정했던 방법을 다시 상기해 보세요: 트리거에 대해 `revealed` 이벤트를 사용했습니다. 여기서 우리가 원하는 것은 그거 아닙니까? 요소가 나타날 때 요청을 발행해야 합니다.

네, 맞습니다. 다시 한 번, 우리는 하이퍼미디어의 새로운 문제 해결을 위해 다양한 UX 패턴 간에 개념을 혼합하고 결합할 수 있습니다.

#figure(caption: [진정으로 게으르게 만들기],
```html
<span hx-get="/contacts/count" hx-trigger="revealed"> <1>
  <img id="spinner" class="htmx-indicator"
    src="/static/img/spinning-circles.svg"/>
</span>
```
1. `hx-trigger`을 `revealed`로 변경합니다.

이제 우리는 진정으로 게으른 구현을 가지고 있으며, 정말로 필요로 하는 순간까지 비싼 계산을 미룹니다. 꽤 멋진 트릭이며, 또 한 번, 한 속성을 변경하는 것만으로도 htmx와 하이퍼미디어 접근 방식의 유연성을 나타냅니다.

=== 인라인 삭제 <_inline_delete>

#index[htmx patterns][인라인 삭제]
다음 하이퍼미디어 트릭으로는 "인라인 삭제" 패턴을 구현할 예정입니다. 이 기능을 사용하면 사용자가 특정 연락처의 편집 보기를 통해 삭제 버튼에 접근하는 대신, 모든 연락처의 테이블에서 직접 삭제할 수 있습니다.

우리는 이미 `rows.html` 템플릿에서 각 행에 "수정" 및 "보기" 링크가 있다는 것을 기억하세요:

#figure(caption: [기존 행 작업],
```html
<td>
    <a href="/contacts/{{ contact.id }}/edit">수정</a>
    <a href="/contacts/{{ contact.id }}">보기</a>
</td>
```

이제 우리는 "삭제" 링크를 추가하고자 합니다. 그리고 그렇게 생각해 보면 이 링크가 `edit.html`에서 사용한 "연락처 삭제" 버튼과 매우 유사하게 작동하기를 원합니다. 우리는 주어진 연락처의 URL에 HTTP `DELETE`를 발행하고자 하며, 사용자가 실수로 연락처를 삭제하지 않도록 확인 대화상자를 원합니다.

여기 "연락처 삭제" 버튼의 HTML이 있습니다:

#figure(caption: [기존 행 작업],
```html
<button
  hx-delete="/contacts/{{ contact.id }}"
  hx-push-url="true"
  hx-confirm="정말로 이 연락처를 삭제하시겠습니까?"
  hx-target="body">
  연락처 삭제
</button>
```

이제 예상했던 것처럼, 이게 또 다른 복사 및 붙여넣기 작업이 될 것입니다.

한 가지 주목할 점은 "연락처 삭제" 버튼의 경우 전체 화면을 다시 렌더링하고 URL을 업데이트하기를 원했는데, 이는 연락처 편집 보기에서 모든 연락처 목록 보기로 돌아오게 되기 때문입니다. 그러나 이 링크의 경우, 이미 연락처 목록에 있으므로 URL을 업데이트할 필요가 없으며 `hx-push-url` 속성을 생략할 수 있습니다.

#index[hx-delete][예시]
여기 인라인 "삭제" 링크의 코드입니다:

#figure(caption: [기존 행 작업],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">수정</a>
  <a href="/contacts/{{ contact.id }}">보기</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-confirm="정말로 이 연락처를 삭제하시겠습니까?"
    hx-target="body">삭제</a> <1>
</td>
```
1. "연락처 삭제" 버튼을 거의 그대로 복사했습니다.

보시는 바와 같이, 우리는 새로운 앵커 태그를 추가했으며, 올바른 마우스 오버 스타일링 동작을 유지하기 위해 공백 타겟(즉 `#` 값을 `href` 속성에 넣음)을 부여했습니다. 우리는 또한 "연락처 삭제" 버튼에서 `hx-delete`, `hx-confirm`, `hx-target` 속성을 복사했지만, URL을 업데이트하지 않을 것이므로 `hx-push-url` 속성은 생략했습니다.

이제 인라인 삭제가 작동하며 확인 대화상자까지 포함됩니다. 사용자는 "삭제" 링크를 클릭하면 행이 UI에서 사라질 것입니다.

#sidebar[스타일 사이드바][이 삭제 링크를 추가함으로써 우리는 연락처 행에 작업이 늘어나고 있습니다:

#figure(
    image("images/screenshot_stacked_actions.png"),
    caption: [작업이 많습니다],
    placement: none,
)<fig-stacked-actions>

작업이 한 줄에 모두 표시되지 않는 것이 좋으며, 사용자가 특정 행에 관심을 표명할 때만 작업을 표시하는 것도 좋습니다. 이 문제는 후속 장에서 스크립팅과 하이퍼미디어 주도 애플리케이션 간의 관계를 살펴본 후에 다루겠습니다.

현재로서는 이러한 덜 이상적인 사용자 인터페이스를 여전히 수용하겠습니다. 나중에 고치겠습니다.]

==== 타겟 좁히기 <_narrowing_our_target>
그러나 여기서도 조금 더 보여줄 수 있습니다. 만약 전체 페이지를 다시 렌더링하는 대신, 삭제할 연락처의 행만 제거한다면 어떨까요? 사용자가 현재 행을 보고 있으므로 전체 페이지를 다시 렌더링해야 할 필요는 없습니다.

이를 위해서는 몇 가지 작업이 필요합니다:
- 링크의 타겟을 해당 링크가 포함된 행으로 업데이트해야 합니다.
- 스와프를 `outerHTML`로 변경해야 하며, 이는 전체 행을 교체(사실상 제거)하기를 원하기 때문입니다.
- 연락처 편집 페이지의 "연락처 삭제" 버튼이 아니라 "삭제" 링크에서 `DELETE` 요청이 발생했을 때 빈 콘텐츠를 렌더링해야 서버 측을 업데이트해야 합니다.

먼저 첫 번째 사항: "삭제" 링크의 타겟을 전체 본체가 아니라 링크가 있는 행으로 업데이트합니다. 우리는 "클릭하여 로드" 및 "무한 스크롤" 기능에서 수행했던 것처럼 가장 가까운 `tr`을 타겟으로 하여 이점을 활용할 수 있습니다:

#figure(caption: [기존 행 작업],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">수정</a>
  <a href="/contacts/{{ contact.id }}">보기</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-swap="outerHTML"
    hx-confirm="정말로 이 연락처를 삭제하시겠습니까?"
    hx-target="closest tr">삭제</a> <1>
</td>
```
1. 링크의 가장 가까운 `tr`(테이블 행)을 타겟으로 업데이트했습니다.

==== 서버 측 업데이트 <_updating_the_server_side>
이제 서버 측을 업데이트해야 합니다. 우리는 "연락처 삭제" 버튼이 여전히 작동하게 하고 싶으므로 현재의 로직이 옳습니다. 따라서 버튼에 의해 트리거된 `DELETE` 요청과 이 앵커에서 오는 `DELETE` 요청을 구별할 수 있는 방법이 필요합니다.

이렇게 하는 가장 깔끔한 방법은 "연락처 삭제" 버튼에 `id` 속성을 추가하여 요청의 `HX-Trigger` HTTP 요청 헤더를 검사하고 버튼이 요청의 원인인지 여부를 판단하도록 하는 것입니다. 이는 기존 HTML에 대한 간단한 변경입니다:

#figure(caption: [연락처 삭제 버튼에 `id` 추가],
```html
<button id="delete-btn" <1>
  hx-delete="/contacts/{{ contact.id }}"
  hx-push-url="true"
  hx-confirm="정말로 이 연락처를 삭제하시겠습니까?"
  hx-target="body">
  연락처 삭제
</button>
```
1. 버튼에 `id` 속성을 추가했습니다.

이 버튼에 id 속성을 부여함으로써 이제 `edit.html` 템플릿의 삭제 버튼과 `rows.html` 템플릿의 삭제 링크를 구별할 수 있는 메커니즘을 갖추게 되었습니다. 이 버튼이 요청을 발행하면, 다음과 같게 요청이 됩니다:

#figure[```http
DELETE http://example.org/contacts/42 HTTP/1.1
Accept: text/html,*/*
Host: example.org
...
HX-Trigger: delete-btn
...
```

이제 요청에 버튼의 `id`가 포함되었습니다. 이를 통해 우리는 이전의 액티브 검색 패턴과 유사한 코드 작성을 할 수 있습니다. `HX-Trigger` 헤더에 대한 조건을 사용하여 원하는 작업을 결정할 수 있습니다. 해당 헤더에 `delete-btn` 값이 있으면 편집 페이지의 버튼에서 요청이 발생했음을 인식할 수 있으며 현재 수행 중인 작업을 진행합니다: 연락처를 삭제하고 `/contacts` 페이지 리디렉션합니다.

그 헤더에 `delete-btn` 값이 _없다면_, 연락처를 삭제하고 빈 문자열만 반환할 수 있습니다. 이 빈 문자열은 주어진 연락처에 해당하는 행을 대체하여 UI에서 행을 제거하게 됩니다.

이제 작업 후 서버 측 코드를 리팩토링하여 이를 수행해 보겠습니다:

#figure(caption: [다양한 삭제 패턴을 처리하는 서버 코드 업데이트],
```python
@app.route("/contacts/<contact_id>", methods=["DELETE"])
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete()
    if request.headers.get('HX-Trigger') == 'delete-btn': <1>
        flash("연락처 삭제됨!")
        return redirect("/contacts", 303)
    else:
        return "" <2>
```
1. 편집 페이지의 삭제 버튼이 이 요청을 제출한 경우, 이전 로직을 계속 진행합니다.
2. 그렇지 않으면 빈 문자열을 반환하여 행을 삭제합니다.

그래서 우리의 서버 측 구현은 다음과 같습니다: 사용자가 연락처 행에서 "삭제"를 클릭하고 삭제를 확인하면 행이 UI에서 사라집니다. 다시 말해, 간단한 코드 몇 줄을 변경하는 것만으로도 극적으로 다른 동작을 얻을 수 있습니다. 이런 방식으로 하이퍼미디어는 강력합니다.

==== Htmx 스와핑 모델 <_the_htmx_swapping_model>

#index[htmx][swap model]
이것은 꽤 멋지지만, htmx 콘텐츠 스와핑 모델을 이해하는 데 시간을 들이면 개선할 수 있는 점이 하나 더 있습니다: 행을 즉시 삭제하는 대신, 삭제하기 전에 이를 서서히 사라지게 할 수 있다면 좋겠습니다. 이렇게 하면 행이 제거되고 있음을 명확하게 하여 사용자에게 삭제에 대한 시각적 피드백을 제공할 수 있습니다.

htmx로 이것을 쉽게 할 수 있는데, 그렇게 하려면 htmx가 콘텐츠를 스와핑하는 방법을 정확히 파악해야 합니다.

htmx가 새로운 콘텐츠를 DOM에 단순히 추가한다고 생각할 수 있지만, 실제로는 그렇게 작동하지 않습니다. 대신 콘텐츠는 DOM에 추가되는 동안 일련의 단계를 거칩니다:
- 콘텐츠를 수신하고 DOM에 스와핑될 준비가 되면, `htmx-swapping` CSS 클래스가 대상 요소에 추가됩니다.
- 작은 지연이 발생합니다(이 지연이 존재하는 이유를 곧 설명하겠습니다).
- 그 다음, `htmx-swapping` 클래스가 대상에서 제거되고 `htmx-settling` 클래스가 추가됩니다.
- 새로운 콘텐츠가 DOM으로 스와핑됩니다.
- 또 다른 작은 지연이 발생합니다.
- 마지막으로, `htmx-settling` 클래스가 대상에서 제거됩니다.

스와프 메커니즘에는 더 많은 것이 있지만(예를 들어, settling은 우리가 나중 장에서 다룰 더 복잡한 주제입니다), 지금은 이것으로 충분합니다.

지금 이 과정에서는 작은 지연이 있습니다. 일반적으로 몇 밀리초의 양입니다. 왜 그럴까요? 이러한 작은 지연은 _CSS 전환_이 발생할 수 있도록 해줍니다.

#sidebar[CSS Transitions][
  #indexed[CSS transitions]는 하나의 스타일에서 다른 스타일로의 전환을 애니메이션할 수 있도록 해주는 기술입니다. 예를 들어, 어떤 것의 높이를 10픽셀에서 20픽셀로 변경하면, CSS 전환을 사용하여 요소가 새 높이로 부드럽게 애니메이션되도록 만들 수 있습니다. 이러한 종류의 애니메이션은 재미있고, 애플리케이션 사용성을 종종 향상시키며, 웹 애플리케이션에 세련됨을 추가하는 훌륭한 메커니즘입니다.
]

불행히도, CSS 전환은 일반 HTML에서 접근하기 어렵습니다: 일반적으로 JavaScript를 사용하고 클래스를 추가하거나 제거해야 트리거됩니다. 그래서 htmx 스와프 모델이 처음 생각했던 것보다 더 복잡합니다. 클래스를 서로 스와핑하고 작은 지연을 추가함으로써 HTML 내에서 CSS 전환을 순수하게 사용할 수 있습니다. JavaScript를 작성할 필요가 없습니다!

==== "htmx-swapping" 활용하기 <_taking_advantage_of_htmx_swapping>
좋아요, 그러면 인라인 삭제 메커니즘으로 돌아가 보겠습니다: 우리는 연락처를 삭제하고 그 행을 위해 빈 콘텐츠로 스와핑하는 htmx-enhanced 링크를 클릭합니다. 우리는 `tr` 요소가 제거되기 전에 `htmx-swapping` 클래스가 추가될 것이라는 것을 알고 있습니다. 이를 활용하여 행의 불투명도를 0으로 서서히 사라지게 하는 CSS 전환을 작성할 수 있습니다. 다음은 해당 CSS의 모습입니다:

#figure(caption: [페이드 아웃 전환 추가],
```css
tr.htmx-swapping { <1>
  opacity: 0; <2>
  transition: opacity 1s ease-out; <3>
}
```)
1. 이 스타일은 `htmx-swapping` 클래스가 있는 `tr` 요소에 적용됩니다.
2. `opacity`는 0이 되어 보이지 않게 됩니다.
3. `opacity`는 1초 동안 0으로 전환되며, `ease-out` 함수를 사용합니다.

다시 말하지만, 이건 CSS 책이 아니고 CSS 전환의 세부 사항을 깊이 다룰 예정이 아니지만, 위의 내용이 여러분에게 이해가 되었기를 바라며, 이전에 CSS 전환을 본 적이 없는 경우에도 이해할 수 있기를 바랍니다.

그래서 htmx 스와핑 모델의 의미를 생각해보세요: htmx가 행에 스와핑할 콘텐츠를 다시 받아왔을 때 `htmx-swapping` 클래스를 행에 추가하고 잠시 기다립니다. 이렇게 하면 불투명도 0으로의 전환이 발생하며 행이 서서히 사라지게 됩니다. 그런 다음 새로운(빈) 콘텐츠가 스와핑되어 행이 효과적으로 제거됩니다.

좋아 보이고 거의 다 왔습니다. 우리가 해야 할 또 한 가지가 있습니다: htmx의 기본 "스와프 지연"은 매우 짧습니다. 몇 밀리초 정도입니다. 대부분의 경우 이건 이해가 됩니다: 새로운 콘텐츠를 DOM에 넣기 전에 많은 지연이 있어서는 안 됩니다. 그러나 이 경우, CSS 애니메이션이 완료될 시간을 주고 싶습니다. 실제로는 1초를 주고 싶습니다.

#index[hx-swap][delay]
다행히 htmx는 `hx-swap` 주석에 대한 옵션을 가지고 있어 스와프 지연을 설정할 수 있습니다: 스와프 유형 뒤에 `swap:`을 추가하고 htmx가 스와핑을 시작하기 전에 특정 시간만큼 기다리도록 지정합니다. 삭제 작업을 위한 스와프가 완료되기 전에 1초의 지연을 허용하도록 HTML을 업데이트해 보겠습니다:

#figure(caption: [기존 행 작업],
```html
<td>
  <a href="/contacts/{{ contact.id }}/edit">편집</a>
  <a href="/contacts/{{ contact.id }}">보기</a>
  <a href="#" hx-delete="/contacts/{{ contact.id }}"
    hx-swap="outerHTML swap:1s" <1>
    hx-confirm="이 연락처를 삭제하시겠습니까?"
    hx-target="closest tr">삭제</a>
</td>
```)
1. 스와프 지연은 htmx가 새로운 콘텐츠를 스와핑하기 전에 얼마나 기다리는지를 변경합니다.

이 수정으로 인해 기존 행은 DOM에 추가로 1초 동안 남아 있으며 `htmx-swapping` 클래스가 붙어 있습니다. 이것은 행이 불투명도 0으로 전환하는 시간도 제공하여 우리가 원하는 페이드 아웃 효과를 줄 것입니다.

이제 사용자가 "삭제" 링크를 클릭하고 삭제를 확인하면, 행이 천천히 사라지고 불투명도가 0이 되면 제거됩니다. 꽤 멋지며, 하이퍼미디어 지향적인 방식으로 모든 것이 이루어졌고 JavaScript는 필요하지 않습니다. (물론 htmx는 JavaScript로 작성되었지만, 우리가 의미하는 바를 아실 겁니다: 기능을 구현하기 위해 아무 JavaScript도 작성할 필요가 없었습니다.)

=== 대량 삭제 <_bulk_delete>

#index[htmx patterns][bulk delete]
이번 장에서 구현할 최종 기능은 "대량 삭제"입니다. 현재 사용자 삭제 메커니즘은 훌륭하지만, 사용자가 한 번에 5개 또는 10개의 연락처를 삭제하려고 한다면 불편할 것입니다, 그렇지 않나요? 대량 삭제 기능을 위해 체크박스 입력을 통해 행을 선택하고 "선택한 연락처 삭제" 버튼을 클릭하여 모두 삭제할 수 있는 기능을 추가하고 싶습니다.

이 기능을 시작하기 위해서는 `rows.html` 템플릿의 각 행에 체크박스 입력을 추가해야 합니다. 이 입력의 이름은 `selected_contact_ids`이고, 값은 현재 행의 연락처에 대한 `id`입니다.

업데이트된 `rows.html`의 코드는 다음과 같습니다:

#figure(caption: [각 행에 체크박스 추가],
```html
{% for contact in contacts %}
<tr>
  <td><input type="checkbox" name="selected_contact_ids"
    value="{{ contact.id }}"></td> <1>
  <td>{{ contact.first }}</td>
  ... 생략
</tr>
{% endfor %}
```)
1. 현재 연락처의 id가 설정된 체크박스 입력이 있는 새로운 셀입니다.

우리는 체크박스 열을 수용할 수 있도록 테이블의 헤더에 빈 열도 추가해야 합니다. 그렇게 하면 각 행마다 하나의 체크박스가 생기고, 이는 웹에서 익숙한 패턴일 것입니다 (@fig-checkboxes).

#figure(image("images/screenshot_checkboxes.png"), caption: [
  연락처 행을 위한 체크박스들
])<fig-checkboxes>

HTML에서 체크박스가 어떻게 작동하는지 잘 모른다면: 체크박스는 해당 입력의 이름과 연결된 값을 제출하는데, 이는 체크되어 있을 때만 해당합니다. 예를 들어, id가 3, 7 및 9인 연락처를 체크하면, 이 세 개의 값이 서버에 제출됩니다. 이 경우 모든 체크박스는 동일한 이름인 `selected_contact_ids`를 가지므로 모두 `selected_contact_ids`라는 이름으로 제출됩니다.

==== "선택한 연락처 삭제" 버튼 <_the_delete_selected_contacts_button>
다음 단계는 테이블 아래에 선택된 모든 연락처를 삭제할 버튼을 추가하는 것입니다. 이 버튼은 각 행의 삭제 링크처럼 HTTP `DELETE`를 발행하되, 특정 연락처의 URL에 발행하는 대신, 여기서는 `/contacts` URL에 발행하고 싶습니다.

다른 삭제 요소와 마찬가지로, 사용자에게 연락처를 삭제하길 원하는지 확인하고, 이번 경우에는 페이지의 본문을 대상으로 하여 전체 테이블을 다시 렌더링합니다.

버튼 코드의 모습은 다음과 같습니다:

#figure(caption: [선택한 연락처 삭제 버튼],
```html
<button
  hx-delete="/contacts" <1>
  hx-confirm="이 연락처를 삭제하시겠습니까?" <2>
  hx-target="body"> <3>
  선택한 연락처 삭제
</button>
```)
1. `/contacts`에 `DELETE` 요청을 발행합니다.
2. 사용자가 선택된 연락처를 삭제하길 원하는지 확인합니다.
3. 본문을 타겟으로 합니다.

꽤 간단합니다. 한 가지 질문이 있습니다: 선택된 체크박스의 모든 값을 요청에 어떻게 포함시킬 것인가요? 현재 상태로는 이 독립 버튼은 다른 정보가 `DELETE` 요청에 포함되어야 한다는 정보를 가지고 있지 않습니다.

#index[input values]
다행히도, htmx는 요청에 입력 값들을 포함시키는 몇 가지 방법이 있습니다.

한 가지 방법은 `hx-include` 속성을 사용하는 것입니다. 이 속성은 요청에 포함할 요소를 지정하기 위해 CSS 선택기를 사용할 수 있게 해줍니다. 이 방법도 잘 작동하지만, 이번 경우에는 다른 약간 더 간단한 접근 방식을 사용할 것입니다.

#index[forms]
기본적으로, 요소가 `form` 요소의 자식이고 비-`GET` 요청을 만드는 경우, htmx는 그 양식 내의 모든 입력 값들을 포함시킵니다. 이처럼 테이블에 대한 대량 작업 상황에서는 전체 테이블을 폼 태그로 감싸는 것이 일반적입니다. 그래서 선택된 항목에 대해 작동하는 버튼을 쉽게 추가할 수 있습니다.

테이블 주위에 그 폼 태그를 추가하고 버튼도 그 안에 포함되도록 해보겠습니다:

#figure(caption: [선택한 연락처 삭제 버튼],
```html
<form> <1>
  <table>
    ... 생략
  </table>
  <button
    hx-delete="/contacts"
    hx-confirm="이 연락처를 삭제하시겠습니까?"
    hx-target="body">
    선택한 연락처 삭제
  </button>
</form> <2>
```)
1. 폼 태그가 전체 테이블을 감쌉니다.
2. 폼 태그가 버튼도 감쌉니다.

이제 버튼이 `DELETE`를 발행하면, 선택된 모든 연락처의 id가 `selected_contact_ids` 요청 변수로 포함됩니다.

==== 선택한 연락처 삭제를 위한 서버 측 코드 <_the_server_side_for_delete_selected_contacts>
서버 측 구현은 연락처를 삭제하기 위한 우리의 원래 서버 측 코드와 유사하게 보일 것입니다. 사실, 우리는 다시 한번 복사해서 붙여넣고 몇 가지 수정을 하면 됩니다:
- URL을 `/contacts`로 변경합니다.
- 핸들러가 제출된 모든 `selected_contact_ids`를 가져와 각각을 반복하며 연락처를 삭제하도록 설정합니다.

변경할 내용은 이것뿐입니다! 서버 측 코드는 다음과 같습니다:

#figure(caption: [선택한 연락처 삭제 버튼],
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
    flash("연락처가 삭제되었습니다!") <5>
    contacts_set = Contact.all()
    return render_template("index.html", contacts=contacts_set)
```)
1. `/contacts/` 경로에 대한 `DELETE` 요청을 처리합니다.
2. 서버에 제출된 `selected_contact_ids` 값을 문자열 목록에서 정수 목록으로 변환합니다.
3. 모든 id를 반복합니다.
4. 각 id로 해당 연락처를 삭제합니다.
5. 그 외의 모든 것은 원래 삭제 핸들러와 동일합니다: 메시지를 플래시하고 `index.html` 템플릿을 렌더링합니다.

우리는 원래 삭제 로직을 가져와 단일 id가 아닌 id 배열을 처리하도록 약간 수정했습니다.

또한 한 가지 작은 변경 사항을 눈치챘을 수 있습니다: 우리는 원래 삭제 코드에 있었던 리다이렉트를 제거했습니다. 이는 이미 다시 렌더링하고자 하는 페이지에 있기 때문에 새 URL로 업데이트할 이유가 없기 때문입니다. 우리는 페이지를 다시 렌더링하고 삭제되지 않은 연락처의 새 목록이 다시 렌더링될 수 있습니다.

이제 대량 삭제 기능이 우리의 애플리케이션에 추가되었습니다. 다시 말하지만, 큰 코드 양 없이 하이퍼미디어를 서버와 교환하여 이러한 기능을 완전히 구현하고 있습니다. HTTP의 전통적인 RESTful 방식으로 말입니다.

#html-note[접근성 기본 설정?][
#index[ARIA]
#index[접근성]
HTML에 내장되지 않은 컨트롤을 구현하려 할 때 접근성 문제가 발생할 수 있습니다.

앞서 한 챕터에서, 버튼처럼 작동하도록 즉흥적으로 만들어진 \<div\>의 예를 살펴보았습니다. 이제는 다른 예를 보겠습니다: 탭 세트를 만들어야 하지만, 라디오 버튼과 CSS 해킹을 사용하여 만든 경우는 어떤가요? 이는 웹 개발 커뮤니티에서 때때로 회자되는 멋진 해킹입니다.

문제는 탭이 콘텐츠를 변경하는 클릭 외에도 요구 사항이 있다는 점입니다. 여러분이 즉흥적으로 만든 탭은 사용자에게 혼란과 좌절을 유발할 수 있는 기능이 누락될 수 있습니다. 또한 어떤 바람직하지 않은 동작을 초래할 수 있습니다. #link(
  "https://www.w3.org/WAI/ARIA/apg/patterns/tabs/",
)[ARIA 작성 지침에서 탭에 대한 내용]:

- 키보드 상호작용

  - Tab 키로 탭에 포커스할 수 있나요?

- ARIA 역할, 상태 및 속성

  - "탭을 포함하는 요소는 역할 `tablist`를 가집니다."

  - "각 [탭]은 역할 `tab`을 가집니다."

  - "각 탭의 콘텐츠 패널을 포함하는 요소는 역할 `tabpanel`을 가집니다."

  - "각 [탭]은 해당하는 탭 패널 요소를 참조하는 `aria-controls` 속성을 가집니다."

  - "활성 `tab` 요소는 상태 `aria-selected`가 `true`로 설정되며, 모든 다른 `tab` 요소는 `false`로 설정됩니다."

  - "각 역할 `tabpanel`을 가진 요소는 해당하는 `tab` 요소를 참조하는 `aria-labelledby` 속성을 가집니다."

여러분이 즉흥적으로 만든 탭이 이러한 모든 요구 사항을 충족하도록 하려면 많은 코드를 작성해야 합니다. 일부 ARIA 속성은 HTML에 직접 추가할 수 있지만 반복적이며, 다른 속성(예: `aria-selected`)은 동적이기 때문에 JavaScript로 설정해야 합니다. 키보드 상호작용 또한 오류가 발생할 수 있습니다.

자신만의 탭 세트 구현을 만드는 것이 불가능하지는 않지만, 모든 사용자가 모든 환경에서 작동하도록 새로운 구현이 신뢰할 수 있는지 확인하기는 어렵습니다. 대부분의 경우 테스트를 위한 리소스가 제한적이기 때문입니다.

_확립된 UI 상호작용 라이브러리를 사용하세요_. 사용 사례가 맞춤형 솔루션을 요구하는 경우, _접근성 및 키보드 상호작용에 대해 철저하게 테스트하세요_. 수동으로 테스트하세요. 자동으로 테스트하세요. 화면 리더로 테스트하세요, 키보드로 테스트하세요, 서로 다른 브라우저와 하드웨어에서 테스트하세요, 그리고 코드를 작성할 때와 CI에서 린터를 실행하세요. 기계 가독성이나 인간 가독성 또는 페이지 크기를 보장하기 위해 테스트는 중요합니다.

#index[HTML][<details>]
또한 고려해야 할 사항: 정보를 탭 형식으로 제공해야 할 필요가 있나요? 때때로 질문의 답은 '예'이지만, 그렇지 않다면 일련의 세부 사항과 공개가 매우 유사한 목적을 충족시킵니다.

#figure(```html
<details><summary>공개 1</summary>
  공개 1 내용
</details>
<details><summary>공개 2</summary>
  공개 2 내용
</details>
```)

UX를 저해하면서 JavaScript를 피하는 것은 나쁜 개발입니다. 하지만 때때로 디자인을 변경하여 더 간단하고 더 견고한 구현을 허용함으로써 동등한(또는 더 나은!) UX 품질을 달성할 수 있는 경우도 있습니다.
]
