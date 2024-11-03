#import "lib/definitions.typ": *

== Htmx 패턴

htmx가 HTML을 하이퍼미디어로 확장하는 방법을 살펴보았으니 이제 이를 실천에 옮길 시간입니다. htmx를 사용하면서 여전히 하이퍼미디어를 사용할 것이며, 우리는 HTTP 요청을 발행하고 HTML을 반환받게 됩니다. 그러나 htmx가 제공하는 추가 기능 덕분에 우리는 더 강력한 하이퍼미디어를 다룰 수 있게 되어 훨씬 더 유연한 인터페이스를 구현할 수 있습니다.

이렇게 하면 긴 피드백 주기나 불편한 페이지 새로 고침과 같은 사용자 경험 문제를 해결할 수 있으며, 많은 경우에 JavaScript를 적게 작성하고 JSON API를 만들 필요 없이 모든 것을 하이퍼미디어에서 구현할 수 있습니다. 우리는 초기 웹의 핵심 하이퍼미디어 개념을 사용하여 모든 것을 구현하게 됩니다.

=== Htmx 설치하기 <_installing_htmx>

#index[htmx][installing]
우리가 가장 먼저 해야 할 일은 웹 애플리케이션에 htmx를 설치하는 것입니다. 이를 위해 소스를 다운로드하여 애플리케이션에 로컬로 저장하여 외부 시스템에 의존하지 않도록 할 것입니다. 이를 "vendoring"이라고 부릅니다. 최신 버전의 htmx를 가져오려면 브라우저를 `https://unpkg.com/htmx.org`로 이동하여 라이브러리의 최신 버전 소스로 리디렉션됩니다.

이 URL의 내용을 프로젝트의 `static/js/htmx.js` 파일에 저장할 수 있습니다.

물론, Node Package Manager(NPM)이나 yarn과 같은 더 정교한 JavaScript 패키지 관리자 를 사용하여 htmx를 설치할 수도 있습니다. 이를 위해 도구에 적합한 방식으로 패키지 이름인 `htmx.org`를 참조하면 됩니다. 하지만 htmx는 아주 작고(압축 및 ZIP으로 약 12kb) 의존성이 없기 때문에 복잡한 메커니즘이나 빌드 도구 없이 사용할 수 있습니다.

`/static/js` 디렉토리에 htmx가 로컬로 다운로드 되었으므로 이제 애플리케이션에 로드할 수 있습니다. 우리는 `layout.html` 파일의 `head` 태그에 다음 `script` 태그를 추가하여 htmx를 사용할 수 있게 합니다. 이로써 htmx는 애플리케이션의 모든 페이지에서 사용 가능하고 활성화됩니다:

#figure(caption: [htmx 설치하기],
```html
<head>
  <script src="/js/htmx.js"></script>
  ...
</head>
```)

`layout.html` 파일은 대부분의 템플릿에 포함되어 있는 _레이아웃_ 파일로, 외부 HTML 요소 내에 템플릿의 내용을 감쌉니다. 여기서는 htmx를 설치하기 위해 사용한 `head` 요소를 포함하고 있습니다.

믿거나 말거나, 그것이 전부입니다! 이 간단한 script 태그만으로 애플리케이션 전역에서 htmx의 기능에 접근할 수 있습니다.

=== 애플리케이션 AJAX화하기 <_ajax_ifying_our_application>

#index[hx-boost]
#index[htmx patterns][boosting]
htmx에 대한 기본적인 이해를 갖기 위해 우리는 처음으로 "부스트"라는 기능을 활용할 것입니다. 이 기능은 우리가 `hx-boost`라는 단 하나의 속성을 애플리케이션에 추가하는 것 외에는 많은 일을 할 필요가 없다는 점에서 약간 "마법적인" 기능입니다.

주어진 요소에 `hx-boost`를 `true` 값으로 설정하면, 해당 요소 내의 모든 앵커 및 폼 요소를 "부스트"합니다. 여기서 "부스트"란 htmx가 모든 앵커와 폼을 "정상" 하이퍼미디어 컨트롤에서 AJAX 기반의 하이퍼미디어 컨트롤로 변환한다는 뜻입니다. "정상" HTTP 요청을 발행하여 전체 페이지를 대체하는 대신, 링크와 폼은 AJAX 요청을 발행하게 됩니다. 그런 다음 htmx는 이러한 요청의 응답에서 `<body>` 태그의 내부 내용을 기존 페이지의 `<body>` 태그에 교체합니다.

이렇게 하면 탐색이 더 빠르게 느껴지게 됩니다. 왜냐하면 브라우저가 응답의 `<head>`와 관련된 대부분의 태그를 재해석하지 않기 때문입니다.

==== 부스트된 링크들 <_boosted_links>
부스트된 링크의 예를 살펴보겠습니다. 아래는 웹 애플리케이션의 가상의 설정 페이지로의 링크입니다. `hx-boost="true"`를 갖고 있기 때문에 htmx는 `/settings` 경로에 요청을 발행하고 전체 페이지를 응답으로 대체하는 정상적인 링크 동작을 중단시킵니다. 대신 htmx는 AJAX 요청을 `/settings`에 발행하여 그 결과를 받아 새로운 내용으로 `body` 요소를 교체합니다.

#figure(caption: [부스트된 링크],
```html
<a href="/settings" hx-boost="true">Settings</a> <1>
```)
1. `hx-boost` 속성 덕분에 이 링크는 AJAX 구동됩니다.

여러분은 합리적으로 물어볼 수 있습니다: 여기서의 장점은 무엇인가요? 우리는 AJAX 요청을 발행하고 단순히 전체 본문을 교체하는 것뿐인데.

단순히 정상 링크 요청을 발행하는 것과 얼마나 큰 차이가 있나요?

예, 확실히 다릅니다: 부스트된 링크를 사용하면 브라우저가 헤드 태그와 관련된 모든 처리 과정을 피할 수 있습니다. 헤드 태그는 종종 많은 스크립트와 CSS 파일 참조를 포함하고 있습니다. 부스트된 시나리오에서는 이러한 자원들을 다시 처리할 필요가 없습니다: 스크립트와 스타일은 이미 처리되었고 새로운 내용에 계속 적용됩니다. 이것은 하이퍼미디어 애플리케이션을 빠르게 만드는 매우 쉬운 방법이 될 수 있습니다.

두 번째 질문은 이렇게 이루어진 응답이 `hx-boost`와 함께 작동하기 위해 특별히 형식이 지정되어야 하나요? 결국 설정 페이지는 일반적으로 `html` 태그와 `head` 태그를 렌더링하니까요. "부스트된" 요청을 처리하기 위해 특별히 처리해야 하나요?

답은 아닙니다: htmx는 스마트하게 `body` 태그의 내용만 꺼내서 새로운 페이지로 교체합니다. `head` 태그는 대부분 무시되며, 제목 태그가 존재하는 경우에만 처리됩니다. 즉, 서버 측에서 `hx-boost`가 처리할 수 있는 템플릿을 렌더링하기 위해 특별한 것을 할 필요가 없습니다: 페이지의 일반 HTML을 반환하면 잘 작동할 것입니다.

참고로 부스트된 링크(및 폼)는 정상 링크와 마찬가지로 탐색 막대와 기록을 계속 업데이트하므로, 사용자는 브라우저 뒤로 버튼을 사용하고, URLs(또는 "딥 링크")를 복사 및 붙여넣기할 수 있습니다. 링크는 거의 "정상"과 같이 작동하며, 다만 더 빠르게 진행됩니다.

==== 부스트된 폼들 <_boosted_forms>
부스트된 폼 태그는 부스트된 앵커 태그와 유사하게 작동합니다: 부스트된 폼은 일반적으로 브라우저에서 발행되는 요청 대신 AJAX 요청을 사용하고 요청의 응답으로 전체 본문을 교체합니다.

여기는 HTTP `POST` 요청을 사용하여 `/messages` 엔드포인트에 메시지를 게시하는 폼의 예입니다. 여기에 `hx-boost`를 추가하여, 이러한 요청이 단순히 일반 브라우저 동작이 아니라 AJAX를 통해 이루어지도록 합니다.

#figure(caption: [부스트된 폼],
```html
<form action="/messages" method="post" hx-boost="true"> <1>
  <input type="text" name="message" placeholder="Enter A Message...">
  <button>Post Your Message</button>
</form>
```)
1. 링크와 마찬가지로 `hx-boost`는 이 폼을 AJAX 구동으로 만듭니다.

#index[스타일 없는 콘텐츠의 순간적 깜박임 (FOUC)]
`hx-boost`가 사용하는 AJAX 기반 요청의 큰 장점 중 하나는 발생하는 헤드 처리의 부재로 인해 _스타일 없는 콘텐츠의 순간적 깜박임_을 피하는 것입니다:

/ 스타일 없는 콘텐츠의 순간적 깜박임 (FOUC): 브라우저가 웹 페이지를 렌더링하기 전에 모든 스타일 정보를 사용할 수 없는 상황. FOUC는 스타일 정보가 모두 제공되면 다시 스타일을 적용하여 비 스타일 콘텐츠가 순간적으로 "깜박이는" 원인이 됩니다. 즉, 사용자가 인터넷을 둘러볼 때 이러한 현상을 목격할 수 있습니다: 텍스트, 이미지 및 기타 콘텐츠가 스타일이 적용됨에 따라 페이지에서 "젖혀질" 수 있습니다.

`hx-boost`를 사용하면 사이트의 스타일이 새로운 콘텐츠를 가져오기 전에 이미 로드되므로 스타일 없는 콘텐츠의 그런 깜박임이 발생하지 않습니다. 이렇게 하면 "부스트된" 애플리케이션이 전반적으로 더 매끄럽고 빠르게 느껴질 수 있습니다.

==== 속성 상속 <_attribute_inheritance>
부스트된 링크의 이전 예를 확장해보면서 그 옆에 몇 개의 부스트된 링크를 추가해보겠습니다. `/contacts` 페이지, `/settings` 페이지, `/help` 페이지로 각각의 링크를 추가할 것입니다. 모든 링크들은 부스트되어 우리가 설명한 대로 동작할 것입니다.

이 부분은 조금 중복된 느낌이 드네요, 그렇죠? 세 개의 링크에 `hx-boost="true"` 속성을 각각 추가하는 것 같아서 어리석은 일처럼 보입니다.

#figure(caption: [부스트된 링크의 모음],
```html
<a href="/contacts" hx-boost="true">Contacts</a>
<a href="/settings" hx-boost="true">Settings</a>
<a href="/help" hx-boost="true">Help</a>
```)

#index[htmx][attribute inheritance]
htmx는 이러한 중복을 줄이는 데 도움을 줄 수 있는 기능인 속성 상속을 제공합니다. 대부분의 htmx 속성은 부모 요소에 속성을 배치하면 자식 요소에도 해당 속성이 적용됩니다. 이는 스타일 시트가 작동하는 방식과 유사하며, 이 아이디어는 htmx가 유사한 "계단식 htmx 속성" 기능을 채택하게 된 영감을 줍니다.

이 예제의 중복을 피하기 위해 모든 링크를 감싸는 `div` 요소를 도입하고, `hx-boost` 속성을 해당 부모 `div`로 "끌어올려" 보겠습니다. 이렇게 하면 중복된 `hx-boost` 속성을 제거할 수 있으며, 모든 링크가 여전히 부스트되어 해당 부모 `div`로부터 해당 기능을 상속받을 수 있도록 보장합니다.

여기서 어떤 유효한 HTML 요소를 사용할 수 있으며, 우리는 그냥 습관적으로 `div`를 사용하고 있습니다.

#figure(caption: [부모를 통한 링크 부스트],
```html
<div hx-boost="true"> <1>
  <a href="/contacts">Contacts</a>
  <a href="/settings">Settings</a>
  <a href="/help">Help</a>
</div>
```)
1. `hx-boost`가 부모 div로 이동되었습니다.

이제 우리는 모든 링크에 `hx-boost="true"`를 넣을 필요가 없으며, 사실 기존의 링크 곁에 더 많은 링크를 추가할 수 있게 되며, 이러한 링크들도 명시적으로 주석을 달지 않고도 부스트될 것입니다.

좋습니다, 하지만 `hx-boost="true"`를 갖고 있는 요소 내에 부스트되지 않기를 원하는 링크가 있다면 어떻게 해야 하나요? 이런 상황의 좋은 예가 PDF 같은 리소스를 다운로드하기 위한 링크일 수 있습니다. 파일 다운로드는 AJAX 요청으로 잘 처리할 수 없기 때문에 해당 링크가 "정상적으로" 작동하길 바라며, 즉 PDF를 위한 전체 페이지 요청을 발행하여 브라우저가 해당 파일을 사용자의 로컬 시스템에 저장할 수 있도록 하기를 원합니다.

이런 상황을 처리하기 위해서는 단순히 부 모 부모 `hx-boost` 값을 `hx-boost="false"`로 오버라이드하여 부스트되어서는 안 되는 앵커 태그에 추가하면 됩니다:

#figure(caption: [부스팅 비활성화],
```html
<div hx-boost="true"> <1>
  <a href="/contacts">Contacts</a>
  <a href="/settings">Settings</a>
  <a href="/help">Help</a>
  <a href="/help/documentation.pdf" hx-boost="false"> <2>
    Download Docs
  </a>
</div>
```)
1. 부모 div에는 여전히 `hx-boost`가 있습니다.
2. 이 링크에 대한 부스팅 동작이 오버라이드되었습니다.

#index[hx-boost][disabling]
여기서 우리는 문서 PDF를 다운로드할 새로운 링크가 있습니다. 이 링크는 일반 링크처럼 작동해야 합니다. 링크에 `hx-boost="false"`를 추가했으며, 이 선언은 부모 `div`의 `hx-boost="true"`를 오버라이드하여 일반 링크 동작으로 되돌려, 우리가 원하는 파일 다운로드 동작을 허용합니다.

==== 점진적 향상 <_progressive_enhancement>

#index[progressive enhancement]
`hx-boost`의 멋진 측면은 그것이 _점진적 향상의_ 예라는 점입니다:

/ 점진적 향상: #[
    가능한 한 많은 사용자에게 필수 콘텐츠 및 기능을 제공하고, 더 발전된 웹 브라우저를 가진 사용자에게 더 나은 경험을 제공하려는 소프트웨어 설계 철학.
]

위의 예제의 링크들을 고려해 보세요. 누군가 JavaScript가 비활성화되어 있다면 어떻게 될까요?

문제 없습니다. 애플리케이션은 계속 작동하지만 정상 HTTP 요청을 발행하고 AJAX 기반의 HTTP 요청을 발행하지는 않습니다. 이 말은 웹 애플리케이션이 최대한 많은 사용자에게 작동할 수 있음을 의미합니다. 현대 브라우저를 사용하는 사용자(또는 JavaScript를 끄지 않은 사용자)는 htmx가 제공하는 AJAX 스타일 탐색의 이점을 누릴 수 있고, 그렇지 않은 사용자도 애플리케이션을 문제 없이 사용할 수 있습니다.

htmx의 `hx-boost` 속성과 JavaScript가 많은 단일 페이지 애플리케이션의 동작을 비교해 봅시다: 그런 애플리케이션은 종종 JavaScript가 비활성화되어 있으면 _전혀_ 작동하지 않습니다. SPA 프레임워크를 사용하면 점진적 향상 접근 방식을 채택하는 것이 종종 매우 어렵습니다.

이것은 모든 htmx 기능이 점진적 향상을 제공한다고 말하는 것이 아닙니다. htmx에서 "JS 없음" 대체 방안을 제공하지 않는 기능을 만드는 것은 분명히 가능하며, 사실 나중에 책에서 구축할 많은 기능이 이 범주에 포함될 것입니다. 우리는 기능이 점진적 향상 친화적인지 여부와 그러지 않은지 알리도록 할 것입니다.

궁극적으로는 개발자인 여러분에게 달려 있습니다. 점진적 향상의 절충(보다 기본적인 UX, 일반 HTML에 대한 제한된 개선)이 애플리케이션 사용자에게 가치는 있는지 결정하는 것은 여러분의 몫입니다.

==== Contact.app에 "hx-boost" 추가하기 <_adding_hx_boost_to_contact_app>
우리가 구축하고 있는 연락처 애플리케이션의 경우, 이 htmx "부스트" 동작을...​ 정말 모든 곳에 적용하고 싶습니다.

그렇죠? 왜 안 되겠어요?

어떻게 이를 달성할 수 있을까요?

글쎄요, 쉬워요(그리고 htmx로 구동되는 웹 애플리케이션에서는 꽤 일반적입니다): 우리는 단순히 `layout.html` 템플릿의 `body` 태그에 `hx-boost`를 추가하면 끝납니다.

#figure(caption: [전체 contact.app 부스트하기],
```html
<html>
...
<body hx-boost="true"> <1>
...
</body>
</html>
```)
1. 이제 모든 링크와 폼이 부스팅됩니다!

이제 애플리케이션의 모든 링크와 폼이 기본적으로 AJAX를 사용하게 되어 훨씬 더 빠르게 느껴질 것입니다. 메인 페이지에 생성했던 "새 연락처" 링크를 생각해 보세요:

#figure(caption: [새롭게 부스트된 "연락처 추가" 링크],
```html
<a href="/contacts/new">Add Contact</a>
```)

비록 우리가 이 링크나 그것이 대상하는 URL의 서버 측 처리에서 아무것도 만지지 않았더라도, 이제는 "부스트된" 링크로서 "잘 작동"하게 되어 AJAX를 사용하여 더 빠른 사용자 경험을 제공하게 되며, 여기에는 기록 업데이트, 뒤로 버튼 지원 등이 포함됩니다. 그리고 JavaScript가 비활성화되어 있다면, 기본 링크 동작으로 돌아가게 됩니다.

모든 것이 htmx 속성 하나로 이루어졌습니다.

`hx-boost` 속성은 멋지지만, 페이지의 많은 요소의 동작을 변경하는 작은 변화를 통해 AJAX 구동 요소로 전환된다는 점에서 다른 htmx 속성과는 다릅니다. 다른 대부분의 htmx 속성은 일반적으로 보다 낮은 수준이며 htmx가 수행해야 하는 정확한 작업을 지정하기 위해 더 명시적으로 주석을 달아야 합니다. 일반적으로, 이것이 htmx의 디자인 철학입니다: 암시적인 것보다 명시적인 것을, 그리고 "마법"보다 분명한 것을 선호합니다.

그러나 `hx-boost` 속성은 너무 유용하기 때문에, 교리를 실용주의로 초과시키는 것은 옳지 않으며, 따라서 라이브러리의 기능으로 포함되었습니다.

=== 두 번째 단계: HTTP DELETE로 연락처 삭제하기 <_a_second_step_deleting_contacts_with_http_delete>
htmx와 함께하는 다음 단계는, Contact.app의 경우에 연락처를 삭제하는 데 사용되는 편집 페이지에 작은 폼이 있다는 점입니다:

#figure(caption: [연락처 삭제를 위한 평범한 HTML 폼],
```html
<form action="/contacts/{{ contact.id }}/delete" method="post">
  <button>Delete Contact</button>
</form>
```)

이 폼은 예를 들어 `/contacts/42/delete`로 HTTP `POST` 요청을 발행하여 ID가 42인 연락처를 삭제합니다.

#index[hx-delete]
우리는 이전에 HTML의 고통스러운 단점 중 하나는 HTTP `DELETE` (또는 `PUT` 또는 `PATCH`) 요청을 직접 발행할 수 없다는 점을 언급했습니다. 비록 이러한 요청이 모두 HTTP의 일부이며 HTTP는 _분명히 HTML 전송을 위해 설계되었습니다_.

다행히도, 이제 htmx 덕분에 이 상황을 수정할 기회를 얻었습니다.

RESTful, 리소스 지향 관점에서 "올바른 일"은 `/contacts/42/delete`에 HTTP `POST` 요청을 발행하는 대신, `/contacts/42`에 HTTP `DELETE` 요청을 발행하는 것입니다. 우리는 연락처를 삭제하고 싶고, 연락처는 리소스입니다. 해당 리소스의 URL은 `/contacts/42`입니다. 그러므로 이상적으로는 `/contacts/42/`에 대한 `DELETE` 요청입니다.

이제 "Delete Contact" 버튼에 htmx `hx-delete` 속성을 추가하여 이를 수행해 보겠습니다:

#figure(caption: [연락처를 삭제하기 위한 htmx 구동 버튼],
```html
<button hx-delete="/contacts/{{ contact.id }}">Delete Contact</button>
```

이제 사용자가 이 버튼을 클릭하면 htmx가 AJAX를 통해 관련 연락처의 URL에 HTTP `DELETE` 요청을 발행합니다.

#index[htmx patterns][delete]
여기서 몇 가지 주목할 사항이 있습니다:
- 버튼을 래핑할 새 `form` 태그가 더 이상 필요하지 않습니다.이유는 버튼 자체가 수행하는 하이퍼미디어 동작을 직접 담고 있기 때문입니다.
- 우리는 우회적으로 사용된 다소 어색한 `"/contacts/{{ contact.id }}/delete"` 경로를 사용할 필요가 없습니다. 단순히 `"/contacts/{{ contact.id }}` 경로를 사용할 수 있으며, 이는 `DELETE`를 발행할 것이기 때문입니다. `DELETE`를 사용함으로써 연락처를 업데이트하는 의도와 삭제 의도를 구분하여 정확한 이유로 사용되는 기존 HTTP 도구를 활용합니다.

여기서 우리는 꽤 마법적인 일을 한 것입니다: 이 버튼을 _하이퍼미디어 컨트롤_로 변환했습니다. HTTP 요청을 발행하기 위해 버튼이 더 이상 더 큰 `form` 태그 내에 있어야 할 필요가 없습니다: 이제 이 버튼은 독립적이며 완전한 기능을 갖춘 하이퍼미디어 컨트롤입니다. 이것이 htmx의 핵심이며, 모든 요소가 하이퍼미디어 컨트롤이 되어 Hypermedia-Driven Application에 완전히 참여할 수 있게 합니다.

또한, 위의 `hx-boost` 예제와 달리 이 솔루션은 둥둥 떠다니는 그런 수행하지 않습니다. 이 솔루션의 마법을 지켜보면 되돌아가는 뒷받침을 삭제할 수 있으며, 서버 측에서 `POST`를 처리해야 합니다.

애플리케이션을 간단하게 유지하기 위해서, 우리는 그보다 더 복잡한 솔루션은 생략할 것입니다.

==== 서버 측 코드 업데이트 <_updating_the_server_side_code>
클라이언트 측 코드를 업데이트하여 적절한 URL로 `DELETE` 요청을 발행하도록 했지만, 아직 해야 할 일이 있습니다. 경로와 사용하는 HTTP 메소드를 업데이트했으므로, 이제 새 HTTP 요청을 처리하기 위해 서버 측 구현을 업데이트해야 합니다.

#figure(caption: [연락처 삭제를 위한 원래의 서버 측 코드],
```python
@app.route("/contacts/<contact_id>/delete", methods=["POST"])
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete()
    flash("Deleted Contact!")
    return redirect("/contacts")
```

우리의 핸들러에서 두 가지를 변경해야 합니다: 경로를 업데이트하고 연락처를 삭제하는 데 사용하는 HTTP 메소드를 업데이트해야 합니다.

#figure(caption: [새 경로 및 메소드가 포함된 업데이트된 핸들러],
```python
@app.route("/contacts/<contact_id>", methods=["DELETE"]) <1>
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete()
    flash("Deleted Contact!")
    return redirect("/contacts")
```
1. 핸들러에 대한 업데이트된 경로와 메소드입니다.

상당히 간단하며 훨씬 깔끔합니다.

===== 응답 코드 문제 <_a_response_code_gotcha>

#index[Flask][redirect]
불행히도 업데이트된 핸들러에는 문제가 있습니다: 기본적으로 Flask의 `redirect()` 메소드는 `302 Found` HTTP 응답 코드로 응답합니다.

Mozilla 개발자 네트워크(MDN)의 문서에 따르면,
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/302",
)[`302 Found`]
응답은 요청의 HTTP _메소드_가 리디렉션된 HTTP 요청이 발행될 때 _변경되지 않을 것_이라는 의미입니다.

우리는 지금 htmx와 함께 `DELETE` 요청을 발행한 후 Flask가 `/contacts` 경로로 리디렉션됩니다. 이러한 논리에 따르면, 리디렉션된 HTTP 요청은 여전히 `DELETE` 메소드가 될 것입니다. 이것은 우리가 원하는 것이 아닙니다: HTTP 리디렉션이 `GET` 요청을 발행하도록 하고 싶습니다. 즉, 우리가 이전에 논의했던 Post/Redirect/Get 동작을 Delete/Redirect/Get으로 약간 수정해야 합니다.

다행히 우리가 원하는 것을 하는 다른 응답 코드인
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303",
)[`303 See Other`]가 있습니다. 브라우저가 `303 See Other` 리디렉션 응답을 받으면, 새 위치에 대해 `GET`을 발행합니다.

따라서 우리는 컨트롤러에서 `303` 응답 코드를 사용하도록 코드를 업데이트해야 합니다.

운 좋게도 이는 매우 쉽습니다: `redirect()`에는 발송할 숫자 응답 코드를 인수로 받을 수 있는 두 번째 매개변수가 있습니다.

#figure(caption: [업데이트된 핸들러와 함께 `303` 리디렉션 응답],
```python
@app.route("/contacts/<contact_id>", methods=["DELETE"])
def contacts_delete(contact_id=0):
    contact = Contact.find(contact_id)
    contact.delete()
    flash("Deleted Contact!")
    return redirect("/contacts", 303) <1>
```
1. 응답 코드가 이제 303입니다.

이제 주어진 연락처를 제거하고자 할 때는 이전에 연락처에 접근하기 위해 사용한 것과 동일한 URL로 `DELETE`를 발행할 수 있습니다.

이는 리소스를 삭제하는 데 있어 자연스러운 HTTP 기반 접근 방식입니다.

==== 정확한 요소 타겟팅 <_targeting_the_right_element>

#index[hx-target][example]
우리는 업데이트된 삭제 버튼의 작업이 끝나지 않았습니다. htmx는 기본적으로 요청을 트리거한 요소를 "타겟" 타겟으로 하고, 서버에서 반환된 HTML을 해당 요소 내부에 배치합니다. 현재 "Delete Contact" 버튼은 자신을 타겟으로 하고 있습니다.

즉, `/contacts` URL로 리디렉션하면 전체 연락처 목록이 재 렌더링 되므로 이 연락처 목록은 "Delete Contact" 버튼 내부에 배치될 것입니다.

이러한 잘못된 타겟팅은 htmx 작업 중 가끔 발생할 수 있으며, 재미있는 상황을 초래할 수 있습니다.

이 문제의 해결은 간단합니다: 버튼에 명시적인 타겟을 추가하고 응답을 `body` 요소로 타겟팅해 보겠습니다:

#figure(caption: [연락처 삭제를 위한 고정된 htmx 구동 버튼],
```html
<button hx-delete="/contacts/{{ contact.id }}"
    hx-target="body"> <1>
  Delete Contact
</button>
```
1. 버튼에 추가된 명시적인 타겟입니다.

이제 버튼은 예상대로 작동합니다: 버튼을 클릭하면 서버에 대한 HTTP `DELETE` 요청을 발행하여 현재 연락처를 삭제하고 해당 연락처 목록 페이지로 리디렉션하고 멋진 플래시 메시지를 표시합니다.

모든 것이 이제 매끄럽게 작동하고 있습니까?

==== 위치 바 URL 적절하게 업데이트하기 <_updating_the_location_bar_url_properly>

글쎄요, 거의 그렇습니다.

#index[htmx][location bar]
버튼을 클릭하면 리디렉션에도 불구하고 위치 바의 URL이 올바르지 않다는 것을 알 수 있습니다. 여전히 `/contacts/{{ contact.id }}`를 가리키고 있습니다. 이는 htmx에 URL을 업데이트하라고 지시하지 않았기 때문입니다. htmx는 단순히 `DELETE` 요청을 발행한 다음 응답으로 DOM을 업데이트합니다.

우리가 언급했듯이, `hx-boost`를 통한 부스트는 자연스럽게 위치 바를 업데이트하여 정상 앵커와 폼을 모방하지만, 현재 우리는 사용자 정의 버튼 하이퍼미디어 컨트롤을 구축하여 `DELETE` 요청을 발행하고 있습니다. 우리는 htmx에 이 요청의 결과 URL이 위치 바에 "푸시"되기를 원합니다.

#index[hx-push-url]
이를 달성하기 위해 버튼에 `hx-push-url` 속성을 추가하고 값을 `true`로 설정하면 됩니다:

#figure(caption: [연락처 삭제 과정, 이제 적절한 위치 정보로],
```html
<button hx-delete="/contacts/{{ contact.id }}"
  hx-target="body"
  hx-push-url="true"> <1>
  Delete Contact
</button>
```
1. htmx에 리디렉션 URL을 위치 바에 푸시하라고 지시합니다.

_이제_ 우리는 끝났습니다.

우리는 버튼 하나만으로 올바른 형식의 HTTP `DELETE` 요청을 적절한 URL로 발행할 수 있는 버튼을 가지고 있으며 UI와 위치 바가 모두 올바르게 업데이트됩니다. 이는 버튼에 직접 배치된 `hx-delete`, `hx-target` 및 `hx-push-url`라는 세 가지 선언적 속성을 통해 달성되었습니다.

이것은 `hx-boost` 변경보다 더 많은 작업이 요구되었지만, 명시적인 코드는 버튼이 사용자 정의 하이퍼미디어 컨트롤로서 수행하고 있는 작업을 쉽게 볼 수 있도록 합니다. 결과 솔루션은 깔끔하게 느껴지며, 하이퍼미디어 시스템으로서의 웹이 제공하는 내장된 기능을 활용했습니다.

==== 한 가지 더…​ <_one_more_thing>

#index[hx-confirm]
#index[htmx patterns][confirmation dialog]
우리가 "Delete Contact" 버튼에 추가할 수 있는 추가 "보너스" 기능이 하나 있습니다: 확인 대화 상자입니다. 연락처를 삭제하는 것은 파괴적인 작업이며 현재 사용자는 실수로 "Delete Contact" 버튼을 클릭하면 애플리케이션이 그 연락처를 즉시 삭제해버릴 것입니다. 사용자에게 매우 안타까운 일이겠죠.

다행스럽게도, htmx는 이와 같은 파괴적 작업에 대한 확인 메시지를 추가할 수 있는 간단한 메커니즘을 제공합니다: `hx-confirm` 속성입니다. 이 속성을 요소에 반복적으로 배치할 수 있으며, 해당 속성의 값으로 메시지를 사용하여 요청이 발행되기 전에 JavaScript 메소드 `confirm()`을 호출하여 사용자에게 확인 메시지를 요청하는 간단한 확인 대화 상자를 표시합니다. 매우 쉽고 실수를 방지하는 훌륭한 방법입니다.

연락처 삭제 작업을 확인하는 방법은 다음과 같습니다:

#figure(caption: [삭제 확인],
```html
<button hx-delete="/contacts/{{ contact.id }}"
  hx-target="body"
  hx-push-url="true"
  hx-confirm="Are you sure you want to delete this contact?"> <1>
  Delete Contact
</button>
```
1. 이 메시지가 사용자에게 표시되어 삭제를 확인할 수 있도록 요청합니다.

이제 누군가 "Delete Contact" 버튼을 클릭하면 "Are you sure you want to delete this contact?"라는 프롬프트가 나타나고 실수로 버튼을 클릭했다면 취소할 기회를 가지게 됩니다. 매우 멋진 기능입니다.

이 최종 변경으로 우리는 꽤 견고한 "연락처 삭제" 메커니즘을 갖게 되었습니다: 우리는 정확한 RESTful 경로와 HTTP 메소드를 사용하고 있으며, 삭제를 확인하고, 일반 HTML이 부과하는 많은 불필요한 부분들을 제거했습니다. 이는 모두 HTML 내 선언적 속성을 사용하여 이루어졌으며, 웹의 정상적인 하이퍼미디어 모델에 확고히 남아 있습니다.

==== 점진적 향상? <_progressive_enhancement_2>

#index[progressive enhancement]
우리가 이 솔루션에 대해 앞서 언급했듯이: 이는 웹 애플리케이션에 대한 _점진적 향상이 아닙니다_. 만약 누군가 JavaScript를 비활성화했다면 이 "Delete Contact" 버튼은 더 이상 작동하지 않습니다. JavaScript가 비활성화된 환경에서 구식 양식 기반 메커니즘을 작동하기 위해 추가적인 작업이 필요합니다.

점진적 향상은 웹 개발에서 핫버튼 주제가 될 수 있으며, 많은 열정적인 의견과 관점이 존재합니다. 거의 모든 JavaScript 라이브러리와 마찬가지로, htmx는 JavaScript 없이 작동하지 않는 애플리케이션을 만드는 가능성을 제공합니다. 비-JavaScript 클라이언트 지원을 유지하려면 애플리케이션에서 추가적인 작업과 복잡성이 필요합니다. htmx 또는 웹 애플리케이션 개선을 위한 다른 JavaScript 프레임워크를 사용할 때 비-JavaScript 클라이언트를 지원하는 것의 중요성을 정확히 판단하는 것이 중요합니다.

=== 다음 단계: 연락처 이메일 검증하기 <_next_steps_validating_contact_emails>

#index[validation]
이제 애플리케이션의 또 다른 개선으로 넘어가겠습니다. 웹 앱의 큰 부분은 서버에 제출된 데이터를 검증하는 것입니다: 이메일이 올바르게 형식화되고 고유한지, 숫자 값이 유효한지, 날짜가 허용되는지 등을 확인하는 것입니다.

현재 우리 애플리케이션은 서버 측에서만 수행되는 검증이 있으며, 오류가 감지될 때 오류 메시지를 표시합니다.

우리는 모델 객체의 검증이 어떻게 작동하는지에 대한 세부 사항을 살펴보려 하지 않지만, 3장 연락처 업데이트의 코드는 다음과 같이 생겼습니다:

#figure(caption: [연락처 업데이트의 서버 측 검증],
```python
def contacts_edit_post(contact_id=0):
    c = Contact.find(contact_id)
    c.update(
      request.form['first_name'],
      request.form['last_name'],
      request.form['phone'],
      request.form['email']) <1>
    if c.save():
        flash("Updated Contact!")
        return redirect("/contacts/" + str(contact_id))
    else:
        return render_template("edit.html", contact=c) <2>
```

1. 우리는 연락처를 저장하려고 시도합니다.
2. 저장이 실패하면 오류 메시지를 표시하기 위해 양식을 다시 렌더링합니다.

따라서 우리는 연락처 저장을 시도하고, `save()` 메소드가 true를 반환하면 연락처 세부 사항 페이지로 리디렉션합니다. `save()` 메소드가 true를 반환하지 않으면 검증 오류가 나타났음을 나타내며, 리디렉션하는 대신 연락처를 편집하기 위해 HTML을 다시 렌더링합니다. 이로써 사용자는 입력란 옆에 표시된 오류를 수정할 기회를 가지게 됩니다.

이메일 입력의 HTML을 살펴보겠습니다:

#figure(caption: [검증 오류 메시지],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="text"
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span> <1>
</p>
```
1. 이메일 필드와 관련된 오류를 표시합니다.

이메일 필드를 표시하는 레이블과 텍스트 유형 입력과 오류 메시지를 이메일과 함께 표시하는 HTML의 구조로 이루어져 있습니다. 서버에서 템플릿이 렌더링되면, 연락처의 이메일과 관련된 오류가 있을 경우, 이 스팬에 빨간색으로 하이라이트된 상태로 표시됩니다.

#sidebar[서버 측 검증 논리][지금 연락처 클래스에는 같은 이메일 주소를 가진 다른 연락처가 있는지 확인하고, 있다면 오류를 추가하여 중복 이메일을 데이터베이스에 두지 않도록 하는 기본적인 로직이 있습니다. 이는 이메일이 보통 유니크하기 때문에 매우 일반적인 검증의 예입니다. 같은 이메일로 두 개의 연락처를 추가하는 것은 거의 확실히 사용자의 실수입니다. 다시 말하지만, 우리는 검증이 모델에서 어떻게 작동하는지에 대한 세부사항을 살펴보려 하지 않지만, 거의 모든 서버 측 프레임워크는 데이터를 검증하고 사용자에 대한 오류를 표시하기 위해 오류를 수집하는 방법을 제공합니다. 이러한 종류의 인프라는 웹 1.0 서버 측 프레임워크에서 매우 일반적입니다.]

사용자가 중복 이메일로 연락처를 저장하려 할 때 표시되는 오류 메시지는 "이메일은 고유해야 합니다."이며, 이는 @fig-emailerror에서 볼 수 있습니다.

#figure([#image("images/screenshot_validation_error.png")], caption: [
  이메일 검증 오류
])<fig-emailerror>

이 모든 것은 순수 HTML을 사용하고 웹 1.0 기법을 사용하여 잘 작동합니다.

그러나, 현재 애플리케이션은 두 가지 성가신 점이 있습니다.
- 첫 번째, 이메일 형식 검증이 없습니다: 사용자는 이메일로 원하는 문자들을 입력할 수 있으며, 고유하기만 하면 시스템이 허용합니다.
- 두 번째, 모든 데이터가 제출될 때만 이메일의 고유성을 검사합니다: 사용자가 중복 이메일을 입력하면 모든 필드를 채운 다음에야 이 사실을 알 수 있습니다. 이는 사용자가 연락처를 다시 입력하고 있으며, 따라서 모든 연락처 정보를 입력하는 데 귀찮은 일이 될 수 있습니다.

==== 입력 유형 업데이트 <_updating_our_input_type>

#index[HTML][inputs]
첫 번째 문제를 해결하기 위해, 애플리케이션을 개선할 수 있는 순수 HTML 기법이 있습니다: HTML 5는 `email` 유형의 입력을 지원합니다. 우리는 입력 유형을 `text`에서 `email`로 전환하기만 하면 됩니다. 그러면 브라우저가 입력된 값이 올바른 이메일 형식인지 강제할 것입니다:

#figure(caption: [입력을 `email` 유형으로 변경하기],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email" <1>
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span>
</p>
```
1. `type` 속성의 변경으로 입력된 값이 유효한 이메일인지 확인합니다.

이것이 변경되면 사용자가 유효하지 않은 이메일을 입력할 경우 브라우저가 그 필드에 대해 올바르게 형식화된 이메일 요청하는 오류 메시지를 표시합니다.

따라서 순수 HTML로 이루어진 단순한 단일 속성의 변경으로 검증이 개선되었으며 우리가 언급한 첫 번째 문제를 해결했습니다.

#sidebar[서버 측 vs. 클라이언트 측 검증][
  숙련된 웹 개발자라면 위의 코드에 질식할 것입니다: 이 검증은 _클라이언트 측_에서 이루어집니다. 즉, 우리는 브라우저가 잘못된 형식의 이메일을 감지하고 이를 사용자가 수정하도록 요구하는 것에 의존하고 있습니다. 불행히도 클라이언트 측은 신뢰할 수 없습니다: 브라우저에는 이 검증 코드를 우회하는 버그가 있을 수 있습니다. 또는 심지어는 해를 끼치려는 사용자가 HTML을 수정하는 등 이 검증을 완전히 우회하는 방법을 생각해 낼 수도 있습니다. 이는 웹 개발에서 지속적인 위험입니다: 클라이언트 측에서 이루어지는 모든 검증은 신뢰할 수 없으며, 검증이 중요하다면 _서버 측에서 다시 진행해야합니다_. 이는 Hypermedia-Driven Applications에서 단일 페이지 애플리케이션보다 덜 문제가 되는 이유는 HDAs의 초점이 서버 측에 있기 때문입니다. 하지만 애플리케이션을 구축할 때 명심할 가치가 있습니다.
]

==== 인라인 검증 <_inline_validation>

#index[htmx patterns][inline validation]
우리는 검증 경험을 약간 개선했지만, 사용자는 여전히 중복된 이메일에 대한 피드백을 얻기 위해 양식을 제출해야 합니다. 우리는 htmx를 이용하여 이 사용자 경험을 개선할 수 있습니다.

사용자가 이메일 값을 입력한 후 즉시 중복 이메일 오류를 볼 수 있다면 더 좋을 것입니다. 입력하는 동안 `change` 이벤트가 발생하며, 실제로 입력에서는 `change` 이벤트가 htmx의 _기본 트리거_입니다. 이 기능을 활용하여 다음과 같은 동작을 구현할 수 있습니다: 사용자가 이메일을 입력할 때 즉시 서버에 요청을 발행하고 그 이메일을 검증하고, 필요시 오류 메시지를 렌더링합니다.

현재 우리의 이메일 입력 HTML을 회상해보십시오:

#figure(caption: [이메일 초기 구성],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email"
    placeholder="Email" value="{{ contact.email }}"> <1>
  <span class="error">{{ contact.errors['email'] }}</span> <2>
</p>
```
1. 이 입력이 HTTP 요청을 발행하도록 설정합니다.
2. 필요한 경우 오류 메시지를 표시할 span입니다.

따라서 우리는 이 입력에 `hx-get` 속성을 추가할 것입니다. 이는 입력이 주어진 URL에 대해 HTTP `GET` 요청을 발행하도록 할 것입니다. 그런 다음 입력란 다음의 오류 span을 타겟하여 서버에서 반환된 오류 메시지를 표시합니다.

HTML을 다음과 같이 변경해 보겠습니다:

#figure(caption: [업데이트된 HTML],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email"
    hx-get="/contacts/{{ contact.id }}/email" <1>
    hx-target="next .error" <2>
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span>
</p>
```
1. 연락처의 `email` 엔드포인트에 HTTP `GET`을 발행합니다.
2. 오류가 있는 경우, 입력 바로 다음에 있는 `class`가 `error`인 그 다음의 요소를 타겟합니다.

`hx-target` 속성에서는 _상대 위치_ 선택기 `next`를 사용하고 있다는 점에 유의하십시오. 이는 htmx의 기능이며 일반 CSS의 확장입니다. htmx는 현재 요소에 상대적으로 대상 요소를 찾아낼 수 있는 접두사를 지원합니다.

#sidebar[htmx의 상대적 위치 표현][
/ `next`: #[
  DOM에서 다음 일치하는 요소를 forward로 스캔합니다. 예를 들어,
  `next .error`
  ]

/ `previous`: #[
  DOM에서 가장 가까운 이전 일치하는 요소로 backward로 스캔합니다. 예를 들어, `previous .alert`
  ]

/ `closest`: #[
  이 요소의 부모에서 일치하는 요소를 스캔합니다. 예를 들어,
  `closest table`
  ]

/ `find`: #[
  이 요소의 자식에서 일치하는 요소를 스캔합니다. 예를 들어,
  `find span`
  ]

/ `this`: #[
    현재 요소가 대상입니다(기본값)
  ]
]

상대적 위치 표현을 사용함으로써 고유한 ID를 요소에 부여하는 것을 피하고 HTML의 로컬 구조에서 이점을 취할 수 있습니다.

따라서 `hx-get` 및 `hx-target` 속성을 추가한 우리의 예제에서는, 누군가 입력 값의 변경을 하게 되면(기억하시겠지만, `change`는 htmx의 _기본_ 트리거라는 점을) HTTP `GET` 요청이 발행될 것입니다. 만약 오류가 있다면, 오류는 오류 span에 로드될 것입니다.

==== 서버 측 이메일 검증하기 <_validating_emails_server_side>
다음으로 서버 측 구현을 살펴보겠습니다. 우리는 연락처의 ID가 URL에 인코딩된 상태를 바탕으로 연락처를 조회하는 또 다른 엔드포인트를 추가할 것입니다. 그러나 이번 경우, 우리는 연락처의 이메일만 업데이트하기를 원하며, 물론 저장하지는 않을 것입니다! 우리는 단지 `validate()` 메소드만 호출하게 될 것입니다.

그 메소드는 이메일이 고유하다는 것을 검증합니다. 이 시점에서 우리는 이메일과 관련된 오류를 직접 반환하거나, 없다면 빈 문자열을 반환할 수 있습니다.

#figure(caption: [이메일 검증 엔드포인트를 위한 코드],
```python
@app.route("/contacts/<contact_id>/email", methods=["GET"])
def contacts_email_get(contact_id=0):
    c = Contact.find(contact_id) <1>
    c.email = request.args.get('email') <2>
    c.validate() <3>
    return c.errors.get('email') or "" <4>
```
1. ID로 연락처를 조회합니다.
2. 이메일을 업데이트합니다(이것은 `GET`이기 때문에 `args` 속성을 사용합니다).
3. 연락처를 검증합니다.
4. 이메일 필드에 관련된 오류가 있으면 반환하며, 없다면 빈 문자열을 반환합니다.

이 작은 서버 측 코드 조각이 추가되면 이제 우리는 다음 사용자 경험을 갖게 됩니다: 사용자가 이메일을 입력하고 다음 입력란으로 탭할 때, 즉시 이메일이 이미 사용 중인지 알림을 받게 됩니다.

이메일 검증은 전체 연락처 업데이트를 위해 제출할 때 _여전히_ 진행됩니다. 따라서 중복 이메일 연락처가 스며들 수 있는 위험이 없습니다. 우리는 단지 사용자가 이 상황을 더 일찍 파악할 수 있게 하였습니다.

또한, 이 특정 이메일 검증은 _서버 측_에서 이루어져야 합니다: 이메일이 모든 연락처에서 고유한지 여부를 확인하려면 기록 데이터 저장소에 접근해야만 가능합니다. 이는 Hypermedia-Driven Applications의 또 다른 단순화된 측면입니다: 검증은 서버 측에서 이루어지므로, 어떤 유형의 검증이든 필요한 모든 데이터에 접근할 수 있습니다.

여기에서도 우리가 이 상호작용을 하이퍼미디어 모델 내에서 전적으로 수행하고 있다는 점을 강조하고 싶습니다: 우리는 선언적 속성을 사용하고 있으며, 링크나 폼처럼 서버와 하이퍼미디어를 교환하는 방식과 매우 유사한 방식으로 진행하고 있습니다. 하지만 우리는 사용자 경험을 극적으로 개선할 수 있었습니다.

==== 사용자 경험 향상 더 진행하기 <_taking_the_user_experience_further>
비록 우리는 여기서 많은 코드를 추가하지 않았지만, 적어도 순수 HTML 기반 애플리케이션과 비교할 때는 꽤 정교한 사용자 인터페이스를 갖추게 되었습니다. 그러나 더 발전된 단일 페이지 애플리케이션을 사용해 보았다면, 이메일 필드(또는 유사한 입력)가 _입력 중에_ 유효성이 검증되는 패턴을 보셨을 것입니다.

이런 상호작용은 복잡한 JavaScript 프레임워크를 사용할 때만 가능할 것 같나요?

글쎄요, 아닙니다.

사실 이 기능을 htmx에서 순수 HTML 속성을 사용하여 구현할 수 있습니다.

#index[hx-trigger][change]
#index[hx-trigger][keyup]
#index[event][change]
#index[event][keyup]
사실 우리가 해야 할 일은 트리거를 변경하는 것입니다. 현재 우리는 입력의 기본 트리거인 `change` 이벤트를 사용하고 있습니다. 사용자가 타이핑하는 동안 검증하려면 `keyup` 이벤트도 캡처해야 합니다:

#figure(caption: [키를 눌러서 트리거하기],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email"
    hx-get="/contacts/{{ contact.id }}/email"
    hx-target="next .error"
    hx-trigger="change, keyup" <1>
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span>
</p>
```
1. 명시적인 `keyup` 트리거가 `change`와 함께 추가되었습니다.

이 작은 변경으로 인해 사용자가 문자를 입력할 때마다 요청을 발행하고 이메일을 검증할 수 있게 됩니다. 간단합니다.

==== 검증 요청 디바운싱 <_debouncing_our_validation_requests>

#index[debouncing]
간단하긴 한데, 아마 원하는 것이 아닐 것입니다: 키를 눌렀을 때마다 새 요청을 발행하는 것은 매우 비효율적이며, 서버를 압도할 수 있는 가능성이 있습니다. 대신, 우리가 원하는 것은 사용자가 잠시 멈춘 후에 요청을 발행하는 것입니다. 이를 "입력을 디바운스한다"라고 하며, 요청이 지연되어 일이 "잠잠해질 때"까지 기다리는 것을 의미합니다.

htmx는 요청을 디바운스 할 수 있는 `delay` 수정자를 지원합니다. 이는 요청이 발송되기 전에 지연을 추가하여 사용하는 것입니다. 동일한 종류의 이벤트가 그 시간 내에 발생하면 htmx는 요청을 발행하지 않고 타이머를 재설정합니다.

이것은 이메일 입력에 적합합니다: 사용자가 이메일을 입력하고 바쁜 동안 인터럽트를 발생시키지 않고, 사용자가 잠시 멈추거나 필드를 떠난 경우 요청을 발행합니다.

이제 `keyup` 트리거에 200밀리초의 지연을 추가하겠습니다. 이는 사용자가 입력을 멈추었음을 감지하기에 충분한 시간입니다:

#figure(caption: [키를 눌러서 디바운싱 요청하기],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email"
    hx-get="/contacts/{{ contact.id }}/email"
    hx-target="next .error"
    hx-trigger="change, keyup delay:200ms" <1>
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span>
</p>
```
1. `delay` 수정자를 추가하여 `keyup` 이벤트를 디바운스합니다.

이제 사용자가 입력하는 동안 검증 요청의 흐름이 발생하지 않습니다. 대신 사용자가 잠시 멈춘 후 요청을 발행하게 됩니다. 서버에는 훨씬 더 나은 방식이며, 여전히 좋은 사용자 경험을 제공합니다.

==== 비변이 키 무시하기 <_ignoring_non_mutating_keys>
키업 이벤트와 관련된 마지막 문제를 처리해야 합니다: 키 입력을 하게 되면 어떤 키를 누르든 관계없이 요청이 발행됩니다. 화살표 키와 같이 입력값에 영향을 주지 않는 키가 있을 때는 요청을 발행하지 않는 것이 더 좋습니다.

#index[event modifier][changed]
htmx는 이러한 패턴을 지원하는 `changed` 수식어를 사용하여 이를 해결할 수 있는 방법이 있습니다. (입력 요소에서 DOM에 의해 트리거된 `change` 이벤트와 혼동해서는 안 됩니다.)

입력에 `keyup` 트리거에 `changed`를 추가하면, 입력 값이 실제로 업데이트되지 않는 한 검증 요청을 발행하지 않습니다:

#figure(caption: [입력 값이 변경될 때만 요청 발송],
```html
<p>
  <label for="email">Email</label>
  <input name="email" id="email" type="email"
    hx-get="/contacts/{{ contact.id }}/email"
    hx-target="next .error"
    hx-trigger="change, keyup delay:200ms changed" <1>
    placeholder="Email" value="{{ contact.email }}">
  <span class="error">{{ contact.errors['email'] }}</span>
</p>
```
1. 입력의 값이 실제로 변경될 때만 요청을 발행하여 무의미한 요청을 없앱니다.

상당히 깔끔하고 강력한 HTML로 보입니다. 대부분의 개발자들은 이를 복잡한 클라이언트 측 솔루션이 필요하다고 생각할 것입니다.

토탈 세 개의 속성과 간단한 새로운 서버 측 엔드포인트로 우리는 웹 애플리케이션에 꽤 정교한 사용자 경험을 추가했다는 것입니다. 더욱이, 우리가 서버 측에서 추가하는 모든 이메일 검증 규칙은 이 모델을 사용하여 _자동으로_ 작동합니다: 우리는 통신 메커니즘으로서 하이퍼미디어를 사용하고 있으므로 클라이언트 측과 서버 측 모델을 서로 동기화할 필요가 없습니다.

하이퍼미디어 아키텍처의 힘에 대한 훌륭한 예시입니다!

=== 또 다른 애플리케이션 개선: 페이지 매김 <_another_application_improvement_paging>

#index[htmx patterns][paging]
연락처 편집 페이지에서 잠시 이동하여 애플리케이션의 루트 페이지, 즉 `/contacts` 경로에서 `index.html` 템플릿을 개선해보겠습니다.

현재 Contact.app은 페이지 매김을 지원하지 않습니다: 데이터베이스에 10,000개의 연락처가 있으면 우리는 루트 페이지에서 모든 10,000개의 연락처를 표시합니다. 이렇게 많은 데이터를 보여주는 것은 브라우저(및 서버)를 느리게 할 수 있으므로 대부분의 웹 애플리케이션은 이러한 대규모 데이터 세트를 처리하기 위해 "페이지 매김" 개념을 채택하며, 여기서 더 작은 수의 항목만 포함된 "페이지"를 표시하고 데이터 세트를 탐색할 수 있는 기능이 제공됩니다.

애플리케이션을 수정하여 연락처 데이터베이스에 10개 이상의 연락처가 있을 경우 "다음" 및 "이전" 링크와 함께 한 번에 10개의 연락처만 표시하겠습니다.

우리가 먼저 수행할 변경 사항은 `index.html` 템플릿에 간단한 페이지 매김 위젯을 추가하는 것입니다.

우리는 조건부로 두 개의 링크를 포함할 것입니다:
- 우리는 "첫" 페이지를 넘어설 경우 이전 페이지로 연결되는 링크를 포함할 것입니다.
- 현재 결과 집합에 10개의 연락처가 있을 경우, 다음 페이지로 연결되는 링크를 포함할 것입니다.

이것은 완벽한 페이지 매김 위젯이 아닙니다: 이상적으로는 페이지 수를 표시하고 보다 구체적인 페이지 탐색 기능을 제공하길 바라며, 다음 페이지가 0개 결과일 가능성도 있으며, 총 결과 수를 확인하고 있지 않기 때문에 달성하지 못했습니다. 그러나 현재로서는 우리 간단한 애플리케이션에는 좋을 것입니다.

이제 이를 `index.html`의 Jinja 템플릿 코드로 살펴보겠습니다.

#figure(caption: [연락처 목록에 페이지 매김 위젯 추가하기],
```html
<div>
  <span style="float: right"> <1>
    {% if page > 1 %}
      <a href="/contacts?page={{ page - 1 }}">Previous</a> <2>
    {% endif %}
    {% if contacts|length == 10 %}
      <a href="/contacts?page={{ page + 1 }}">Next</a> <1>
    {% endif %}
  </span>
</div>
```)
1. 탐색 링크를 담을 새로운 div를 테이블 아래에 추가합니다.
2. 1페이지를 초과하면, 페이지 수를 1 줄인 앵커 태그를 포함합니다.
3. 현재 페이지에 10개의 연락처가 있을 경우, 페이지 수를 1 늘린 앵커 태그를 포함합니다.

여기서는 특별한 Jinja 필터 구문인 `contacts|length`를 사용하여 연락처 목록의 길이를 계산하고 있습니다. 이 필터 구문의 세부 사항은 이 책의 범위를 넘어서는 것이므로, 이 경우에는 `contacts.length` 속성을 호출하고 이를 `10`과 비교하는 것으로 생각하시면 됩니다.

이제 이러한 링크들이 추가되었으니, 다음으로 서버 측 페이지 매김 구현을 살펴보겠습니다.

우리는 요청의 상태를 UI에 인코딩하기 위해 `page` 요청 매개변수를 사용하고 있습니다. 따라서 우리의 핸들러에서 `page` 매개변수를 검색하여 이러한 값을 모델로 전달해야 합니다. 이 값은 정수여야 하며 연락처의 어떤 페이지를 반환해야 하는지 모델이 알 수 있어야 합니다.

#figure(caption: [요청 핸들러에 페이지 매김 추가하기],
```python
@app.route("/contacts")
def contacts():
    search = request.args.get("q")
    page = int(request.args.get("page", 1)) <1>
    if search is not None:
        contacts_set = Contact.search(search)
    else:
        contacts_set = Contact.all(page) <2>
    return render_template("index.html",
      contacts=contacts_set, page=page)
```
1. 페이지 매개변수를 확인하고, 페이지가 전달되지 않는 경우 1페이지로 기본 설정합니다.
2. 연락처를 모두 로드할 때 모델에 페이지를 전달하여 10개의 연락처 페이지를 반환하도록 합니다.

상당히 간단합니다: 여기서 다시 다른 매개변수를 가져오고(`q` 매개변수를 연락처 검색 시 전달했듯이) 이를 정수로 변환한 후 `Contact` 모델에 넣어주면 됩니다. 그러고 나면 연락처의 해당 페이지를 반환할 수 있습니다.

희망컨대, 그 작은 변화로 우리는 웹 애플리케이션을 위한 매우 기본적인 페이지 매김 메커니즘을 이미 구현하게 됩니다.

믿거나 말거나, 애플리케이션은 이미 AJAX를 사용하고 있으며, `hx-boost` 덕분입니다. 쉽죠!

==== 클릭하여 로드 <_click_to_load>

#index[htmx patterns][click to load]
이 페이지 매김 메커니즘은 기본 웹 애플리케이션에서는 적합하지만, 인터넷에서 많이 사용되고 있습니다. 하지만 몇 가지 단점이 있습니다: "다음"이나 "이전" 버튼을 클릭할 때마다 전체 연락처 페이지가 새로 로드되고 이전 페이지에서의 컨텍스트를 잃게 됩니다.

때로는 좀 더 발달된 페이지 매김 UI 패턴이 더 나을 수 있습니다. 즉, 새 요소의 페이지를 로드하는 대신 기존 요소 뒤에 다음 요소를 _인라인_으로 추가하는 것이 더 좋을 수 있습니다.

이것이 좀 더 발전된 웹 애플리케이션에서 발견되는 일반적인 "클릭하여 로드" UX 패턴입니다.

#figure(
  caption: [클릭하여 로드 UI], image("images/screenshot_click_to_load.png"),
)<fig-clicktoload>

@fig-clicktoload에서는 클릭 시 연락처의 다음 세트를 페이지에 직접 로드할 수 있는 버튼이 있습니다. 이렇게 하면 현재 연락처가 페이지에서 시각적으로 "컨텍스트"를 유지할 수 있으며, 여전히 정상적인 페이지된 사용자 인터페이스처럼 진행할 수 있습니다.

이 UX 패턴을 htmx에서 구현해 보겠습니다.

사실 매우 간단하게 구현할 수 있습니다: 현재 "다음" 링크를 가져와 몇 개의 htmx 속성만으로 약간 수정할 수 있습니다!

#index[hx-select][example]
우리는 클릭 시 현재의 기존 테이블에 다음 연락처의 행을 추가할 수 있는 버튼을 원합니다. 이를 위해, 우리는 바로 그런 버튼을 포함한 새로운 행을 테이블에 추가할 수 있습니다:

#figure(caption: [클릭하여 로드로 변경하기],
```html
<tbody>
{% for contact in contacts %}
  <tr>
    <td>{{ contact.first }}</td>
    <td>{{ contact.last }}</td>
    <td>{{ contact.phone }}</td>
    <td>{{ contact.email }}</td>
    <td>
      <a href="/contacts/{{ contact.id }}/edit">Edit</a>
      <a href="/contacts/{{ contact.id }}">View</a></td>
  </tr>
{% endfor %}
{% if contacts|length == 10 %} <1>
  <tr>
    <td colspan="5" style="text-align: center">
      <button hx-target="closest tr" <2>
        hx-swap="outerHTML" <3>
        hx-select="tbody > tr" <4>
        hx-get="/contacts?page={{ page + 1 }}">
        Load More
      </button>
    </td>
  </tr>
{% endif %}
</tbody>
```
1. 현재 페이지에 10개의 연락처 결과가 있는 경우에만 "더 로드하기"를 표시합니다.
2. 가장 가까운 `tr` 요소를 타겟팅합니다.
3. 서버로부터의 응답으로 이 _전체_ 행을 교체합니다.
4. 응답에서 테이블 행만 선택합니다.

이제 여기서 각 속성을 자세히 살펴보겠습니다.

첫째, `hx-target`를 사용하여 "가장 가까운" `tr` 요소를 타겟팅하고, 즉, 가장 가까운 _부모_ 테이블 행을 타겟팅하고 있습니다.

둘째, 우리는 이 _전체_ 행을 서버로부터 반환된 아무 콘텐츠로도 교체하고자 합니다.

셋째, 우리는 응답에서 `tr` 요소만 빼내고자 합니다. 이 `tr` 요소를 새 `tr` 요소 집합으로 교체할 것입니다. 이 새 요소들에는 추가 연락처 정보가 포함되어 있으며, 필요한 경우 새로은 "더 로드하기" 버튼이 다음 페이지로의 포인터를 포함하게 됩니다. 이를 위해 CSS 선택기 `tbody > tr`을 사용하여 응답에서 테이블 본문의 행만을 끌어내는 것이 중요합니다. 예를 들어, 테이블 헤더의 행을 포함하지 않도록 하기 위해서입니다.

마찬가지로, 이 새로운 기능을 위해서는 서버 측의 변경이 필요하지 않습니다. 이는 htmx가 서버 응답 처리 방식에서 제공하는 유연성 때문입니다.

이제 네 개의 속성으로 우리는 htmx를 통해 정교한 "클릭하여 로드" UX를 구현하게 되었습니다.

==== 무한 스크롤 <_infinite_scroll>

#index[htmx patterns][infinite scroll]
많은 대규모 요소 세트를 처리하기 위한 또 다른 일반적인 패턴은 "무한 스크롤" 패턴으로 알려져 있습니다. 이 패턴에서는 리스트나 테이블의 마지막 요소가 보이는 위치로 스크롤되어지면서 더 많은 요소가 로드되고 목록이나 테이블에 추가됩니다.

이러한 동작은 사용자가 카테고리나 소셜 미디어 게시물 연동을 탐색할 때 더 잘 작동하며, 연락처 애플리케이션에서는 그러하지 않습니다. 그러나 완전성을 위해 htmx에서 이 패턴으로 이식하는 방법을 보여드리겠습니다. 

생각해보면 무한 스크롤은 "클릭하여 로드" 논리와 동일합니다. 클릭 이벤트가 발생할 때 로드하는 것 대신, 요소가 브라우저의 보기 포털에 "드러날" 때 로드하려고 합니다.

행운히도, htmx는 `revealed`라는 합성(비표준) DOM 이벤트를 제공합니다. 이 이벤트는 `hx-trigger` 속성과 함께 사용하여 요청을 발생시킬 수 있도록 하며, 즉, 요소가 보일 때 요청을 발생하는 것입니다.

#index[hx-select][example]
따라서 버튼을 span으로 변환하여 이 이벤트를 활용해 보겠습니다:

#figure(caption: [무한 스크롤 변경하기],
```html
{% if contacts|length == 10 %}
  <tr>
    <td colspan="5" style="text-align: center">
      <span hx-target="closest tr"
        hx-trigger="revealed"
        hx-swap="outerHTML"
        hx-select="tbody > tr"
        hx-get="/contacts?page={{ page + 1 }}">Loading More...</span>
    </td>
  </tr>
{% endif %}
```
1. 사용자가 클릭하지 않으므로 요소를 버튼에서 span으로 변경했습니다.
2. 요소가 드러났을 때 즉, 브라우저의 설정에서 들어올 때 요청이 트리거됩니다.

"클릭하여 로드"에서 "무한 스크롤"로 전환하려는 모든 처리가 간단하게 이루어졌습니다: 요소를 span으로 변경한 후, `revealed` 이벤트 트리거를 추가하기만 하면 됩니다.

이렇게 쉽게 무한 스크롤로 전환할 수 있다는 사실은 htmx가 HTML을 얼마나 잘 일반화시키는지를 보여줍니다: 몇 개의 속성만으로 하이퍼미디어에서 얻을 수 있는 것을 극적으로 확장할 수 있게 됩니다.

그리고 여전히 웹의 RESTful 모델을 활용하고 있습니다. 모든 이 새로운 동작에도 불구하고, 우리는 여전히 서버와 하이퍼미디어를 교환하고 있으며, JSON API 응답은 보이지 않습니다.

웹이 설계되었던 방식입니다.

#html-note[모달과 "display: none"에 대한 주의] [
#index[modal window]
#index[display: none]
_모달에 대해 한번 더 생각하세요._ 모달 창은 오늘날 많은 웹 애플리케이션에서 인기를 끌고 있으며 거의 표준이 되었습니다.

안타깝게도, 모달 창은 웹의 구조와 잘 맞지 않으며 하이퍼미디어 기반 접근 방식과 통합하기 어려운 클라이언트 측 상태를 도입합니다.

모달 창은 리소스를 구성하지 않거나 도메인 엔터티에 해당하지 않는 뷰를 위한 경우 안전하게 사용할 수 있습니다:

- 경고

- 확인 대화 상자

- 엔터티를 생성/업데이트하기 위한 양식

그렇지 않다면, 모달 대신 인라인 편집 또는 별도의 페이지와 같은 대안을 고려해 보십시오.

_`display: none;`을 사용할 때는 주의하십시오._ 문제는 순전히 미용상의 문제가 아닙니다. — 이는 접근성 트리와 키보드 포커스를 제거합니다. 이는 가끔 시각적 및 청각적 인터페이스에 동일한 내용을 제공하기 위해 사용됩니다. 요소를 스타일로 인해 시각적으로 숨기되 보조 기술에서 숨기지 않으려면 이 유틸리티 클래스를 사용할 수 있습니다:

#figure(
```css
.vh {
    clip: rect(0 0 0 0);
    clip-path: inset(50%);
    block-size: 1px;
    inline-size: 1px;
    overflow: hidden;
    white-space: nowrap;
}
```

`vh`는 "시각적으로 숨겨진"의 약자입니다. 이 클래스는 브라우저가 요소의 기능을 제거하지 않도록 하기 위해 여러 가지 방법과 우회 방법을 사용합니다.
]
