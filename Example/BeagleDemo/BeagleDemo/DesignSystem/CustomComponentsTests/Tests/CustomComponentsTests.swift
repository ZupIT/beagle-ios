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
@testable import Beagle
import SnapshotTesting
@testable import BeagleDemo

class CustomComponentsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        registerDummyComponents()
        let encoder = (Dependencies.coder as? Beagle.Coder)?.encoder
        encoder?.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    
    func testDecodingOfTextContainer() throws {
        try testCodable(type: TextContainer.self, fileName: "TextContainer")
    }
    
    func testDecodingOfSingleTextContainerWithoutActions() throws {
        try testCodable(type: SingleTextContainer.self, fileName: "SingleTextContainerWithoutActions")
    }
    
    func testDecodingOfSingleTextContainer() throws {
        try testCodable(type: SingleTextContainer.self, fileName: "SingleTextContainer")
    }
    
    func testDecodingOfSingleCustomActionableContainer() throws {
        try testCodable(type: SingleCustomActionableContainer.self, fileName: "SingleCustomActionableContainer")
    }
    
    func testDecodingOfCustomActionableContainer() throws {
        try testCodable(type: CustomActionableContainer.self, fileName: "CustomActionableContainer")
    }
    
    func testDecodingOfTextContainerWithAction() throws {
        try testCodable(type: TextContainerWithAction.self, fileName: "TextContainerWithAction")
    }
    
    func testDecodingOfTextContainerMissingAction() throws {
        try testCodable(type: TextContainerWithAction.self, fileName: "TextContainerMissingSecondAction")
    }
    
    private func testCodable<T: BeagleCodable>(type: T.Type, fileName: String) throws {
        let component: T = try componentFromJsonFile(fileName: fileName)
        assertSnapshot(matching: AutoCodable(wrappedValue: component), as: .json, named: fileName, testName: "codable")
    }
    
    private func registerDummyComponents() {
        let coder = Dependencies.coder
        coder.register(type: TextContainer.self)
        coder.register(type: SingleTextContainer.self)
        coder.register(type: CustomActionableContainer.self)
        coder.register(type: TextContainerWithAction.self)
        coder.register(type: SingleCustomActionableContainer.self)
        coder.register(type: TextComponentHeaderDefault.self)
        coder.register(type: TextComponentsDefault.self)
        coder.register(type: ActionDummyDefault.self)
    }
}
