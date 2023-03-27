//
/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
import SnapshotTesting
@testable import Beagle

final class CustomBeagleScreenViewControllerTests: EnvironmentTestCase {
    
    func testLifecycleMethods() {
        let viewController = CustomBeagleScreenViewControllerStub(ComponentStub(), controllerId: #function)
        viewController.viewDidAppearExpectation.expectedFulfillmentCount = 1
        viewController.viewWillAppearExpectation.expectedFulfillmentCount = 1
        viewController.viewDidDisappearExpectation.expectedFulfillmentCount = 1
        
        viewController.viewWillAppear(true)
        viewController.viewDidAppear(true)
        viewController.viewDidDisappear(true)
        
        wait(
            for: [
                viewController.viewDidAppearExpectation,
                viewController.viewWillAppearExpectation,
                viewController.viewDidDisappearExpectation
            ],
            timeout: 0.1
        )
    }

    func testScreenDidChangeState() {
        let viewController = CustomBeagleScreenViewControllerStub(ComponentStub(), controllerId: #function)
        viewController.didChangeStateExpectation.expectedFulfillmentCount = 1
        
        viewController.didChangeState(.started)
        
        wait(for: [viewController.didChangeStateExpectation], timeout: 0.1)
    }
    
}


class CustomBeagleScreenViewControllerStub: BeagleScreenViewController {
    
    private(set) var viewWillAppearExpectation: XCTestExpectation = .init(description: "viewWillAppearExpectation")
    private(set) var viewDidAppearExpectation: XCTestExpectation = .init(description: "viewDidAppearExpectation")
    private(set) var viewDidDisappearExpectation: XCTestExpectation = .init(description: "viewDidDisappearExpectation")
    private(set) var didChangeStateExpectation: XCTestExpectation = .init(description: "didChangeStateExpectation")
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearExpectation.fulfill()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearExpectation.fulfill()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappearExpectation.fulfill()
    }
    
    override func didChangeState(_ state: ServerDrivenState) {
        super.didChangeState(state)
        didChangeStateExpectation.fulfill()
    }
}
