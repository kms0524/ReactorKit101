//
//  TestReactor.swift
//  ReactorKit101
//
//  Created by 강민성 on 2022/08/29.
//

import Foundation
import ReactorKit

class TestReactor: Reactor {
    
    enum Action {
        case testAction
    }
    
    struct State {
        var testState: Bool
    }
    
    var initialState: State = State(testState: false)
    
}
