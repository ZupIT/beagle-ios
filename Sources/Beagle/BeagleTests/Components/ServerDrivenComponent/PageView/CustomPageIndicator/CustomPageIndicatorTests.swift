/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
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

class CustomPageIndicatorTests: EnvironmentTestCase {

    private static let typeName = "CustomPageIndicator"
    private let indicator = CustomPageIndicator(
        selectedColor: "selectedColor",
        defaultColor: "defaultColor"
    )
    
    override func setUp() {
        super.setUp()
        enviroment.coder.register(
            type: CustomPageIndicator.self,
            named: CustomPageIndicatorTests.typeName
        )
    }

    func test_indicator_render() {
        let controller = BeagleControllerStub()
        let renderer = BeagleRenderer(controller: controller)
        let view = renderer.render(indicator)
        assertSnapshotImage(view, size: .custom(.init(width: 200, height: 30)))
    }

}
