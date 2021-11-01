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

class PageIndicatorTests: XCTestCase {

    private static let typeName = "CustomPageIndicator"
    private let indicator = CustomPageIndicator(
        selectedColor: "selectedColor",
        defaultColor: "defaultColor"
    )
    
    override func setUp() {
        super.setUp()
        dependencies.coder.register(
            type: CustomPageIndicator.self,
            named: PageIndicatorTests.typeName
        )
    }
    
    override func tearDown() {
        super.tearDown()
        dependencies = BeagleDependencies()
    }
    
    func test_indicator_decoder() throws {
        let component: CustomPageIndicator = try componentFromJsonFile(
            fileName: PageIndicatorTests.typeName
        )
        assertSnapshot(matching: component, as: .dump)
    }

}
