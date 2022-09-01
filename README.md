##### <i>??? : RxSwift 쓰는데 왜 ReactorKit은 안썼음? Me : 그러게요...</i>


# 🥳그래서 정리합니다! ReactorKit!🥳

이 저장소는 [ReactorKit](https://github.com/ReactorKit/ReactorKit)을 공부하면서 정리하는 저장소입니다! 정리하는 모든 내용은 [공식 GitHub README](https://github.com/ReactorKit/ReactorKit)를 참고하여 정리하였습니다.
#### ❗️정리하는 모든 내용은 비동기 프로그래밍, MVVM, RxSwift, RxCocoa에 대한 기본 지식이 있다는것을 전제를 두고 정리된 내용입니다!

### 8/29
이제 ReactorKit을 다뤄볼려한다. RxSwift를 써서 비동기 프로그래밍을 하는건 익숙한데, ReactorKit을 쓰지않은 형태로 해서 그런지, 작성했던 코드들이 좀 더럽다 라는 느낌을 받아 ReactorKit을 공부해보면 어떨까 싶어서 한번 도전해본다. 오늘은 일단 간단하게만....

### 8/31
Global State.... 전역상태에 대해서 조금 더 파고들어봐야할거같다.... 생각해보니 전역상태라는걸 깊게 생각해보지 않은거같은데... 전역변수랑은 다른걸까...

### 9/1
전역상태에 대해서 많이 찾아봤다. Redux에서 나온 개념이라 생소했으나, 결국 말 그대로 전역에서 쓰이는 이벤트 스트림을 말하는거였구나... 이제 리드미는 정리 끝!

# What is ReactorKit?

## 기본 개념

ReactorKit은 RxSwift, RxCocoa 를 사용하는 비동기 프로그래밍과 MVVM 디자인패턴을 가진 프로젝트에 최조의 시너지를 가진 프레임워크이다. MVVM 디자인패턴이 적용된 프로젝트에서 RxSwift 를 사용한 프로젝트들을 보면 Input/Output 구조를 사용한 프로젝트들이 다수 존재한다. 이 Input/Output 구조를 체계화한 프레임워크가 ReactorKit 이라고 보면 된다.

<p float = "middle">
  <img width = "450" src="https://cloud.githubusercontent.com/assets/931655/25073432/a91c1688-2321-11e7-8f04-bf91031a09dd.png" />
</p>

위 그림은 ReactorKit이 어떤식으로 굴러가는지를 보여주는 그림인데 View에서 나온 화살표가 Action을 통과한 뒤, Reactor에서 끝나고, 이후 Reactor에서 나온 화살표가 State를 통과한 뒤, View에서 끝난뒤 계속 사이클이 돌아가는 모습이다.

각각을 설명하자면 아래와 같다.
- View : MVVM 에서의 View, VC 와 비슷한 의미
- Action : View에서 발생된 이벤트(예를들어, button.rx.tap)가 Reactor로 전달되는 형태(단위)
- Reactor : MVVM 에서의 ViewModel 과 비슷한 의미
- State : Reactor에서 생성된 비즈니스 로직의 결과(예를들어, 버튼의 상태변화)가 View로 전달되는 형태(단위)

즉, MVVM + Input/Output 패턴에서의 Input이 Action, Output이 State와 같다고 생각하면 된다.

## ReactorKit 사용 목적

- Testablility : MVVM 패턴의 가장 큰 이점 중 하나는 바로 <b>테스트 유용성(Testablility)</b>이다. <br />뷰와 뷰모델로 분리하여 뷰가 완성된 형태가 아니더라도 테스트가 가능케하여 테스트하는 시점을 훨씬 더 앞당길 수 있다.
- Start Small : Input/Output 패턴이 사용된 프로젝트들을 살펴보면, 프로젝트 전체에 패턴에 적용된것이 보인다. 이는, 간단한 로직이라도 Input/Output패턴을 적용사켜야 한다는 뜻이며, 이는 개발자에게 피로감을 안겨주게된다.<br /> 반대로, <b>ReactorKit은 필요하다고 생각되는 부분에만 적용시킬 수 있다.</b> 이는 프로잭트 개발단계 혹은 리팩토링단계에서 소요되는 개발자의 시간과 피로감을 감소시켜준다.
- Less Typing : 프레임워크로 정형화시켜, 개발자들이 머리써서 생각해야할 코드들을 더 간결하게 만들어낼 수 있다.

## View

View(UIVIew 가 아니다!)는 ReactorKit의 프로토콜로서 사용되며, VC와 Cell에서 호출하는 방식으로 선언된다. 
```swift
class ProfileViewController: UIViewController, View {
  var disposeBag = DisposeBag()
}
profileViewController.reactor = UserViewReactor() // inject reactor
```
말 그대로, 데이터를 화면에 보여주는 역할을 수행하고 View 에서 발생된 이벤트들을 액션 스트림에 bind하고 UI 컴포넌트에 state를 적용시킨다.

VC나 Cell에 View라는 프로토콜을 적용시키면 자동으로 typealias 키워드를 가진형태로 Reactor를 바인딩하도록 나온다. 

reactor가 할당되면 자동으로 .bind(reactor:) 함수가 호출된다. .bind(reactor:) 함수는 action 스트림과 state 스트림을 묶어주는 역할을 수행한다.
```swift
func bind(reactor: ProfileViewReactor) {
  // action (View -> Reactor)
  refreshButton.rx.tap.map { Reactor.Action.refresh }
    .bind(to: reactor.action)
    .disposed(by: self.disposeBag)

  // state (Reactor -> View)
  reactor.state.map { $0.isFollowing }
    .bind(to: followButton.rx.isSelected)
    .disposed(by: self.disposeBag)
}
```

## 스토리보드 지원

스토리보드를 사용하는 VC에 StoryboardView 프로토콜을 사용해야한다 View 프로토콜과의 차이점은 딱 하나인데, 바로 viewDidLoad()가 모두 진행 된 이후에 .bind(reactor:) 함수가 호출된다는 점이다.

## Reactor

Reactor는 UI와 독립된 계층으로, view의 statea를 관리하는 역할을 수행한다. reactor의 가장 큰 역할은 view에서 나오는 제어 흐름(control flow)를 분리하는 역할이다. 모든 view는 각각 상응하는 redactor가 있으며, 모든 비즈니스 로직을 reactor에 deleagte 시킨다. readctor은 view와의 dependency가 없기때문에 테스트환경이 더 쉽게 구축된다.

reactor는 Reactor 프로토콜을 적용하는것으로 시작하고, Action, Mutation, State, initialState를 정의해야 사용가능하다. Action, Mutation은 enum으로, State는 struct 형태로 선언이 가능하다.

```swift
class ProfileViewReactor: Reactor {
  // represent user actions
  enum Action {
    case refreshFollowingStatus(Int)
    case follow(Int)
  }

  // represent state changes
  enum Mutation {
    case setFollowing(Bool)
  }

  // represents the current view state
  struct State {
    var isFollowing: Bool = false
  }

  let initialState: State = State()
}
```

![image](https://user-images.githubusercontent.com/48994081/187618297-f34d1371-b020-41a5-847e-a47a197d2e3f.png)


위 그림에서 각각의 의미은,
- Action : 사용자의 상호작용을 의미한다.
- State : 뷰의 state를 의미한다.
- Mutation : Action과 State의 연결고리를 의미한다.

reactor는 action 스트림을 mutate()와 reduce() 두 단계로 action 스트림에서 state 스트림으로 바꾼다.

### mutate()

Action을 수신받아 `Observable<Mutaion>` 형태로 생성한다.

```swift
func mutate(action: Action) -> Observable<Mutation>
```

```swift
func mutate(action: Action) -> Observable<Mutation> {
  switch action {
  case let .refreshFollowingStatus(userID): // action을 전달받음
    return UserAPI.isFollowing(userID) // API 스트림을 생성함
      .map { (isFollowing: Bool) -> Mutation in
        return Mutation.setFollowing(isFollowing) // Mutaion 스트림으로 변환함
      }
  case let .follow(userID):
    return UserAPI.follow()
      .map { _ -> Mutation in
        return Mutation.setFollowing(true)
      }
  }
}
```

### reduce()
이전의 State와 Mutaion으로부터 새로운 State를 생성한다.

```swift
func reduce(state: State, mutation: Mutation) -> State
```
```swift
func reduce(state: State, mutation: Mutation) -> State {
  var state = state // 이전 state를 그대로 가져옴
  switch mutation {
  case let .setFollowing(isFollowing):
    state.isFollowing = isFollowing // 새로운 state를 생성하고 이전 state를 그대로 붙여놓음
    return state // 새로운 state를 반환함
  }
}
```

위 예제 코드에서 봤듯이, reduce()는 순수한 함수의 역할만 한다. API호출과 같은 side effect는 호출되어서는 안된다.

## Global State and transform()
지금까지 배운 내용에 따르면, 스트림을 제어하는 절차는 Action -> Mutation -> State 절차로 흘러가는것으로 알고있을것이다.
하지만, 이 절차(flow)는 Global State가 아니다.

#### ❓Global State 는 무엇인가요?
전역 상태(Global State)라는 말의 의미는, 모든곳(여러곳)에서 영향을 주는 컴포넌트(이벤트 스트림)이라는 뜻이며 1:N의 연결을 가진 스트림을 말한다.

그렇다면, 이미 진행했던 프로젝트에서 전역 이벤트 스트림으로 구성해놨던 작업은 전부 리팩토링해야하는가? 
### 아니다!
바로 .transform() 함수를 통해서 전역 이벤트 스트림을 합치는 방식이나 다른 방식으로 전역 이벤트 스트림을 action, mutation, state 로 변환할 수 있다.

.transform() 함수는 파라미터로 action, mutation, state타입을 가진 옵저버블을 같은 형태로 반환하는 함수이다. 함수의 기능은 다른 옵저버블 스트림을 파라미터로 전달받은 옵저버블과 합친 후 변환하는 기능을 가지고있다.


```swift
var currentUser: BehaviorSubject<User> // global state

func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
  return Observable.merge(mutation, currentUser.map(Mutation.setUser))
}
```

## View 간의 커뮤니케이션

![image](https://user-images.githubusercontent.com/48994081/187837547-2064f9ce-7e8c-4686-8310-a25fe5af9c7e.png)

본문 맨 처음에 얘기했던 내용처럼, ReactorKit은 RxSwfit(Reactive Programming)에 적합한 프레임워크이다. 뷰 간의 커뮤니케이션은 뷰를 UIButton, UILabel 처럼 다뤄줘야하는데, 이 방식의 대표로는 ControlEvent, UIButton.rx.tap 이 있다.

## 테스트
ReactorKit은 내장된 테스트 기능을 사용하여 더 쉽고 빠르게 테스트가 가능하다.

#### 무엇을 테스트 할것인가?
일단, View 혹은 Reactor 중 어떤것을 테스트 할 지 결정해야한다.
- View : 사용자의 상호작용으로인한 적합한 Action이 Reactor이 전달되는가 / View가 State에 변화에 따라 적합하게 설정되어 있는가
- Reactor : Action과 적합하게 State가 변경되었는가

### View 테스트

Reactor의 stub 기능을 활용하면 View를 테스트할 수 있다. Reactor.isStubEnabled 을 활성화하면 Reactor가 받은 Action을 모두 기록하고, mutate(), reduce() 함수대신 테스트환경에 맞게 외부에서 상태를 설정할 수 있다.

stub은 아래 3개의 프로퍼티를 가진다.

```swift
var state: StateRelay<Reactor.State> { get }
var action: ActionSubject<Reactor.Action> { get }
var actions: [Reactor.Action] { get } // recorded actions
```

테스트 하는 예제 코드는 아래와 같다.

```swift
func testAction_refresh() {
  // 1. Stub 리액터를 준비
  let reactor = MyReactor()
  reactor.isStubEnabled = true

  // 2. Stub 리액터를 주입한 뷰를 준비
  let view = MyView()
  view.reactor = reactor

  // 3. 사용자 상호작용을 실행
  view.refreshControl.sendActions(for: .valueChanged)

  // 4. 액션이 올바르게 전달되었는지 검증
  XCTAssertEqual(reactor.stub.actions.last, .refresh)
}

func testState_isLoading() {
  // 1. Stub 리액터를 준비
  let reactor = MyReactor()
  reactor.isStubEnabled = true

  // 2. Stub 리액터를 주입한 뷰를 준비
  let view = MyView()
  view.reactor = reactor

  // 3. 리액터의 상태를 설정
  reactor.stub.state.value = MyReactor.State(isLoading: true)

  // 4. 뷰 컴포넌트가 올바르게 변경되었는지 검증
  XCTAssertEqual(view.activityIndicator.isAnimating, true)
}
```

### Reactor 테스트
Reactor은 아래 예시 코드와 같이 독립적으로 테스트가 가능하다.

```swift
func testIsBookmarked() {
  let reactor = MyReactor()
  reactor.action.onNext(.toggleBookmarked)
  XCTAssertEqual(reactor.currentState.isBookmarked, true)
  reactor.action.onNext(.toggleBookmarked)
  XCTAssertEqual(reactor.currentState.isBookmarked, false)
}
```
하지만, 몇몇 State는 한번의 Action으로 여러번 바뀌는 경우가있다. 이럴때는 [RxTest](https://github.com/ReactiveX/RxSwift) 혹은 [RxExpect](https://github.com/devxoul/RxExpect)를 사용하는것이 바람직하다.

아래는 RxTest를 사용하여 테스트한 예시 코드이다.

```swift
func testIsLoading() {
  // given
  let scheduler = TestScheduler(initialClock: 0)
  let reactor = MyReactor()
  let disposeBag = DisposeBag()

  // when
  scheduler
    .createHotObservable([
      .next(100, .refresh) // send .refresh at 100 scheduler time
    ])
    .subscribe(reactor.action)
    .disposed(by: disposeBag)

  // then
  let response = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
    reactor.state.map(\.isLoading)
  }
  XCTAssertEqual(response.events.map(\.value.element), [
    false, // initial state
    true,  // just after .refresh
    false  // after refreshing
  ])
}
```

## 스케쥴링
scheduler 프로퍼티를 사용하여 특정 스케쥴러에서 state 스트림을 관측할 수 있다. 반드시 <b>serial queue<b>이어야 하며, 기본값으로는 MainSchedueler가 설정되어있다.

```swift
final class MyReactor: Reactor {
  let scheduler: Scheduler = SerialDispatchQueueScheduler(qos: .default)

  func reduce(state: State, mutation: Mutation) -> State {
    // executed in a background thread
    heavyAndImportantCalculation()
    return state
  }
}
```

## 펄스
펄스는 새로운 값이 할당되었을때(이전과 같은 값을 가져도)만 이벤트를 받고싶을때 사용한다.

```swift
// Reactor
private final class MyReactor: Reactor {
  struct State {
    @Pulse var alertMessage: String?
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .alert(message):
      return Observable.just(Mutation.setAlertMessage(message))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case let .setAlertMessage(alertMessage):
      newState.alertMessage = alertMessage
    }

    return newState
  }
}

// View
reactor.pulse(\.$alertMessage)
  .compactMap { $0 } // filter nil
  .subscribe(onNext: { [weak self] (message: String) in
    self?.showAlert(message)
  })
  .disposed(by: disposeBag)

// Cases
reactor.action.onNext(.alert("Hello"))  // showAlert() is called with `Hello`
reactor.action.onNext(.alert("Hello"))  // showAlert() is called with `Hello`
reactor.action.onNext(.doSomeAction)    // showAlert() is not called
reactor.action.onNext(.alert("Hello"))  // showAlert() is called with `Hello`
reactor.action.onNext(.alert("tokijh")) // showAlert() is called with `tokijh`
reactor.action.onNext(.doSomeAction)    // showAlert() is not called
```

위 에시 코드를 보면, 펄스를 사용하여 Hello 라는 값을 두번 전달하여도 정상적으로 수신되며, 값을 할당하지 않는 .doSomeAction 에는 showALert() 함수가 호출되지 않는것을 볼 수 있다.

