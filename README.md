##### <i>??? : RxSwift 쓰는데 왜 ReactorKit은 안썼음? Me : 그러게요...</i>


# 그래서 정리합니다! ReactorKit!

이 저장소는 [ReactorKit](https://github.com/ReactorKit/ReactorKit)을 공부하면서 정리하는 저장소입니다! 정리하는 모든 내용은 [공식 GitHub README](https://github.com/ReactorKit/ReactorKit)를 참고하여 정리하였습니다.
#### ❗️정리하는 모든 내용은 비동기 프로그래밍, MVVM, RxSwift, RxCocoa에 대한 기본 지식이 있다는것을 전제를 두고 정리된 내용입니다!

### 8/29
이제 ReactorKit을 다뤄볼려한다. RxSwift를 써서 비동기 프로그래밍을 하는건 익숙한데, ReactorKit을 쓰지않은 형태로 해서 그런지, 작성했던 코드들이 좀 더럽다 라는 느낌을 받아 ReactorKit을 공부해보면 어떨까 싶어서 한번 도전해본다. 오늘은 일단 간단하게만....

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

