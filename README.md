##### <i>??? : RxSwift 쓰는데 왜 ReactorKit은 안썼음? Me : 그러게요...</i>


# 그래서 정리합니다! ReactorKit!

이 저장소는 [ReactorKit](https://github.com/ReactorKit/ReactorKit)을 공부하면서 정리하는 저장소입니다! 정리하는 모든 내용은 [공식 GitHub README](https://github.com/ReactorKit/ReactorKit)를 참고하여 정리하였습니다.
#### ❗️정리하는 모든 내용은 비동기 프로그래밍, MVVM, RxSwift, RxCocoa에 대한 기본 지식이 있다는것을 전제를 두고 정리된 내용입니다!

### 8/29
이제 ReactorKit을 다뤄볼려한다. RxSwift를 써서 비동기 프로그래밍을 하는건 익숙한데, ReactorKit을 쓰지않은 형태로 해서 그런지, 작성했던 코드들이 좀 더럽다 라는 느낌을 받아 ReactorKit을 공부해보면 어떨까 싶어서 한번 도전해본다. 오늘은 일단 간단하게만....

### 8/31
Global State.... 전역상태에 대해서 조금 더 파고들어봐야할거같다.... 생각해보니 전역상태라는걸 깊게 생각해보지 않은거같은데... 전역변수랑은 다른걸까...

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

### Global State and transform()
지금까지 배운 내용에 따르면, 스트림을 제어하는 절차는 Action -> Mutation -> State 절차로 흘러가는것으로 알고있을것이다.
하지만, 이 절차(flow)는 Global State가 아니다.

### ❓Global State 는 무엇인가요?

