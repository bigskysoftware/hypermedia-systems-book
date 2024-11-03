#import "lib/definitions.typ": *

== Htmx 마스터의 기술

이번 장에서는 htmx 도구 상자를 좀 더 깊이 살펴보겠습니다. 지금까지 배운 것만으로도 상당한 성과를 이루었습니다. 하지만 하이퍼미디어 기반 애플리케이션을 개발할 때, 추가적인 옵션과 기술이 필요할 때가 있을 것입니다.

htmx의 고급 속성들을 살펴보고, 이미 사용했던 속성의 고급 세부사항도 확장할 것입니다.

또한, htmx가 제공하는 단순 HTML 속성을 넘어선 기능들에 대해서도 살펴보겠습니다: htmx가 표준 HTTP 요청과 응답을 어떻게 확장하는지, htmx가 이벤트와 어떻게 작동하는지, 단일 명확한 업데이트 대상이 없을 때 어떤 방식으로 접근해야 하는지에 대해서도 논의할 것입니다.

마지막으로, htmx 개발 시 실용적인 고려사항에 대해서도 살펴보겠습니다: htmx 기반 애플리케이션을 효과적으로 디버그하는 방법, htmx 작업 시 고려해야 할 보안 사항들, 그리고 htmx의 동작을 구성하는 방법에 대해서도 알아보겠습니다.

이번 장의 기능과 기술을 통해, htmx와 소량의 하이퍼미디어 친화적인 클라이언트 측 스크립팅만으로도 매우 정교한 사용자 인터페이스를 구현할 수 있을 것입니다.

=== Htmx 속성

#index[htmx][attributes]
지금까지 우리는 애플리케이션에서 약 15개의 다양한 htmx 속성을 사용했습니다. 가장 중요한 속성들은 다음과 같았습니다:

/ `hx-get`, `hx-post` 등: #[
    요소가 수행해야 할 AJAX 요청을 지정합니다.
  ]

/ `hx-trigger`: #[
    요청을 트리거하는 이벤트를 지정합니다.
  ]

/ `hx-swap`: #[
    DOM에 반환된 HTML 콘텐츠를 어떻게 교환할지를 지정합니다.
  ]

/ `hx-target`: #[
    반환된 HTML 콘텐츠를 교환할 위치를 DOM에서 지정합니다.
  ]

이 속성들 중 두 개인 `hx-swap`과 `hx-trigger`는 더 발전된 하이퍼미디어 기반 애플리케이션을 만드는 데 유용한 여러 옵션을 지원합니다.

==== #indexed[hx-swap]

우리는 hx-swap 속성으로 시작하겠습니다. 이 속성은 htmx 기반 요청을 발행하는 요소에 자주 포함되지 않는데, 그 이유는 기본 동작인 'innerHTML'이 대부분의 사용 사례를 커버하기 때문입니다.

앞서 우리는 기본 동작을 재정의하고 'outerHTML'을 사용하고 싶었던 상황을 보았습니다. 그리고 2장에서 우리는 'beforebegin', 'afterend' 등 이 두 가지를 넘어선 다른 교환 옵션에 대해서도 논의했습니다.

5장에서는 `hx-swap`의 `swap` 지연 수정자도 살펴보았는데, 이는 DOM에서 콘텐츠가 제거되기 전에 일부 콘텐츠를 서서히 사라지게 해 주었습니다.

이 외에도, `hx-swap`은 다음과 같은 수정자를 제공하여 추가적인 제어를 할 수 있습니다:

/ `settle`: #[
  #index[hx-swap][settle] 'swap'과 마찬가지로, 콘텐츠가 DOM에 교환된 후, 속성이 이전 값(있는 경우)에서 새 값으로 "안정화"되는 데 필요한 지연을 적용할 수 있습니다. 이는 CSS 전환에 대한 세밀한 제어를 가능하게 합니다.
  ]

/ `show`: #[
    #index[hx-swap][show] 요청이 완료될 때 표시해야 하는 요소를 지정합니다 --- 필요 시 브라우저의 뷰포트로 스크롤됩니다.
  ]

/ `scroll`: #[
    #index[hx-swap][scroll] 요청이 완료될 때 맨 위 또는 맨 아래로 스크롤해야 하는 스크롤 가능한 요소(즉, 스크롤바가 있는 요소)를 지정합니다.
  ]

/ `focus-scroll`: #[
    #index[hx-swap][focus-scroll] 요청이 완료될 때 htmx가 포커스된 요소로 스크롤해야 한다고 지정합니다. 이 수정자의 기본값은 "false"입니다.
  ]

예를 들어, `GET` 요청을 발행하는 버튼이 있고 요청이 완료되면 `body` 요소의 맨 위로 스크롤하고 싶다면, 다음과 같은 HTML을 작성할 것입니다:

#figure(caption: [페이지 맨 위로 스크롤하기])[
```html
<button hx-get="/contacts" hx-target="#content-div"
  hx-swap="innerHTML show:body:top"> <1>
  연락처 가져오기
</button>
``` ]
1. 이는 htmx에게 스왑이 발생한 후에 본문의 맨 위를 표시하라고 지시합니다.

더 많은 세부사항과 예제는 `hx-swap` #link("https://htmx.org/attributes/hx-swap/")[문서]에서 확인하실 수 있습니다.

==== hx-trigger

#index[hx-trigger][about]
#index[hx-trigger][element defaults]
`hx-swap`와 마찬가지로, `hx-trigger`도 htmx를 사용할 때 종종 생략될 수 있습니다. 그 이유는 기본 동작이 일반적으로 원하는 것이기 때문입니다. 기본 트리거 이벤트는 요소의 유형에 따라 결정됩니다:
- `input`, `textarea` 및 `select` 요소의 요청은 `change` 이벤트로 트리거됩니다.
- `form` 요소의 요청은 `submit` 이벤트로 트리거됩니다.
- 나머지 모든 요소의 요청은 `click` 이벤트로 트리거됩니다.

그러나 때때로 더 정교한 트리거 사양이 필요한 경우가 있습니다. Contact.app에서 구현했던 능동적 검색 예제가 고전적인 예입니다:

#figure(
  caption: [능동 검색 입력],
)[
```html
<input id="search" type="search" name="q"
  value="{{ request.args.get('q') or '' }}"
  hx-get="/contacts"
  hx-trigger="search, keyup delay:200ms changed"/> <1>
``` ]
1. 정교한 트리거 사양입니다.

이 예제는 `hx-trigger` 속성에 대해 사용할 수 있는 두 가지 수정자를 활용했습니다:

/ `delay`: #[
    #index[hx-trigger][delay] 요청이 발행되기 전에 기다리는 지연을 지정합니다. 이벤트가 다시 발생하면 첫 번째 이벤트는 무시되고 타이머가 재설정됩니다. 이를 통해 요청을 "디바운스"할 수 있습니다.
  ]

/ `changed`: #[
  #index[hx-trigger][changed] 주어진 요소의 `value` 속성이 변경될 때만 요청이 발행되도록 지정할 수 있습니다.
  ]

`hx-trigger`에는 몇 가지 추가 수정자가 있습니다. 이는 이벤트가 상당히 복잡하고 우리가 제공하는 모든 기능을 활용하고 싶기 때문에 합리적입니다. 아래에서 이벤트에 대해 더 자세히 논의할 것입니다.

다음은 `hx-trigger`에서 사용할 수 있는 다른 수정자입니다:

/ `once`: #[
    #index[hx-trigger][once] 주어진 이벤트는 요청을 한 번만 트리거합니다.
  ]

/ `throttle`: #[
  #index[hx-trigger][throttle] 이벤트를 조절하여 특정 간격마다만 요청을 발행할 수 있습니다. 이는 `delay`와는 다릅니다; 첫 번째 이벤트는 즉시 트리거되지만, 이후의 이벤트는 조절 시간 기간이 지난 후에야 트리거됩니다.
  ]

/ `from`: #[
    #index[hx-trigger][from] 다른 요소에서 이벤트를 수신하도록 선택하는 CSS 선택자입니다. 더 나중에 이 사용 예제를 볼 것입니다.
  ]

/ `target`: #[
  #index[hx-trigger][target] 주어진 요소에서 발생하는 이벤트만 필터링할 수 있는 CSS 선택자입니다. DOM에서 이벤트는 조상 요소로 "버블링"하므로, 버튼에서 발생한 `click` 이벤트는 포함된 `div` 및 `body` 요소의 `click` 이벤트도 트리거합니다. 때때로 주어진 요소에서 직접 이벤트를 지정하고 싶고, 이 속성을 통해 그렇게 할 수 있습니다.
  ]

/ `consume`: #[
  #index[hx-trigger][consume] 이 옵션이 `true`로 설정되면, 트리거 이벤트가 취소되고 조상 요소로 전파되지 않습니다.
  ]

/ `queue`: #[
  #index[hx-trigger][queue] 이 옵션을 통해 htmx에서 이벤트가 대기되는 방식을 지정할 수 있습니다. 기본적으로 htmx가 트리거 이벤트를 수신하면 요청을 발행하고 이벤트 큐를 시작합니다. 요청이 진행 중일 때 다른 이벤트가 수신되면, 해당 이벤트가 대기열에 추가되고 요청이 완료되면 새로운 요청이 트리거됩니다. 기본값은 수신된 마지막 이벤트만 유지하지만, 이 옵션을 사용하여 해당 동작을 수정할 수 있습니다: 예를 들어 `none`으로 설정하여 요청 중 발생하는 모든 트리거 이벤트를 무시할 수 있습니다.
  ]

===== 트리거 필터

#index[hx-trigger][event filters]
`hx-trigger` 속성을 사용하여 이벤트의 _필터_를 지정할 수 있습니다. 이를 위해 이벤트 이름 뒤에 대괄호 사이에 JavaScript 표현식을 사용할 수 있습니다.

복잡한 상황에서 연락처를 특정 상황에서만 검색 가능해야 한다고 가정해 봅시다. `contactRetrievalEnabled()`라는 JavaScript 함수가 있으며 이 함수는 연락처를 검색할 수 있으면 `true`, 그렇지 않으면 `false`를 반환합니다. 이 함수를 어떻게 사용하여 `/contacts`에 요청을 발행하는 버튼에 게이트를 추가할 수 있을까요?

이벤트 필터를 사용하여 htmx로 이 작업을 수행하려면 다음과 같은 HTML을 작성합니다:

#figure(caption: [능동 검색 입력])[
```html
<script>
  function contactRetrievalEnabled() {
    // 연락처 검색 가능 여부를 테스트하는 코드
    ...
  }
</script>
<button hx-get="/contacts"
  hx-trigger="click[contactRetrievalEnabled()]"> <1>
  연락처 가져오기
</button>
``` ]
1. `contactRetrievalEnabled()`가 `true`를 반환할 때만 클릭 시 요청이 발생합니다.

버튼은 `contactRetrievalEnabled()`가 false를 반환할 경우 요청을 발행하지 않으므로, 요청이 언제 이루어질지 동적으로 제어할 수 있습니다. 요청 트리거를 만날 수 있는 일반적인 상황은 다음과 같습니다:
- 특정 요소가 포커스를 가지고 있을 때
- 주어진 폼이 유효할 때
- 특정 값이 있는 입력 세트가 있을 때

이벤트 필터를 사용하면 요청을 htmx로 필터링하는 데 필요한 모든 로직을 사용할 수 있습니다.

===== 합성 이벤트

#index[hx-trigger][synthetic events]
이러한 수정자 외에도, `hx-trigger`는 일반 DOM API의 일부가 아닌 몇 가지 "합성" 이벤트도 제공합니다. 우리는 이미 지연 로딩 및 무한 스크롤 예제에서 `load`와 `revealed`를 보았지만, htmx는 뷰포트와 교차하는 요소에서 트리거되는 `intersect` 이벤트도 제공합니다.

#index[hx-trigger][intersect]
이 합성 이벤트는 현대의 Intersection Observer API를 사용합니다. 이에 대한 자세한 내용은
#link(
  "https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API",
)[MDN]에서 확인할 수 있습니다.

교차점은 요청이 트리거될 정확한 시점을 세밀하게 제어할 수 있게 해줍니다. 예를 들어, 임계값을 설정하여 요소가 50% 보일 때만 요청을 발행하도록 지정할 수 있습니다.

`hx-trigger` 속성은 확실히 htmx에서 가장 복잡한 속성입니다. 추가 세부사항과 예제는 #link("https://htmx.org/attributes/hx-trigger/")[문서]에서 확인할 수 있습니다.

==== 기타 속성 <_other_attributes>
Htmx는 하이퍼미디어 기반 애플리케이션의 동작을 미세 조정하기 위해 덜 일반적으로 사용되는 많은 다른 속성을 제공합니다.

가장 유용한 속성들 중 일부는 다음과 같습니다:

```Markdown
/hx-push-url: #[ 
    #index[hx-push-url] 요청 URL(또는 다른 값을) 네비게이션 바에 "푸시"합니다.
  ]
/hx-preserve: #[ 
    #index[hx-preserve] 요청 간에 DOM의 일부를 보존합니다; 원본 콘텐츠는 반환된 것과 관계없이 유지됩니다.
  ]
/hx-sync: #[ 
    #index[hx-sync] 두 개 이상의 요소 간의 요청을 동기화합니다.
  ]
/hx-disable: #[ 
    #index[hx-disable] 이 요소 및 모든 자식에 대해 htmx 동작을 비활성화합니다. 이는 보안 주제를 다룰 때 다시 살펴보겠습니다.
  ]
```

이제 `hx-sync`를 살펴보겠습니다. 이것은 두 개 이상의 요소 간의 AJAX 요청을 동기화할 수 있도록 합니다. 화면의 동일한 요소를 대상으로 하는 두 개의 버튼이 있다고 가정해 보겠습니다:

#figure(caption: [충돌하는 두 버튼])[
```html
<button hx-get="/contacts" hx-target="body">
  연락처 가져오기
</button>
<button hx-get="/settings" hx-target="body">
  설정 가져오기
</button>
``` ]

이것은 괜찮고 작동하지만, 사용자가 "연락처 가져오기" 버튼을 클릭하고 요청이 응답하기까지 시간이 걸린다면 어떻게 될까요? 그리고 그 사이에 사용자가 "설정 가져오기" 버튼을 클릭하면 어떨까요? 이 경우 두 개의 요청이 동시에 진행될 것입니다.

만약 `/settings` 요청이 먼저 끝나고 사용자 설정 정보를 표시하면 사용자가 변경을 시작했을 때 갑자기 `/contacts` 요청이 끝나고 모든 본문이 연락처로 대체된다면 그들은 매우 놀랄 것입니다!

이러한 상황을 처리하기 위해, 우리는 사용자에게 무언가가 진행 중임을 알리기 위해 `hx-indicator`를 사용하고 두 번째 버튼을 클릭할 가능성을 줄일 수 있습니다. 하지만 이러한 두 버튼 간에 한 번에 하나의 요청만이 발행되도록 보장하고 싶다면, 올바른 방법은 `hx-sync` 속성을 사용하는 것입니다. 두 버튼을 `div`로 묶고 중복된 `hx-target` 지정을 제거하여 해당 `div`로 속성을 끌어올릴 수 있습니다. 그러면 그 `div`에 `hx-sync`를 사용하여 두 버튼 간의 요청을 조정할 수 있습니다.

여기 업데이트된 코드가 있습니다:

#index[hx-sync][example]
#figure(caption: [두 개의 버튼 동기화])[
```html
<div hx-target="body" <1>
  hx-sync="this"> <2>
  <button hx-get="/contacts">
    연락처 가져오기
  </button>
  <button hx-get="/settings">
    설정 가져오기
  </button>
</div>
``` ]
1. 중복된 `hx-target` 속성을 상위 `div`로 끌어올립니다.
2. 상위 `div`에서 동기화합니다.

`hx-sync` 속성을 `this` 값을 가진 `div`에 배치하면, "이 div 요소 내에서 발생하는 모든 htmx 요청을 서로 동기화합니다."라는 의미입니다. 이는 한 버튼이 이미 요청을 진행 중일 경우, 해당 `div` 내의 다른 버튼이 요청을 발행하지 않도록 합니다.

`hx-sync` 속성은 진행 중인 기존 요청을 대체하거나 특정 쿼리 전략으로 요청을 대기열하는 등의 다양한 전략을 지원합니다. 전체 문서와 예제는 htmx.org의 #link("https://htmx.org/attributes/hx-sync/")[`hx-sync`] 페이지에서 확인할 수 있습니다.

보시다시피, htmx는 더 발전된 하이퍼미디어 기반 애플리케이션을 위한 속성 기반 기능을 많이 제공합니다. 모든 htmx 속성에 대한 완전한 참조는 #link("https://htmx.org/reference/#attributes")[htmx 웹사이트에서 찾을 수 있습니다].

=== 이벤트

#index[events]
지금까지 우리는 주로 `hx-trigger` 속성을 통해 htmx에서 JavaScript 이벤트를 다루어 왔습니다. 이 속성은 선언적이고 HTML 친화적인 문법을 사용하여 애플리케이션을 구동하는 강력한 메커니즘으로 입증되었습니다.

하지만 우리는 이벤트로 할 수 있는 것이 훨씬 더 많습니다. 이벤트는 HTML을 하이퍼미디어로 확장하는 데 중요한 역할을 하며, 하이퍼미디어 친화적인 스크립팅에서도 마찬가지입니다. 이벤트는 DOM, HTML, htmx 및 스크립팅을 결합하는 "접착제"와 같은 역할을 합니다. DOM을 응용 프로그램을 위한 정교한 "이벤트 버스"라고 생각할 수 있습니다.

고Advanced Hypermedia-Driven Applications를 구축하려면, 이벤트에 대해 깊이 공부할 가치를 높이 평가합니다. #link("https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Building_blocks/Events")[자세히 알아보세요].

==== htmx 생성 이벤트

#index[htmx events]
htmx는 이벤트에 _응답_하기 쉽게 만드는 것 외에도, 유용한 많은 이벤트를 _발행_합니다. 이 이벤트들은 htmx 자체를 통해, 또는 스크립팅을 통해 애플리케이션에 더 많은 기능을 추가하는 데 사용할 수 있습니다.

htmx가 트리거하는 가장 일반적으로 사용되는 이벤트는 다음과 같습니다:

```Markdown
/ `htmx:load`: #[ 
    #index[htmx events][htmx:load] htmx에 의해 DOM에 새로운 콘텐츠가 로드될 때 트리거됩니다.
  ]
/ `htmx:configRequest`: #[ 
    #index[htmx events][htmx:configRequest] 요청이 실행되기 전에 트리거되어 프로그램적으로 요청을 구성하거나 완전히 취소할 수 있습니다.
  ]
/ `htmx:afterRequest`: #[ 
    #index[htmx events][htmx:afterRequest] 요청이 응답받은 후 트리거됩니다.
  ]
/ `htmx:abort`: #[ 
    #index[htmx events][htmx:abort] 열린 요청을 중단하기 위해 htmx 기반 요소에 보낼 수 있는 사용자 지정 이벤트입니다.
  ]
```

==== htmx:configRequest 이벤트 사용하기

htmx가 생성한 이벤트와 함께 작업하는 방법의 예를 살펴보겠습니다. HTTP 요청을 구성하기 위해 `htmx:configRequest` 이벤트를 사용할 것입니다.

#index[localStorage]
다음과 같은 시나리오를 고려해 보세요: 서버 측 팀은 각 요청에 대해 추가 보안을 위해 서버 생성 토큰을 포함하길 원합니다. 이 토큰은 브라우저의 `localStorage`에 `special-token` 슬롯에 저장될 것입니다.

사용자가 처음 로그인할 때 JavaScript에 의해 이 토큰이 설정됩니다(구체적인 내용은 걱정하지 마세요):

#figure(caption: [JavaScript에서 토큰 가져오기])[
```js
let response = await fetch("/token"); <1>
localStorage['special-token'] = await response.text();
``` ]
1. 토큰의 값을 가져와 `localStorage`에 설정합니다.

서버 측 팀은 htmx가 발행하는 모든 요청에 대해 이 특별 토큰을 `X-SPECIAL-TOKEN` 헤더로 포함하길 원합니다. 이를 어떻게 달성할 수 있을까요? 한 가지 방법은 `htmx:configRequest` 이벤트를 포착하고 `localStorage`에서 이 토큰으로 `detail.headers` 객체를 업데이트하는 것입니다.

VanillaJS로는 다음과 같이 보일 것입니다. `<head>`의 `<script>` 태그에 배치합니다:

#figure(caption: [X-SPECIAL-TOKEN 헤더 추가하기])[
```js
document.body.addEventListener("htmx:configRequest", configEvent => {
  configEvent.detail.headers['X-SPECIAL-TOKEN'] = <1>
    localStorage['special-token'];
})
``` ]
1. 로컬 저장소에서 값을 검색하여 헤더에 설정합니다.

보시다시피, 우리는 이벤트의 세부 속성의 `headers` 속성에 새 값을 추가합니다. 이벤트 핸들러가 실행된 후, 이 `headers` 속성은 htmx에 의해 읽히고, htmx가 수행하는 AJAX 요청의 요청 헤더를 구성하는 데 사용됩니다.

`htmx:configRequest` 이벤트의 `detail` 속성에는 "요청 모양"을 변경하기 위해 업데이트할 수 있는 유용한 속성이 많습니다. 이를 통해 요청 매개변수를 추가하거나 제거할 수 있습니다,

```Markdown
/ `detail.parameters`: #[ 
    #index[htmx:configRequest][detail.parameters] 요청 매개변수를 추가하거나 제거할 수 있습니다.
  ]
/ `detail.target`: #[ 
    #index[htmx:configRequest][detail.target] 요청의 대상을 업데이트할 수 있습니다.
  ]
/ `detail.verb`: #[ 
  #index[htmx:configRequest][detail.verb] 요청의 HTTP "동사"(예: `GET`)를 업데이트할 수 있습니다.
  ]
```

예를 들어, 서버 측 팀이 토큰을 요청 헤더 대신 매개변수로 포함하길 원한다면, 다음과 같이 코드를 수정할 수 있습니다:

#figure(caption: [token 매개변수 추가하기])[
```js
document.body.addEventListener("htmx:configRequest", configEvent => {
    configEvent.detail.parameters['token'] = <1>
      localStorage['special-token'];
})
``` ]
1. 로컬 저장소에서 값을 검색하여 매개변수에 설정합니다.

이렇게 하면 htmx가 만드는 AJAX 요청을 업데이트하는 데 많은 유연성을 얻을 수 있습니다.

`htmx:configRequest` 이벤트(및 관심 있는 다른 이벤트)의 전체 문서는 #link("https://htmx.org/events/#htmx:configRequest")[htmx 웹사이트]에서 확인할 수 있습니다.

==== htmx:abort를 사용하여 요청 취소하기

#index[htmx:abort] #index[canceling a request]
우리는 htmx의 다양한 유용한 이벤트를 수신할 수 있고, `hx-trigger`를 사용하여 이러한 이벤트에 응답할 수 있습니다. 그런데 이벤트와 관련해서 우리는 무엇을 더 할 수 있을까요?

htmx는 특별한 이벤트인 `htmx:abort`를 수신합니다. htmx는 요청이 진행 중인 요소에서 이 이벤트를 수신할 때 요청을 취소합니다.

예를 들어, `/contacts`에 대해 잠재적으로 오랜 요청이 있을 때 사용자가 그 요청을 취소할 수 있는 방법을 제공하고 싶다면 어떻게 진행할까요? 원하는 것은 htmx에 의해 실행 되는 요청을 하는 버튼과, 그 버튼에게 `htmx:abort` 이벤트를 전송하는 두 번째 버튼입니다.

코드 예시는 다음과 같을 것입니다:

#figure(caption: [취소 버튼이 있는 버튼])[
```html
<button id="contacts-btn" hx-get="/contacts" hx-target="body"> <1>
  연락처 가져오기
</button>
<button
  onclick="
    document.getElementById('contacts-btn')
      .dispatchEvent(new Event('htmx:abort')) <2>
  ">
  취소
</button>
``` ]
1. `/contacts`에 대한 정상적인 htmx 기반 `GET` 요청입니다.
2. 버튼을 찾아서 `htmx:abort` 이벤트를 보낼 JavaScript입니다.

이제 사용자가 "연락처 가져오기" 버튼을 클릭하고 요청이 시간이 걸릴 때 "취소" 버튼을 클릭하여 요청을 종료할 수 있습니다. 물론 더 정교한 사용자 인터페이스에서는 HTTP 요청이 진행 중이지 않을 경우 "취소" 버튼을 비활성화해야 할 수도 있지만, 이를 순수 JavaScript로 구현하는 것은 번거로울 것입니다.

다행히도, 하이퍼스크립트를 사용하면 그리 복잡하지 않게 구현할 수 있습니다. 따라서 그것이 어떻게 보일지 살펴보겠습니다:

#figure(caption: [하이퍼스크립트로 구현된 취소 버튼])[
```html
<button id="contacts-btn" hx-get="/contacts" hx-target="body">
  연락처 가져오기
</button>
<button
  _="on click send htmx:abort to #contacts-btn
    on htmx:beforeRequest from #contacts-btn remove @disabled from me
    on htmx:afterRequest from #contacts-btn add @disabled to me">
  취소
</button>
``` ]

이제 "취소" 버튼은 `contacts-btn` 버튼의 요청이 진행 중일 때만 활성화됩니다. 하이퍼미디어 생성 및 처리 이벤트와 하이퍼스크립트의 이벤트 친화적인 문법을 활용하여 이를 실현하고 있습니다. 굉장하네요!

==== 서버 생성 이벤트 <_server_generated_events>
우리는 다음 섹션에서 htmx가 일반 HTTP 요청과 응답을 향상시키는 다양한 방법에 대해 더 논의할 것입니다. 그러나 이벤트와 관련이 있으므로, htmx가 지원하는 한 가지 HTTP 응답 헤더인 `HX-Trigger`에 대해 논의할 것입니다. 우리는 이전에 HTTP 요청과 응답이 _헤더_를 지원하는 방법에 대해 논의했으며, 이는 특정 요청이나 응답에 대한 메타데이터를 포함하는 이름-값 쌍입니다. 우리는 주어진 요청을 트리거한 요소의 ID를 포함하는 `HX-Trigger` 요청 헤더의 이점을 누릴 수 있습니다.

#index[response header][HX-Trigger]
이 _요청 헤더_ 외에도 htmx는 `HX-Trigger`라는 _응답 헤더_도 지원합니다. 이 응답 헤더를 통해 AJAX 요청을 제출한 요소에서 _이벤트를 트리거_할 수 있습니다. 이는 DOM에서 요소를 느슨한 방식으로 조정하는 강력한 방법이 될 수 있습니다.

이것이 어떻게 작동할 수 있는지 보기 위해, 다음과 같은 상황을 고려해 보겠습니다. 우리는 서버의 원격 시스템에서 새로운 연락처를 가져오는 버튼이 있습니다. 서버 측 구현의 세부 사항은 무시하겠습니다. 하지만 `/sync` 경로에 `POST`를 발행하면 시스템과의 동기화가 트리거됩니다.

이 동기화는 새 연락처가 생성될 수도 있고 생성되지 않을 수도 있습니다. 새 연락처가 생성된 경우, 우리는 연락처 테이블을 새롭게 고쳐야 합니다. 반면, 연락처가 생성되지 않은 경우 테이블을 새롭게 고치지 않아야 합니다.

이를 구현하기 위해, `HX-Trigger` 응답 헤더에 값을 `contacts-updated` 조건부로 추가할 수 있습니다:

#figure(caption: [contacts-updated 이벤트를 조건부로 트리거하기])[
```py
@app.route('/sync', methods=["POST"])
def sync_with_server():
    contacts_updated = RemoteServer.sync() <1>
    resp = make_response(render_template('sync.html'))
    if contacts_updated <2>
      resp.headers['HX-Trigger'] = 'contacts-updated'
    return resp
``` ]
1. 원격 시스템에 연락처 데이터베이스와 동기화된 호출.
2. 연락처가 업데이트된 경우 `contacts-updated` 이벤트를 조건부로 클라이언트에서 트리거합니다.

이 값은 `/sync`에 AJAX 요청을 발행한 버튼에서 `contacts-updated` 이벤트를 트리거할 것입니다. 그 다음, `hx-trigger` 속성의 `from:` 수정자를 사용하여 해당 이벤트를 청취할 수 있습니다. 이 패턴을 사용하여 실제로 서버 측에서 htmx 요청을 트리거할 수 있습니다.

다음은 클라이언트 측 코드 예시입니다:

#figure(
  caption: [연락처 테이블],
)[
```html
<button hx-post="/integrations/1"> <1>
  통합에서 연락처 가져오기
</button>

  ...

<table hx-get="/contacts/table"
  hx-trigger="contacts-updated from:body"> <2>
  ...
</table>
``` ]
1. 이 요청의 응답은 조건부로 `contacts-updated` 이벤트를 트리거할 수 있습니다.
2. 이 테이블은 이벤트를 청취하고 발생 시 새로 고쳐집니다.

테이블은 `contacts-updated` 이벤트를 청취하며, 이에 대해 `body` 요소에서 청취합니다. 이벤트가 버튼에서 버블링 될 것이기 때문에 `body` 요소에서 청취하는 것이 적합합니다. 이렇게 하면 버튼과 테이블을 서로 연결시키지 않고 원하는데로 버튼과 테이블을 이동할 수 있습니다. 또한, 다른 요소나 요청도 `contacts-updated` 이벤트를 트리거할 수 있으므로, 이는 우리의 애플리케이션에서 연락처 테이블을 새로 고치는 일반 메커니즘을 제공합니다.

=== HTTP 요청 및 응답 <_http_requests_responses>
우리는 방금 htmx가 지원하는 고급 HTTP 응답 기능인 `HX-Trigger` 응답 헤더에 대해 살펴보았지만, htmx는 요청과 응답 모두에 대해 꽤多한 응답 헤더를 지원합니다. 4장에서는 HTTP 요청의 헤더에 대해 논의했습니다. htmx의 동작을 HTTP 응답과 함께 변경할 수 있는 몇 가지 중요한 헤더는 다음과 같습니다:

/ `HX-Location`: #[
    #index[response header][HX-Location] 클라이언트 측에서 새 위치로 리디렉션합니다.
  ]

/ `HX-Push-Url`: #[
    #index[response header][HX-Push-Url] 새 URL을 위치 표시줄에 푸시합니다.
  ]

/ `HX-Refresh`: #[
    #index[response header][HX-Refresh] 현재 페이지를 새로 고칩니다.
  ]

/ `HX-Retarget`: #[
    #index[response header][HX-Retarget] 응답 콘텐츠를 클라이언트 측의 새로운 대상으로 교환하도록 지정합니다.
  ]

모든 요청 및 응답 헤더에 대한 참조는 #link("https://htmx.org/reference/#headers")[htmx 문서]에서 확인하실 수 있습니다.

==== HTTP 응답 코드

#index[HTTP response codes]
응답 헤더보다 클라이언트에 전달되는 정보 면에서 더 중요한 것은 _HTTP 응답 코드_입니다. 우리는 3장에서 HTTP 응답 코드에 대해 논의했습니다. 대체로, htmx는 다양한 응답 코드를 예상한 대로 처리합니다. 200 수준의 응답 코드에 대해 콘텐츠를 교환하고, 다른 응답 코드에 대해서는 아무 것도 하지 않습니다. 그러나 두 개의 "특별한" 200 수준의 응답 코드가 있습니다:
- `204 No Content` - htmx가 이 응답 코드를 수신하게 되면, DOM에 어떤 콘텐츠도 _교환하지_ 않습니다(응답에 본문이 있어도).
- `286` - htmx가 폴링 요청에 이 응답 코드를 수신하게 되면, 폴링을 중단합니다.

응답 코드와 관련하여 htmx의 동작을 재정의할 수 있습니다. 예상하신 대로, 이벤트에 응답함으로써 할 수 있습니다! `htmx:beforeSwap` 이벤트는 htmx의 동작을 다양한 상태 코드와 관련하여 변경할 수 있도록 해줍니다.

예를 들어, `404`가 발생했을 때 아무것도 하지 않는 것이 아니라, 사용자에게 오류가 발생했음을 경고하고 싶다고 합시다. 이를 위해 JavaScript 메서드인 `showNotFoundError()`를 호출하고 싶습니다. 이 작업을 수행하기 위해, `htmx:beforeSwap` 이벤트를 사용하여 이를 실현합시다:

#figure(caption: [404 대화 상자 표시하기])[
```js
document.body.addEventListener('htmx:beforeSwap', evt => { <1>
  if (evt.detail.xhr.status === 404) { <2>
    showNotFoundError();
  }
});
``` ]
1. `htmx:beforeSwap` 이벤트에 후킹합니다.
2. 응답 코드가 `404`인 경우 사용자에게 대화 상자를 표시합니다.

또한 `htmx:beforeSwap` 이벤트를 사용하여 응답이 DOM에 교환될지 및 응답이 교환될 요소를 설정할 수 있습니다. 이를 통해 응답 코드의 사용 방법을 선택하는 데 큰 유연성을 부여합니다. `htmx:beforeSwap` 이벤트에 대한 완전한 문서는 #link("https://htmx.org/events/#htmx:beforeSwap")[htmx.org]에서 확인하실 수 있습니다.

=== 다른 콘텐츠 업데이트하기 <_updating_other_content>
우리는 위에서 서버 트리거 이벤트를 사용하여 한 DOM의 조각을 다른 DOM의 응답에 따라 업데이트하는 방법을 보았습니다. 이 기술은 하이퍼미디어 기반 애플리케이션에서 발생하는 일반적인 문제를 해결합니다: "어떻게 다른 콘텐츠를 업데이트할까요?" 결국, 일반적인 HTTP 요청에서는 단일 "대상"이 있습니다. 전체 화면과 마찬가지로, htmx 기반 요청에서도 요소의 명시적 또는 암시적 대상이 하나뿐입니다.

htmx에서 다른 콘텐츠를 업데이트하려면 몇 가지 옵션이 있습니다:

==== 선택 확대하기 <_expanding_your_selection>
첫 번째 옵션은 가장 간단한 "대상 확대"입니다. 즉, 화면의 작은 부분을 단순히 교체하는 대신, htmx 기반 요청의 대상을 모든 요소를 감싸고 있는 충분히 큰 영역으로 확장합니다. 이는 간단하고 신뢰할 수 있다는 장점이 있습니다. 단점은 사용자가 원하는 사용자 경험을 제공하지 못할 수 있으며, 특정 서버 측 템플릿 레이아웃과 잘 맞지 않을 수 있습니다. 그럼에도 불구하고, 우리는 이 접근 방식을 항상 먼저 고려해 보기를 권장합니다.

==== 밴드 스왑

#index[hx-swap-oob]
#index[htmx][out of band swaps]
두 번째 옵션은 약간 더 복잡한 'Out Of Band' 콘텐츠 지원을 활용하는 것입니다. htmx가 응답을 수신하면, `hx-swap-oob` 속성을 포함한 최상위 콘텐츠가 있는지 검사합니다. 해당 콘텐츠는 응답에서 제거되며, 정상적으로 DOM에 교환되지 않습니다. 대신, 해당 콘텐츠는 ID에 따라 적합한 콘텐츠로 교환될 것입니다.

예를 들어, 앞서 살펴본 연락처 테이블이 통합에서 새로운 연락처를 가져온 경우 업데이트해야 합니다. 이전에는 이벤트와 `HX-Trigger` 응답 헤더를 사용하여 이를 해결했습니다.

이번에는 `/integrations/1`에 대한 `POST` 응답에서 `hx-swap-oob` 속성을 사용하겠습니다. 새로운 연락처 테이블 콘텐츠는 응답으로 "탄탄하게" 추가됩니다.

#figure(caption: [업데이트된 연락처 테이블])[
```html
<button hx-post="/integrations/1"> <1>
  통합에서 연락처 가져오기
</button>

  ...

<table id="contacts-table"> <2>
  ...
</table>
``` ]
1. 버튼은 여전히 `/integrations/1`에 `POST`를 발행합니다.
2. 이제 테이블은 이벤트를 청취하지 않지만 ID를 갖추고 있습니다.

다음으로, `/integrations/1`에 대한 `POST` 응답은 버튼과 관련된 내용을 포함할 것 외에도 `hx-swap-oob="true"`로 표시된 업데이트된 연락처 테이블의 새 내용을 포함할 것입니다. 이 콘텐츠는 버튼에 삽입되지 않도록 응답에서 제외됩니다. 반면, 기존 테이블에 대해서는 ID에 따라 그 자리에서 DOM에 교환될 것입니다.

#figure(caption: [Out-of-band 콘텐츠가 있는 응답])[
```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
...

통합에서 연락처 가져오기 <1>

<table id="contacts-table" hx-swap-oob="true"> <2>
  ...
</table>
``` ]
1. 이 콘텐츠는 버튼에 배치됩니다.
2. 이 콘텐츠는 응답에서 제거되고 ID에 의해 교환됩니다.

이러한 "탄탄한" 기술을 사용하면 페이지의 어느 곳에서나 콘텐츠를 업데이트할 수 있습니다. `hx-swap-oob` 속성은 다양한 추가 기능을 지원하고 있으며, 이 모든 것은 #link("https://htmx.org/attributes/hx-swap-oob/")[문서화]되어 있습니다.

서버 측 템플릿 기술이 어떻게 작동하는지에 따라, 응용 프로그램이 요구하는 상호작용 수준에 따라, 대역 외 교환은 콘텐츠 업데이트를 위한 강력한 메커니즘이 될 수 있습니다.

==== 이벤트

#index[htmx patterns][server-triggered events]
마지막으로, 콘텐츠를 업데이트하는 가장 복잡한 메커니즘은 이전 섹션에서 보았던: 서버 트리거 이벤트를 사용하는 것입니다. 이 접근방식은 매우 깔끔할 수 있지만, HTML과 이벤트에 대한 깊은 개념적 지식과 이벤트 기반 접근 방식에 대한 헌신이 필요합니다. 우리는 이 스타일의 개발을 좋아하지만, 모든 사람에게 적합한 것은 아닙니다. 일반적으로 htmx의 이벤트 기반 하이퍼미디어 철학이 당신에게 진정으로 말하는 경우에만 이 패턴을 권장합니다.

하지만 만약 그것이 여러분에게 말을 걸면, 우리는 그걸 시도해 보라고 말합니다. 우리는 이 접근 방식을 사용하여 매우 복잡하고 유연한 사용자 인터페이스를 만들었으며, 이를 매우 좋아합니다.

==== 현실적으로 접근하기

#index[hypermedia][limitations]
"다른 콘텐츠 업데이트" 문제에 대한 이러한 모든 접근 방식은 잘 작동하고 종종 잘 작동합니다. 하지만 때때로 UI에 대해 다른 접근 방식, 예를 들어 반응형 접근 방식을 사용하는 것이 더 간단할 때가 있습니다. 하이퍼미디어 접근 방식을 좋아하더라도, 현실적으로는 간단하게 구현할 수 없는 UX 패턴들이 존재합니다. 가능한 예로는 실시간 온라인 스프레드시트 같은 것들이 있습니다. 이러한 것은 복잡한 사용자 인터페이스이므로, 하이퍼미디어와의 서버 간 교환을 통해 잘 구현할 수 없습니다.

이와 같은 경우에나, htmx 기반 솔루션이 다른 접근 방식보다 복잡하다고 판단될 경우, 다른 기술을 고려할 것을 권장합니다. 현실적으로 접근하고, 일에 맞는 도구를 사용하십시오. 복잡성과 전반적인 복잡함이 필요하지 않은 애플리케이션의 부분에 htmx를 사용할 수 있으며 복잡성을 필요로 하는 부분에 위해는 다른 프레임워크를 아끼고 사용할 수 있습니다.

다양한 웹 기술을 배우며 각 기술의 강점과 약점을 알아가는 것을 권장합니다. 이를 통해 문제가 발생했을 때 방문할 수 있는 깊은 도구 상자를 갖게 됩니다. 우리의 경험에 따르면, htmx는 자주 사용할 수 있는 도구입니다.

=== 디버깅

#index[events][debugging]
#index[htmx][debugging]
우리는 이벤트에 대한 큰 팬임을 부끄러워하지 않습니다. 이벤트는 거의 모든 흥미로운 사용자 인터페이스의 기초 기술이며, 이미 일반 사용을 위해 해제된 HTML에서는 DOM에서 특히 유용합니다. 이는 잘 분리된 소프트웨어를 구축할 수 있게 해주며, 우리가 좋아하는 행동의 지역성을 종종 보존합니다.

그러나 이벤트는 완벽하지 않습니다. 특히 이벤트를 _디버그_하는 데 있어, 이벤트가 _발생하지 않는_ 이유를 알고 싶어 하는 경우 있습니다. 하지만 발생하지 않는 것에 대해 디버그 포인트를 설정할 수 있는 위치가 어디일까요? 현재 답은: 할 수 없습니다.

이와 관련해 도움이 될 수 있는 두 가지 기술이 있습니다. 하나는 htmx에서 제공하고, 다른 하나는 Google의 브라우저인 Chrome에서 제공하는 것입니다.

==== htmx 이벤트 로깅하기 <_logging_htmx_events>
htmx 자체에서 제공하는 첫 번째 기술은 `htmx.logAll()` 메서드를 호출하는 것입니다. 이를 수행하면 htmx는 콘텐츠를 로드하고 이벤트에 응답하는 동안 발생하는 모든 내부 이벤트를 기록합니다.

이는 압도적일 수 있지만, 적절히 필터링하여 문제를 정확히 파악할 수 있습니다. 다음은 #link("https://htmx.org")에서 "docs" 링크를 클릭할 때의 로그 예시입니다. `logAll()`이 활성화된 상태에서 생성되었습니다:

#figure(
  caption: [Htmx 로그],
)[
```text
htmx:configRequest
<a href="/docs/">
Object { parameters: {}, unfilteredParameters: {}, headers: {…}, target: body, verb: "get", errors: [], withCredentials: false, timeout: 0, path: "/docs/", triggeringEvent: a
, … }
htmx.js:439:29
htmx:beforeRequest
<a href="/docs/">
Object { xhr: XMLHttpRequest, target: body, requestConfig: {…}, etc: {}, pathInfo: {…}, elt: a
 }
htmx.js:439:29
htmx:beforeSend
<a class="htmx-request" href="/docs/">
Object { xhr: XMLHttpRequest, target: body, requestConfig: {…}, etc: {}, pathInfo: {…}, elt: a.htmx-request
 }
htmx.js:439:29
htmx:xhr:loadstart
<a class="htmx-request" href="/docs/">
Object { lengthComputable: false, loaded: 0, total: 0, elt: a.htmx-request
 }
htmx.js:439:29
htmx:xhr:progress
<a class="htmx-request" href="/docs/">
Object { lengthComputable: true, loaded: 4096, total: 19915, elt: a.htmx-request
 }
htmx.js:439:29
htmx:xhr:progress
<a class="htmx-request" href="/docs/">
Object { lengthComputable: true, loaded: 19915, total: 19915, elt: a.htmx-request
 }
htmx.js:439:29
htmx:beforeOnLoad
<a class="htmx-request" href="/docs/">
Object { xhr: XMLHttpRequest, target: body, requestConfig: {…}, etc: {}, pathInfo: {…}, elt: a.htmx-request
 }
htmx.js:439:29
htmx:beforeSwap
<body hx-ext="class-tools, preload">
``` ]

그렇게 보기는 쉽지 않은 것도 아닌가요?

하지만, 심호흡을 하고 눈을 가득 찼을 때, 그렇게 나쁘지 않다는 것을 알 수 있습니다. htmx 이벤트 몇 개가 있고, 그중 일부는 전에 본 것들이며(`htmx:configRequest`가 있습니다!) 콘솔에 기록됩니다. 적절한 독서 및 필터링 후 이벤트 스트림을 이해하고, htmx와 관련된 문제를 디버그하는 데 도움이 될 것입니다.

==== Chrome에서 이벤트 모니터링하기 <_monitoring_events_in_chrome>
앞서 언급한 기술은 문제가 htmx 내에서 발생하는 경우에 유용하지만, 문제를 발생하지 않게 하는 경우는 어떤가요? 이럴 때는 이벤트 이름을 잘못 입력한 경우와 같이, 문제가 발생하는 경우가 종종 있습니다.

이럴 때 사용할 수 있는 도구는 브라우저에 내장된 기능입니다. 다행히도 Google의 Chrome 브라우저는 `monitorEvents()`라는 매우 유용한 기능을 제공하여 요소에서 트리거되는 _모든_ 이벤트를 모니터링할 수 있도록 합니다.

이 기능은 _오직_ 콘솔에서만 사용할 수 있으므로 페이지의 코드에서는 사용할 수 없습니다. 그러나 Chrome에서 htmx로 작업하고 있으며 특정 요소에서 이벤트가 트리거되지 않는 이유가 궁금하다면, 개발자 콘솔을 열고 다음을 입력하면 됩니다:

#figure(caption: [Htmx 로그])[
```javascript
monitorEvents(document.getElementById("some-element"));
``` ]

이렇게 하면 `some-element` ID를 가진 요소에서 트리거되는 _모든_ 이벤트가 콘솔에 출력됩니다. 이는 htmx와 함께 응답하기 원하는 이벤트를 이해하거나 예상되는 이벤트가 발생하지 않는 이유를 문제 해결하는 데 매우 유용할 수 있습니다.

이 두 가지 기술을 사용하면 (드물게, 우리는 희망합니다) htmx로 개발할 때 이벤트 관련 문제를 디버그하는 데 도움이 될 것입니다.

=== 보안 고려사항

#index[htmx][security]
#index[security]
일반적으로 htmx와 하이퍼미디어는 JavaScript 중심의 웹 애플리케이션 구축 접근 방식보다 더 안전합니다. 이는 많은 처리를 백엔드로 이동함으로써 하이퍼미디어 접근 방식이 최종 사용자에게 시스템의 많은 표면적을 조작하고 장난칠 수 있는 권한을 제공하지 않기 때문입니다.

그러나 하이퍼미디어가 적용되더라도, 개발할 때 주의가 필요한 상황이 여전히 존재합니다. 특히 사용자 생성 콘텐츠가 다른 사용자에게 표시되는 특정 상황이 우려의 원인입니다. 영리한 사용자는 다른 사용자가 원하지 않는 작업을 트리거하는 콘텐츠를 클릭하도록 속이는 htmx 코드를 삽입하려고 할 수 있습니다.

일반적으로 모든 사용자 생성 콘텐츠는 서버 측에서 이스케이프되어야 하며, 대부분의 서버 측 렌더링 프레임워크는 이 상황을 처리하는 기능을 제공합니다. 하지만 항상 무언가가 결함을 피하는 데 있어 위험이 존재합니다.

#index[hx-disable]
사용자가 밤에 좀 더 편안하게 지낼 수 있도록, htmx는 `hx-disable` 속성을 제공합니다. 이 속성이 요소에 배치되면 해당 요소 내의 모든 htmx 속성이 무시됩니다.

==== 콘텐츠 보안 정책 및 htmx

#indexed[Content Security Policy (CSP)]는 특정 유형의 콘텐츠 삽입 기반 공격을 감지하고 방지할 수 있는 브라우저 기술입니다. CSP에 대한 전체 논의는 이 책의 범위를 초과하지만, 이 주제에 대한 추가 정보는 #link("https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP")[Mozilla Developer Network article]을 참조하시기 바랍니다.

CSP를 사용할 때 비활성화할 수 있는 일반적인 기능 중 하나는 JavaScript의 `eval()` 기능으로, 이는 문자열에서 임의의 JavaScript 코드를 평가할 수 있게 해줍니다. 이는 보안 문제로 입증되었으며, 많은 팀이 이 기능을 웹 애플리케이션에서 비활성화하기로 결정했습니다.

#index[event filters][security]
htmx는 `eval()`을 많이 사용하지 않기 때문에, 이 제한이 있는 CSP는 괜찮을 것입니다. `eval()`에 의존하는 유일한 기능은 위에서 논의한 이벤트 필터입니다. 웹 애플리케이션의 `eval()`을 비활성화하기로 결정을 내린 경우, 이벤트 필터링 문법을 사용할 수 없습니다.

=== 구성하기

#index[htmx][configuration]
htmx에 대해 사용 가능한 구성 옵션이 많이 있습니다. 구성할 수 있는 항목의 몇 가지 예는 다음과 같습니다:
- 기본 스왑 스타일
- 기본 스왑 지연
- AJAX 요청의 기본 타임아웃

전체 구성 옵션 목록은 #link("https://htmx.org/docs/#config")[주요 htmx 문서]의 구성 섹션에서 확인할 수 있습니다.

htmx는 일반적으로 페이지의 헤더에 있는 `meta` 태그를 통해 구성됩니다. 메타 태그의 이름은 `htmx-config`이어야 하며, 내용 속성에는 JSON 형식으로 구성 덮어쓰기가 포함되어야 합니다. 다음은 예시입니다:

#figure(caption: [`meta` 태그를 통한 htmx 구성])[
```html
<meta name="htmx-config" content='{"defaultSwapStyle":"outerHTML"}'>
``` ]

이 경우, 우리는 기본 스왑 스타일을 일반적인 `innerHTML`에서 `outerHTML`로 덮어쓰고 있습니다. 이는 `outerHTML`을 사용해야 하는 일이 더 자주 발생할 경우 유용하며, 애플리케이션 전반에 걸쳐 그 스왑 값을 명시적으로 설정하는 것을 피할 수 있습니다.

#html-note[시맨틱 HTML][
  "시맨틱 HTML을 사용하라"고 사람들에게 권장하는 대신 "사양을 읽어라"고 하는 것은 많은 사람들이 태그의 의미에 대해 추측하게 만들었습니다 --- "나에게는 꽤 시맨틱해 보이네!"라고 --- 사양에 맞게 태그를 사용하는 것이 소프트웨어, 예를 들어 브라우저 및 접속 기술, 검색 엔진의 필요를 충족시키는 것과 관련되어 있다는 것을 실현하는 더 나은 길입니다.

  #blockquote(
    attribution: [https://t-ravis.com/post/doc/semantic_the_8_letter_s-word/],
  )[
    의미 있는 HTML을 작성해야 한다고 요청하는 것이, 그것이 사람에게 어떤 의미인지에 대한 것이 아니라, 사양에 맞추어 태그를 사용하여 브라우저, 보조 기술, 검색 엔진과 같은 소프트웨어의 요구를 충족시키는 것이라는 것을 깨닫는 더 나은 길이라고 생각합니다.
  ]

  우리는 _준수하는_ HTML에 대해 이야기하고 작성하는 것을 추천합니다. (우리는 항상 더 많은 논의를 할 수 있습니다). HTML 사양에서 제공하는 요소를 최대한 활용하고, 소프트웨어가 해석할 수 있는 의미를 가지고 가져가도록 하십시오.
]
