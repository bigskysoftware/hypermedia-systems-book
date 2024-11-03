#import "lib/definitions.typ": *

== 동적 아카이브 UI

Contact.app는 전통적인 웹 1.0 스타일의 웹 애플리케이션에서 많은 발전을 이루었습니다: 우리는 능동 검색, 일괄 삭제, 몇 가지 멋진 애니메이션 및 기타 여러 기능을 추가했습니다. 우리는 대부분의 웹 개발자가 어떤 종류의 단일 페이지 애플리케이션(JavaScript 프레임워크가 필요하다고 가정할) 요구되는 상호작용 수준에 도달했지만, 우리는 대신 htmx 기반의 하이퍼미디어를 사용하여 이를 구현했습니다.

#index[htmx 패턴][다운로드 아카이브]
Contact.app에 최종적인 중요한 기능인 모든 연락처의 아카이브 다운로드를 추가하는 방법을 살펴보겠습니다.

하이퍼미디어 관점에서 파일 다운로드는 아주 간단한 작업입니다: HTTP `Content-Disposition` 응답 헤더를 사용하면 브라우저에 파일 다운로드 및 로컬 컴퓨터에 저장하도록 쉽게 지시할 수 있습니다.

그러나 이 문제를 좀 더 흥미롭게 만들어 보겠습니다: 내보내는데 5초에서 10초, 때론 더 오랜 시간이 걸릴 수 있다는 사실을 추가해 보겠습니다.

이것은 우리가 다운로드를 "정상" HTTP 요청으로 구현한다면, 링크나 버튼에 의해 유도될 경우, 사용자가 거의 시각적 피드백 없이 다운로드가 실제로 진행되고 있는지 궁금해하며 꽤 오랫동안 기다리게 된다는 것을 의미합니다. 그들은 심지어 좌절감을 느끼고 다운로드 하이퍼미디어 컨트롤을 다시 클릭하여 _두 번째_ 아카이브 요청을 발생시킬 수도 있습니다. 좋지 않습니다.

이것은 웹 앱 개발에서 고전적인 문제로 판명됩니다. 이렇게 장시간 실행될 가능성이 있는 프로세스에 직면했을 때, 우리는 궁극적으로 두 가지 옵션이 있습니다:
- 사용자가 작업을 트리거하면 완료될 때까지 차단하고 결과로 응답합니다.
- 작업을 시작하고 즉시 응답하여 진행 중임을 나타내는 UI를 표시합니다.

작업 완료를 위해 차단하고 기다리는 것은 분명히 더 간단한 처리 방법이지만, 작업이 완료되는 데 시간이 걸리면 나쁜 사용자 경험이 될 수 있습니다. 웹 1.0 스타일의 애플리케이션에서 뭔가를 클릭하고 아무 일이 일어나기까지 영원히 기다려야 했던 경험이 있다면, 여러분은 이 선택의 실제 결과를 보았던 것입니다.

두 번째 옵션인 비동기적으로 작업을 시작하는 것은 사용자 경험 관점에서 훨씬 더 좋습니다: 서버가 즉시 응답할 수 있고 사용자는 무슨 일이 일어나고 있는지 궁금해하면서 기다릴 필요가 없습니다.

하지만 문제는, 우리가 무엇으로 응답해야 할까요? 작업이 아마도 아직 완료되지 않았으므로 결과에 대한 링크를 제공할 수 없습니다.

이 상황에서는 다양한 웹 애플리케이션에서 몇 가지 "간단한" 접근 방식을 보았습니다:
- 프로세스가 시작되었다는 사실을 사용자에게 알리고, 완료된 프로세스 결과에 대한 링크가 이메일로 전송될 것이라고 알려줍니다.
- 프로세스가 시작되었다고 알리고, 수동으로 페이지를새로고침하여 프로세스의 상태를 확인하도록 추천합니다.
- 프로세스가 시작되었다고 알리고, JavaScript를 이용해 몇 초마다 페이지를 자동으로 새로 고칩니다.

이 모든 접근 방식은 작동하지만, 사용자 경험이 뛰어난 것은 아닙니다.

이 시나리오에서 우리가 _정말_ 원하는 것은 브라우저를 통해 큰 파일을 다운로드 받을 때와 비슷한 것입니다: 처리 과정에서 자신이 위치하고 있는 부분을 표시하는 멋진 진행 표시줄과 프로세스가 완료되었을 때 즉시 결과를 볼 수 있도록 클릭할 수 있는 링크입니다.

이것은 하이퍼미디어로 구현하기에는 불가능할 것처럼 들릴 수 있으며, 솔직히 말해서 이 모든 기능을 구현하기 위해 htmx를 꽤 열심히 활용해야 하겠지만, 막상 구현하게 되면 생각보다 많은 코드가 필요하지 않으며 이 아카이빙 기능에서 원하는 사용자 경험을 달성할 수 있습니다.

=== UI 요구 사항 <_ui_requirements>
구현에 들어가기 전에, 우리의 새로운 UI가 어떻게 생겼으면 좋겠는지 전반적으로 이야기해 봅시다: "연락처 아카이브 다운로드"라는 레이블이 붙은 버튼이 애플리케이션에 필요합니다. 사용자가 그 버튼을 클릭하면 아카이빙 프로세스의 진행 상황을 보여주는 UI로 버튼을 교체하고, 이상적으로는 진행 표시줄과 함께 교체하고 싶습니다. 아카이브 작업이 진행되면서, 우리는 진행 표시줄을 완료 시점으로 이동시키고 싶습니다. 그런 다음 아카이브 작업이 완료되면, 사용자에게 연락처 아카이브 파일을 다운로드할 수 있는 링크를 보여주고자 합니다.

#index[아카이버]
실제로 아카이빙을 수행하기 위해, 필요한 모든 기능을 구현하는 `Archiver`라는 파이썬 클래스를 사용할 것입니다. `Contact` 클래스와 마찬가지로, `Archiver`의 구현 세부 사항에 대해서는 이 책의 범위를 벗어나므로 들어가지 않을 것입니다. 현재 필요한 것은 연락처 아카이브 프로세스를 시작하고 그 프로세스가 완료되었을 때 결과를 가져오는 데 필요한 모든 서버 측 동작을 제공한다는 것입니다.

`Archiver`는 다음과 같은 메서드를 제공합니다:
- `status()` - 다운로드 상태를 나타내는 문자열로, `Waiting`, `Running`, 또는 `Complete`
- `progress()` - 아카이브 작업의 진행 정도를 나타내는 0과 1 사이의 숫자
- `run()` - 새로운 아카이브 작업을 시작합니다 (현재 상태가 `Waiting`일 때)
- `reset()` - 현재 아카이브 작업을 취소하고, "Waiting" 상태로 재설정합니다
- `archive_file()` - 서버에서 생성된 아카이브 파일의 경로, 따라서 클라이언트로 보낼 수 있습니다
- `get()` - 현재 사용자에 대한 Archiver를 가져오는 클래스 메서드

상당히 복잡하지 않은 API입니다.

API의 유일한 다소 까다로운 점은 `run()` 메서드가 _비차단적_이라는 점입니다. 즉, 아카이브 파일을 _즉시_ 생성하는 것이 아니라, 실제 아카이빙을 수행하기 위해 백그라운드 작업(스레드로)을 시작합니다. 이는 코드에서 멀티스레딩에 익숙하지 않은 경우 혼란스럽게 느껴질 수 있습니다: `run()` 메서드가 "차단되기를" 기대할 수 있습니다. 즉, 전체 내보내기를 실제로 실행하고 완료될 때만 반환할 것이라는점입니다. 그러나 그렇게 된다면 아카이브 프로세스를 시작하고 즉시 원하는 아카이브 진행 UI를 렌더링할 수 없게 됩니다.

=== 구현 시작하기 <_beginning_our_implementation>
이제 UI 구현을 시작하는 데 필요한 모든 것을 갖추었습니다: 어떤 모양일지에 대한 적절한 개요와 이를 지원하는 도메인 로직이 있습니다.

시작하자면, 이 UI는 대부분 독립적으로 구성됩니다: 우리는 버튼을 다운로드 진행 표시줄로 교체하고, 그런 다음 진행 표시줄을 완료된 아카이브 프로세스의 결과를 다운로드할 수 있는 링크로 교체하고 싶습니다.

아카이브 사용자 인터페이스가 UI의 특정 부분 내에 모두 있을 것이라는 사실은 우리가 이를 처리하기 위한 새로운 템플릿을 생성해야 한다는 강력한 힌트입니다. 이 템플릿은 `archive_ui.html`이라고 부르겠습니다.

또한, 여러 경우에 전체 다운로드 UI를 교체해야 한다는 것도 주목하십시오:
- 다운로드를 시작할 때 버튼을 진행 표시줄로 교체합니다.
- 아카이브 프로세스가 진행되면서 진행 표시줄을 교체/업데이트합니다.
- 아카이브 프로세스가 완료되면 진행 표시줄을 다운로드 링크로 교체합니다.

이런 방식으로 UI를 업데이트하기 위해서는 업데이트의 좋은 대상을 설정해야 합니다. 따라서 전체 UI를 `div` 태그로 감싸고, 그 `div`를 모든 작업의 대상으로 사용하겠습니다.

다음은 새로운 아카이브 사용자 인터페이스의 템플릿 시작 부분입니다:

#figure(caption: [초기 아카이브 UI 템플릿],
```html
<div id="archive-ui"
  hx-target="this" <1>
  hx-swap="outerHTML"> <2>
</div>
```)
1. 이 div는 그 안의 모든 요소에 대한 대상이 됩니다.
2. 매번 전체 div를 `outerHTML`로 교체합니다.

다음으로, 아카이브를 다운로드하는 프로세스를 시작하는 버튼인 "연락처 아카이브 다운로드" 버튼을 이 `div`에 추가합시다. 우리는 아카이브 프로세스의 시작을 트리거하기 위해 `/contacts/archive` 경로에 `POST`를 보낼 것입니다:

#figure(caption: [아카이브 버튼 추가],
```html
<div id="archive-ui" hx-target="this" hx-swap="outerHTML">
  <button hx-post="/contacts/archive"> <1>
    Download Contact Archive
  </button>
</div>
```)
1. 이 버튼은 `/contacts/archive`에 `POST` 요청을 보냅니다.

마지막으로, 이 새로운 템플릿을 우리의 메인 `index.html` 템플릿에 포함시킵니다. 연락처 테이블 위에 배치합니다:

#figure(caption: [초기 아카이브 UI 템플릿],
```html
{% block content %}
  {% include 'archive_ui.html' %} <1>

  <form action="/contacts" method="get" class="tool-bar">
```)
1. 이 템플릿이 이제 메인 템플릿에 포함됩니다.

이렇게 하면 이제 다운로드를 시작하는 버튼이 웹 애플리케이션에 표시됩니다. 포함된 `div`에 `hx-target="this"`가 설정되어 있기 때문에, 버튼은 그 대상을 상속받아 `/contacts/archive`에 대한 `POST` 요청으로부터 반환된 HTML로 그 포함된 `div`를 교체하게 됩니다.

=== 아카이빙 엔드포인트 추가하기 <_adding_the_archiving_endpoint>
다음 단계는 버튼이 만드는 `POST` 요청을 처리하는 것입니다. 현재 사용자에 대한 `Archiver`를 가져와서 그 메서드인 `run()`을 호출합니다. 이것은 아카이브 프로세스를 실행하게 될 것입니다. 그런 다음 프로세스가 실행 중임을 나타내는 새로운 내용을 렌더링할 것입니다.

이를 위해, 우리는 아카이버가 "Waiting" 상태일 때와 "Running" 상태일 때 아카이브 UI 렌더링을 처리하기 위해 `archive_ui` 템플릿을 재사용하고자 합니다. (이후에 "Complete" 상태를 처리할 것입니다).

이는 매우 일반적인 패턴입니다: 우리는 주어진 사용자 인터페이스 조각에 대해 모든 서로 다른 가능한 UI를 하나의 템플릿에 넣고 적절한 인터페이스를 조건부로 렌더링합니다. 모든 것을 하나의 파일로 유지하면 다른 개발자들이 (또는 우리가 다시 돌아왔을 때!) 클라이언트 측에서 UI가 어떻게 작동하는지 이해하는 것이 훨씬 쉬워집니다.

아카이버 상태에 따라 다른 사용자 인터페이스를 조건부로 렌더링해야 하므로 템플릿에 아카이버를 매개변수로 전달해야 합니다. 따라서, 다시: 우리는 컨트롤러에서 아카이버의 `run()`을 호출하고 아카이버를 템플릿으로 전달하여 아카이브 프로세스의 현재 상태에 적합한 UI를 렌더링할 수 있게 해야 합니다.

코드는 다음과 같습니다:

#figure(caption: [아카이브 프로세스 시작을 위한 서버 측 코드],
```python
@app.route("/contacts/archive", methods=["POST"]) <1>
def start_archive():
    archiver = Archiver.get() <2>
    archiver.run() <3>
    return render_template("archive_ui.html", archiver=archiver) <4>
```)
1. `/contacts/archive`에 대한 `POST` 요청을 처리합니다.
2. 아카이버를 찾습니다.
3. 비차단적인 `run()` 메서드를 호출합니다.
4. 아카이브 UI를 렌더링하는 `archive_ui.html` 템플릿을 반환하고, 아카이버를 전달합니다.

=== 진행 UI 조건부 렌더링 <_conditionally_rendering_a_progress_ui>

#index[조건부 렌더링]
이제 아카이브 프로세스의 상태에 따라 상이한 내용을 조건적으로 렌더링하기 위해 `archive_ui.html`을 업데이트하는 데 주목하겠습니다.

아카이버는 `status()` 메서드를 가지고 있습니다. 아카이버를 변수를 통해 템플릿에 전달하면 이 `status()` 메서드를 참조하여 아카이브 프로세스의 상태를 알 수 있습니다.

아카이버 상태가 `Waiting`이면 "연락처 아카이브 다운로드" 버튼을 렌더링하고, 상태가 `Running`이면 진행 중임을 표시하는 메시지를 렌더링합니다. 템플릿 코드를 이와 같이 업데이트해 봅시다:

#figure(caption: [조건부 렌더링 추가],
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
1. 상태가 "Waiting"인 경우에만 아카이브 버튼을 렌더링합니다.
2. 상태가 "Running"일 때는 다른 콘텐츠를 렌더링합니다.
3. 당분간은 단순히 프로세스가 실행 중이라는 텍스트만 표시합니다.

좋습니다. 템플릿 뷰에 조건부 로직이 생겼고, 아카이브 프로세스를 시작하는 서버 측 로직도 준비되었습니다. 아직 진행 표시줄은 없지만, 곧 추가할 것입니다! 이대로 작동하는지 확인하고 애플리케이션의 메인 페이지를 새로 고쳤습니다... 

#figure(caption: [문제가 발생했습니다],
```
UndefinedError
jinja2.exceptions.UndefinedError: 'archiver' is undefined
```)

아이스!

바로 에러 메시지가 출력됩니다. 왜 그런지요? 아, 우리는 `index.html` 템플릿에 `archive_ui.html`을 포함하고 있지만, 이제 `archive_ui.html` 템플릿은 조건부로 올바른 UI를 렌더링할 수 있도록 아카이버가 전달되기를 기대하고 있습니다.

이는 쉽게 해결할 수 있습니다: `index.html` 템플릿을 렌더링할 때 아카이버를 전달하면 됩니다.

#figure(caption: [index.html 렌더링 시 아카이버 포함],
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
1. 메인 템플릿에 아카이버를 전달합니다.

이제 이 작업이 완료되었으므로 페이지를 불러올 수 있습니다. 그리고 정말로 "연락처 아카이브 다운로드" 버튼이 보입니다.

버튼을 클릭하면 버튼이 "Running..."이라는 내용으로 교체되고, 서버 측의 개발자 콘솔에서 작업이 제대로 시작되고 있는 것을 확인할 수 있습니다.

=== 폴링 <_polling>

#index[폴링]
확실히 발전은 있지만, 여기에는 가장 좋은 진행 표시기가 없습니다: 단지 프로세스가 실행되고 있음을 사용자에게 알리는 정적 텍스트만 있습니다.

우리는 프로세스 진행에 따라 내용이 업데이트되기를 원하고, 이상적으로 진행 표시줄이 얼마나 진행되었는지를 보여주기를 원합니다. 하이퍼미디어를 사용하여 이 작업을 어떻게 수행할 수 있을까요?

우리가 사용하고자 하는 기술은 "폴링"이라고 하며, 이는 일정한 간격으로 요청을 발행하고 서버의 새로운 상태에 기반하여 UI를 업데이트하는 기술입니다.

#sidebar[폴링? 정말?][폴링은 다소 나쁜 평판이 있으며, 세계에서 가장 섹시한 기술은 아닙니다:
  오늘날 개발자들은 이 상황을 해결하기 위해 WebSockets나 Server Sent Events(SSE)와 같은 보다 진보된 기술을 사용할 수도 있습니다.

  그러나 무엇이라 하든지 간에, 폴링은 _작동_하며 매우 간단합니다. 폴링 요청으로 시스템이 압도되지 않도록 주의해야지만, 약간의 주의를 기울이면 UI 내에서 신뢰할 수 있고 수동으로 업데이트되는 구성 요소를 만들 수 있습니다.]

Htmx는 두 가지 유형의 폴링을 제공합니다. 첫 번째는 "고정 비율 폴링"으로, 특별한 `hx-trigger` 구문을 사용하여 무언가가 고정 간격으로 폴링되어야 함을 나타냅니다.

예를 들어 보겠습니다:

#figure(caption: [고정 간격 폴링],
```html
<div hx-get="/messages" hx-trigger="every 3s"> <1>
</div>
```)
1. 3초마다 `/messages`에 대한 `GET` 요청을 트리거합니다.

이는 새 메시지를 사용자가 볼 수 있도록 무한정 폴링하고자 할 때 훌륭하게 작동합니다. 그러나 고정 비율 폴링은 명확한 프로세스가 끝난 후에는 폴링이 멈춰야 하므로 이상적이지 않습니다: DOM에서 요소가 제거될 때까지 영원히 폴링합니다.

우리의 경우, 우리는 명확한 프로세스를 가지고 있으며 종료가 있습니다. 따라서 두 번째 폴링 기술인 "로드 폴링"을 사용하는 것이 좋습니다. 로드 폴링에서는 htmx가 콘텐츠가 DOM에 로드될 때 `load` 이벤트를 트리거하는 사실을 활용합니다. 우리는 이 `load` 이벤트에 대한 트리거를 생성하고 요청이 즉시 트리거되지 않도록 약간의 지연을 추가할 수 있습니다.

이렇게 하면 요청이 있을 때마다 `hx-trigger`를 조건부로 렌더링할 수 있습니다: 프로세스가 완료되면 우리는 단순히 `load` 트리거를 포함하지 않으면 되고, 그러면 로드 폴링이 멈춥니다. 이는 확정적인 프로세스가 완료될 때까지 폴링하는 간단하고 좋은 방법을 제공합니다.

==== 폴링을 사용해 아카이브 UI 업데이트하기 <_using_polling_to_update_the_archive_ui>
아카이버가 진행 중일 때 우리 UI를 업데이트하기 위해 로드 폴링을 사용하겠습니다. 진행 상황을 표시하기 위해서는 CSS 기반의 진행 표시줄을 사용하고, `progress()` 메서드를 활용하겠습니다. 이 메서드는 아카이브 프로세스가 완료에 얼마나 가까운지를 나타내는 0과 1 사이의 숫자를 반환합니다.

다음은 사용할 HTML 코드 조각입니다:

#figure(caption: [CSS 기반의 진행 표시줄],
```html
<div class="progress">
    <div class="progress-bar"
         style="width:{{ archiver.progress() * 100 }}%"></div> <1>
</div>
```)
1. 내부 요소의 너비는 진행 상황에 해당합니다.

이 CSS 기반의 진행 표시줄은 두 가지 구성 요소로 이루어져 있습니다: 진행 표시줄의 외부 `div`와 실제 진행 표시를 나타내는 내부 `div`입니다. 내부 진행 표시줄의 너비를 특정 비율로 설정하는데 (여기서 `progress()` 결과를 100으로 곱하여 백분율로 바꿉니다) 그렇게 하면 진행 표시기가 상위 `div` 내에서 적절한 너비를 가지게 됩니다.

#sidebar[<progress> 요소는 뭐죠?][우리는 아마도 여기서 "div 스프"에 발을 담그고 있습니다. 진행 상황을 보여주기 위해 특별히 설계된 완벽하게 좋은 HTML5 태그인
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/progress",
)[`progress`]
요소를 사용하는 대신 `div` 태그를 사용하는 것입니다.

이번 예제에서 `progress` 요소를 사용하지 않기로 결정한 이유는 진행 표시줄이 부드럽게 업데이트되기를 원하고, 그렇게 하려고 하면 `progress` 요소에서 사용할 수 없는 CSS 기술을 사용해야 하기 때문입니다. 불행하게도, 이것은 우리가 부여받은 카드를 가지고 플레이해야 할 때가 있습니다.

그러나 우리는 적절한
#link(
  "https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/roles/progressbar_role",
)[진행 표시줄 역할]
을 사용하여 우리의 `div` 기반 진행 표시줄이 보조 기술과 잘 작동하도록 하겠습니다.]

이제 #indexed[진행 표시줄]을 적절한 ARIA 역할과 값으로 업데이트해 보겠습니다:

#figure(caption: [CSS 기반의 진행 표시줄])[
```html
<div class="progress">
  <div class="progress-bar"
    role="progressbar" <1>
    aria-valuenow="{{ archiver.progress() * 100 }}" <2>
    style="width:{{ archiver.progress() * 100 }}%"></div>
</div>
``` ]
1. 이 요소는 진행 표시줄 역할을 합니다.
2. 진행률은 아카이버의 백분율 완전성을 나타내며, 100은 완전한 상태를 나타냅니다.

마지막으로, 완결성을 위해 우리는 이 진행 표시줄을 위한 CSS를 다음과 같이 설정할 것입니다:

#figure(caption: [진행 표시줄을 위한 CSS])[
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
  우리의 CSS 기반 진행 표시줄, @lst:progress-bar-css에서 구현됨
])

===== 진행 표시줄 UI 추가하기 <_adding_the_progress_bar_ui>
아카이버가 실행 중일 때의 경우에 `archive_ui.html` 템플릿에 진행 표시줄 코드를 추가하고, "아카이브 생성 중..."이라는 문구로 업데이트합시다:

#figure(caption: [진행 표시줄 추가])[
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
1. 우리의 새로운 진행 표시줄

이제 "연락처 아카이브 다운로드" 버튼을 클릭하면 진행 표시줄이 나타납니다. 하지만 여전히 업데이트되지 않기 때문에 로드 폴링을 아직 구현하지 않았습니다: 그저 제자리에서 0으로 머물고 있습니다.

진행 표시줄을 동적으로 업데이트하도록 하려면 `hx-trigger`를 사용하여 로드 폴링을 구현해야 합니다. 아카이버가 실행 중일 때 조건부 블록 내의 거의 모든 요소에 추가할 수 있으므로, "아카이브 생성 중..." 텍스트와 진행 표시줄을 감싸고 있는 그 `div`에 추가하겠습니다.

그것을 폴링하도록 하여 HTTP `GET` 요청을 `POST`와 동일한 경로인 `/contacts/archive`에 발행해 보겠습니다:

#figure(caption: [로드 폴링 구현하기])[
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
1. 콘텐츠 로드 500밀리초 후에 `/contacts/archive`에 대한 `GET` 요청을 발행합니다.

이 `/contacts/archive`에 대한 `GET` 요청이 발행되면 `archive-ui`라는 ID를 가진 `div`가 교체될 것입니다. `archive-ui`가 설정된 `hx-target` 속성이 이 `div`의 하위 요소에 상속되므로, 자식 요소 모두가 `archive_ui.html` 파일에서 그 외부 `div`를 대상으로 합니다.

이제 서버에서 `/contacts/archive`에 대한 `GET` 요청을 처리해야 합니다. 다행히 이건 아주 쉽습니다: 우리가 해야 할 일은 아카이버와 함께 `archive_ui.html`을 다시 렌더링하는 것입니다.

#figure(caption: [진행 업데이트 처리하기])[
```python
@app.route("/contacts/archive", methods=["GET"]) <1>
def archive_status():
    archiver = Archiver.get()
    return render_template("archive_ui.html", archiver=archiver) <2>
``` ]
1. `/contacts/archive` 경로로 `GET` 요청 처리
2. 단순히 `archive_ui.html` 템플릿을 다시 렌더링합니다.

하이퍼미디어와 같이 많은 다른 것들과 마찬가지로, 코드는 매우 읽기 쉽고 복잡하지 않습니다.

이제 "연락처 아카이브 다운로드"를 클릭하면, 확실히 500밀리초마다 업데이트되는 진행 표시줄이 나타납니다. `archiver.progress()`에 대한 호출 결과가 0에서 1로 점진적으로 업데이트됨에 따라, 진행 표시줄이 화면을 가로지르는 것을 볼 수 있습니다. 아주 멋집니다!

==== 결과 다운로드하기 <_downloading_the_result>
마지막으로 처리해야 할 상태가 하나 더 있습니다. `archiver.status()`가 "Complete"로 설정되고, 다운로드할 준비가 된 JSON 아카이브 데이터가 있는 경우입니다. 아카이버가 완료되면 `archive_file()` 호출을 통해 서버에서 로컬 JSON 파일을 가져올 수 있습니다.

"Complete" 상태를 처리하기 위해 if 문에 또 다른 경우를 추가하고, 아카이브 작업이 완료되면 새로운 경로 `/contacts/archive/file`로 렌더링할 수 있는 링크를 만들겠습니다. 다음은 새로운 코드입니다:

#figure(caption: [아카이빙 완료 시 다운로드 링크 렌더링])[
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
1. 상태가 "Complete"인 경우 다운로드 링크를 렌더링합니다.
2. 링크는 `/contacts/archive/file`에 대한 `GET` 요청을 발행합니다.

링크에 `hx-boost`가 `false`로 설정되어 있다는 점에 유의하십시오. 이는 링크가 다른 링크에 대해 존재하는 부스트 동작을 상속받지 않도록 하여 AJAX를 통해 발행되지 않도록 합니다. 우리는 AJAX 요청으로 파일을 직접 다운로드할 수 없으므로, "정상" 링크 동작이 필요합니다. 일반 앵커 태그는 이를 가능합니다.

==== 완료된 아카이브 다운로드하기 <_downloading_the_completed_archive>
마지막 단계는 `/contacts/archive/file`에 대한 `GET` 요청을 처리하는 것입니다. 우리는 아카이버가 생성한 파일을 클라이언트로 전송해야 합니다. 우리는 행운이 따릅니다: Flask는 파일을 다운로드 응답으로 발송하는 메커니즘이 있는 `send_file()` 메서드를 가지고 있습니다.

다음 코드에서 보듯이, 우리는 `send_file()`에 세 가지 인수를 전달합니다: 아카이버가 생성한 아카이브 파일의 경로, 브라우저가 생성할 파일 이름, 그리고 "첨부로" 전송하고 싶은지 여부입니다. 이 마지막 인수는 Flask에게 HTTP 응답 헤더 `Content-Disposition`을 주어진 파일 이름과 함께 `attachment`로 설정하라고 지시합니다. 이것이 브라우저의 파일 다운로드 동작을 유발하는 것입니다.

#figure(caption: [클라이언트에 파일 전송하기])[
```python
@app.route("/contacts/archive/file", methods=["GET"])
def archive_content():
    manager = Archiver.get()
    return send_file(
      manager.archive_file(), "archive.json", as_attachment=True) <1>
``` ]
1. Flask의 `send_file()` 메서드를 사용하여 클라이언트에 파일을 전송합니다.

완벽합니다. 이제 우리는 매우 매끄러운 아카이브 UI를 갖추고 있습니다. "연락처 아카이브 다운로드" 버튼을 클릭하면 진행 표시줄이 나타납니다. 진행 표시줄이 100%에 도달하면 사라지고, 아카이브 파일을 다운로드할 수 있는 링크가 나타납니다. 사용자는 해당 링크를 클릭하여 아카이브를 다운로드 할 수 있습니다.

우리는 많은 웹사이트의 일반적인 클릭-기다림 경험보다 훨씬 더 사용자 친화적인 사용자 경험을 제공합니다.

=== 매끄럽게 만드는 것: Htmx의 애니메이션 <_smoothing_things_out_animations_in_htmx>
이 UI가 훌륭하긴 하지만, 하나의 약간의 불만이 있습니다: 진행 표시줄이 업데이트될 때 "점프"합니다. 이는 웹 1.0 스타일의 애플리케이션에서 전체 페이지 새로 고침과 같은 느낌이 듭니다. 이를 해결할 방법이 있을까요?
(당연히 있습니다. 그래서 `progress` 요소 대신에 `div`를 선택한 것입니다!)

시각적 문제의 원인을 살펴보고 그것을 어떻게 해결할 수 있는지 살펴보겠습니다. (빠르게 답을 찾고 싶다면 "우리의 해결책"으로 넘어가셔도 됩니다.)

#index[CSS 전환]
사실, 요소의 한 상태에서 다른 상태로의 변경을 부드럽게 하는 네이티브 HTML 기술이 있습니다: CSS 전환 API, 우리가 4장에서 논의했던 바로 그 API입니다. CSS 전환을 사용하면 `transition` 속성을 사용하여 요소를 다양한 스타일로 부드럽게 애니메이션할 수 있습니다.

`.progress-bar` 클래스의 CSS 정의를 되돌아보면 다음과 같은 전환 정의가 있습니다:
`transition: width .6s ease;`. 이는 진행 표시줄의 너비가 예를 들어 20%에서 30%로 변경될 때, 브라우저가 0.6초 동안 "ease" 함수 (부드러운 가속/감속 효과)로 애니메이션을 수행한다는 것을 의미합니다.

그런데 왜 현재 UI에서 해당 전환이 적용되지 않을까요? 그 이유는 우리의 예제에서 htmx가 각 폴링마다 진행 표시줄을 _교체_하고 있기 때문입니다. 이는 기존 요소의 너비를 업데이트하지 않습니다. 안타깝게도 CSS 전환은 기존 요소의 속성이 인라인으로 변경될 때만 적용되며, 요소가 교체될 때는 적용되지 않습니다.

이는 순수 HTML 기반 애플리케이션이 SPA 모델에 비해 덜 순조롭게 느껴지게 만드는 이유입니다: 자바스크립트 없이 CSS 전환을 사용하기는 어렵습니다.

하지만 좋은 소식이 있습니다: htmx는 DOM에서 콘텐츠를 교체할 때 CSS 전환을 활용할 수 있는 방법을 제공합니다.

==== Htmx의 "안정화" 단계 <_the_settling_step_in_htmx>

#index[htmx][스왑 모델]
#index[htmx][안정화]
4장에서 htmx 스왑 모델에 대해 논의할 때, 우리는 htmx가 추가하고 제거하는 클래스에 집중했습니다. 그러나 "안정화" 프로세스는 생략했습니다. htmx에서 안정화에는 여러 단계가 포함됩니다: htmx가 콘텐츠의 조각을 교체하기 직전에, 새 콘텐츠를 살펴보고 그 위에 있는 모든 `id`가 있는 요소를 찾습니다. 그런 다음, _기존_ 콘텐츠에서 동일한 `id`를 가진 요소를 찾습니다.

하나 있으면, 다음과 같은 다소 복잡한 셔플을 수행합니다:
- _새로운_ 콘텐츠가 일시적으로 _오래된_ 콘텐츠의 속성을 가져옵니다.
- 새로운 콘텐츠가 삽입됩니다.
- 짧은 지연 후, 새로운 콘텐츠의 속성이 실제 값으로 되돌아갑니다.

이것은 이 이상한 작은 춤이 무엇을 달성하려는 것일까요?

음, 요소가 교체 간 안정적인 ID가 있을 경우, 다양한 상태 간에 CSS 전환을 작성할 수 있습니다. _ 새로운_ 콘텐츠가 일시적으로 _오래된_ 속성을 가지고 있기 때문에, 실제 값이 복원될 때 일반적인 CSS 전환 메커니즘이 작동하게 됩니다.

==== 우리의 매끄럽게 만드는 해결책 <_our_smoothing_solution>
따라서, 우리는 해결책에 도달했습니다.

우리가 할 일은 `progress-bar` 요소에 안정적인 ID를 추가하는 것입니다.

#figure(caption: [매끄럽게 만드는 것])[
```html
<div class="progress" >
    <div id="archive-progress" class="progress-bar" role="progressbar"
         aria-valuenow="{{ archiver.progress() * 100 }}"
         style="width:{{ archiver.progress() * 100 }}%"></div> <1>
</div>
``` ]
1. 진행 표시줄 div는 이제 요청 간에 안정적인 ID를 가집니다.

htmx의 이면에서 복잡한 메커니즘이 진행되고 있지만, 해결책은 우리가 애니메이션을 원했던 요소에 안정적인 `id` 속성을 추가하는 것으로 간단합니다.

이제 진행 표시줄은 매 업데이트마다 점프하는 대신, CSS 전환이 정의된 스타일 시트를 사용하여 부드럽게 화면을 가로지르게 됩니다. htmx의 스왑 모델 덕분에, 우리는 HTML을 새롭게 교체하고 있어도 이를 달성할 수 있습니다.

그리고 voila: 연락처 아카이빙 기능을 위한 멋진 매끄러운 애니메이션 진행 표시줄이 만들어졌습니다. 결과는 자바스크립트 기반 솔루션의 모양과 느낌을 가지지만, 우리는 HTML 기반 접근 방식의 단순함으로 그것을 구현했습니다.

이제 독자님, 기쁨이 느껴지겠네요.

=== 다운로드 UI 해제 <_dismissing_the_download_ui>
일부 사용자들은 마음이 바뀌어 아카이브를 다운로드하지 않기로 할 수 있습니다. 그들은 우리 화려한 진행 표시줄을 결코 목격하지 않을 수 있지만, 괜찮습니다. 우리는 이러한 사용자들에게 다운로드 링크를 해제하고 원래 내보내기 UI 상태로 돌아가기 위한 버튼을 제공할 것입니다.

이를 위해 우리는 현재 아카이브를 제거하거나 정리할 수 있다고 표시하는 `DELETE` 요청을 `/contacts/archive` 경로로 발행하는 버튼을 추가할 것입니다.

우리는 다운로드 링크 아래에 다음과 같이 추가할 것입니다:

#figure(caption: [다운로드 해제하기])[
```html
<a hx-boost="false" href="/contacts/archive/file">
 Archive Ready! Click here to download. &downarrow;
</a>
<button hx-delete="/contacts/archive">Clear Download</button> <1>
``` ]
1. `/contacts/archive`에 `DELETE` 요청을 발행하는 간단한 버튼입니다.

이제 사용자는 아카이브 다운로드 링크를 해제할 수 있는 버튼을 클릭할 수 있습니다. 그러나 우리는 이를 서버 측에서 연결해야 합니다. 평소와 같이, 이는 꽤 간단합니다: `DELETE` HTTP 작업을 위한 새로운 핸들러를 작성하고, 아카이버에서 `reset()` 메서드를 호출한 다음, `archive_ui.html` 템플릿을 다시 렌더링하면 됩니다.

이 버튼은 나머지와 동일한 `hx-target` 및 `hx-swap` 구성에서 작동하므로 "그냥 작동"합니다.

서버 측 코드는 다음과 같습니다:

#figure(caption: [다운로드 리셋 핸들러])[
```python
@app.route("/contacts/archive", methods=["DELETE"])
def reset_archive():
    archiver = Archiver.get()
    archiver.reset() <1>
    return render_template("archive_ui.html", archiver=archiver)
``` ]
1. 아카이버에서 `reset()`을 호출합니다.

이것은 다른 핸들러와 꽤 비슷하게 보입니다, 그렇지 않습니까?

확실히 그렇습니다! 그게 아이디어입니다!

=== 대체 사용자 경험: 자동 다운로드 <_an_alternative_ux_auto_download>

#index[자동 다운로드]
우리는 연락처 아카이빙을 위한 현재 사용자 경험을 선호하지만, 다른 대안도 있습니다. 현재 진행 표시줄은 프로세스의 진행을 보여주고, 완료되면 사용자가 실제로 파일을 다운로드할 수 있는 링크를 표시합니다. 웹에서 보는 또 다른 패턴은 "자동 다운로드"입니다. 사용자가 링크를 클릭할 필요 없이 즉시 파일이 다운로드됩니다.

우리는 이 기능을 조금의 스크립팅으로 애플리케이션에 쉽게 추가할 수 있습니다. 하이퍼미디어 기반 애플리케이션에서 스크립팅에 대해 보다 깊이 있게 논의할 것입니다. 그러나 간단히 말해서, 스크립팅은 애플리케이션의 핵심 하이퍼미디어 메커니즘을 대체하지 않는다면 HDA에서 완벽하게 허용됩니다.

자동 다운로드 기능에는 #link("https://hyperscript.org")[\_hyperscript]를 사용할 것입니다. 우리 선호하는 스크립팅 옵션입니다. 여기서 자바스크립트 또한 잘 작동하며 거의 간단할 것입니다. 마찬가지로, 9장에서 스크립팅 옵션에 대해 자세히 논의할 것입니다.

자동 다운로드 기능을 구현하기 위해 필요한 것은 다음과 같습니다: 다운로드 링크가 렌더링 될 때 사용자 대신 링크를 자동으로 클릭하는 것입니다.

\_hyperscript 코드는 이전 문장과 거의 동일하게 읽힙니다(이것이 우리가 하이퍼스크립트를 좋아하는 주된 이유입니다):

#figure(caption: [자동 다운로드 주기])[
```html
<a hx-boost="false" href="/contacts/archive/file"
  _="on load click() me"> <1>
  Archive Downloading! Click here if the download does not start.
</a>
``` ]
1. 파일을 자동으로 다운로드하는 약간의 \_hyperscript입니다.

중요하게도, 여기서 스크립팅은 기존 하이퍼미디어를 _강화_하는 것이지 비하이퍼미디어 요청으로 대체하는 것이 아닙니다. 이에 대해서는 잠시 후에 더 깊이 다룰 것입니다.

=== 동적 아카이브 UI: 완료 <_a_dynamic_archive_ui_complete>
이 장에서는 진행 표시줄 및 자동 다운로드 기능이 있는 동적 UI를 우리 연락처 아카이브 기능을 위해 생성하는 데 성공했습니다. 거의 모든 것이 하이퍼미디어로 이루어졌습니다. 다만, 자동 다운로드를 위한 작은 부분의 스크립팅만 제외하고 말이죠. 전체적으로 약 16줄의 프론트 엔드 코드와 16줄의 백엔드 코드가 필요했습니다.

HTML은 htmx와 같은 하이퍼미디어 지향 JavaScript 라이브러리의 도움을 받으면 매우 강력하고 표현력이 뛰어납니다.

#html-note[Markdown 스프]([
#index[Markdown]
_마크다운 스프_는 `<div>` 스프의 덜 알려진 형제입니다. 이는 웹 개발자들이 마크다운 언어가 제공하는 요소 집합으로 제한되면서 생기는 결과입니다. 이러한 요소들이 부적절한 경우에도 말이죠. 더 심각하게는, HTML을 포함한 도구의 전반적인 힘을 인식하는 것이 중요합니다. 다음은 IEEE 스타일 인용의 예입니다:

#figure(
```markdown
[1] C.H. Gross, A. Stepinski, and D. Akşimşek, <1>
  _Hypermedia Systems_, <2>
  Bozeman, MT, USA: Big Sky Software.
  Available: <https://hypermedia.systems/>
```)
1. 참조 번호는 괄호로 작성됩니다.
2. 책 제목 주위의 밑줄은 \<em\> 요소를 생성합니다.

여기서 \<em\>이 사용됩니다. 이는 기본적으로 이탤릭체로 표시되는 유일한 마크다운 요소입니다. 이는 책 제목에 강조를 주지만, 그 목적은 작품의 제목으로 마크업하는 것입니다. HTML에는 바로 이 목적을 위해 의도된 `<cite>` 요소가 있습니다.

게다가, 이것은 순서가 지정된 리스트로 `<ol>` 요소에 적합한 번호 매기기 목록임에도 불구하고, 참조 번호는 대신 일반 텍스트로 사용됩니다. 왜일까요? IEEE 인용 스타일은 이러한 숫자가 대괄호로 표시되어야 한다고 요구합니다. 이는 `<ol>`에서 CSS를 사용하여 달성할 수 있지만, 마크다운은 요소에 클래스를 추가할 방법이 없으므로 대괄호가 모든 순서 있는 목록에 적용됩니다.

마크다운에서 삽입된 HTML 사용을 두려워하지 마십시오. 더 큰 사이트의 경우, 마크다운 확장을 고려하는 것도 좋습니다.

#figure(
```markdown
{.ieee-reference-list} <1>
1. C.H. Gross, A. Stepinski, and D. Akşimşek, <2>
  <cite>Hypermedia Systems</cite>, <3>
  Bozeman, MT, USA: Big Sky Software.
  Available: <https://hypermedia.systems/>
```)

1. 많은 마크다운 방언은 중괄호를 사용하여 추가적인 ID, 클래스 및 속성을 추가할 수 있도록 허용합니다.
2. 이제 우리는 \<ol\> 요소를 사용할 수 있으며, CSS에서 대괄호를 만들 수 있습니다.
3. 우리는 인용되는 작품의 제목을 버림으로써 `<cite>`를 사용합니다(전체 인용이 아님!).

사용자 정의 프로세서를 사용하여 추가 세부 HTML을 수동으로 작성하여 더 자세한 HTML을 생성할 수도 있습니다:

#figure(
```markdown
{% reference_list %} <1>
[hypers2023]: <2>
  C.H. Gross, A. Stepinski, and D. Akşimşek, _Hypermedia Systems_,
  Bozeman, MT, USA: Big Sky Software, 2023.
  Available: <https://hypermedia.systems/>
{% end %}
```)

1. `reference_list`는 단순 텍스트를 고도로 세부화된 HTML로 변환하는 매크로입니다.
2. 프로세서는 또한 식별자를 해결할 수 있어, 참조 목록을 정렬된 상태로 유지하고 in-text 인용을 동기화하는 번거로움을 덜어줍니다.
]
