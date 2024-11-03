#import "lib/definitions.typ": *
#import "lib/snippets.typ": fielding-rest-thesis

== 클라이언트 사이드 스크립팅

#blockquote(
  attribution: fielding-rest-thesis,
)[
  REST는 클라이언트 기능을 애플릿이나 스크립트 형태로 코드 다운로드 및 실행을 통해 확장할 수 있도록 허용합니다. 이는 클라이언트에서 미리 구현해야 하는 기능의 수를 줄여 간소화합니다.
]

지금까지 우리는 Contact.app에서 JavaScript(또는 \_hyperscript)를 작성하는 것을 (주로) 피했습니다. 주로 우리가 구현한 기능이 이를 요구하지 않았기 때문입니다. 이번 장에서는 스크립팅, 특히 하이퍼미디어 친화적 스크립팅을 하이퍼미디어 주도 애플리케이션의 맥락에서 살펴보겠습니다.

=== 스크립팅이 허용되는가? <_is_scripting_allowed>
웹에 대한 일반적인 비판 중 하나는 그것이 잘못 사용되고 있다는 것입니다. WWW가 "문서"를 전달하기 위한 시스템으로 만들어졌고, "애플리케이션"으로 사용되게 된 것은 우연한 사고나 기이한 상황이라는 내러티브가 있습니다.

하지만 하이퍼미디어의 개념은 문서와 애플리케이션의 구분에 도전합니다. 하이퍼카드와 같은 하이퍼미디어 시스템은 웹보다 이전에 등장했으며, 스크립팅을 포함한 능동적이고 상호작용적인 경험을 위한 풍부한 기능을 제공했습니다.

정의되고 구현된 HTML은 매우 상호작용적인 애플리케이션을 구축하는 데 필요한 가능성이 부족하긴 하지만, 하이퍼미디어의 _목적_이 "문서"보다 "애플리케이션"이라는 뜻은 아닙니다.

오히려 이론적 기초는 있지만, 구현이 미비한 상황입니다. JavaScript만이 유일한 확장점이기 때문에 하이퍼미디어 제어가 JavaScript와 잘 통합되지 않았습니다(어째서 프로그램을 중단하지 않고는 링크를 클릭할 수 없는가?). 개발자들은 하이퍼미디어를 내재화하는 데 실패하고 대신 "네이티브" 애플리케이션을 모방하는 앱을 위해 웹을 단순한 파이프라인으로 사용했습니다.

이 책의 목표 중 하나는 대중적인 JavaScript 프레임워크에서 제공하는 추상화에 손을 뻗지 않고도 원래 웹 기술인 하이퍼미디어를 사용하여 정교한 웹 애플리케이션을 구축할 수 있음을 보여주는 것입니다.

Htmx 자체는 물론 JavaScript로 작성되며, 그 장점 중 하나는 htmx를 통해 하이퍼미디어 상호작용을 하면 하이퍼미디어 코드가 JavaScript 코드에 대해 풍부한 인터페이스를 제공하며, 이와 관련된 구성, 이벤트 및 htmx 자체의 확장 지원을 노출합니다.

Htmx는 HTML의 표현력을 확장하여 많은 상황에서 스크립팅의 필요성을 제거합니다. 따라서 htmx는 JavaScript를 작성하고 싶지 않은 사람들에게 매력적이며, 많은 그러한 개발자들이 있습니다. 이들은 Single Page Application 프레임워크의 복잡성을 경계하고 있습니다.

하지만 JavaScript를 비난하는 것이 htmx 프로젝트의 목표는 아닙니다. htmx의 목표는 JavaScript를 줄이는 것이 아니라 코드의 양을 줄이고, 더 읽기 쉽고 하이퍼미디어 친화적인 코드가 되는 것입니다.

스크립팅은 웹에 엄청난 힘을 더했습니다. 스크립팅을 사용함으로써 웹 애플리케이션 개발자는 HTML 웹사이트를 향상시키는 것뿐만 아니라 종종 네이티브 두꺼운 클라이언트 애플리케이션과 경쟁할 수 있는 완전하게 클라이언트 사이드 애플리케이션을 생성할 수 있습니다.

이 JavaScript 중심의 웹 애플리케이션 빌딩 접근법은 웹과 특히 웹 브라우저의 복잡함을 입증하는 것입니다. 웹 개발에는 자리가 있습니다. 하이퍼미디어 접근 방식이 SPA가 제공하는 상호작용 수준을 제공할 수 없는 상황도 있습니다.

하지만 이 JavaScript 중심 스타일 외에도 우리는 하이퍼미디어 주도 애플리케이션과 더 호환 가능하고 일관된 스크립팅 스타일을 개발하고자 합니다.

=== 하이퍼미디어를 위한 스크립팅

#index[scripting][hypermedia friendly]
로이 필딩의 REST 정의에 대한 "제약" 개념을 차용하여, 우리는 하이퍼미디어 친화적 스크립팅의 두 가지 제약을 제안합니다. 다음 두 가지 제약을 준수하면 HDA 호환 방식으로 스크립팅하고 있다고 볼 수 있습니다:
- 서버와 클라이언트 간에 교환되는 주요 데이터 형식은 스크립팅이 없는 경우와 동일하게 하이퍼미디어여야 합니다.
- DOM 자체 외부의 클라이언트 측 상태는 최소한으로 유지해야 합니다.

이러한 제약의 목표는 스크립팅을 빛나게 하는 최적의 장소로 제한하여 다른 무언가가 근접할 수 없는 _상호작용 디자인_으로 귀결됩니다. 비즈니스 로직과 프레젠테이션 로직은 서버의 책임입니다. 서버에서 비즈니스 도메인에 적절한 언어 또는 도구를 선택할 수 있습니다.

#block(breakable: false,
sidebar[서버][비즈니스 로직과 프레젠테이션 로직을 모두 "서버에" 두는 것은 이 두 가지 "관심사"가 혼합되거나 결합된다는 것을 의미하지 않습니다. 이들은 서버에서 모듈화 될 수 있습니다. 사실 이들은 _모듈화_ 되어야 하며, 애플리케이션의 다른 모든 관심사와 함께 다루어져야 합니다.

웹 개발 용어에서 겸손한 "서버"는 일반적으로 수많은 랙, 가상 머신, 컨테이너, 그리고 더 많은 것들이 포함된 전체 집합을 나타냅니다. 심지어 전 세계의 데이터센터 네트워크조차도 하이퍼미디어 주도 애플리케이션의 서버 측을 논의할 때는 "서버"로 축소됩니다.])

이 두 가지 제약을 충족하려면 때때로 일반적으로 JavaScript에 대해 최선의 실천으로 여겨지는 것에서 벗어나야 할 필요가 있습니다. JavaScript의 문화적 지혜는 주로 JavaScript 중심의 SPA 애플리케이션에서 개발되었습니다.

하이퍼미디어 주도 애플리케이션은 이 전통에 편안하게 의존할 수 없습니다. 이 장은 우리가 하이퍼미디어 주도 애플리케이션을 위한 새로운 스타일과 최선의 실천법 개발에 기여하는 것입니다.

불행히도 단순히 "모범 사례"를 나열하는 것은 드물게 설득력이 있거나 유익합니다. 솔직히, 그것은 지루합니다.

대신 우리는 Contact.app에서 클라이언트 측 기능을 구현하여 이러한 모범 사례를 보여줄 것입니다. 하이퍼미디어 친화적 스크립팅의 다양한 측면을 다루기 위해 세 가지 다양한 기능을 구현할 것입니다:
- 우리 연락처 목록의 시각적 혼잡을 줄이기 위해 _Edit_, _View_ 및 _Delete_ 작업을 보관할 오버플로우 메뉴.
- 일괄 삭제를 위한 개선된 인터페이스.
- 검색 상자에 포커스를 맞추기 위한 키보드 단축키.

각 기능의 구현에서 중요한 것은, 이들이 스크립팅을 사용하여 완전히 클라이언트 측에서 구현되었지만, 서버와 _비하이퍼미디어 형식_ 즉, JSON과 시간 정보를 교환하지 않고 DOM 자체 외부의 상태를 저장하지 않는다는 것입니다.

=== 웹용 스크립팅 도구 <_scripting_tools_for_the_web>
웹의 주요 스크립팅 언어는 물론 JavaScript로, 오늘날 웹 개발에서 널리 사용되고 있습니다.

그러나 흥미로운 인터넷 전설 중 하나는 JavaScript가 항상 유일한 내장 옵션이 아니었다는 것입니다. 이 장 초반에 인용된 로이 필딩의 인용처럼, Java와 같은 다른 언어로 작성된 "애플릿"은 웹의 스크립팅 인프라의 일부로 간주되었습니다. 게다가 Internet Explorer가 Visual Basic을 기반으로 한 스크립팅 언어인 VBScript를 지원하던 시기도 있었습니다.

오늘날 우리는 TypeScript, Dart, Kotlin, ClojureScript, F# 등 다양한 언어를 JavaScript로 변환하는 _transcompilers_ (종종 _transpilers_ 라고 줄여 부름)와 함께 WebAssembly (WASM) 바이트코드 형식을 가지고 있습니다. WASM은 C, Rust 및 WASM 중심 언어인 AssemblyScript의 컴파일 대상 지원 언어입니다.

하지만 이러한 대부분의 옵션은 하이퍼미디어 친화적 스크립팅 방식에 맞춰 설계되지 않았습니다. Compile-to-JS 언어는 종종 SPA지향 라이브러리(Dart 및 AngularDart, ClojureScript 및 Reagent, F# 및 Elm)와 함께 결합되며, 현재 WASM는 주로 JavaScript의 C/C++ 라이브러리와 연결하는 데 사용됩니다.

우리는 대신 세 가지 클라이언트 측 스크립팅 기술에 집중할 것입니다:
- VanillaJS, 즉 어떤 프레임워크에도 의존하지 않고 JavaScript 사용.
- Alpine.js, HTML에 직접 동작을 추가하는 JavaScript 라이브러리.
- \_hyperscript, htmx와 함께 만들어진 비JavaScript 스크립팅 언어. AlpineJS와 마찬가지로 \_hyperscript는 일반적으로 HTML에 내장됩니다.

각 스크립팅 옵션을 빠르게 살펴보겠습니다. 각 옵션이 어떻게 작동하는지에 대한 맛을 제공하며, 우리는 그러한 옵션들을 보다 깊이 있게 살펴보기를 희망합니다.

=== 바닐라 #indexed[JavaScript]

#blockquote(attribution: [Merb (Ruby 웹 프레임워크), motto])[
  코드보다 빠른 코드는 없다.
]

바닐라 JavaScript는 단순히 응용 프로그램에서 순수 JavaScript를 사용하는 것입니다. 중간 계층 없이. "바닐라"라는 용어는 적절한 "고급" 웹 앱이 ".js"로 끝나는 이름의 어떤 라이브러리를 사용할 것이라고 가정하게 되면서 프론트엔드 웹 개발 용어에 들어왔습니다. 그러나 JavaScript가 스크립팅 언어로 성숙해지고, 브라우저에서 표준화되며, 점점 더 많은 기능을 제공하게 되면서 이러한 프레임워크와 라이브러리는 덜 중요해졌습니다.

아이러니하게도 JavaScript가 점점 더 강력해지고 첫 번째 세대 JavaScript 라이브러리인 jQuery의 필요성을 제거하면서 복잡한 SPA 라이브러리를 구축할 수 있게 되었습니다. 이러한 SPA 라이브러리는 종종 원래의 첫 번째 세대 JavaScript 라이브러리보다 훨씬 더 정교합니다.

#link("http://vanilla-js.com") 웹사이트에서의 인용은 다소 구식이지만, 상황을 잘 나타냅니다:

#blockquote(
  attribution: [http:\/\/vanilla-js.com],
)[
  VanillaJS는 내가 써본 프레임워크 중 가장 적은 오버헤드와 가장 포괄적입니다.
]

JavaScript가 스크립팅 언어로 성숙해지면서 이는 많은 애플리케이션에서 확실히 그러합니다. HDAs의 경우, 하이퍼미디어를 사용함으로써 귀하의 애플리케이션은 더 정교한 Single Page Application JavaScript 프레임워크가 일반적으로 제공하는 많은 기능을 필요로 하지 않을 것입니다:
- 클라이언트 측 라우팅
- DOM 조작에 대한 추상화 (즉, 참조된 변수 변경 시 자동으로 업데이트되는 템플릿)
- 서버 측 렌더링 #footnote[여기서 렌더링은 HTML 생성을 의미합니다. HDA에서는 서버에서 HTML을 생성하는 것이 기본이므로 서버 측 렌더링에 대한 프레임워크 지원이 필요하지 않습니다.]
- 로드 시 서버 렌더링된 태그에 동적 동작 추가 (즉, "수분 공급")
- 네트워크 요청

이 모든 복잡성을 JavaScript에서 처리하지 않으므로 프레임워크의 요구 사항이 급격히 감소합니다.

바닐라JavaScript의 장점 중 하나는 그것을 설치하는 방법입니다: 설치할 필요가 없습니다!

그냥 웹 애플리케이션에서 JavaScript를 작성하기 시작하면 그냥 작동합니다.

이게 좋은 소식입니다. 나쁜 소식은 지난 10년 동안의 개선에도 불구하고 JavaScript가 하이퍼미디어 주도 애플리케이션의 독립적인 스크립팅 기술로는 그다지 이상적이지 않은 몇 가지 중요한제한 사항을 가지고 있다는 것입니다:
- 확립되어 온 덕분에 많은 기능과 결함이 누적되었습니다.
- 비동기 코드를 작업하기 위한 복잡하고 혼란스러운 기능 집합이 있습니다.
- 이벤트를 다루는 것은 놀랄 만큼 어렵습니다.
- DOM API(대부분 원래 Java로 설계된 큰 부분)는 장황하고 일반적인 기능을 사용하기 쉽게 만드는 습관이 없습니다.

이러한 제한 사항 중 어느 것도 거래 파괴자는 아닙니다. 많은 사람들이 이러한 제한 사항을 점진적으로 수정하고 있으며, Vanilla JavaScript의 "철저한" 성격을 선호합니다. 

==== 간단한 카운터 <_a_simple_counter>
바닐라 JavaScript를 프론트 엔드 스크립팅 옵션으로 탐색하기 위해 간단한 카운터 위젯을 만들어 보겠습니다.

카운터 위젯은 JavaScript 프레임워크의 일반적인 "Hello World" 예제이므로, 바닐라 JavaScript(그리고 우리가 살펴보고자 하는 다른 옵션들)에서 이를 수행할 수 있는 방법을 살펴보는 것은 유익할 것입니다.

우리의 카운터 위젯은 매우 간단할 것입니다: 숫자가 텍스트로 표시되고 숫자가 증가하는 버튼이 있습니다.

바닐라 JavaScript로 이 문제를 해결한 한 가지 문제는 대부분의 JavaScript 프레임워크가 제공하는 기본 코드 및 아키텍처 스타일이 부족하다는 것입니다.

바닐라 JavaScript에는 규칙이 없습니다!

이렇다고 해서 모두 나쁜 것은 아닙니다. 다양한 스타일을 통해 JavaScript를 작성하는 사람들의 스타일을 작은 여정을 할 수 있는 좋은 기회를 제공합니다.

===== 인라인 구현 <_an_inline_implementation>
간단한 것으로 시작합시다: 모든 JavaScript를 HTML에 인라인으로 작성합니다. 버튼이 클릭되면 숫자를 보유하고 있는 `output` 요소를 찾아서 그 안의 숫자를 증가시킵니다.

#figure(caption: [바닐라 JavaScript의 카운터 인라인 버전])[
```html
<section class="counter">
  <output id="my-output">0</output>  <1>
  <button
    onclick=" <2>
      document.querySelector('#my-output') <3>
        .textContent++ <4>
    "
  >Increment</button>
</section>
``` ]
1. 출력 요소는 찾기 쉽게 ID를 가집니다.
2. 이벤트 리스너를 추가하기 위해 `onclick` 속성을 사용합니다.
3. querySelector() 호출을 통해 출력을 찾습니다.
4. JavaScript는 문자열에 대해 `++` 연산자를 사용할 수 있습니다.

나쁘지 않죠.

가장 아름다운 코드는 아니며, 특히 DOM API에 익숙하지 않은 경우는 짜증이 날 수도 있습니다.

`output` 요소에 `id`를 추가해야 했던 점이 다소 불편합니다. `document.querySelector()` 함수는 예를 들어 `$` 함수에 비해 장황합니다. 

그러나 잘 작동합니다. 이해하기에도 충분히 쉽고, 중요하게도 다른 JavaScript 라이브러리를 필요로 하지 않습니다.

그래서 이것이 바닐라JavaScript의 간단한 인라인 접근 방식입니다. 

===== 스크립트를 분리하기 <_separating_our_scripting_out>
인라인 구현이 어떤 의미에서 간단하지만, 이를 작성하는 보다 표준적인 방법은 코드를 별도의 JavaScript 파일로 이동하는 것입니다. 이 JavaScript 파일은 `<script src>` 태그를 통해 링크되거나 빌드 프로세스를 통해 인라인 `<script>` 태그에 배치될 수 있습니다.

여기에서 우리는 HTML과 JavaScript가 서로 _분리되어_ 다른 파일에 있는 것을 봅니다. HTML은 이제 JavaScript 없이 더 "깨끗"합니다.

JavaScript는 인라인 버전보다 조금 더 복잡합니다: querySelector를 사용하여 버튼을 찾아 클릭 이벤트를 처리하고 카운터를 증가시킬 _이벤트 리스너_를 추가해야 합니다.

#figure(caption: [카운터 HTML])[
```html
<section class="counter">
  <output id="my-output">0</output>
  <button class="increment-btn">Increment</button>
</section>
``` ]

#figure(caption: [카운터 JavaScript])[
```js
const counterOutput = document.querySelector("#my-output"), <1>
  incrementBtn = document.querySelector(".counter .increment-btn") <2>

incrementBtn.addEventListener("click", e => { <3>
  counterOutput.innerHTML++ <4>
})
``` ]
1. 출력 요소를 찾습니다.
2. 버튼을 찾습니다.
3. 서로 다른 많은 이유로 `onclick`보다 선호되는 `addEventListener`를 사용합니다.
4. 논리는 동일하게 유지되며 구조만 변경됩니다.

#index[관심사의 분리 (SoC)]
JavaScript를 다른 파일로 이동함으로써 우리는 _관심사의 분리(Separation of Concerns, SoC)_라는 소프트웨어 디자인 원칙을 따르고 있습니다.

관심사의 분리는 소프트웨어 프로젝트의 다양한 "관심사"(또는 측면)를 여러 파일로 나누어 서로 "오염"되지 않도록 해야 한다고 가정합니다. JavaScript는 마크업이 아니므로 HTML에 있어서는 안 되며 _다른 곳에_ 있어야 합니다. 마찬가지로 스타일링 정보도 마크업이 아니며 그 자체로도 별도의 파일에 있어야 합니다(CSS 파일 예).

상당한 시간 동안 이러한 관심사의 분리는 웹 애플리케이션을 구축하는 "정통적인" 방법으로 여겨져 왔습니다.

관심사의 분리에 따른 목표는 각 관심사를 독립적으로 수정하고 발전시킬 수 있어야 하며, 다른 관심사를침해하지 않을 것이라는 확신을 가지는 것입니다.

하지만 간단한 카운터 예제를 통해 이 원칙이 어떻게 작동하는지 살펴보겠습니다. 새로운 HTML에 자세히 살펴보면, 버튼에 클래스를 추가해야 했음을 알 수 있습니다. 우리는 JavaScript에서 버튼을 찾아서 "click" 이벤트의 이벤트 핸들러를 추가할 수 있도록 이 클래스를 추가했습니다.

이제 HTML과 JavaScript 모두에서 이 클래스 이름은 단순한 문자열이며, 이로 인해 버튼이 올바른 클래스가 있는지 또는 그 조상 클래스를 확인할 프로세스가 없습니다. 실제로 인해 밀접하게 연결된 커널에 의해 고통을 겪고 있습니다.

안타깝게도 JavaScript에서 CSS 선택자의 부주의한 사용은 _#indexed[jQuery 스프]를 초래할 수 있습니다. jQuery 수프는 다음과 같은 상황입니다:
- 특정 요소에 주어진 동작을 연결하는 JavaScript 코드를 찾기가 어렵습니다.
- 코드 재사용이 어렵습니다.
- 코드는 무질서하고 "평평하게" 되어 많은 무관한 이벤트 핸들러가 뒤섞입니다.

"jQuery soup"라는 이름은 대부분의 JavaScript 중심 애플리케이션이 jQuery로 구축되었던(지금도 여전히 대부분), 이러한 JavaScript 스타일을 유도하는 경향이 있었습니다.

따라서 "관심사의 분리"라는 개념이 항상 약속한 만큼 잘 작동하지 않는 모습을 볼 수 있습니다. 관심사들이 서로 얽히고 깊게 연결되며, 서로 다른 파일로 분리하더라도 마찬가지입니다.

#asciiart(read("images/diagram/separation-of-concerns.txt"), caption: [어떤 관심사?])

관심사의 이름 짓는 것이 문제를 일으킬 수 있는 것만이 아니라는 것을 보여주기 위해, HTML에서의 작은 변화를 고려해 보겠습니다. 숫자 필드를 `<output>` 태그에서 `<input type="number">`로 변경한다고 상상해 보세요.

HTML에 대한 이러한 작은 변화는 JavaScript를 엉망으로 만들고, 우리는 "관심사"를 분리했음에도 불구하고 이를 해결해야 합니다.

이 문제의 해결은 간단합니다(우리는 `.textContent` 프로퍼티를 `.value` 프로퍼티로 변경해야 합니다), 그래도 여러 파일 전반에서 마크업 변경과 코드 변경을 동기화하는 부담을 나타냅니다. 애플리케이션 크기가 증가함에 따라 모든 것을 동기화하는 것은 점점 더 어려워질 수 있습니다.

HTML의 작은 변경으로 인해 스크립트가 손상된다는 사실은 두 가지가 _밀접하게 결합되어 있다는 것을_ 나타냅니다. 이 짙은 결합은 HTML과 JavaScript(및 CSS) 간의 분리라는 끌어당김을 악화합니다. 이 원리는 서로 간에 충분한 상관 관계가 있으므로 쉽게 분리되지 않습니다.

우리는 Contact.app에서 "구조", "스타일링" 또는 "동작"에 대해 _걱정하지 않습니다_; 우리는 연락처 정보를 수집하고 사용자에게 제시하는 것에 대해 걱정합니다. 웹 개발 정통성에서 제안된 방식으로 SoC는 사실상 깨지지 않는 건축 지침이 아니라, 우리는 이와 같은 스타일적 선택을 볼 수 있습니다. 

===== 행동의 지역성

#index[행동의 지역성 (LoB)]
재미있게도, _Separation of Concerns_ 디자인 원칙에 대한 반발이 생겨났습니다. 다음 웹 기술 및 기법을 고려해 보세요:
- JSX
- LitHTML
- CSS-in-JS
- 단일 파일 구성요소
- 파일 시스템 기반 라우팅

이러한 기술들은 모두 하나의 _특징_ (일반적으로는 UI 위젯)을 다루는 다양한 언어에서 코드를 _동시 위치시키도록_ 기획되었습니다.

모든 이들은 사용자에게 통합된 추상화를 제공하기 위해 _구현_ 관심을 혼합합니다. 기술적 세부 사항을 분리하는 것은 별로 _관심이_ 없습니다.

행동의 지역성(LoB)은 관심사의 분리(Separetion of Concerns)와 반대되는 대안 소프트웨어 디자인 원칙입니다. 이는 소프트웨어의 한 유닛의 다음과 같은 특성을 설명합니다:

#blockquote(
  attribution: [https:\/\/htmx.org/essays/locality-of-behaviour/],
)[
  코드 유닛의 동작은 그 코드 유닛만 보고도 가능한 한 명확해야 합니다.
]

간단히 말해서: 버튼이 하는 일을 그 버튼을 생성하는 코드 또는 마크업만 보고 알아야 합니다. 이는 전체 구현을 인라인으로 표시할 필요는 없지만, 필요한 경우에는 이를 찾기 위해 헌터를 사냥하거나 코드베이스에 대한 이전 지식을 요구하지 않아야 한다는 것입니다.

우리는 카운터 데모와 Contact.app에 추가하는 기능 모두에서 행동의 지역성(LoB)을 보여줄 것입니다. 행동의 지역성은 \_hyperscript 및 Alpine.js(차후에 다룰 예정)와 htmx의 명시적 디자인 목표입니다.

이 모든 도구는 코드에서 기능을 추적할 수 없이 코드 또는 마크업의 CSS 선택자를 사용하여 문서 내에서 직접 속성을 내장하도록 제공합니다.

하이퍼미디어 주도 애플리케이션에서 행동의 지역성 디자인 원칙은 종종 더 전통적인 관심사의 분리 원칙보다 더 중요하다고 생각합니다.

===== 카운터로 무엇을 할 것인가?

#index[JavaScript][on*]
그렇다면 다시 `onclick` 속성 방법으로 돌아가야 할까요? 해당 방식은 행동의 지역성에서확실히 승리하며, HTML에 기본으로 내장되어 있는 추가적인 이점이 있습니다.

하지만 불행히도 `on*` JavaScript 속성에는 몇 가지 단점도 있습니다:
- 사용자 지정 이벤트를 지원하지 않습니다.
- 요소와 장기 지속 변수를 연결할 좋은 메커니즘이 없습니다---모든 변수는 이벤트 리스너가 실행을 완료하면 삭제됩니다.
- 요소의 여러 인스턴스가 있는 경우, 각 인스턴스에 리스너 코드를 반복해서 작성하거나 이벤트 위임과 같은 더 영리한 방법을 사용해야 합니다.
- DOM을 직접 조작하는 JavaScript 코드는 장황하게 되어 마크업이 혼잡해집니다.
- 한 요소가 다른 요소에서 이벤트를 수신할 수 없습니다.

다음과 같은 일반적인 상황을 고려해 보세요: 팝업이 있고 사용자가 팝업 외부를 클릭하면 닫히기를 원할 수 있습니다. 이 경우 리스너는 본체 요소에 부착해야 하므로 실제 팝업 마크업에서 멀리 떨어져 있습니다. 이는 본체 요소에 여러 무관한 컴포넌트와 관련된 리스너를 부착해야 한다는 의미입니다. 이러한 컴포넌트 중 일부는 초기 HTML 페이지가 렌더링될 때 페이지에 없을 수 있으며, 처음에 렌더링된 후에 동적으로 추가됩니다.

따라서 바닐라 JavaScript와 행동의 지역성(LoB)은 서로 맞물려 작동하지 않을 것으로 보입니다.

하지만 상황이 절망적이지는 않습니다. LoB는 행동이 사용 사이트에서 _구현_ 되는 것이 아니라 그곳에서 _호출_ 되어야 한다는 것을 이해하는 것이 중요합니다. 즉, 모든 코드를 특정 요소에 작성할 필요는 없으며, 특정 요소가 _어떤 코드를 호출_ 한다는 것을 분명히 할 수 있습니다. 이 코드는 다른 곳에 위치할 수 있습니다.

이를 염두에 두고, 우리는 JavaScript를 별도의 파일로 작성하면서 행동의 지역성을 개선할 수 있습니다. 세련된 JavaScript 구조화 시스템이 있으면 가능합니다.

==== RSJS

#index[RSJS] 
#(합리적인 자바스크립트 구조화 시스템,"#link("https://ricostacruz.com/rsjs/"))는 "전형적인 비SPA 웹사이트"를 대상으로 하는 JavaScript 구조 지침 세트입니다. RSJS는 앞서 언급한 바닐라 JavaScript의 표준 코드 스타일 부족 문제에 대한 해결책을 제공합니다.

다음은 우리 카운터 위젯에 가장 관련된 RSJS 지침입니다:
- HTML에서 "data-" 속성을 사용하십시오: 데이터 속성 추가를 통해 행동을 호출하면 자바스크립트가 발생하고 있음을 명확하게 나타내는 반면, 임의의 클래스나 ID를 사용하는 것은 실수로 삭제되거나 변경될 수 있습니다.
- "파일당 하나의 구성 요소": 파일의 이름은 데이터 속성을 일치시켜 쉽게 찾을 수 있어야 하며, LoB에 대해 이점입니다.

RSJS 지침을 따르기 위해 현재 HTML 및 JavaScript 파일을 재구성해 보겠습니다. 먼저 하이퍼미디어 요소로 바꿉니다. 이제 출력 요소와 버튼을 원소로 배치해 보겠습니다. 카운터를 구현하기 위해 버튼에 적당한 하이퍼미디어 코드를 추가해야 합니다. 클릭 시 이전 출력 태그의 텍스트를 증가시켜야 합니다.

우리 코드 모습은 다음과 같습니다:

#figure(caption: [바닐라 JavaScript의 카운터, RSJS])[
```html
<section class="counter" data-counter> <1>
  <output id="my-output" data-counter-output>0</output> <2>
  <button class="increment-btn" data-counter-increment>Increment</button>
</section>
``` ]
1. JavaScript에서 데이터 속성으로 행동을 호출합니다.
2. 관련 하위 요소를 표시합니다.


#figure[
```js
// counter.js <1>
document.querySelectorAll("[data-counter]") <1>
  .forEach(el => {
    const
    output = el.querySelector("[data-counter-output]"),
    increment = el.querySelector("[data-counter-increment]"); <3>

    increment.addEventListener("click", e => output.textContent++); <4>
  });
```]
1. 파일은 데이터 속성의 이름과 같은 이름이어야 다양한 기능을 쉽게 찾을 수 있습니다.
2. 이 행동을 호출하는 모든 요소를 가져옵니다.
3. 필요한 자식 요소를 확보합니다.
4. 이벤트 핸들러를 등록합니다.

RSJS는 우리가 최초의 비구조화된 바닐라JavaScript 예에서 지적한 여러 문제를 해결하거나 완화합니다.
- 특정 요소에 행동을 부착하는 JavaScript 쇼가 _명확_합니다. 
- 재사용은 _쉬운_ - 페이지에서 또 다른 카운터 컴포넌트를 만들면 그냥 작동할 것입니다.
- 코드는 _잘 조직되어 있습니다_ - 한 파일당 한 행동.

전반적으로 RSJS는 하이퍼미디어 주도 애플리케이션의 바닐라 JavaScript를 구조화하기에 좋은 방법입니다. JavaScript가 일반 데이터 JSON API를 통해 서버와 통신하지 않거나 DOM 외부에 내부 상태를 유지하지 않는 한, 이는 HDA 접근 방식과 완벽하게 호환됩니다.

RSJS/바닐라 JavaScript 접근 방식을 사용하여 Contact.app에서 기능을 구현해 보겠습니다.

==== 바닐라JS 작동 중: 오버플로우 메뉴 <_vanillajs_in_action_an_overflow_menu>
홈페이지에는 각 연락처에 대해 "Edit", "View" 및 "Delete" 링크가 있습니다. 이로 인해 많은 공간을 차지하고 시각적 혼란을 발생시킵니다. 이를 수정하여 이러한 작업을 아래로 드롭다운 메뉴에 넣고 열기 위한 버튼을 만듭시다.

JavaScript와 관련된 코드가 너무 복잡하게 느껴진다면 걱정하지 마세요. 다음에 살펴볼 Alpine.js와 \_hyperscript 예제가 따라가기 쉬울 것입니다.

먼저 드롭다운 메뉴에 원하는 마크업을 스케치해 보겠습니다. 먼저 전체 위젯을 봉인할 요소인 `<div>`를 사용하여 메뉴 컴포넌트로 표시해야 합니다. 이 div 내에서 메뉴 항목을 표시하는 메커니즘으로 작동할 표준 `<button>`을 갖게 됩니다. 마지막으로 보여줄 메뉴 항목을 보유하는 또 다른 `<div>`가 생성됩니다.

이 메뉴 항목들은 현재 연락처 테이블과 같이 단순한 앵커 태그로 될 것입니다.

RSJS로 구성된 업데이트된 HTML은 다음과 같습니다:

#figure[
```html
<div data-overflow-menu> <1>
    <button type="button" aria-haspopup="menu"
        aria-controls="contact-menu-{{ contact.id }}"
        >Options</button> <2>
    <div role="menu" hidden id="contact-menu-{{ contact.id }}"> <3>
        <a role="menuitem"
          href="/contacts/{{ contact.id }}/edit">Edit</a> <4>
        <a role="menuitem" href="/contacts/{{ contact.id }}">View</a>
        <!-- ... -->
    </div>
</div>
```]
1. 메뉴 컴포넌트의 원소형을 표시합니다.
2. 이 버튼은 우리 메뉴를 열린 상태와 닫힌 상태로 전환합니다.
3.메뉴 항목을 보유할 수 있는 컨테이너입니다.
4. 메뉴 항목들입니다.

역할 및 ARIA 속성은 ARIA 저자 실천 가이드의 메뉴 및 메뉴 버튼 패턴에 근거하고 있습니다.

#sidebar[ARIA란 무엇인가?][
웹 개발자가 더 많은 상호작용적 애플리케이션과 같은 웹사이트를 만들면서 HTML의 구성 요소만으로는 모든 것을 갖추고 있지 않습니다. 앞서 언급한 바와 같이, CSS와 JavaScript를 사용하여 기존 요소에 필요에 따른 행동과 외형을 부여할 수 있어, 네이티브 컨트롤의 기능과 맞먹는 모습을 보일 수 있습니다.

그러나 웹 애플리케이션은 복제할 수 없는 한 가지가 있었습니다. 이러한 위젯은 실제와 충분히 비슷하더라도 보조 기술(예: 스크린 리더)은 기본 HTML 요소만 처리할 수 있었습니다.

모든 키보드 상호작용을 제대로 구현하려고 하더라도, 일부 사용자는 이러한 사용자 정의 요소와 함께 쉽게 작업할 수 없습니다.

ARIA는 W3C의 웹 접근성 이니셔티브(WAI)에서 2008년에 이 문제를 해결하기 위해 만들어졌습니다. 기본 수준에서 이는 스크린 리더와 같은 보조 소프트웨어에 의미를부여하기 위해 HTML에 추가할 수 있는 속성 집합입니다.
 
ARIA는 상호작용하는 두 가지 주요 구성 요소가 있습니다:

첫 번째는 `role` 속성입니다. 이 속성은 세트된 가능할 수 있는 값들인 `menu`, `dialog`, `radiogroup` 등을 가집니다. 이 `role` 속성은 HTML 요소에 행동을 추가하지 않습니다. 오히려 사용자에게 하기로 약속입니다. 요소를 `role='menu'`로 주석을 달면, 이 요소가 메뉴처럼 작동하도록 하겠다는 의미입니다.

만약 요소에 `role`을 추가했지만 이를 지키지 않는다면, 많은 사용자에게는 이 요소가 _전혀_ `role`이 없는 경우보다 _나쁜_ 경험을 제공하게 됩니다. 따라서 다음과 같이 되어 있습니다:

#blockquote(attribution: [W3C, Read Me First | APG,
  https:\/\/www.w3.org/WAI/ARIA/apg/practices/read-me-first/])[
  나쁜 ARIA보다 ARIA 없음이낫다.
]

ARIA의 두 번째 구성 요소는 `aria-` 접두사가 붙은 _상태 및 속성_입니다: `aria-expanded`, `aria-controls`, `aria-label` 등. 이러한 속성들은 위젯의 상태, 구성 요소 간의 관계 또는 추가하는 의미를 지정할 수 있습니다. 다시 말해 이러한 속성은 _약속_이지 구현이 아닙니다.

대부분의 개발자에게 사용하기 위해 모든 역할과 속성을 배우고 이를 사용 가능한 위젯으로 조합하는 것보다 가장 좋은 방법은 ARIA 저자 실천 가이드(APG), 웹 리소스를 활용하는 것입니다. 이 웹 리소스는 웹 개발자에게 직접적으로 유용한 정보를 제공합니다.

ARIA에 처음이라면 다음 W3C 리소스를 확인해 보세요:

- ARIA: Read Me First:
  #link("https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/")

- ARIA UI 패턴: #link("https://www.w3.org/WAI/ARIA/apg/patterns/")

- ARIA 모범 사례:
  #link("https://www.w3.org/WAI/ARIA/apg/practices/")

웹 사이트의 접근 가능성 테스트를 항상 #strong[기억하세요]. 모든 사용자가 쉽게효과적으로 상호 작용할 수 있도록 해야 합니다.
]

이제 우리의 구현에서 JS 측은 RSJS 보일러 플레이트로 시작합니다:
모든 데이터 속성을 가진 요소에 대해 쿼리하고, 이를 걸러내고, 관련 하위 요소를 가져옵니다.

참고로 아래쪽에서 htmx가 새로운 콘텐츠를 불러올 때 오버플로우 메뉴를 통합하기 위해 RSJS 보일러 플레이트를 조금 수정했습니다.

#figure[
```js
function overflowMenu(tree = document) {
  tree.querySelectorAll("[data-overflow-menu]").forEach(menuRoot => { <1>
    const
    button = menuRoot.querySelector("[aria-haspopup]"), <2>
    menu = menuRoot.querySelector("[role=menu]"), <3>
    items = [...menu.querySelectorAll("[role=menuitem]")];
  });
}

addEventListener("htmx:load", e => overflowMenu(e.target)); <4>
```]
1. RSJS를 사용하면 `document.querySelectorAll(…​).forEach`를 많이 작성하게 됩니다.
2. HTML을 깔끔하게 유지하기 위해 ARIA 속성을 사용하고 사용자 정의 데이터 속성을 사용하지 않습니다.
3. `NodeList`를 일반 `Array`로 변환하기 위해 확산 연산자를 사용합니다.
4. 페이지가 로드될 때 또는 htmx로 구성 요소가 삽입될 때 모든 오버플로우 메뉴를 초기화합니다.

전통적으로 사용자는 JavaScript 변수를 사용하거나 JavaScript 상태 객체 내에 속성을 가지고 메뉴가 열려 있는지 추적하게 됩니다. 이러한 접근 방식은 대규모 JavaScript 중심 웹 애플리케이션에서 일반적입니다.

하지만 이 방법에는 몇 가지 단점이 있습니다:
- DOM을 상태와 동기화하는 것이 필요합니다(프레임워크 없이 더 어렵습니다).
- HTML을 직렬화할 수 있는 능력을 잃게 됩니다(이 열린 상태는 DOM에 저장되지 않고 JavaScript에 저장됩니다).

대신 이 접근 방식을 사용하는 대신, 우리는 DOM을 사용하여 상태를 저장합니다. 메뉴 요소의 `hidden` 속성을 사용하여 닫혀 있음을 알려줍니다. 페이지의 HTML이 스냅샷되고 복원될 경우, JavaScript를 다시 실행하여 메뉴를 간단히 복원할 수 있습니다.

#figure[
```js
items = [...menu.querySelectorAll("[role=menuitem]")]; <1>

const isOpen = () => !menu.hidden; <2>
```]
1. 시작 시 메뉴 항목 목록을 가져옵니다. 이 구현은 메뉴 항목을 동적으로 추가하거나 제거하는 것을 지원하지 않습니다.
2. `hidden` 속성은 `hidden` _속성_으로 반영되므로 `getAttribute`를 사용할 필요가 없습니다.

우리 메뉴 항목도 비탭 가능하게 만들어 스스로 포커스를 관리할 수 있습니다.

#figure[
```js
items.forEach(item => item.setAttribute("tabindex", "-1"));
```]

이제 JavaScript에서 메뉴를 전환하는 기능을 구현해 보겠습니다:

#figure[
```js
function toggleMenu(open = !isOpen()) { <1>
  if (open) {
    menu.hidden = false;
    button.setAttribute("aria-expanded", "true");
    items[0].focus(); <2>
  } else {
    menu.hidden = true;
    button.setAttribute("aria-expanded", "false");
  }
}

toggleMenu(isOpen()); <3>
button.addEventListener("click", () => toggleMenu()); <4>
menuRoot.addEventListener("blur", e => toggleMenu(false)); <5>
```]
1. 원하는 상태를 지정하는 선택적 매개변수. 메뉴를 열거나 닫거나 토글하기 위해 하나의 함수를 사용할 수 있게 됩니다.
2. 열릴 때 메뉴의 첫 번째 항목에 포커스를 줍니다.
3. 현재 상태를 가지고 `toggleMenu`를 호출하여 요소 속성을 초기화합니다.
4. 버튼을 클릭할 때 메뉴를 전환합니다.
5. 포커스가 멀어지면 메뉴를 닫습니다.

이제 메뉴가 외부를 클릭할 때 닫히도록 만듭니다. 이는 네이티브 드롭다운 메뉴처럼 작동하는 멋진 동작입니다. 이는 전체 창에 대한 이벤트 리스너가 필요합니다.

이러한 종류의 리스너에 대해 주의해야 한다는 점에 유의하십시오. 구성 요소가 리스너를 추가하고 해당 구성 요소가 DOM에서 제거될 때 제거하지 않으면 리스너가 누적될 수 있습니다. 불행히도 이렇게 되면 해결하기 어려운 메모리 누수로 이어질 수 있습니다.

JavaScript에서는 요소가 제거될 때 로직을 실행하는 쉬운 방법이 없습니다. 가장 좋은 옵션은 `MutationObserver` API로 알려져 있습니다. `MutationObserver`는 매우 유용하지만, API가 다소 무겁고 약간 신비합니다. 따라서 우리의 예제에서는 사용하지 않겠습니다.

대신 이벤트 리스너가 실행될 때 해당 요소가 여전히 DOM에 있는지 확인하고, 요소가 DOM에 더 이상 존재하지 않으면 리스너를 제거하고 종료하는 간단한 패턴을 사용합니다.

이는 다소 해킹 방식의 수동 형태의 _가비지 수집_입니다. 일반적으로(대부분) 다른 가비지 수집 알고리즘의 경우 같은 방식이 적용되었습니다. 우리의 전략은 필요하지 않게 된 후의 리스너를 제거합니다. 사용자가 페이지에서 클릭할 때와 같이 자주 발생하는 이벤트가 수집하게 하여 시스템에 대해 잘 작동하도록 해야 합니다.

#figure[
```js
window.addEventListener("click", function clickAway(event) {
  if (!menuRoot.isConnected)
    window.removeEventListener("click", clickAway); <1>
  if (!menuRoot.contains(event.target)) toggleMenu(false); <2>
});
```]
1. 이 줄이 가비지 수집입니다.
2. 클릭이 메뉴 외부에서 발생할 경우 메뉴를 닫습니다.

이제 드롭다운 메뉴의 키보드 상호작용으로 넘어가겠습니다. 키보드 핸들러는 서로 비슷하고 특히 복잡하지 않기 때문에 한 번에 모두 처리하겠습니다:

#figure[
```js
const currentIndex = () => { <1>
  const idx = items.indexOf(document.activeElement);
  if (idx === -1) return 0;
  return idx;
}

menu.addEventListener("keydown", e => {
  if (e.key === "ArrowUp") {
    items[currentIndex() - 1]?.focus(); <2>

  } else if (e.key === "ArrowDown") {
    items[currentIndex() + 1]?.focus(); <3>

  } else if (e.key === "Space") {
    items[currentIndex()].click(); <4>

  } else if (e.key === "Home") {
    items[0].focus(); <5>

  } else if (e.key === "End") {
    items[items.length - 1].focus(); <6>

  } else if (e.key === "Escape") {
    toggleMenu(false); <7>
    button.focus(); <8>
  }
});
```]
1. 도와줍니다: 현재 포커스된 메뉴 항목의 인덱스를 가져옵니다(없으면 0).
2. 위 방향 화살표 키를 누를 때 이전 메뉴 항목으로 포커스를 이동합니다.
3. 아래 방향 화살표 키를 누르면 다음 메뉴 항목으로 포커스를 이동합니다.
4. 스페이스 키가 눌리면 현재 포커스된 요소를 활성화합니다.
5. Home을 누를 때 첫 번째 메뉴 항목으로 포커스를 이동합니다.
6. End를 누를 때 마지막 메뉴 항목으로 포커스를 이동합니다.
7. Escape를 누를 때 메뉴를 닫습니다.
8. 메뉴를 닫을 때 메뉴 버튼으로 포커스를 되돌립니다.

모든 기본 사항을 다루었으며, 많은 코드량인 점은 인정합니다. 그러나 공정하게도 많은 동작을 코드에 저장하는 것입니다.

이제 우리는 드롭다운 메뉴가 완벽하지 않다는 것을 인정해야 합니다. 많은 것들을 처리하지 않으며, 예를 들어 서브 메뉴를 지원하지 않거나 메뉴 항목을 동적으로 추가하거나 제거할 수 없습니다. 이렇게 추가적인 메뉴 기능이 필요하다면, GitHub에서 제공하는 `details-menu-element`와 같은 기성 라이브러리를 사용하는 것이 더 의미 있을 수 있습니다.

그러나 비교적 단순한 사용 사례로 보았을 때, 바닐라 JavaScript는 잘 작동하며, 이를 구현하는 동안 ARIA와 RSJS를 탐험할 수 있었습니다.

=== Alpine.js

이제 바닐라 JavaScript 스타일의 코드를 구조화하는 방법을 깊이 있게 살펴보았습니다. 이제 동적 행동을 애플리케이션에 추가하기 위한 실제 JavaScript 프레임워크에 관심을 두어 보겠습니다, #link("https://alpinejs.dev")[#indexed[Alpine.js]].

Alpine은 비교적 새로운 JavaScript 라이브러리로서 개발자가 HTML 내에 JavaScript 코드를 직접 삽입할 수 있도록 합니다. 기본 HTML 및 JavaScript에서 사용 가능한 `on*` 속성처럼 작동합니다. 그러나 Alpine은 내장 스크립팅 개념을 훨씬 더 확장합니다.

Alpine은 매우 널리 사용되고 있는 이전 JavaScript 라이브러리인 jQuery의 현대적 대안으로 홍보되고 있습니다. 사실, 여러분은 그것이 이러한 약속을 충족한다고 보장할 수 있습니다.

#index[Alpine.js][설치]
Alpine 설치는 매우 쉽습니다: 단일 파일로만 이루어져 있으며 종속성이 없으므로 CDN을 통해 간단히 포함하시면 됩니다:

#figure(caption: [Alpine 설치])[ ```html
<script src="https://unpkg.com/alpinejs"></script>
``` ]

NPM과 같은 패키지 관리자를 통해 설치하거나 자체 서버에서 공급받을 수도 있습니다.

#index[Alpine.js][x-data]
Alpine는 모두 `x-` 접두사로 시작하는 HTML 속성을 제공하며, 그중 핵심은 `x-data`입니다. `x-data`의 내용은 객체로 평가되는 JavaScript 표현식입니다. 이 객체의 속성은 `x-data` 속성이 위치한 요소 내에서 액세스할 수 있습니다.

AlpineJS의 맛을 보게 해주기 위해, 카운터 예제를 사용하여 이를 구현해보겠습니다.

카운터에서는 현재 숫자를 추적할 수 있는 상태만 필요하므로, 배열 속성인 `count`를 가진 JavaScript 객체를 `x-data` 속성으로 지정하겠습니다:

#figure(caption: [Alpine의 카운터, 1행]) [ ```html
<div class="counter" x-data="{ count: 0 }">
``` ]

#index[Alpine.js][x-text]
이 속성은 동적으로 DOM을 업데이트하는 데 사용할 데이터인 상태를 정의합니다. 이렇게 상태를 선언한 후 우리는 이제 그것을 _해당 div_에서 사용할 수 있습니다. `x-text` 속성을 가진 `output` 요소를 추가하겠습니다.

다음으로 우리는 부모 `div` 요소의 `x-data` 속성에 선언된 `count` 속성에 `x-text` 속성을 _바인딩_할 것입니다. 이를 통해 `output` 요소의 텍스트가 `count`의 값에 의해 설정되며, `count`가 업데이트될 경우 `output`의 텍스트도 동일하게 업데이트 결과를 제공합니다. 이는 "반응형" 프로그래밍으로, DOM이 백업 데이터 변경에 "반응"하는 것입니다.

#figure(caption: [Alpine의 카운터, 1-2행]) [ ```html
<div x-data="{ count: 0 }">
  <output x-text="count"></output> <1>
``` ]
1. `x-text` 속성.

이제 버튼을 사용하여 숫자를 업데이트해야 합니다. Alpine은 `x-on` 속성을 통해 이벤트 리스너를 부착할 수 있게 해줍니다.

리스너를 추가하려면 `x-on` 속성 이름 뒤에 콜론을 추가한 후 이벤트 이름을 추가합니다. 그런 다음, 속성의 값은 실행할 JavaScript가 됩니다. 이는 앞서 논의한 평범한 `on*` 속성과 유사하지만, 훨씬 더 유연합니다.

`click` 이벤트를 듣고 클릭이 발생할 때 `count`를 증가시켜야 하므로, Alpine 코드가 다음과 같이 보일 것입니다:

#figure(caption: [Alpine의 카운터, 전체 구현]) [ ```html
<div x-data="{ count: 0 }">
  <output x-text="count"></output>

  <button x-on:click="count++">Increment</button> <1>
</div>
```]
1. `x-on`을 통해 속성 _이름_에 이벤트를 지정합니다.

이게 전부입니다. 카운터 같은 간단한 컴포넌트는 코딩하기 쉬워야 하고, Alpine이 이를 잘 제공합니다.

==== "x-on:click" vs. "onclick"

#index[Alpine.js][x-on:click]
Alpine의 `x-on:click` 속성(또는 단축형인 `@click` 속성)은 내장 `onclick` 속성과 유사하지만, 상당히 유용한 추가 기능이 있습니다:
- 다른 요소의 이벤트를 수신할 수 있습니다. 예를 들어 `.outside` 수식어를 사용하면 _요소 내에서_ 발생하지 않은 모든 클릭 이벤트를 수신할 수 있습니다.
- 기타 수식어를 사용해:
  - 이벤트 리스너를 스로틀하거나 디바운싱할 수 있습니다.
  - 자식 요소에서 버블링된 이벤트를 무시할 수 있습니다.
  - 수동 리스너를 추가할 수 있습니다.
- 사용자 정의 이벤트를 수신할 수 있습니다. 예를 들어 `htmx:after-request` 이벤트를 수신하려면 `x-on:htmx:after-request="doSomething()"`이라고 작성할 수 있습니다.

==== 반응성 및 템플릿화

AlpineJS 버전의 카운터 위젯이 바닐라JavaScript의 구현보다 일반적으로 더 나은 점에 동의하게 될 것입니다. 이는 다소 해킹이거나 여러 파일에 걸쳐 분산되어 있기 때문입니다.

AlpineJS의 강력한 부분은 "반응형" 변수를 지원하여 `div` 요소의 `count`를 두 가지의 모든 의존성과 올바르게 업데이트할 수 있는 변수를 결합할 수 있다는 것입니다. Alpine은 우리가 여기서 시연한 것보다 훨씬 더 복잡한 데이터 바인딩을 허용하며, 훌륭한 범용 클라이언트 측 스크립팅 라이브러리입니다.

==== Alpine.js 실행 중: 일괄 작업 도구 모음 <_alpine_js_in_action_a_bulk_action_toolbar>
이번에는 Alpine을 사용하여 Contact.app에서 기능을 구현해 보겠습니다. 현재 Contact.app은 페이지 맨 아래에 "선택된 연락처 삭제" 버튼이 있습니다. 이 버튼은 긴 이름을 가지고 있으며 찾기 어렵고 많은 공간을 차지합니다. 추가 "일괄" 작업을 추가하려면 시간이 지남에 따라 시각적으로 변하지 않아야 합니다.

우리는 먼저 `x-data` 속성을 추가해야 합니다. 이는 도구 모음의 가시성을 결정하는 데 사용할 상태를 저장합니다. 이는 추가할 도구 모음과 체크박스의 조상 요소에 배치하여 체크되었을 때 상태를 업데이트하여야 하는 자신의 책임을 지게 해야 합니다. 현 시점에서 가장 적절한 선택은 연락처 테이블을 둘러싼 `form` 요소에 해당 속성을 배치하는 것입니다. 우리는 속성 `selected`를 선언할 것입니다. 이는 체크된 체크박스를 기반으로 선택된 연락처 ID를 보유하는 배열이 될 것입니다.

여기서 우리의 form 태그는 다음과 같습니다:

#figure[```html
<form x-data="{ selected: [] }"> <1>
```]
1. 이 양식은 연락처 테이블을 둘러싸고 있습니다.

#index[Alpine.js][x-if]
다음으로 연락처 테이블의 상단에 `template` 태그를 추가합니다. 템플릿 태그는 기본적으로 브라우저에서 렌더링되지 않으므로 약간 놀랄 것입니다. 그러나 Alpine 자산의 `x-if` 속성을 추가함으로써 우리는 Alpine에 조건이 참일 때 이 템플릿 내의 HTML을 표시하도록 지시할 수 있습니다.

우리가 원했던 것은 하나 이상의 연락처가 선택되었을 경우에만 도구 모음을 표시하고 싶습니다. 하지만 우리는 선택된 연락처의 ID는 `selected` 속성에 있기 때문에 확인할 수 있습니다.
따라서 우리는 쉽게 선택된 연락처의 _길이_를 확인할 수 있습니다:

#figure[```html
<template x-if="selected.length > 0"> <1>
  <div class="box info tool-bar">
    <slot x-text="selected.length"></slot>
    선택된 연락처

    <button type="button" class="bad bg color border">삭제</button> <2>
    <hr aria-orientation="vertical">
    <button type="button">취소</button> <2>
  </div>
</template>
```]
1. 선택된 연락처가 1개 이상일 경우 이 HTML을 표시합니다.
2. 이 버튼들을 바로 구현할 것입니다.

#index[Alpine.js][x-model]
다음 단계는 지정된 연락처에 대한 체크박스를 토글할 때 해당 연락처의 ID를 `selected` 속성에 추가(또는 제거)하려는 것입니다. 이를 위해 우리는 새로운 Alpine 속성인 `x-model`을 사용할 것입니다. `x-model` 속성은 주어진 요소에 대해 특정 데이터로 _바인딩_할 수 있도록 해줍니다.

이 경우 우리는 체크박스 입력의 값을 `selected` 속성에 바인딩하고 싶습니다. 우리는 다음과 같이 수행할 수 있습니다:

#figure[```html
<td>
  <input type="checkbox" name="selected_contact_ids"
    value="{{ contact.id }}" x-model="selected"> <1>
</td>
```]
1. `x-model` 속성은 이 입력의 `value`를 `selected` 속성과 바인딩합니다.

이제 체크박스가 체크되거나 체크 해제될 때, `selected` 배열이 지정된 행의 연락처 ID로 업데이트됩니다. 또한 `selected` 배열에 대한 변경사항은 체크박스의 상태에도 반영됩니다. 이를 _양방향_ 바인딩이라고 합니다.

이 코드를 작성하면 체크박스가 선택된 경우에만 도구 모음이 보였다가 사라지게 할 수 있습니다.

아주 멋집니다.

이제 우리는 도구 모음을 표시하고 숨기는 매커니즘을 구현했으니, 버튼을 살펴보겠습니다.

먼저 "Clear" 버튼을 구현해 보겠습니다. 진행할 일이 간단합니다. 버튼이 클릭되면 `selected` 배열을 지우기만 하면 됩니다. Alpine이 제공하는 양방향 바인딩 덕분에 선택된 모든 연락처를 체크 해제하고 도구 모음을 숨길 수 있습니다!

Cancel 버튼을 위한 작업은 간단합니다:

#figure[```html
<button type="button" @click="selected = []">취소</button> <1>
```]
1. `selected` 배열을 재설정합니다.

다시 말하지만, AlpineJS는 이것을 매우 쉽게 만들어 줍니다.

하지만 "삭제" 버튼은 좀 더 복잡할 겁니다. 두 가지 일을 수행해야 하기 때문입니다: 첫째, 사용자가 선택된 연락처를 정말 지우려고 하는지를 확인해야 합니다. 그런 다음, 사용자가 작업을 확인하면 htmx JavaScript API를 사용하여 `DELETE` 요청을 발송할 것입니다.

#figure[```html
<button type="button" class="bad bg color border"
  @click="
    confirm(`Delete ${selected.length} contacts?`) && <1>
    htmx.ajax('DELETE', '/contacts',
      { source: $root, target: document.body }) <2>
  ">
  삭제
</button>
```]
1. 사용자가 삭제할 연락처 수의 선택을 원하는지 확인합니다.
2. htmx JavaScript API를 사용하여 `DELETE` 요청을 발송합니다.

`confirm()` 호출이 false를 반환하면 `htmx.ajax()` 호출을 피할 수 있도록 JavaScript에서 `&&` 연산자의 단락 성격을 사용하고 있습니다.

#index[htmx][htmx.ajax()]
`htmx.ajax()` 함수는 htmx의 HTML 특성이 직접 JavaScript에서 데이터와 교환할 수 있는 방법일 뿐입니다.

우리가 `htmx.ajax`를 호출하는 방법을 살펴보면, 먼저 `/contacts`에 `DELETE`를 발급하겠다고 선언합니다. 그 다음 두 가지 추가 정보를 제공합니다: `source`와 `target`. `source` 속성은 htmx가 요청에 포함할 데이터를 수집하는 요소입니다. 우리는 이를 `$root`로 설정합니다. `$root`는 Alpine에서 이 속성이 선언된 요소를 참조합니다. 이 경우 모두 우리의 연락처를 포함한 양식이 됩니다. 응답 HTML이 위치할 `target`은 단순히 문서 본체가 됩니다. `DELETE` 핸들러가 완료될 때 전체 페이지가 반환됩니다.

여기서 우리는 HDA에 호환되는 방식으로 Alpine을 사용하고 있습니다. 우리는 직접적으로 Alpine에서 AJAX 요청을 발급하여 그 요청 결과에 따라 `x-data` 속성을 업데이트할 수 있습니다. 하지만 대신, 우리는 htmx의 JavaScript API에 위임하여 서버와 _하이퍼미디어 교환_을 수행하고 있습니다.

이것이 하이퍼미디어 친화적인 방식으로 하이퍼미디어 주도 애플리케이션 내에서 스크립팅하는 핵심입니다.

따라서 모든 것이 준비되었으니, 이제 연락처에 대한 일괄 작업을 수행하는 훨씬 개선된 경험이 생겼습니다: 시각적 혼잡을 줄이고 메뉴 막대에 추가적인 옵션을 추가하여 애플리케이션의 주요 인터페이스가 비대해지지 않도록 합니다.

=== \_hyperscript

#index[\_hyperscript]
우리가 살펴볼 마지막 스크립팅 기술은 약간 먼 분야인 \_hyperscript입니다. 이 책의 저자들은 처음에 htmx와 함께 \_hyperscript를 형제 프로젝트로 만들었습니다. 우리는 JavaScript가 이벤트 지향적이지 않다고 느꼈습니다. 이는 htmx 애플리케이션에 소규모 스크립팅 개선을 추가하는 것을 번거롭게 만들었습니다.

이전 두 예제는 JavaScript 중심이지만, \_hyperscript는 JavaScript와 완전히 다른 구문을 가지고 있으며, 이는 하이퍼카드라는 오래된 언어를 기반으로 합니다. HyperTalk는 초창기 매킨토시 컴퓨터에서 사용된 오래된 하이퍼미디어 시스템에 대한 스크립팅 언어였습니다.

\_hyperscript의 가장 두드러진 점은 다른 프로그래밍 언어보다 영어 문장과 더 흡사하다는 것입니다.

Alpine처럼 \_hyperscript는 현대의 jQuery 대체물입니다. Alpine과 마찬가지로 \_hyperscript를 HTML 내에서 인라인으로 작성할 수 있습니다.

하지만 Alpine와는 다르게, \_hyperscript는 _반응형이 아닙니다_. 대신 이벤트에 대한 반응을 기반으로 DOM 조작을 쉽게 작성하고 읽을 수 있도록 하는 데 중점을 두고 있습니다. 많은 DOM 작업에 대한 기본 언어 구성 요소가 있어 때로는 장황한 JavaScript DOM API를 탐색할 필요가 없습니다.

우리는 \_hyperscript 언어로 스크립팅이 무엇인지에 대한 작은 맛을 제공할 것이며, 만약 흥미를 느낀다면 나중에 더 깊이 탐색할 수 있습니다.

#index[\_hyperscript]
htmx와 AlpineJS처럼 \_hyperscript는 CDN 또는 npm(패키지 이름 `hyperscript.org`)에서 설치할 수 있습니다:

#figure(caption: [CDN을 통한 \_hyperscript 설치])[ ```html
<script src="//unpkg.com/hyperscript.org"></script>
``` ]

\_hyperscript는 DOM 요소에 스크립팅을 추가하는 데 `_` (언더스코어) 속성을 사용합니다. HTML 검증 요구에 따라 `script` 또는 `data-script` 속성을 사용할 수도 있습니다.

이제, 우리가 방금 살펴본 간단한 카운터 컴포넌트를 \_hyperscript을 사용하여 구현해 보겠습니다. 우리는 `output` 요소와 `button`을 `div` 내에 배치할 것입니다. 카운터를 구현하려면 버튼에 약간의 \_hyperscript를 추가해야 합니다. 클릭되는 경우 버튼은 이전 출력 태그의 텍스트를 증가시켜야 합니다.

마지막 문장은 실제 \_hyperscript 코드에 매우 가깝습니다:

#figure[```html
<div class="counter">
  <output>0</output>
  <button _="on click
    increment the textContent of the previous <output/>"> <1>
    증가
  </button>
</div>
```]
1. 버튼에 인라인으로 추가된 \_hyperscript 코드.

이 스크립트의 구성 요소를 살펴보겠습니다:
- `on click`은 클릭 이벤트를 수신하는 이벤트 리스너로, 버튼이 `click` 이벤트를 수신하고 나머지 코드를 실행하게 합니다.
- `increment`는 "증가"하는 명령어로, JavaScript에서의 `++` 연산자와 유사합니다.
- `the`는 \_hyperscript에서 의미가 없습니다. 다만 스크립트를 통해 가독성을 높일 수 있도록 사용됩니다.
- `textContent of`는 \_hyperscript에서 속성 접근을 표현하는 한 형태입니다. JavaScript 구문인 `a.b`와 같은 방식입니다.
- `previous`는 조건에 맞는 이전 요소를 찾아주는 표현식입니다.
- `<output />`는 CSS 선택자를 `<`와 `/>`로 감싼 _쿼리 리터럴_입니다.

이 코드에서 `previous` 키워드(및 동반하는 `next` 키워드는) \_hyperscript가 DOM 작업을 쉽게 만들어주는 방법 중 하나의 예입니다. 이는 표준 DOM API에서 찾을 수 없는 기능이며, VanillaJS를 사용하여 구현하는 것은 생각보다 더 어려운 작업입니다!

따라서 \_hyperscript는 표현력이 뛰어나고 특히 DOM 조작과 관련하여 쉽게 작성할 수 있도록 합니다. 이는 HTML에 직접 스크립트를 삽입하기 훨씬 쉬워집니다: 스크립트 언어가 더 강력하므로 그 안에 작성된 스크립트는 일반적으로 더 짧고 읽기 쉽습니다.

#sidebar[자연어 프로그래밍?][
숙련된 프로그래머는 \_hyperscript에 의심을 가질 수 있습니다: 많은 "자연어 프로그래밍" (NLP) 프로젝트는 비 프로그래머 및 초보 프로그래머를 대상으로 하며, 그들이 "자연어"로 코드를 읽을 수 있다면 그만큼 코드를 작성할 수 있다고 가정하였습니다. 이는 불행히도 형편없이 작품이 잘 쓰여지지 않았고 구조가 부실한 코드로 이어졌습니다. 

\_hyperscript는 _자연어 NLP 프로그래밍 언어가 아닙니다. 네, 그 구문은 이후 웹 개발자의 말을 떠올리는 것들이 많은 곳에서 영감을 받았습니다. 하지만 \_hyperscript의 가독성은 복잡한 휴리스틱이나 모호한 NLP 처리 덕분이 아니라, 공통 구문 처리 기술을 잘 활용하고 읽기와 가독성을 높일 수 있도록 한 문화적 발상 덕분입니다.

앞서 예시에서 본 것처럼, _쿼리 참조_ `<output/>`를 사용함으로 \_hyperscript는 적절한 경우 DOM에서 비자연 언어를 사용하기를 주저하지 않습니다.]

==== \_hyperscript 작동 중: 키보드 단축키 <_hyperscript_in_action_a_keyboard_shortcut>
카운터 데모는 다양한 스크립팅 접근법을 비교하기에 좋은 방법이지만, 실제 유용한 기능을 구현하려 할 때 그 rubber meets the road에서는 다릅니다. \_hyperscript에서 Contact.app에 키보드 단축키를 추가해 보겠습니다: 사용자가 Alt+S를 누르면 검색 필드에 포커스를 줍니다.

우리의 키보드 단축키가 검색 입력을 포커스하기 때문에, 그것에 대한 코드가 해당 검색 입력에 있어야 하며, 지역성을 충족합니다.

검색 입력을 위한 원래 HTML은 다음과 같습니다:

#figure[```html
<input id="search" name="q" type="search" placeholder="연락처 검색">
```]

#index[\_hyperscript][이벤트 리스너]
#index[\_hyperscript][이벤트 필터]
#index[\_hyperscript][필터 표현식]
우리는 `on keydown` 구문을 사용하여 이벤트 리스너를 추가할 것입니다. 이는 키가 눌리면 발생하게 됩니다. 또한 \_hyperscript의 이벤트 필터 구문을 사용하여 이벤트 발생이 필요하지 않을 때 이벤트가 무시되게 할 수 있습니다. 이 경우 누를 키보드가 Alt키가 눌려져 있을 때와 "S" 키가 눌리는 조건만 고려하고자 합니다. 우리는 `altKey` 속성이 true인지, 이벤트의 `code` 속성이 "KeyS"인지를 확인하는 부울 표현식을 명시할 수 있습니다.

지금까지 우리의 \_hyperscript 코드는 다음과 같습니다:

#figure(caption: [우리의 키보드 단축키 시작])[
```hyperscript
on keydown[altKey and code is 'KeyS'] ...
``` ]

#index[\_hyperscript][from]
이제 기본적으로 \_hyperscript는 선언된 요소의 _이벤트를 수신합니다_. 우리의 스크립트로는 검색 박스가 이미 포커스되어 있지 않는 한 `keydown` 이벤트를 수신할 수 없습니다. 우리는 이를 _전역적으로_ 작동시키고자 합니다. 이 경우, 이벤트 리스너에 `from` 구문을 추가하여 이를 해결할 수 있습니다. 이번 경우 키보드 다운을 윈도우에서 받길 원하며, 우리의 코드는 자연스럽게 다음과 같이 보이게 됩니다:

#figure(caption: [전역에서 리스닝하기])[
```hyperscript
on keydown[altKey and code is 'KeyS'] from window ...
``` ]

`from` 구문을 사용하여, 우리는 윈도우에 리스너를 추가하면서, 이를 다시 연결한 요소에 걸맞게 코드를 유지할 수 있습니다.

이제 포커스할 검색 상자의 키 이벤트를 선택했으므로, 표준 `.focus()` 메소드를 호출하여 실제 포커스를 구현해 봅시다.

다음은 전체 스크립트로 HTML에 내장되어 있습니다:

#figure(caption: [우리의 최종 스크립트])[
```html
<input id="search" name="q" type="search" placeholder="연락처 검색"
  _="on keydown[altKey and code is 'KeyS'] from the window
    focus() me"> <1>
``` ]
1. "me"는 스크립트가 작성된 요소를 나타냅니다.

모든 기능을 갖춘 이 구현은 놀랍도록 간결하고, 영어 기반 프로그래밍 언어로서 읽기 쉽습니다.

==== 왜 새로운 프로그래밍 언어인가? <_why_a_new_programming_language>
이번에는 모든 것이 괜찮지만 "전혀 새로운 스크립팅 언어? 너무 과한 것 같다."고 느낄 수 있습니다. 어느 정도 당신이 맞습니다: JavaScript는 좋은 스크립팅 언어이며, 잘 최적화돼 있습니다. 또한 웹 개발에서 널리 이해되고 있습니다. 반면, 새로운 프론트 엔드 스크립팅 언어를 만들면서 우리는 JavaScript에서 발생한 소란스러운 코드에서 문제가 되는 일부를 해결할 자유를 얻었으며:

/ 비동기 투명성: #[
  #index[\_hyperscript][async transparency] \_hyperscript에서 비동기 함수(즉, 'Promise' 인스턴스를 반환하는 함수)는 _동기적인 방법으로_ 호출될 수 있습니다. 함수가 동기에서 비동기으로 변경되는 경우 \_hyperscript 코드가 이를 호출하는 것을 중단하지 않습니다. 이는 모든 표현이 `Promise`를 고려하도록 하고 어떤 경우에는 현재 실행 중인 스크립트를 유보하고 주 스레드를 차단하지 않도록 입수됩니다. 대조적으로, JavaScript에서는 명시적인 콜백을 사용하거나 명시적인 `async` 주석을 사용해야 하며, 이는 동기 코드를 섞지 않고 사용할 수 없습니다.
]

/ 배열 속성 접근: #[
  #index[\_hyperscript][array property access] \_hyperscript에서는 배열에서 속성을 액세스할 경우(길이 또는 숫자가 아닌 경우) 배열의 각 구성 요소에 대한 속성 값을 배열 형태로 반환하여, 배열 속성 접근이 평면-맵 작업처럼 작동합니다. jQuery에서는 유사한 기능이 있지만, 자신의 Data Structure에만 용이합니다.
]

/ 네이티브 CSS 구문: #[
  #index[\_hyperscript][native CSS syntax] \_hyperscript에서는 JavaScript에서와는 달리 CSS 클래스 및 ID 리터럴 또는 CSS 쿼리 리터럴을 직접 사용할 수 있습니다.
]

/ 깊이 있는 이벤트 지원: #[
  #index[\_hyperscript][event support] \_hyperscript에서 이벤트를 처리하는 것은 JavaScript에서 취급할 때보다 훨씬 좋으며, 이벤트를 수신하거나 전송할 수 있는 기본 지원과 함께 "디바운싱" 또는 속도를 조정한 이벤트와 같은 일반적인 이벤트 처리 패턴을 제공합니다. \_hyperscript 또한 주어진 요소와 여러 요소 간에 이벤트를 동기화하는 선언적 메커니즘을 제공합니다.
]

우리는 이 예가 하이퍼미디어 주도 애플리케이션의 경계를 넘어서는 것을 바라는 것은 아니며, 대신 클라이언트 측 기능이 사용자와 제어할 수 있게 하는 것이 기간이 짧도록 하여 여유롭게 접근할 수 있습니다. 우리는 많은 내부 상태를 DOM 외부에 두지 않거나 비하이퍼미디어 교환으로 서버와 대화하지 않도록 사용해야 합니다.

게다가, \_hyperscript가 HTML에 매우 잘 내장되기 때문에 초점은 _하이퍼미디어_에 유지되고 스크립팅 논리에 두지 않게 됩니다.

모든 스크립트 스타일이나 필요에 맞지는 않겠지만, \_hyperscript는 하이퍼미디어 주도 애플리케이션에 좋은 스크립팅 경험을 제공할 수 있습니다. 간단하고 불분명한 프로그래밍 언어의 특징을 잘 이해하고발전시키면 누가 과감해지고 충분히 긴박하게 나아가야 하며 관심과 좋아하는 기회를 가지고 더 많은 고급 스크립팅 언어를 목표로 삼기를 바랍니다.

=== 기성 구성 요소 사용하기 <_using_off_the_shelf_components>
이제 하이퍼미디어 주도 애플리케이션을 향상시키기 위해 _당신이_ 작성하는 코드의 세 가지 구성 요소에 대해 살펴보았습니다. 하지만 클라이언트 측 스크립팅에 관계된 또 다른 주요 분야가 있습니다: "재고" 구성 요소입니다. 즉, 다른 사람들이 생성한 JavaScript 라이브러리로 어떤 형태의 기능을 제공합니다.

#index[구성 요소들]
구성 요소는 웹 개발 세계에서 매우 인기가 높아지면서 #link("https://datatables.net/")[DataTables]와 같은 라이브러리를 제공하여 사용자가 쉽게 JavaScript 코드를 작성하지 않고도 풍부한 사용자 경험을 제공합니다. 그러나 이러한 라이브러리가 웹사이트에 잘 통합되지 않는다면 어플리케이션이 "조합된 느낌"을 줄 수 있습니다. 게다가, 일부 라이브러리는 단순한 DOM 조작을 넘어 서버 엔드포인트와 통합해야 하며, 거의 언제나 JSON 데이터 API와 연결되기를 요구합니다. 이는 특정 위젯이 다른 것을 요구하게 되는 것처럼, 하이퍼미디어 주도 애플리케이션을 만드는 방법이 아니게 됩니다. 아쉽습니다!

#sidebar[웹 컴포넌트][
웹 컴포넌트는 몇 가지 표준; 사용자 정의 요소, 그림자 DOM, `<template>` 및 `<slot>`의 집합적인 명칭입니다.

#index[웹 구성 요소]
이 모든 표준들은 유용한 기능을 테이블에 가져옵니다. `<template>` 요소는 그 내용물을 문서에서 제거하지만 HTML로 파싱 중에(댓글처럼 아님) JavaScript에 접근할 수 있도록 합니다. 사용자 정의 요소는 추가하거나 제거 될 때 요소에 기능의 초기화와 철수를 가능하게 하여, 수동적인 작업이나 MutationObservers를 요구하지 않습니다. 그림자 DOM은 요소들을 캡슐화하여 "빛" (비그림자) DOM을 깨끗하게 유지하도록 합니다.

하지만 이러한 이점을 얻는 것은 종종 좌절스럽습니다. 이러한 어려움은 단순히 새로운 표준(그림자 DOM의 접근성 문제와 같은 성장통)이 요구하는 발전에 대한 문제일 수 있습니다. 다른 문제들은 웹 구성 요소가 동시에 너무 많은 것을 시도하는 결과입니다:

- HTML의 확장 메커니즘. 이 목적을 위해 각 사용자 정의 요소는 언어에 추가되는 태그입니다.
- Behaviors에 대한 라이프사이클 메커니즘. `createdCallback`, `connectedCallback` 등과 같은 메소드들은 요소가 추가될 때 직접적으로 수동적으로 동작할 수 있게 할 수 있습니다.
- 캡슐화를 위한 단위. Shadow DOM은 요소들을 그 주위의 영향을 차단합니다.

결과적으로 이러한 요소 중 하나를 원한다면 저것들이 합쳐지는 것을 피해야만 합니다. 특정 요소에 행동을 추가하기 위해 라이프사이클 콜백을 사용하고자 한다면 새로운 태그를 만들어야 하며, 이는 한 요소에 여러 행동을 추가할 수 없게 만드는 문제를 초래하며, 또한 이미 추가된 요소들로부터 링크할 필요성을 가진 요소들을 차단하게 됩니다.

웹 컴포넌트를 언제 사용해야 할까요? 좋은 규칙은 "이것이 합리적으로 내장 HTML 요소가 될 수 있을까?"라고 스스로에게 물어보는 것입니다. 예를 들어, 코드 편집기는 좋은 후보입니다. 이미 HTML에는 `<textarea>`와 `contenteditable` 요소가 있기 때문입니다. 또한, 완전한 기능을 갖춘 코드 편집기는 많은 자식 요소를 포함할 것이며, 이들은 그다지 많은 정보를 제공하지 않을 것입니다. 우리는 이러한 요소들을 캡슐화하기 위해 #link(
  "https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM",
)[Shadow DOM]와 같은 기능을 사용할 수 있습니다#footnote[Shadow DOM은 현재 작성 시점에서 개발 중인 최신 웹 플랫폼 기능입니다. 특히, shadow root 내부와 외부의 요소가 상호작용할 때 발생할 수 있는 접근성 오류가 있습니다.]. 우리는 원하는 경우 언제든지 페이지에 드롭할 수 있는 #link(
  "https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_custom_elements",
)[custom element], 즉 `<code-area>`를 만들 수 있습니다.

==== 통합 옵션 <_integration_options>
하이퍼미디어 기반 애플리케이션을 구축할 때 가장 잘 작동하는 자바스크립트 라이브러리는 다음과 같은 특성을 가진 것들입니다:
- DOM을 수정하지만 JSON을 통해 서버와통신하지 않는 것
- HTML 규범을 존중하는 것 (예: 값을 저장하기 위한 `input` 요소 사용)
- 라이브러리에서 여러 커스텀 이벤트를 트리거하는 것

마지막 포인트인 여러 커스텀 이벤트를 트리거하는 것은 특히 중요합니다. 이는 이러한 커스텀 이벤트가 추가적인 스크립팅 언어로 작성된 코드 없이 전달되거나 들을 수 있기 때문입니다.

JavaScript 콜백을 사용하는 접근 방식과 이벤트를 사용하는 접근 방식 두 가지를 살펴봅시다.

#index[SweetAlert2]
구체적으로, 이전 섹션의 Alpine에서 생성한 `DELETE` 버튼에 대한 더 나은 확인 대화 상자를 구현해보겠습니다. 원래 예제에서는 시스템의 기본 확인 대화 상자를 보여주는 자바스크립트의 `confirm()` 함수를 사용했습니다. 이 함수를 SweetAlert2라는 인기 있는 자바스크립트 라이브러리로 교체하여 훨씬 더 보기 좋은 확인 대화 상자를 보여주겠습니다. `confirm()` 함수와 달리, 블록하고 Boolean을 반환하는(`user confirmed`인 경우 `true`, 그렇지 않은 경우 `false`) SweetAlert2는 비동기 작업(예: 사용자가 작업을 확인하거나 거부할 때까지 기다리는 과정)이 완료되면 콜백을 연결하기 위한 자바스크립트 메커니즘인 `Promise` 객체를 반환합니다.

===== 콜백을 사용한 통합 <_integrating_using_callbacks>
SweetAlert2 라이브러리가 설치되면 `Swal` 객체에 접근할 수 있으며, 이 객체에는 경고를 표시하는 `fire()` 함수가 있습니다. `fire()` 메서드에 인수를 전달하여 확인 대화 상자의 버튼 모양, 대화 상자의 제목 등을 정확히 구성할 수 있습니다. 이러한 세부 사항에 대해서는 자세히 설명하지 않겠지만, 곧 대화 상자가 어떻게 생겼는지 보실 수 있습니다.

따라서 SweetAlert2 라이브러리를 설치했으므로 `confirm()` 함수 호출을 대신 교체할 수 있습니다. 그런 다음 `Swal.fire()`가 반환하는 `Promise`의 `then()` 메서드에 _콜백_을 전달하도록 코드를 재구성해야 합니다. `Promise`에 대한 자세한 설명은 이 장의 범위를 넘어섭니다. 그러나 이 콜백은 사용자가 작업을 확인하거나 거부할 때 호출된다고 말할 수 있습니다. 사용자가 작업을 확인한 경우 `result.isConfirmed` 속성은 `true`가 됩니다.

그런 모든 것을 감안할 때, 업데이트된 코드는 다음과 같이 보일 것입니다:

#figure(
  caption: [콜백 기반 확인 대화 상자],
)[ ```html
<button type="button" class="bad bg color border"
  @click="Swal.fire({ <1>
    title: '이 연락처들을 삭제할까요?', <2>
    showCancelButton: true,
    confirmButtonText: '삭제'
  }).then((result) => { <3>
    if (result.isConfirmed) htmx.ajax('DELETE', '/contacts',
        { source: $root, target: document.body })
  });"
>삭제</button>
``` ]
1. `Swal.fire()` 함수를 호출합니다.
2. 대화 상자를 구성합니다.
3. 사용자의 선택 결과를 처리합니다.

이제 이 버튼이 클릭되면 우리의 웹 애플리케이션에서 멋진 대화 상자를 얻게 됩니다 (@fig-swal-screenshot) --- 시스템 확인 대화 상자보다 훨씬 나아 보입니다. 그럼에도 불구하고 이건 좀 잘못된 기분이 듭니다. 조금 더 나은 `confirm()`를 호출하기 위해 이렇게 많은 코드를 작성해야 하는 건가요? 그리고 여기서 사용하고 있는 htmx JavaScript 코드는 어색합니다. htmx를 버튼의속성으로 이동해 왔던 방식으로 할 수 있다면 더 자연스러울 것이고, 그런 다음 이벤트를 통해 요청을 트리거할 수 있습니다.

#figure(
  image("images/screenshot_sweet_alert.png"),
  caption: [SweetAlert 대화 상자]
)<fig-swal-screenshot>

그럼 다른 접근 방식을 취해 어떻게 보이는지 살펴봅시다.

===== 이벤트를 사용하여 통합 <_integrating_using_events>
이 코드를 정리하기 위해, `Swal.fire()` 코드를 우리가 만들 `sweetConfirm()`라는 사용자 정의 JavaScript 함수로 끌어낼 것입니다. `sweetConfirm()`는 `fire()` 메서드에 전달된 대화 상자 옵션과 작업을 확인하는 요소를 가져옵니다. 여기서 큰 차이점은 새 `sweetConfirm()` 함수가 htmx를 직접 호출하는 대신, 사용자가 삭제하기를 원한다고 확인했을 때 버튼에서 `confirmed` 이벤트를 트리거한다는 것입니다.

이것이 우리의 JavaScript 함수입니다:

#figure(caption: [이벤트 기반 확인 대화 상자])[
```javascript
function sweetConfirm(elt, config) {
  Swal.fire(config) <1>
    .then((result) => {
      if (result.isConfirmed) {
        elt.dispatchEvent(new Event('confirmed')); <2>
      }
    });
}
``` ]
1. 구성 정보를 `fire()` 함수로 전달합니다.
2. 사용자가 작업을 확인했을 경우 `confirmed` 이벤트를 트리거합니다.

이 방법이 가능해짐에 따라, 이제 삭제 버튼을 꽤 많이 간소화할 수 있습니다. `@click` Alpine 속성에 있던 모든 SweetAlert2 코드를 제거하고, 이 새로운 `sweetConfirm()` 메서드를 호출하여 `$el` 인수를 전달할 수 있습니다. `$el`은 스크립트가 위치한 "현재 요소"를 가져오는 Alpine 구문이며, 대화 상자에 원하는 정확한 구성을 전달할 수 있습니다.

사용자가 작업을 확인하면 버튼에서 `confirmed` 이벤트가 트리거됩니다. 이는 우리가 신뢰할 수 있는 htmx 속성을 다시 사용할 수 있다는 것을 의미합니다! 즉, `DELETE`를 `hx-delete` 속성으로 이동하고, `hx-target`으로 본문을 지정할 수 있습니다. 그리고 여기서 중요한 단계는 `sweetConfirm()` 함수에서 발생하는 `confirmed` 이벤트를 요청을 트리거하는 데 사용할 수 있다는 점입니다. 이를 위해 `hx-trigger`를 추가합니다.

우리의 코드는 다음과 같습니다:

#figure(caption: [이벤트 기반 확인 대화 상자])[
```html
<button type="button" class="bad bg color border"
  hx-delete="/contacts" hx-target="body" hx-trigger="confirmed" <1>
  @click="sweetConfirm($el, { <2>
    title: '이 연락처들을 삭제할까요?', <3>
    showCancelButton: true,
    confirmButtonText: '삭제'
  })">
``` ]
1. 우리의 htmx 속성이 돌아왔습니다.
2. 버튼을 함수에 전달하여, 버튼에서 이벤트를 트리거할 수 있게 합니다.
3. SweetAlert2 구성 정보를 전달합니다.

#index[htmx patterns][이벤트 전달을 위한 래핑]
보시다시피, 이 이벤트 기반 코드는 훨씬 더 깔끔하고 확실히 더 "HTML적"입니다. 이 깔끔한 구현의 핵심은 새 `sweetConfirm()` 함수가 htmx가 들을 수 있는 이벤트를 발생시킨다는 것입니다.

이것이 바로 라이브러리를 선택할 때 풍부한 이벤트 모델이 중요한 이유입니다. 이는 htmx와 일반적으로 하이퍼미디어 기반 애플리케이션 모두에 해당됩니다.

안타깝게도 오늘날 JavaScript 중심의 사고방식이 만연하고 지배적이기 때문에, 많은 라이브러리는 SweetAlert2와 같습니다: 첫 번째 스타일의 콜백을 전달할 것으로 예상합니다. 이러한 경우, 이곳에서 데모한 기술을 사용하여 라이브러리를 이벤트를 트리거하는 콜백으로 래핑하여 라이브러리를 보다 하이퍼미디어 및 htmx 친화적으로 만드는 것이 가능할 수 있습니다.

=== 실용적인 스크립팅 <_pragmatic_scripting>
#blockquote(
  attribution: [W3C, HTML 디자인 원칙 § 3.2 우선 순위],
)[
  충돌이 발생할 경우, 사양자보다 구현자, 구현자보다 저자, 저자보다 사용자, 이론적 순수성보다 사용자를 고려하십시오.
]

우리는 하이퍼미디어 기반 애플리케이션에서 스크립팅을 위한 여러 도구 및 기술을 살펴보았습니다. 이 중에서 어떤 것을 선택해야 할까요? 이 질문에 대한 단일하고 항상 올바른 답변은 결코 없을 것입니다.

순수한 자바스크립트 전용에 전념하고 계신가요? 그렇다면 하이퍼미디어 기반 애플리케이션을 스크립팅하기 위해 기존의 자바스크립트를 효과적으로 사용할 수 있습니다.

더 자유롭고 Alpine.js의 모양이 마음에 드시나요? 이는 애플리케이션에 좀 더 구조화된, 지역화된 자바스크립트를 추가하는 훌륭한 방법이며, 몇 가지 멋진 반응형 기능도 제공합니다.

기술 선택에 있어 좀 더 대담하신 편인가요? 그렇다면 \_hyperscript를 살펴보는 것도 좋습니다. (저희는 분명 그렇다고 생각합니다.)

때로는 애플리케이션 내에서 이러한 접근 방식을 두 개(또는 더 많이) 선택하는 것도 고려할 수 있습니다. 각각은 고유한 강점과 약점을 가지고 있으며 모두 상대적으로 작고 독립적이기 때문에, 해당 작업에 적합한 도구를 선택하는 것이 최선의 접근 방식일 수 있습니다.

일반적으로 우리는 스크립팅에 걸쳐 _실용적인_ 접근을 권장합니다: 무엇이 적절하게 느껴지든 아마도 적절할 것입니다 (혹은 적어도, 당신에게 충분히 올바른). 특정 스크립팅 접근 방식을 취하는 데 우려하기보다는, 더 일반적인 문제에 집중하는 것이 좋습니다:
- JSON 데이터 API를 통해 서버와 통신하지 마십시오.
- DOM 외부에 대량의 상태를 저장하지 마십시오.
- 하드코딩된 콜백이나 메서드 호출보다는 이벤트 사용을 선호하십시오.

그리고 이러한 주제들에 대해서도, 때때로 웹 개발자는 웹 개발자가 해야 할 일을 해야 합니다. 애플리케이션에 완벽한 위젯이 존재하므로 JSON 데이터 API를 사용하나요? 괜찮습니다.

다만 그것을 습관으로 만들지는 마십시오.

#html-note[HTML은 애플리케이션을 위한 것입니다][
  개발자들 사이에서 널리 퍼진 귀신 같은 메모는 HTML이 "문서"를 위해 설계되었으며 "애플리케이션"에 적합하지 않다는 것입니다. 하지만 실제로는 하이퍼미디어가 애플리케이션을 위한 정교하고 현대적인 아키텍처일 뿐만 아니라, 이 인공적인 앱/문서 분할을 영원히 없앨 수 있도록 해 줍니다.

  #blockquote(
    attribution: [Roy Fielding, #link(
        "https://www.slideshare.net/royfielding/a-little-rest-and-relaxation",
      )[A little REST and Relaxation]],
  )[
    내가 하이퍼텍스트라고 말할 때, 정보와 컨트롤을 동시에 제공하여 정보가 사용자가 선택과 행동을 선택할 수 있는 수단이 된다는 것을 의미합니다.
  ]

  HTML은 문서에 이미지, 오디오, 비디오, 자바스크립트 프로그램, 벡터 그래픽, (일부 도움으로) 3D 환경을 포함하는 풍부한 멀티미디어를 허용합니다. 그러나 더 중요한 것은, 이러한 문서 안에 대화형 컨트롤을 포함할 수 있게 해 준다는 점입니다. 정보를 통해 접근할 수 있는 앱을 직접 제공합니다.

  생각해 보세요: 모든 종류의 컴퓨터와 운영 체제에서 작동하는 단일 애플리케이션이 뉴스 읽기, 영상 통화, 문서 작성, 가상 세계 진입, 거의 모든 일상적인 컴퓨팅 작업을 수행할 수 있도록 할 수 있다는 것이 아닙니까?

  불행히도 HTML의 대화형 기능은 가장 덜 발전된 측면입니다. 우리에게 알려지지 않은 이유로 HTML은 5버전으로 발전했고 많은 게임 체인징 기능을 축적했습니다. 그럼에도 불구하고 그 안의 데이터 상호작용은 여전히 링크와 폼으로 제한됩니다. HTML을 확장하는 것은 개발자에게 달려 있으며, 우리는 그 과정에서 HTML의 단순함을 고전적인 "네이티브" 툴킷의 모방으로 추상화하지 않기를 원합니다.

  #blockquote(
    attribution: [Leah Clark, \@leah\@tilde.zone],
  )[
    - #smallcaps[소프트웨어는 네이티브 툴킷을 사용해야 하지 않았다]

    - #smallcaps[UI 라이브러리를 수년간 만들었지만] #smallcaps[웹보다 더 낮은 수준에서 사용할 수 있는 실제 세계의 사용은 발견되지 않았다]

    - 어쨌든 웃기려고 하셨나요? 우리는 "#smallcaps[Electron]"이라는 도구가 있었습니다.

    - "네, 저는 같은 UI의 4 #smallcaps[다른] 복사본을 작성하고 싶습니다." - 완전히 엉뚱한 사람들의 발언
  ]
]
