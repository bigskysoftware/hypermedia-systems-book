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

This constraint states that a RESTful system should support the notion of
caching, with explicit information on the cache-ability of responses for future
requests of the same resource. This allows both clients as well as intermediary
servers between a given client and final server to cache the results of a given
request.

As we discussed earlier, HTTP has a sophisticated caching mechanism via response
headers that is often overlooked or underutilized when building hypermedia
applications. Given the existence of this functionality, however, it is easy to
see how this constraint is satisfied by the web.

==== The Uniform Interface Constraint <_the_uniform_interface_constraint>
Now we come to the most interesting and, in our opinion, most innovative
constraint in REST: that of the _uniform interface_.

This constraint is the source of much of the _flexibility_ and
_simplicity_ of a hypermedia system, so we are going to spend some time on it.

See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_5",
)[Section 5.1.5]
for the Uniform Interface constraint.

In this section, Fielding says:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  The central feature that distinguishes the REST architectural style from other
  network-based styles is its emphasis on a uniform interface between components…​
  In order to obtain a uniform interface, multiple architectural constraints are
  needed to guide the behavior of components. REST is defined by four interface
  constraints: identification of resources; manipulation of resources through
  representations; self-descriptive messages; and, hypermedia as the engine of
  application state
]

So we have four sub-constraints that, taken together, form the Uniform Interface
constraint.

===== Identification of resources <_identification_of_resources>
In a RESTful system, resources should have a unique identifier. Today the
concept of Universal Resource Locators (URLs) is common, but at the time of
Fielding’s writing they were still relatively new and novel.

What might be more interesting today is the notion of a _resource_, thus being
identified: in a RESTful system, _any_ sort of data that can be referenced, that
is, the target of a hypermedia reference, is considered a resource. URLs, though
common enough today, end up solving the very complex problem of uniquely
identifying any and every resource on the internet.

===== Manipulation of resources through representations <_manipulation_of_resources_through_representations>
In a RESTful system, _representations_ of the resource are transferred between
clients and servers. These representations can contain both data and metadata
about the request (such as "control data" like an HTTP method or response code).
A particular data format or
_media type_ may be used to present a given resource to a client, and that media
type can be negotiated between the client and the server.

We saw this latter aspect of the uniform interface in the `Accept`
header in the requests above.

===== Self-descriptive messages <_self_descriptive_messages>

#index[self-descriptive messages]
The Self-Descriptive Messages constraint, combined with the next one, HATEOAS,
form what we consider to be the core of the Uniform Interface, of REST and why
hypermedia provides such a powerful system architecture.

The Self-Descriptive Messages constraint requires that, in a RESTful system,
messages must be _self-describing_.

This means that _all information_ necessary to both display
_and also operate_ on the data being represented must be present in the
response. In a properly RESTful system, there can be no additional
"side" information necessary for a client to transform a response from a server
into a useful user interface. Everything must "be in" the message itself, in the
form of hypermedia controls.

This might sound a little abstract so let’s look at a concrete example.

Consider two different potential responses from an HTTP server for the URL `https://example.com/contacts/42`.

Both responses will return information about a contact, but each response will
take very different forms.

The first implementation returns an HTML representation:

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

The second implementation returns a JSON representation:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Active"
}
```)

What can we say about the differences between these two responses?

One thing that may initially jump out at you is that the JSON representation is
smaller than the HTML representation. Fielding notes exactly this trade-off when
using a RESTful architecture:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  The trade-off, though, is that a uniform interface degrades efficiency, since
  information is transferred in a standardized form rather than one which is
  specific to an application’s needs.
]

So REST _trades off_ representational efficiency for other goals.

To understand these other goals, first notice that the HTML representation has a
hyperlink in it to navigate to a page to archive the contact. The JSON
representation, in contrast, does not have this link.

What are the ramifications of this fact for a _client_ of the JSON API?

#index[JSON API][vs. HTML]
What this means is that the JSON API client must know _in advance_
exactly what other URLs (and request methods) are available for working with the
contact information. If the JSON client is able to update this contact in some
way, it must know how to do so from some source of information _external_ to the
JSON message. If the contact has a different status, say "Archived", does this
change the allowable actions? If so, what are the new allowable actions?

The source of all this information might be API documentation, word of mouth or,
if the developer controls both the server and the client, internal knowledge.
But this information is implicit and _outside_
the response.

Contrast this with the hypermedia (HTML) response. In this case, the hypermedia
client (that is, the browser) needs only to know how to render the given HTML.
It doesn’t need to understand what actions are available for this contact: they
are simply encoded _within_ the HTML response itself as hypermedia controls. It
doesn’t need to understand what the status field means. In fact, the client
doesn’t even know what a contact is!

The browser, our hypermedia client, simply renders the HTML and allows the user,
who presumably understands the concept of a Contact, to make a decision on what
action to pursue from the actions made available in the representation.

This difference between the two responses demonstrates the crux of REST and
hypermedia, what makes them so powerful and flexible: clients (again, web
browsers) don’t need to understand _anything_ about the underlying resources
being represented.

Browsers only (only! As if it is easy!) need to understand how to interpret and
display hypermedia, in this case HTML. This gives hypermedia-based systems
unprecedented flexibility in dealing with changes to both the backing
representations and to the system itself.

===== Hypermedia As The Engine of Application State (HATEOAS) <_hypermedia_as_the_engine_of_application_state_hateoas>

The final sub-constraint on the Uniform Interface is that, in a RESTful system,
hypermedia should be "the engine of application state." This is sometimes
abbreviated as "#indexed[HATEOAS]", although Fielding prefers to use the
terminology "the hypermedia constraint" when discussing it.

This constraint is closely related to the previous self-describing message
constraint. Let us consider again the two different implementations of the
endpoint `/contacts/42`, one returning HTML and one returning JSON. Let’s update
the situation such that the contact identified by this URL has now been
archived.

What do our responses look like?

The first implementation returns the following HTML:

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

The important point to notice here is that, by virtue of being a self-describing
message, the HTML response now shows that the "Archive" operation is no longer
available, and a new "Unarchive" operation has become available. The HTML
representation of the contact _encodes_
the state of the application; it encodes exactly what can and cannot be done
with this particular representation, in a way that the JSON representation does
not.

A client interpreting the JSON response must, again, understand not only the
general concept of a Contact, but also specifically what the
"status" field with the value "Archived" means. It must know exactly what
operations are available on an "Archived" contact, to appropriately display them
to an end user. The state of the application is not encoded in the response, but
rather conveyed through a mix of raw data and side channel information such as
API documentation.

Furthermore, in the majority of front end SPA frameworks today, this contact
information would live _in memory_ in a JavaScript object representing a model
of the contact, while the page data is held in the browser’s
#link(
  "https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model",
)[Document Object Model]
(DOM). The DOM would be updated based on changes to this model, that is, the DOM
would "react" to changes to this backing JavaScript model.

This approach is certainly _not_ using Hypermedia As The Engine Of Application
State: rather, it is using a JavaScript model as the engine of application
state, and synchronizing that model with a server and with the browser.

With the HTML approach, the Hypermedia is, indeed, The Engine Of Application
State: there is no additional model on the client side, and all state is
expressed directly in the hypermedia, in this case HTML. As state changes on the
server, it is reflected in the representation (that is, HTML) sent back to the
client. The hypermedia client (a browser) doesn’t know anything about contacts,
what the concept of "Archiving" is, or anything else about the particular domain
model for this response: it simply knows how to render HTML.

Because a hypermedia client doesn’t need to know anything about the server model
beyond how to render hypermedia to a client, it is incredibly flexible with
respect to the representations it receives and displays to users.

===== HATEOAS & API churn <_hateoas_api_churn>
This last point is critical to understanding the flexibility of hypermedia, so
let’s look at a practical example of it in action. Consider a situation where a
new feature has been added to the web application with these two end points.
This feature allows you to send a message to a given Contact.

How would this change each of the two responses—​HTML and JSON—​from the server?

The HTML representation might now look like this:

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

Note that, once again, the JSON representation is unchanged. There is no
indication of this new functionality. Instead, a client must _know_
about this change, presumably via some shared documentation between the client
and the server.

Contrast this with the HTML response. Because of the uniform interface of the
RESTful model and, in particular, because we are using Hypermedia As The Engine
of Application State, no such exchange of documentation is necessary! Instead,
the client (a browser) simply renders the new HTML with this operation in it,
making this operation available for the end user without any additional coding
changes.

A pretty neat trick!

Now, in this case, if the JSON client is not properly updated, the error state
is relatively benign: a new bit of functionality is simply not made available to
users. But consider a more severe change to the API: what if the archive
functionality was removed? Or what if the URLs or the HTTP methods for these
operations changed in some way?

In this case, the JSON client may be broken in a much more serious manner.

The HTML response, however, would simply be updated to exclude the removed
options or to update the URLs used for them. Clients would see the new HTML,
display it properly, and allow users to select whatever the new set of
operations happens to be. Once again, the uniform interface of REST has proven
to be extremely flexible: despite a potentially radically new layout for our
hypermedia API, clients continue to work.

An important fact emerges from this: due to this flexibility, hypermedia APIs _do not have the versioning headaches that JSON Data APIs do_.

Once a Hypermedia-Driven Application has been "entered into" (that is, loaded
through some entry point URL), all functionality and resources are surfaced
through self-describing messages. Therefore, there is no need to exchange
documentation with the client: the client simply renders the hypermedia (in this
case HTML) and everything works out. When a change occurs, there is no need to
create a new version of the API: clients simply retrieve updated hypermedia,
which encodes the new operations and resources in it, and display it to users to
work with.

==== Layered System <_layered_system>
The final "required" constraint on a RESTful system that we will consider is The
Layered System constraint. This constraint can be found in
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_6",
)[Section 5.1.6]
of Fielding’s dissertation.

To be frank, after the excitement of the uniform interface constraint, the "layered
system" constraint is a bit of a let down. But it is still worth understanding
and it is actually utilized effectively by The web. The constraint requires that
a RESTful architecture be "layered," allowing for multiple servers to act as
intermediaries between a client and the eventual "source of truth" server.

These intermediary servers can act as proxies, transform intermediate requests
and responses and so forth.

A common modern example of this layering feature of REST is the use of Content
Delivery Networks (CDNs) to deliver unchanging static assets to clients more
quickly, by storing the response from the origin server in intermediate servers
more closely located to the client making a request.

This allows content to be delivered more quickly to the end user and reduces
load on the origin server.

Not as exciting for web application developers as the uniform interface, at
least in our opinion, but useful nonetheless.

==== An Optional Constraint: Code-On-Demand <_an_optional_constraint_code_on_demand>
We called The Layered System constraint the final "required" constraint because
Fielding mentions one additional constraint on a RESTful system. This Code On
Demand constraint is somewhat awkwardly described as
"optional" (Section 5.1.7).

In this section, Fielding says:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  REST allows client functionality to be extended by downloading and executing
  code in the form of applets or scripts. This simplifies clients by reducing the
  number of features required to be pre-implemented. Allowing features to be
  downloaded after deployment improves system extensibility. However, it also
  reduces visibility, and thus is only an optional constraint within REST.
]

So, scripting was and is a native aspect of the original RESTful model of the
web, and thus should of course be allowed in a Hypermedia-Driven Application.

However, in a Hypermedia-Driven Application the presence of scripting should _not_ change
the fundamental networking model: hypermedia should continue to be the engine of
application state, server communication should still consist of hypermedia
exchanges rather than, for example, JSON data exchanges, and so on. (JSON Data
API’s certainly have their place; in Chapter 10 we’ll discuss when and how to
use them).

Today, unfortunately, the scripting layer of the web, JavaScript, is quite often
used to _replace_, rather than augment the hypermedia model. We will elaborate
in a later chapter what scripting that does not replace the underlying
hypermedia system of the web looks like.

=== Conclusion <_conclusion>
After this deep dive into the components and concepts behind hypermedia systems
--- including Roy Fielding’s insights into their operation --- we hope you have
much better understanding of REST, and in particular, of the uniform interface
and HATEOAS. We hope you can see _why_ these characteristics make hypermedia
systems so flexible.

If you were not aware of the full significance of REST and HATEOAS before now,
don’t feel bad: it took some of us over a decade of working in web development,
and building a hypermedia-oriented library to boot, to understand the special
nature of HTML, hypermedia and the web!

#html-note[HTML5 Soup][
#blockquote(attribution: [Confucius])[
  The beginning of wisdom is to call things by their right names.
]

Elements like `<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`,
`<figure>` have become a sort of shorthand for HTML.

By using these elements, a page can make false promises, like
`<article>` elements being self-contained, reusable entities, to clients like
browsers, search engines and scrapers that can’t know better. To avoid this:

- Make sure that the element you’re using fits your use case. Check the HTML spec.

- Don’t try to be specific when you can’t or don’t need to. Sometimes,
  `<div>` is fine.

#index[HTML][spec]
The most authoritative resource for learning about HTML is the HTML
specification. The current specification lives on
#link("https://html.spec.whatwg.org/multipage").#footnote[The single-page version is too slow to load and render on most computers.
  There’s also a "developers’ edition" at /dev, but the standard version has nicer
  styling.] There’s no need to rely on hearsay to keep up with developments in
HTML.

Section 4 of the spec features a list of all available elements, including what
they represent, where they can occur, and what they are allowed to contain. It
even tells you when you’re allowed to leave out closing tags!
]
