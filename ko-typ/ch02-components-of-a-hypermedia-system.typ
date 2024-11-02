#import "lib/definitions.typ": *
#import "lib/snippets.typ": fielding-rest-thesis

== 하이퍼미디어 시스템의 구성 요소

_하이퍼미디어 시스템_은 다음을 포함한 여러 구성 요소로 구성됩니다:

- 하이퍼미디어(예: HTML)
- 네트워크 프로토콜(예: HTTP)
- 네트워크 요청에 하이퍼미디어 응답으로 응답하는 하이퍼미디어 API를 제공하는 서버
- 그러한 응답을 적절히 해석하는 클라이언트

이 장에서는 이러한 구성 요소와 웹의 맥락에서의 구현을 살펴볼 것입니다.

웹을 하이퍼미디어 시스템으로서의 주요 구성 요소를 검토한 후, 이 시스템의 핵심 아이디어, --- 특히 Roy Fielding이 그의 논문 "Architectural Styles and the Design of Network-based Software Architectures"에서 개발한 이론을 살펴보겠습니다. 우리는 REpresentational State Transfer(REST), RESTful 및 Hypermedia As The Engine Of Application State(HATEOAS)라는 용어의 기원을 살펴보고, 이 용어들을 웹의 맥락에서 분석할 것입니다.

이렇게 하면 하이퍼미디어 시스템으로서 웹의 이론적 기초에 대한 더 강한 이해를 갖게 되고, 그것이 어떻게 결합되어야 하는지, 그리고 하이퍼미디어 기반 애플리케이션이 RESTful인 이유와 JSON API가 그렇지 않은 이유 --- 산업에서 현재 REST라는 단어가 어떻게 사용되고 있는지와는 별개로  ---  를 이해할 수 있을 것입니다.

=== 하이퍼미디어 시스템의 구성 요소 <_components_of_a_hypermedia_system>

==== 하이퍼미디어 <_the_hypermedia>
하이퍼미디어 시스템의 기본 기술은 클라이언트와 서버가 동적이고 비선형적으로 서로 통신할 수 있도록 해주는 하이퍼미디어입니다. 다시 말해 하이퍼미디어를 하이퍼미디어로 만드는 것은 _하이퍼미디어 제어_의 존재입니다: 사용자가 하이퍼미디어 내에서 비선형적인 동작을 선택할 수 있도록 해주는 요소들입니다. 사용자는 단순히 처음부터 끝까지 읽는 것 이상의 방식으로 미디어와 _상호작용_할 수 있습니다.

우리는 이미 HTML에서 두 가지 주요 하이퍼미디어 제어인 앵커와 폼을 언급했습니다. 이들은 브라우저가 사용자에게 링크와 작업을 제시할 수 있도록 해줍니다.

#index[Uniform Resource Locator (URL)]
HTML의 경우 이러한 링크와 폼은 일반적으로 _Uniform Resource Locators(URLs)_를 사용하여 작업의 대상을 지정합니다:

/ Uniform Resource Locator: #[
    통일 자원 위치 지정자는 자원에 대한 위치를 참조하거나 _가리키는_ 텍스트 문자열입니다. 이는 자원을 검색할 수 있는 네트워크의 위치와 자원을 검색하는 메커니즘을 포함합니다.
  ]

URL은 다양한 하위 구성 요소로 구성된 문자열입니다:

#figure(caption: [URL Components],
```
[scheme]://[userinfo]@[host]:[port][path]?[query]#[fragment]
```)

이 하위 구성 요소 중 많은 부분은 필수적이지 않으며, 종종 생략됩니다.

전형적인 URL은 다음과 같을 수 있습니다:

#figure(caption: [A simple URL],
```
https://hypermedia.systems/book/contents/
```)

이 특정 URL은 다음 구성 요소로 구성됩니다:
- 프로토콜 또는 스킴(이 경우 `https`)
- 도메인(예: `hypermedia.systems`)
- 경로(예: `/book/contents`)

이 URL은 HTTP 요청이 하이퍼미디어 클라이언트(예: 웹 브라우저)에서 "HTTPS"를 사용하는 특정 하이퍼미디어 _자원_을 식별합니다. 이 URL이 HTML 문서 내의 하이퍼미디어 제어 참조로 발견되면, 이는 네트워크 반대편에서 HTTPS를 이해하는 _하이퍼미디어 서버_가 존재하고, 주어진 자원의 _표현_으로 이 요청에 응답할 수 있음을 의미합니다(또는 다른 위치로 리디렉션할 수 있습니다 등).

URL이 HTML 내에서 전체적으로 작성되지 않는 경우가 많습니다. 예를 들어, 다음과 같은 앵커 태그를 자주 볼 수 있습니다:

#figure(caption: [A Simple Link],
```html
<a href="/book/contents/">Table Of Contents</a>
```)

여기에는 프로토콜, 호스트 및 포트가 "현재 문서"의 것으로 _암시되는_ 상대 하이퍼미디어 참조가 있습니다. 즉, 현재 HTML 페이지를 검색했던 것과 동일한 프로토콜과 서버와 같습니다. 따라서 이 링크가 `https://hypermedia.systems/`에서 검색되었다면, 이 앵커의 암시된 URL은 `https://hypermedia.systems/book/contents/`가 됩니다.

==== 하이퍼미디어 프로토콜 <_hypermedia_protocols>
위의 하이퍼미디어 제어(링크)는 브라우저에 "사용자가 이 텍스트를 클릭하면, Hypertext Transfer Protocol을 사용하여 `https://hypermedia.systems/book/contents/`에 요청을 발행하라"고 지시합니다. 

HTTP는 브라우저와 서버 간에 HTML(하이퍼미디어)을 전송하는 데 사용되는 _프로토콜_이며, 따라서 웹의 분산 하이퍼미디어 시스템을 결합하는 주요 네트워크 기술입니다.

HTTP 버전 1.1은 비교적 간단한 네트워크 프로토콜이므로, 앵커 태그에서 트리거되는 `GET` 요청이 어떻게 보이는지 살펴보겠습니다. 
이는 기본적으로 `80` 포트에서 `hypermedia.systems`에 대한 서버로 전송될 요청입니다:

#figure(
```http
GET /book/contents/ HTTP/1.1
Accept: text/html,*/*
Host: hypermedia.systems
```)

첫 번째 줄은 HTTP `GET` 요청임을 지정합니다. 그런 다음 요청된 자원의 경로를 지정합니다. 마지막으로 이 요청의 HTTP 버전을 포함합니다.

그 이후에는 일련의 HTTP _요청 헤더_가 있으며, 각 헤더는 이름/값 쌍으로 콜론으로 구분됩니다. 요청 헤더는 서버가 클라이언트 요청에 어떻게 응답할지를 결정하는 데 사용할 수 있는 _메타데이터_를 제공합니다. 이 경우, `Accept` 헤더에 따라 브라우저는 응답 형식으로 HTML을 선호하지만, 서버의 어떤 응답도 수용합니다.

다음으로, 요청이 전송된 서버를 지정하는 `Host` 헤더가 있습니다. 이는 동일한 호스트에서 여러 도메인이 호스팅될 때 유용합니다.

서버의 이 요청에 대한 HTTP 응답은 다음과 같은 형식일 수 있습니다:

#figure(
```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 870
Server: Werkzeug/2.0.2 Python/3.8.10
Date: Sat, 23 Apr 2022 18:27:55 GMT

<html lang="en">
<body>
  <header>
    <h1>HYPERMEDIA SYSTEMS</h1>
  </header>
  ...
</body>
</html>
```)

첫 번째 줄에서는 HTTP 응답의 HTTP 버전을 지정하고, 그 다음에 주어진 자원이 발견되었음을 나타내는 응답 코드 `200`을 나타냅니다. 이는 응답 코드에 해당하는 문자열 `OK`가 뒤따릅니다. (실제 문자열은 중요하지 않으며, 클라이언트에 요청 결과를 알려주는 것은 응답 코드입니다. 이에 대해서는 아래에서 더 자세히 논의하겠습니다.)

응답의 첫 번째 줄 아래에는 HTTP 요청과 마찬가지로, _응답 헤더_가 일련으로 있으며 클라이언트가 자원의 _표현_을 올바르게 표시하는 데 필요한 메타데이터를 제공합니다.

마지막으로, 우리는 새로운 HTML 콘텐츠를 봅니다. 이 콘텐츠는 요청된 자원의 HTML _표현_이며, 이 경우 책의 목차입니다. 브라우저는 이 HTML을 사용하여 표시 창의 전체 콘텐츠를 교체하고, 사용자에게 이 새로운 페이지를 보여주며, 주소 표시줄을 새 URL을 반영하도록 업데이트합니다.

===== HTTP 메서드 <_http_methods>

#index[HTTP methods]
#index[HTTP methods][GET]
#index[HTTP methods][POST]
#index[HTTP methods][PUT]
#index[HTTP methods][PATCH]
#index[HTTP methods][DELETE]
위의 앵커 태그는 HTTP `GET` 요청을 발행했습니다. 여기서 `GET`은 요청의 _메서드_입니다. HTTP 요청에서 사용되는 특정 메서드는 요청이 지정된 자원에 대한 것이므로 아마도 가장 중요한 정보 조각일 것입니다.

HTTP에는 많은 메서드가 있으며 개발자에게 가장 중요한 실제 메서드는 다음과 같습니다:

/ `GET`: #[
    GET 요청은 지정된 자원의 표현을 검색합니다. GET 요청은 데이터를 변경하지 않아야 합니다.
  ]

/ `POST`: #[
    POST 요청은 지정된 자원에 데이터를 제출합니다. 이는 종종 서버의 상태 변화를 초래합니다.
  ]

/ `PUT`: #[
    PUT 요청은 지정된 자원의 데이터를 교체합니다. 이는 서버의 상태 변화를 초래합니다.
  ]

/ `PATCH`: #[
    PATCH 요청은 지정된 자원의 데이터를 교체합니다. 이는 서버의 상태 변화를 초래합니다.
  ]

/ `DELETE`: #[
    DELETE 요청은 지정된 자원을 삭제합니다. 이는 서버의 상태 변화를 초래합니다.
  ]

이러한 메서드는 대체로 "생성/읽기/업데이트/삭제" 또는 CRUD 패턴과 일치합니다:

- `POST`는 자원을 생성하는 것에 해당합니다.
- `GET`은 자원을 읽는 것에 해당합니다.
- `PUT`과 `PATCH`는 자원을 업데이트하는 것에 해당합니다.
- `DELETE`는 자원을 삭제하는 것에 해당합니다.

#sidebar[Put vs. Post][

While HTTP Actions correspond roughly to CRUD, they are not the same. The
technical specifications for these methods make no such connection, and are
often somewhat difficult to read. Here, for example, is the documentation on the
distinction between a `POST` and a `PUT` from
#link("https://www.rfc-editor.org/rfc/rfc9110")[RFC-9110].

#blockquote(
  attribution: [RFC-9110, https:\/\/www.rfc-editor.org/rfc/rfc9110\#section-9.3.4],
)[
  The target resource in a POST request is intended to handle the enclosed
  representation according to the resource’s own semantics, whereas the enclosed
  representation in a PUT request is defined as replacing the state of the target
  resource. Hence, the intent of PUT is idempotent and visible to intermediaries,
  even though the exact effect is only known by the origin server.
]

In plain terms, a `POST` can be handled by a server pretty much however it
likes, whereas a `PUT` should be handled as a "replacement" of the resource,
although the language, once again allows the server to do pretty much whatever
it would like within the constraint of being
#link(
  "https://developer.mozilla.org/en-US/docs/Glossary/Idempotent",
)[_idempotent_].
]

In a properly structured HTML-based hypermedia system you would use an
appropriate HTTP method for the operation a particular hypermedia control
performs. For example, if a hypermedia control such as a button
_deletes_ a resource, ideally it should issue an HTTP `DELETE`
request to do so.

HTML에서의 이상한 점은 기본 하이퍼미디어 제어가 HTTP `GET` 및 `POST` 요청만을 발행할 수 있다는 것입니다.

앵커 태그는 항상 `GET` 요청을 발행합니다.

폼은 `method` 속성을 사용하여 `GET` 또는 `POST`를 발행할 수 있습니다.

HTML - 세계에서 가장 인기 있는 하이퍼미디어가 HTTP(결국 하이퍼텍스트 전송 프로토콜)를 기반으로 설계되었다는 사실에도 불구하고, 현재 `PUT`, `PATCH` 또는 `DELETE` 요청을 발행하려면 현재 JavaScript를 사용해야만 합니다. `POST`는 거의 모든 것을 할 수 있으므로 서버의 모든 변이에서 사용되며, `PUT`, `PATCH` 및 `DELETE`는 일반 HTML 기반 애플리케이션에서 제외됩니다.

이는 하이퍼미디어로서 HTML의 명백한 단점입니다. HTML 사양에서 이러한 문제가 해결되기를 바라는 것이 좋습니다. 현재로서는 4장에서 이 문제를 해결하는 방법에 대해 논의하겠습니다.

===== HTTP 응답 코드 <_http_response_codes>
HTTP 요청 메서드는 클라이언트가 서버에 특정 자원에 대해 _무엇을_ 해야 하는지를 말할 수 있게 해줍니다. HTTP 응답에는 요청의 결과를 클라이언트에게 알려주는 _응답 코드_가 포함되어 있습니다. HTTP 응답 코드는 위에서 언급한대로 HTTP 응답에 포함된 숫자 값입니다.

웹 개발자에게 가장 익숙한 응답 코드는 "404"일 것입니다. 이는 "찾을 수 없음"을 의미합니다. 이는 존재하지 않는 자원이 요청될 때 웹 서버가 반환하는 응답 코드입니다.

#index[HTTP response][codes]
HTTP는 응답 코드를 다양한 카테고리로 나누는 구조를 가지고 있습니다:

/ `100`-`199`: 서버가 응답을 처리하는 방법에 대한 정보 응답입니다.

/ `200`-`299`: 요청이 성공했음을 나타내는 성공적인 응답입니다.

/ `300`-`399`: 요청이 다른 URL로 전송되어야 함을 나타내는 리디렉션 응답입니다.

/ `400`-`499`: 클라이언트 측에서 잘못된 요청을 나타내는 클라이언트 오류 응답입니다(예: `404` 오류의 경우 존재하지 않는 항목을 요청하는 경우).

/ `500`-`599`: 서버가 요청에 응답하면서 내부적으로 오류에 직면했음을 나타내는 서버 오류 응답입니다.

각 카테고리 내에 특정 상황을 위한 여러 응답 코드가 있습니다.

여기서 더 일반적이거나 흥미로운 몇 가지 응답 코드를 살펴보겠습니다:

/ `200 OK`: HTTP 요청이 성공했습니다.

/ `301 Moved Permanently`: 요청된 자원의 URL이 영구적으로 새로운 위치로 이동했으며, 새 URL은 `Location` 응답 헤더에 제공됩니다.

/ `302 Found`: 요청된 자원의 URL이 임시로 새로운 위치로 이동했으며, 새 URL은 `Location` 응답 헤더에 제공됩니다.

/ `303 See Other`: 요청된 자원의 URL이 새로운 위치로 이동했으며, 새 URL은 `Location` 응답 헤더에 제공됩니다. 필드에서는 이 새 URL을 `GET` 요청으로 검색해야 합니다.

/ `401 Unauthorized`: 클라이언트가 아직 인증되지 않았으며(이름과는 달리 인증됨), 주어진 자원을 검색하기 위해 인증이 필요합니다.

/ `403 Forbidden`: 클라이언트가 이 자원에 대한 접근 권한이 없습니다.

/ `404 Not Found`: 서버가 요청한 자원을 찾을 수 없습니다.

/ `500 Internal Server Error`: 서버가 응답을 처리하려고 시도하는 동안 오류를 만났습니다.

HTTP 응답 코드 간에는 꽤 미묘한 차이점이 있으며, 솔직히 말해 그 사이에는 약간의 모호함이 존재합니다. 예를 들어 `302` 리디렉션과 `303` 리디렉션의 차이는 전자는 초기 요청과 동일한 HTTP 메서드를 사용하여 새 URL에 요청을 발행하는 반면, 후자는 항상 `GET`을 사용합니다. 이는 작은 차이지만 종종 중요한 차이점입니다.

잘 구성된 하이퍼미디어 기반 애플리케이션은 HTTP 메서드와 HTTP 응답 코드를 모두 활용하여 합리적인 하이퍼미디어 API를 생성합니다. 예를 들어, 모든 요청에 대해 `POST` 메서드를 사용하고 매 응답에 대해 `200 OK`로 응답하는 하이퍼미디어 기반 애플리케이션은 바람직하지 않습니다. (HTTP 위에 구축된 일부 JSON 데이터 APIs는 정확히 이렇게 작동하고 있습니다!)

하이퍼미디어 기반 애플리케이션을 구축할 때는, 웹의 "결정적인" 방향으로 나아가야 하며, HTTP 메서드와 응답 코드를 설계된 대로 사용해야 합니다.

===== HTTP 응답 캐싱 <_caching_http_responses>

#index[HTTP response][caching]
REST(따라서 HTTP의 특징)의 제한 사항은 응답 캐싱 개념입니다. 서버는 클라이언트(뿐만 아니라 중개 HTTP 서버)에게 주어진 응답이 동일한 URL로 미래 요청에 대해 캐시될 수 있음을 나타낼 수 있습니다.

#index[HTTP response header][Cache-Control]
HTTP 응답이 서버에서 캐시된 응답의 캐시 동작은 `Cache-Control` 응답 헤더로 표시될 수 있습니다. 이 헤더는 주어진 응답의 캐시 가능성을 나타내는 다양한 값을 가질 수 있습니다. 예를 들어, 헤더에 `max-age=60`이라는 값이 포함되어 있다면 이는 클라이언트가 이 응답을 60초 동안 캐시할 수 있으며, 제한 기간이 만료될 때까지 해당 자원에 대한 추가 HTTP 요청을 발행할 필요가 없음을 나타냅니다.

#index[HTTP response header][Vary]
또 다른 중요한 캐시 관련 응답 헤더는 `Vary`입니다. 이 응답 헤더는 HTTP 요청에서 어떤 헤더가 캐시된 결과의 고유 식별자를 형성하는지를 명확히 나타내는 데 사용할 수 있습니다. 이 점은 특정 헤더가 서버 응답의 형식에 영향을 미치는 경우, 브라우저가 콘텐츠를 올바르게 캐시하는 데 중요해집니다.

#index[HTTP response header][custom]
#index[HX-Request][about]
예를 들어, htmx이 제공하는 응용 프로그램에서 자주 사용되는 패턴은 htmx가 설정한 사용자 지정 헤더인 `HX-Request`를 사용하여 "일반" 웹 요청과 htmx에 의해 제출된 요청을 구분하는 것입니다. 이러한 요청에 대한 응답을 적절하게 캐시하기 위해서는 `HX-Request` 요청 헤더가 `Vary` 응답 헤더로 표시되어야 합니다.

HTTP 응답 캐싱에 대한 전체 논의는 이 장의 범위를 넘어서므로, 더 알고 싶다면 #link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching",
)[MDN의 HTTP 캐싱에 관한 기사]를 참조하십시오.

==== 하이퍼미디어 서버 <_hypermedia_servers>
하이퍼미디어 서버는 HTTP 요청에 HTTP 응답으로 응답할 수 있는 모든 서버입니다. HTTP가 매우 간단하므로 거의 모든 프로그래밍 언어를 사용하여 하이퍼미디어 서버를 구축할 수 있습니다. 상상할 수 있는 거의 모든 프로그래밍 언어에 대해 HTTP 기반 하이퍼미디어 서버를 구축하는 데 사용할 수 있는 수많은 라이브러리가 있습니다.

하이퍼미디어를 웹 애플리케이션 구축의 기본 기술로 채택하는 가장 좋은 측면 중 하나는 JavaScript를 백엔드 기술로 채택해야 하는 압박을 제거한다는 점입니다. 만약 JavaScript 중심의 단일 페이지 애플리케이션 기반의 프론트 엔드를 사용하고 JSON 데이터 API를 사용한다면 백엔드에서도 JavaScript를 배포해야 한다는 상당한 압박을 느낄 것입니다.

후자의 경우, JavaScript로 이미 많은 코드가 작성되어 있습니다. 왜 두 개의 서로 다른 언어로 두 개의 별도 코드베이스를 유지해야 합니까? 클라이언트 측과 서버 측 모두에서 재사용 가능한 도메인 로직을 만들지 왜 하지 않습니까? 이제 JavaScript에는 Node와 Deno와 같은 훌륭한 서버 측 기술이 있어, 모든 것을 하나의 언어로 사용할 수 있습니다.

반대로 하이퍼미디어 기반 애플리케이션을 구축하면 원하는 백엔드 기술을 선택하는 데 훨씬 더 자유롭습니다. 여러분의 결정은 애플리케이션의 도메인, 여러분이 익숙하거나 열정을 느끼는 언어 및 서버 소프트웨어 또는 단순히 시도해 보고 싶은 것에 기반할 수 있습니다.

여러분은 분명히 서버 측 로직을 HTML로 작성하지 않습니다! 또한 모든 주요 프로그래밍 언어는 HTTP 요청을 깔끔하게 처리하는 데 사용할 수 있는 좋은 웹 프레임워크 및 템플릿 라이브러리가 적어도 하나는 있습니다.

여러분이 빅데이터 작업을 하고 있다면, 지원이 뛰어난 Python을 사용하고 싶을 지도 모릅니다.

AI 작업을 하고 있다면, 그 분야의 오랜 역사를 지닌 Lisp와 같은 언어를 사용하고 싶을지도 모릅니다.

여러분이 함수형 프로그래밍 애호가라면 OCaml이나 Haskell을 사용하고 싶을지도 모릅니다. 또는 Julia나 Nim을 정말 좋아할 수도 있습니다.

이러한 모든 이유는 특정 서버 측 기술을 선택하는 데 완전히 유효한 이유입니다!

하이퍼미디어를 시스템 아키텍처로 사용함으로써 이러한 선택을 채택할 수 있는 자유가 생겼습니다. 클라이언트를 두는 데 있어서 JavaScript의 대규모 코드베이스가 없어, 백엔드에서 JavaScript를 통합해야 할 압박이 없습니다.

#sidebar[Hypermedia On Whatever you'd Like (HOWL)][
  In the htmx community we call this (with tongue in cheek) the HOWL stack:
  Hypermedia On Whatever you’d Like. The htmx community is multi-language and
  multi-framework, there are rubyists as well as pythonistas, lispers as well as
  haskellers. There are even JavaScript enthusiasts! All these languages and
  frameworks are able to adopt hypermedia, and are able to still share techniques
  and offer support to one another because they share a common underlying
  architecture: they are all using the web as a hypermedia system.

  Hypermedia, in this sense, provides a "universal language" for the web that we
  can all use.
]

==== 하이퍼미디어 클라이언트 <_hypermedia_clients>

#index[web browsers]
이제 하이퍼미디어 시스템의 마지막 주요 구성 요소인 하이퍼미디어 클라이언트로 넘어가겠습니다. 하이퍼미디어 _클라이언트_는 특정 하이퍼미디어 및 그 내부의 하이퍼미디어 제어를 올바르게 해석하는 방법을 이해하는 소프트웨어입니다. 표준적인 예는 물론 웹 브라우저로, HTML을 이해하고 사용자가 상호작용할 수 있도록 나타냅니다. 웹 브라우저는 믿을 수 없을 정도로 정교한 소프트웨어입니다. (사실 이 정도로 정교하니, 하이퍼미디어 클라이언트 역할을 넘어 단일 페이지 애플리케이션을 연출하는 일종의 크로스 플랫폼 가상 머신으로 재활용되기도 합니다.)

그러나 브라우저만 하이퍼미디어 클라이언트는 아닙니다. 이 책의 마지막 부분에서는 모바일 지향 하이퍼미디어인 Hyperview를 살펴보겠습니다. Hyperview의 뛰어난 기능 중 하나는 HXML이라는 하이퍼미디어를 제공할 뿐만 아니라, 해당 하이퍼미디어에 대한 _작동하는 하이퍼미디어 클라이언트_도 제공한다는 것입니다. 이를 통해 Hyperview로 올바른 하이퍼미디어 기반 애플리케이션을 매우 쉽게 구축할 수 있습니다.

하이퍼미디어 시스템의 중요한 기능은 _통일된 인터페이스_로 알려져 있습니다. 이 개념은 다음 섹션에서 REST에 대해 깊이 있도록 논의할 것입니다. 하이퍼미디어에 관한 논의에서 종종 간과되는 것은 하이퍼미디어 클라이언트가 이 통일된 인터페이스를 활용하는 데 얼마나 중요한지를 보여주는 것입니다. 하이퍼미디어 클라이언트는 하이퍼미디어 서버로부터 하이퍼미디어 응답에 포함된 하이퍼미디어 제어를 올바르게 해석하고 표시하는 방법을 알아야 전체 하이퍼미디어 시스템이 결합될 수 있습니다. 이러한 작업을 수행할 수 있는 정교한 클라이언트 없이는 하이퍼미디어 제어와 하이퍼미디어 기반 API가 훨씬 덜 유용해집니다.

이것이 JSON API가 하이퍼미디어 제어를 흔히 성공적으로 채택하지 못하는 이유 중 하나입니다. JSON API는 일반적으로 고정된 형식을 기대하는 코드에 의해 소비되며, 하이퍼미디어 클라이언트로 설계되지 않았습니다. 이는 전적으로 이해할 수 있는 점입니다. 좋은 하이퍼미디어 클라이언트를 만드는 것은 어렵습니다! 이러한 JSON API 클라이언트에게는 API 응답에 내장된 하이퍼미디어 제어의 힘이 관련이 없고 종종 불편하게 느껴질 수 있습니다.

#blockquote(
  attribution: [Freddie Karlbom,
    https:\/\/techblog.commercetools.com/graphql-and-rest-level-3-hateoas-70904ff1f9cf],
)[
  The short answer to this question is that HATEOAS isn’t a good fit for most
  modern use cases for APIs. That is why after almost 20 years, HATEOAS still
  hasn’t gained wide adoption among developers. GraphQL on the other hand is
  spreading like wildfire because it solves real-world problems.
]

HATEOAS will be described in more detail below, but the takeaway here is that a
good hypermedia client is a necessary component within a larger hypermedia
system.

=== REST <_rest>
하이퍼미디어 시스템의 주요 구성 요소를 검토했으니 이제 REST 개념을 보다 깊이 있게 살펴볼 시간입니다. "REST"라는 용어는 Roy Fielding의 웹 아키텍처에 관한 박사 논문에서 유래된 것입니다. Fielding은 U.C. Irvine에서 그의 논문을 작성했으며, 초기에 Apache 웹 서버를 포함한 많은 웹 인프라 구축에 도움을 주었습니다. Roy는 그가 구축한 새로운 분산 컴퓨팅 시스템을 형식화하고 설명하고자 했습니다.

우리는 웹 개발 관점에서 Fielding의 저술 중 가장 중요한 부분에 초점을 맞출 것입니다: 5.1 섹션. 이 섹션은 표현 상태 이전의 핵심 개념(필드에서는 이를 _제약_이라고 부름)을 포함하고 있습니다.

그러나 우리는 본론에 들어가기 전에 Fielding이 REST를 _네트워크 아키텍처_로 다루었다는 점을 이해하는 것이 중요합니다. 이는 분산 시스템을 아키텍처하는 완전히 다른 방식으로, 이전 분산 시스템에 대한 접근 방식과 대조되는 새로운 네트워크 아키텍처로서 이해해야 합니다.

또한 Fielding이 그의 논문을 작성했을 당시 JSON API와 AJAX는 존재하지 않았다는 점을 강조하는 것이 중요합니다. 그는 HTML이 초기 브라우저에 의해 HTTP를 통해 전송되는 초기 웹을 하이퍼미디어 시스템으로 설명하고 있었습니다.

오늘날 이상하게도 "REST"라는 용어는 HTML과 하이퍼미디어보다는 JSON 데이터 API와 주로 연관되어 있습니다. 이는 매우 웃긴 일입니다. 왜냐하면 대다수의 JSON 데이터 API가 원래의 의미에서 RESTful이 아니며, 사실상 _RESTful이 될 수 없기 때문입니다. 그 이유는 그들이 자연적인 하이퍼미디어 형식을 사용하지 않기 때문입니다.

다시 강조하자면: 필딩이 정의한 REST는 _사전 API 웹_을 설명하는 것이며, "REST"라는 용어를 단순히 "JSON API"라는 의미로 간소화하는 것을 포기하는 것이 이 아이디어에 대한 적절한 이해를 발전시키는 데 필요합니다.

==== REST의 "제약" <_the_constraints_of_rest>

#index[Fielding, Roy]
#index[REST][constraints]
Fielding은 그의 논문에서 RESTful 시스템이 어떻게 동작해야 하는지를 설명하기 위해 여러 가지 "제약"을 정의하고 있습니다. 이 접근법은 많은 사람들에게 다소 간접적이고 따라가기 어렵게 느껴질 수 있지만, 학술 문서에 적합한 접근 방식입니다. 그가 구체적으로 설명하는 제약을 깊이 생각해보고 그 제약의 구체적인 예시와 함께 자신의 시스템이 REST의 건축적 요구사항을 충족하는지 평가하기가 쉬워질 것입니다.

다음은 Fielding이 설명하는 REST의 제약입니다:

- 클라이언트-서버 아키텍처이다 (섹션 5.1.2).
- stateless여야 한다; (섹션 5.1.3) 즉, 모든 요청은 그 요청에 응답하는 데 필요한 모든 정보를 포함한다.
- 캐싱을 허용해야 한다 (섹션 5.1.4).
- _통일된 인터페이스_가 있어야 한다 (섹션 5.1.5).
- 계층화된 시스템이다 (섹션 5.1.6).
- 선택적으로, Code-On-Demand를 허용할 수 있다 (섹션 5.1.7) 즉, 스크립팅이다.

이러한 제약 각각을 순차적으로 살펴보고 자세히 논의하여 웹이 각각을 얼마나 충족하는지 (그리고 어떤 정도에서) 살펴보겠습니다.

==== 클라이언트-서버 제약 <_the_client_server_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_2",
)[Section 5.1.2]
for the Client-Server constraint.

Fielding이 설명한 REST 모델은 네트워크 연결을 통해 _클라이언트_ (웹의 경우 브라우저)와 _서버_ (그가 작업하던 Apache 웹 서버와 같은) 간의 통신을 포함합니다. 이것이 그의 작업에서 언급된 맥락입니다. 그는 월드 와이드 웹의 네트워크 아키텍처를 설명하고, Common Object Request Broker Architecture (CORBA)와 같은 Thick-client 네트워킹 모델과 같은 이전의 아키텍처와 대조적으로 설명하고 있습니다. 

어떤 웹 애플리케이션이 어떻게 설계되든 이 요구 사항을 충족해야 한다는 점은 분명해야 합니다.

==== Statelessness 제약 <_the_statelessness_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_3",
)[Section 5.1.3]
for the Stateless constraint.

Fielding이 설명한 대로 RESTful 시스템은 무상태입니다. 즉, 모든 요청은 그 요청에 응답하는 데 필요한 모든 정보를 캡슐화해야 하며, 클라이언트 또는 서버에 저장된 부수적인 상태나 문맥이 없어야 합니다.

실제로 오늘날 많은 웹 애플리케이션에서 우리는 이 제약을 위반합니다. 특정 사용자를 고유하게 식별하는 _세션 쿠키_를 설정하는 것이 일반적이며, 이는 모든 요청과 함께 전송됩니다. 이 세션 쿠키 자체는 상태 정보를 유지하지 않지만 (모든 요청과 함께 전송되기 때문에) 일반적으로 "세션"이라는 용어로 불리는 서버에 저장된 정보를 조회하는 데 사용됩니다.

이 세션 정보는 일반적으로 여러 웹 서버 전반에 걸쳐 공유 스토리지에 저장되어 있으며, 현재 사용자의 이메일이나 ID, 역할, 부분적으로 생성된 도메인 객체, 캐시 등을 포함하고 있습니다.

무상태 REST 건축 제약의 이러한 위반은 웹 애플리케이션 구축에 유용하다고 입증되었으며, 웹의 전반적인 유연성에 큰 영향을 주지 않는 것처럼 보입니다. 그러나 심지어 Web 1.0 애플리케이션도 때때로 유용한 거래의 측면에서 REST의 순수성을 위반하는 것을 염두에 두어야 합니다.

또한 세션은 하이퍼미디어 서버를 배포할 때 추가적인 운영 복잡성 문제를 일으킬 수 있습니다. 이들은 전체 클러스터에 저장된 세션 상태 정보에 대한 공유 액세스가 필요합니다. 따라서 Fielding은 이상적인 RESTful 시스템, 즉 이 제약을 위반하지 않는 시스템이 더 간단하고 따라서 더 강력할 것이라고 지적한 것이 맞습니다.


==== The Caching Constraint <_the_caching_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_4",
)[Section 5.1.4]
for the Caching constraint.

이 제약은 RESTful 시스템이 캐싱의 개념을 지원해야 하며, 동일한 자원에 대해 향후 요청에 대한 응답의 캐시 가능성에 대한 명확한 정보를 제공해야 함을 의미합니다. 이를 통해 클라이언트는 물론 각 클라이언트와 최종 서버 간의 중개 서버 모두 요청의 결과를 캐시할 수 있습니다.

앞서 논의한 바와 같이 HTTP는 응답 헤더를 통한 정교한 캐싱 메커니즘을 제공하며, 이는 하이퍼미디어 애플리케이션을 구축할 때 종종 간과되거나 제대로 활용되지 않습니다. 이러한 기능이 존재하기 때문에 웹이 이 제약을 얼마나 충족하는지 쉽게 확인할 수 있습니다.


==== 통일된 인터페이스 제약 <_the_uniform_interface_constraint>
이제 REST에서 가장 흥미롭고, 우리 생각으로는, 가장 혁신적인 제약인: _통일된 인터페이스_에 대해 설명합니다.

이 제약은 하이퍼미디어 시스템의 _유연성_과 _단순성_의 많은 부분의 출처가 되기 때문에 우리는 여기에 좀 더 시간을 쓸 것입니다.

See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_5",
)[Section 5.1.5]
for the Uniform Interface constraint.

Fielding은 이 섹션에서 다음과 같이 말합니다:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  REST 아키텍처 스타일을 다른 네트워크 기반 스타일과 구별하는 중심 특징은 구성 요소 간의 통일된 인터페이스에 대한 강조입니다…​
  통일된 인터페이스를 얻기 위해서는 구성 요소의 동작을 안내하는 여러 개의 건축 제약이 필요합니다. REST는 네 가지 인터페이스 제약으로 정의되는데: 자원의 식별; 표현(representations)을 통한 자원의 조작; 자기 설명(self-descriptive)적인 메시지; 애플리케이션 상태 엔진으로서의 하이퍼미디어로 정의됩니다.
]

따라서 함께 고려할 때 통일된 인터페이스 제약을 구성하는 네 가지 하위 제약이 있습니다.

===== 자원의 식별 <_identification_of_resources>
RESTful 시스템에서 자원은 고유 식별자를 가져야 합니다. 오늘날 URL의 개념이 보편적이지만, Fielding이 저술했을 당시에는 여전히 비교적 새롭고 참신한 것이었습니다.

오늘날보다 더 흥미로운 것은 자원이 어떻게 식별되는지의 개념일 수 있습니다. RESTful 시스템에서는 _어떠한_ 종류의 데이터가 참조될 수 있으며, 즉, 하이퍼미디어 참조의 목표로 간주됩니다. 오늘날에는 URL이 보편적이지만, 복잡한 문제를 해결하고 모든 자원을 고유하게 식별하는 데 도움이 됩니다.

===== 표현을 통한 자원의 조작 <_manipulation_of_resources_through_representations>
RESTful 시스템에서 _표현(representations)_ 은 클라이언트와 서버 간에 전달됩니다. 이러한 표현은 요청에 대한 데이터 및 메타데이터(예를 들어, HTTP 메서드나 응답 코드와 같은 "제어 데이터")를 포함할 수 있습니다. 특정 데이터 형식이나 _미디어 타입_이 클라이언트에 표현할 자원을 제시하는 데 사용되며, 이러한 미디어 타입은 클라이언트와 서버 간에 협상이 가능합니다.

이러한 통일된 인터페이스의 마지막 측면은 위 요청의 `Accept` 헤더에서 보았습니다.

===== 자기 설명적 메시지 <_self_descriptive_messages>

#index[self-descriptive messages]
자기 설명 메시지 제약은 다음 제약인 HATEOAS와 결합되어, 우리가 REST의 통일된 인터페이스의 핵심이라고 여기는 부분을 형성합니다. 자기 설명 메시지 제약은 RESTful 시스템에서 메시지가 _자기 설명적_이어야 한다고 요구합니다.

즉, _모든 정보_는 데이터를 표시하고 _작업_할 수 있는 데 반드시 응답에 있어야 합니다. 적절히 RESTful 시스템에서 클라이언트가 서버 응답을 유용한 사용자 인터페이스로 전환하는 데 필요한 추가적인 "부수적" 정보는 없어야 합니다. 모든 것은 하이퍼미디어 제어의 형식으로 메시지 자체에 "존재해야" 합니다.

이것은 다소 추상적으로 들릴 수 있으니, 구체적인 예를 살펴보겠습니다.

HTTP 서버에서 URL `https://example.com/contacts/42`를 위한 두 가지 다른 응답을 고려해보겠습니다.

두 응답 모두 연락처에 대한 정보를 반환하지만, 각각은 매우 다른 형태를 취할 것입니다.

첫 번째 구현은 HTML 표현을 반환합니다:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Active</div>
</div>
<p>
    <a href="/contacts/42/archive">Archive</a>
</p>
</body>
</html>
```)

두 번째 구현은 JSON 표현을 반환합니다:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Active"
}
```)

이 두 응답 간의 차이에 대해 어떤 말을 할 수 있을까요?

처음 눈에 띄는 점은 JSON 표현이 HTML 표현보다 더 작다는 것입니다. Fielding은 RESTful 아키텍처를 사용할 때 정확히 이러한 트레이드 오프를 언급합니다:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  트레이드 오프는 통일된 인터페이스가 효율성을 저하시킨다는 것입니다. 정보는 특정 애플리케이션의 필요에 맞지 않은 표준화된 형식으로 전송됩니다.
]

따라서 REST는 표현 효율성을 다른 목표와 _트레이드 오프_합니다.

다른 목표를 이해하기 위해서 첫 번째로 HTML 표현에 있는 하이퍼링크를 주목하십시오. 이 링크는 연락처를 아카이브하기 위한 페이지로 이동할 수 있게 해줍니다. 반면 JSON 표현은 이러한 링크가 없습니다.

이러한 사실이 JSON API 클라이언트에 대해 어떤 의미를 가질까요?

#index[JSON API][vs. HTML]
JSON API 클라이언트는 _사전에_ 연락처 정보를 처리하기 위해 어떤 다른 URL(및 요청 메서드)이 있는지 정확히 알아야 합니다. JSON 클라이언트가 이 연락처를 무언가로 업데이트할 수 있는 경우, 이는 JSON 메시지 외부의 정보 출처에서 어떻게 수행해야 하는지 알아야 합니다. 예를 들어, 연락처의 상태가 "아카이브됨"인 경우, 이는 허용 가능한 동작에 변화를 가져올까요? 그렇다면 새로운 허용 가능한 동작은 무엇일까요?

이 모든 정보의 출처는 API 문서, 입소문, 또는 만약 개발자가 서버와 클라이언트를 모두 제어한다면 내부 지식이 될 수 있습니다. 그러나 이 정보는 암묵적이며 _응답 외부_에 존재합니다.

하이퍼미디어(HTML) 응답과 대조해 보겠습니다. 이 경우 하이퍼미디어 클라이언트(브라우저)는 단지 주어진 HTML을 렌더링하는 법만 알고 있으면 됩니다. 이 연락처의 사용 가능한 동작을 알아야 할 필요가 없습니다. 그들은 하이퍼미디어 제어로써 HTML 응답 내에 단순히 인코딩되어 있습니다. 그들은 상태 필드가 무엇을 의미하는지 이해할 필요가 없습니다. 사실, 클라이언트는 연락처가 무엇인지조차 모릅니다!

브라우저는 하이퍼미디어 클라이언트로서 단순히 HTML을 렌더링하고, 사용자가 접촉의 개념을 이해하고 있으며, 제공된 표현에서 사용할 수 있는 동작을 결정하게 합니다.

이 두 응답 간의 차이는 REST와 하이퍼미디어의 핵심을 보여줍니다. 클라이언트는 (웹 브라우저를 다시 말하자면) _어떠한_ 기반이 되는 자원에 관하여 알고 있을 필요가 없습니다.

브라우저는 단지 하이퍼미디어(이 경우 HTML)를 해석하고 표시하는 방법을 이해하면 됩니다. 이는 하이퍼미디어 기반 시스템이 백업 표현 및 시스템 자체에 대한 변화를 처리하는 데 있어 전례 없는 유연성을 제공합니다.

===== 하이퍼미디어, 애플리케이션 상태 엔진(HATEOAS)으로서의 <_hypermedia_as_the_engine_of_application_state_hateoas>

통일된 인터페이스의 마지막 하위 제약은 RESTful 시스템에서 하이퍼미디어가 "애플리케이션 상태의 엔진"이 되어야 한다는 것입니다. 이러한 것은 때때로 #indexed[HATEOAS]로 약칭되지만, Fielding은 이를 논의할 때 "하이퍼미디어 제약"이라는 용어를 사용하는 것을 선호합니다.

이 제약은 이전의 자기 설명 메시지 제약과 밀접하게 관련되어 있습니다. 다시 두 가지 서로 다른 `/contacts/42`에 대한 구현, HTML과 JSON을 검토해 보겠습니다. 이 URL로 식별된 연락처가 이제 아카이브되었다고 업데이트하겠습니다.

우리의 응답은 어떻게 보일까요?

첫 번째 구현은 다음과 같은 HTML을 반환합니다:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Archived</div>
</div>
<p>
    <a href="/contacts/42/unarchive">Unarchive</a>
</p>
</body>
</html>
```)

The second implementation returns the following JSON representation:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Archived"
}
```)

여기서 유의해야 할 중요한 점은 자기 설명 메시지인 HTML 응답이 "아카이브" 작업이 더 이상 사용할 수 없다는 것을 보여주고, 새로운 "Unarchive" 작업이 사용 가능해졌다는 점입니다.연락처의 HTML 표현은 애플리케이션의 상태를 _인코딩_합니다; 즉, 이 특정 표현으로 할 수 있고 할 수 없는 것을 정확히 인코딩합니다. JSON 표현은 이렇게 하지 않습니다.

JSON 응답을 해석하는 클라이언트는 연락처의 일반적인 개념을 이해해야 할 뿐만 아니라, "상태" 필드가 "Archived"라는 값을 가질 때의 의미를 명확히 이해해야 합니다. "아카이브된" 연락처에 사용할 수 있는 작업은 무엇인지, 이를 적절히 표시하기 위한 방법을 반드시 알아야 합니다. 응답의 상태는 응답에 인코딩되어 있지 않고, 대신 원시 데이터와 API 문서와 같은 측면의 부수적 정보로 전달됩니다.

게다가 오늘날 대부분의 프론트 엔드 SPA 프레임워크에서 이러한 연락처 정보는 JavaScript 객체의 모델로 _메모리_에 존재할 것이며, 페이지 데이터는 브라우저의 #link(
  "https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model",
)[Document Object Model]
(DOM)에 저장될 것입니다. DOM은 모델의 변화에 따라 업데이트되므로, 이는 DOM이 이 뒷받침 JavaScript 모델의 변화에 "반응"하게 됩니다.

이 접근 방식은 애플리케이션 상태 엔진으로서의 하이퍼미디어(HATEOAS)을 사용하는 것이 _아닙니다_: 오히려 JavaScript 모델을 애플리케이션 상태의 엔진으로 사용하고, 해당 모델을 서버와 브라우저와 연결하여 동기화하는 것입니다.

HTML 접근 방식에서는 하이퍼미디어가 실제로 애플리케이션 상태의 엔진입니다: 즉, 클라이언트 측에 추가적인 모델이 없고 모든 상태가 하이퍼미디어, 이 경우 HTML로 직접 표현됩니다. 서버에서 상태가 변경될 때, 이는 클라이언트에 전송되는 표현(HTML 형식)에서 반영됩니다. 하이퍼미디어 클라이언트(브라우저)는 연락처가 무엇인지, "아카이빙"이 무엇인지, 또는 해당 응답의 특정 도메인 모델에 대해 아무것도 알지 못합니다. 단지 HTML을 렌더링하는 방법을 알고 있습니다.

하이퍼미디어 클라이언트는 서버 모델에 대한 정보를 기다리는 것이 아니기 때문에, 수신하고 사용자에게 표시할 수 있는 표현에 대해 전례 없는 유연성을 제공합니다.


===== HATEOAS와 API 변경 <_hateoas_api_churn>
하이퍼미디어의 유연성을 이해하는 데 있어 이 마지막 점은 중요합니다. 따라서 현실세계에서 이 점이 작동하는 방식의 실용적인 예를 살펴보겠습니다.웹 애플리케이션에 새로운 기능이 추가되어 다음의 두 개의 끝점이 생겼다고 가정합니다. 이 기능은 주어진 연락처에 메시지를 보낼 수 있게 해줍니다.

이 기능은 서버로부터 HTML과 JSON 응답 각각을 어떤 식으로 바꿀까요?

HTML 표현은 이제 다음과 같을 수 있습니다:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Active</div>
</div>
<p>
    <a href="/contacts/42/archive">Archive</a>
    <a href="/contacts/42/message">Message</a>
</p>
</body>
</html>
```)

The JSON representation, on the other hand, might look like this:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Active"
}
```)

다시 한 번, JSON 표현은 변경되지 않습니다. 이러한 새로운 기능은 어떤 형태의 이 표현에도 나타나지 않습니다. 대신 클라이언트는 이러한 변경을, 클라이언트와 서버 간에 공유된 문서를 통해서, _알아야_ 합니다, 

HTML 응답과 비교해 보십시오. RESTful 모델의 통일된 인터페이스 때문에, 특히 하이퍼미디어가 애플리케이션 상태의 엔진으로 작용하기 때문에, 어떠한 문서 교환도 필요하지 않습니다! 대신 클라이언트(브라우저)는 단순히 이 동작을 포함하는 새로운 HTML을 렌더링할 뿐입니다. 추가적인 코드 변경 없이도 최종 사용자가 이용할 수 있는 이 작업을 제공합니다.

상당히 멋진 점입니다!

지금 이 경우 JSON 클라이언트가 제대로 업데이트되지 않으면 오류 상태는 비교적 온건합니다. 새로운 기능이 사용자에게 제공되지 않는 것뿐입니다. 그러나 API에 대해 더 심각한 변경이 있을지 생각해 보십시오. 예를 들어 아카이브 기능이 제거되었다면? 혹은 이러한 작업의 URL이나 HTTP 메서드가 어떤 방식으로든 변경되었다면?

이 경우 JSON 클라이언트는 훨씬 더 심각하게 깨질 수 있습니다.

HTML 응답은 그러나 제거된 옵션을 제외하는 식으로 업데이트되거나 해당 옵션에 대한 URL을 업데이트하여 클라이언트가 새 HTML을 보고 적절하게 디스플레이하고 사용자에게 새 작업 세트를 선택할 수 있도록 합니다. 한 번 더, REST의 통일된 인터페이스는 매우 유연하게 밝혀졌습니다. 하이퍼미디어 API의 레이아웃이 비록 상당히 급격하게 바뀌더라도 클라이언트는 계속 작동합니다.

이로 인해 중요한 사실이 나타납니다: 이 유연성 덕분에 하이퍼미디어 API는 _JSON 데이터 API가 갖는 버전 관리 문제를 겪지 않습니다_.

하이퍼미디어 기반 애플리케이션이 "진입"되었을 때(즉, 어떤 진입점 URL을 통해 로드되었을 때), 모든 기능과 자원은 자기 설명 메시지를 통해 드러납니다. 따라서 클라이언트와 문서를 교환할 필요가 없습니다. 클라이언트는 단순히 하이퍼미디어(HTML)를 렌더링하면 모든 것이 작동합니다. 변경이 발생했을 때 API의 새 버전을 생성할 필요가 없습니다. 클라이언트는 단순히 업데이트된 하이퍼미디어를 검색하고, 새로운 동작 및 자원을 인코딩한 후 사용자가 작업할 수 있도록 표시합니다.


==== 레이어된 시스템 <_layered_system>
우리가 고려할 마지막 "필수" RESTful 시스템 제약은 계층화된 시스템 제약입니다. 이 제약은 Fielding 논문의 #link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_6",
)[5.1.6 섹션]
에서 확인할 수 있습니다. 솔직히 말해 통일된 인터페이스 제약의 흥미진진한 후에는 "계층화된 시스템" 제약이 약간 저조합니다. 그러나 이는 여전히 이해할 가치가 있으며 실제로 웹에 의해 효과적으로 활용됩니다. 이 제약은 RESTful 아키텍처가 "계층화"되어 클라이언트와 최종 "진실의 근원" 서버 간의 중개자로서 여러 서버가 작용할 수 있도록 요구합니다.

이 중개 서버는 프록시 역할을 하거나 중간 요청과 응답을 변환하는 등의 역할을 수행할 수 있습니다.

REST의 이러한 계층화 기능의 현대적 예는 CDN(콘텐츠 전송 네트워크)을 사용하는 것입니다. 이는 변경되지 않는 정적 자산을 클라이언트에게 더 빠르게 전달하기 위해 변경된 응답을 요청한 클라이언트에게 더 밀접하게 위치한 중개 서버에 저장함으로써 가능합니다.

이를 통해 최종 사용자에게 더 빠르게 콘텐츠를 전달할 수 있으며, 원본 서버의 부하를 줄일 수 있습니다.

적어도 우리의 의견으로는 웹 애플리케이션 개발자에게는 통일된 인터페이스만큼 흥미롭지는 않지만 유용함은 분명합니다.

==== 선택적 제약: 코드 온디맨드 <_an_optional_constraint_code_on_demand>
우리는 계층화된 시스템 제약을 필수 제약으로 마지막 제약으로 언급했습니다. 왜냐하면 Fielding은 RESTful 시스템에서 추가 제약인 코드 온디맨드 제약을 언급하기 때문입니다. 이는 다소 불편하게 "선택적"으로 설명됩니다.

Fielding은 이 섹션에서 다음과 같이 말합니다:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  REST는 클라이언트 기능을 확장할 수 있도록 코드를 다운로드하고 실행할 수 있게 허용합니다. 이는 필요한 사전 구현된 기능 수를 줄여 클라이언트를 단순화합니다. 배포 후 기능을 다운로드할 수 있도록 하는 것은 시스템의 확장성을 높이고 가시성을 낮출 수 있습니다. 따라서 REST 내에서 선택적 제약입니다.
]

따라서 스크립팅은 웹의 원래 RESTful 모델의 고유한 측면이며, 따라서 하이퍼미디어 기반 애플리케이션에서도 허용되어야 합니다.

하지만 하이퍼미디어 기반 애플리케이션에서 스크립팅의 존재는 기본 네트워크 모델을 _바꾸어서는 안 됩니다._ 하이퍼미디어는 계속해서 애플리케이션 상태의 엔진이 되어야 하고, 서버 통신은 여전히 하이퍼미디어 교환으로 구성되어야 하며, 예를 들어 JSON 데이터 교환이 되어서는 안 됩니다. (JSON 데이터 API도 확실히 그 자리를 차지할 수 있으며, 10장에서 언제 어떻게 사용할지는 논의할 것입니다.)

안타깝게도 오늘날 웹의 스크립팅 계층인 JavaScript는 종종 하이퍼미디어 모델을 _대체_하기보다 보충하기 위해 사용됩니다. 나중의 장에서는 기본 하이퍼미디어 시스템을 대체하지 않는 스크립팅이 어떤 모습인지 상세히 설명하도록 하겠습니다.

=== 결론 <_conclusion>
하이퍼미디어 시스템의 구성 요소와 개념에 대한 깊이 있는 논의를 마친 후 --- Roy Fielding의 통찰이 포함되어 있습니다 --- REST, 통일된 인터페이스 및 HATEOAS에 대해 훨씬 더 나은 이해를 가질 수 있기를 바랍니다. 이러한 특성이 하이퍼미디어 시스템을 왜 그렇게 유연하게 만드는지 알 수 있기를 바랍니다.

이제까지 REST와 HATEOAS의 전체 의미를 이해하지 못했다면 걱정하지 마십시오. 우리는 웹 개발에서 10년 이상 일하며 하이퍼미디어 지향 라이브러리를 구축하는 데에도 마찬가지 조건이 필요했습니다. HTML, 하이퍼미디어 및 웹에 대한 특별한 본질을 이해하는 데 오랜 시간이 필요했습니다!

#html-note[HTML5 Soup][
#blockquote(attribution: [Confucius])[
  지혜의 시작은 사물을 본질적으로 부르기 위해 노력을 기울이는 것입니다.
]

`<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`, `<figure>` 와 같은 요소들은 HTML에서의 일종의 약어가 되었습니다.

이러한 요소를 사용함으로써 페이지는 `<article>` 요소가 독립적이고 재사용 가능한 엔티티가 된다는 잘못된 약속을 사용자(예: 브라우저, 검색 엔진 및 스크래퍼)에게 합니다. 이를 피하기 위해서는:

- 사용하는 요소가 케이스에 맞는지 확인하세요. HTML 사양을 확인하십시오.

- 필요 없거나 맞지 않는 경우 구체적으로 사용하지 마십시오. 때로는 `<div>`도 괜찮습니다.

HTML에 대한 가장 권위있는 자료는 HTML 스펙입니다. 현재 사양은 [https://html.spec.whatwg.org/multipage](https://html.spec.whatwg.org/multipage)에서 확인할 수 있습니다. 단일 페이지 버전은 대부분의 컴퓨터에서 너무 느리게 로드되고 렌더링됩니다. /dev에서 "개발자 에디션"이 있지만, 표준 버전은 더 나은 스타일링을 제공합니다. HTML의 발전에 대해 듣고 있지 않은 이상, 괴소문에 의지할 필요는 없습니다.


#index[HTML][spec]
HTML에 대한 가장 권위있는 자료는 HTML 스펙입니다. 현재 사양은 #link(https://html.spec.whatwg.org/multipage).#footnote[단일 페이지 버전은 대부분의 컴퓨터에서 너무 느리게 로드되고 렌더링됩니다.
  /dev에서 "개발자 에디션"이 있지만, 표준 버전은 더 나은 스타일링을 제공합니다.]  HTML의 발전에 대해 듣고 있지 않은 이상, 괴소문에 의지할 필요는 없습니다.

스펙의 섹션 4에는 사용 가능한 모든 요소의 목록이 나와 있으며, 각 요소가 무엇을 나타내는지, 어디에 발생할 수 있는지, 무엇을 포함할 수 있는지가 나와 있습니다. 언제 닫는 태그 생략을 허용하는지도 알려줍니다!
]
