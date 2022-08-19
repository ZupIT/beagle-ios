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

final class BeagleCoderTests: EnvironmentTestCase {
    // swiftlint:disable force_unwrapping
    
    private lazy var sut = Coder()

    func testIfAllComponentsAreBeingRegistered() {
        let sut = Coder()
        assertSnapshot(matching: sut.types[Coder.BaseType.component.rawValue], as: .dump)
    }
    
    func testIfAllActionsAreBeingRegistered() {
        let sut = Coder()
        assertSnapshot(matching: sut.types[Coder.BaseType.action.rawValue], as: .dump)
    }
    
    func testRegisterAndDecodeCustomComponent() throws {
        // Given
        let sut = Coder()
        let expectedText = "something"
        let jsonData = """
        {
            "_beagleComponent_": "custom:newcomponent",
            "text": "\(expectedText)"
        }
        """.data(using: .utf8)!

        // When
        sut.register(type: NewComponent.self)
        enviroment.coder = sut
        let component: NewComponent = try sut.decode(from: jsonData)
        
        // Then
        XCTAssertEqual(component.text, expectedText)
    }
    
    func testRegisterComponentWithCustomTypeName() throws {
        // Given
        let sut = Coder()

        // When
        sut.register(type: NewComponent.self, named: "NewCustomComponent")
        let componentDecoder = sut.types[Coder.BaseType.component.rawValue]?["custom:newcustomcomponent"]

        // Then
        XCTAssertNotNil(componentDecoder)
        XCTAssert(componentDecoder is NewComponent.Type)
    }
    
    func testRegisterActionWithCustomTypeName() throws {
        // Given
        let sut = Coder()

        // When
        sut.register(type: TestAction.self, named: "NewCustomAction")
        let actionDecoder = sut.types[Coder.BaseType.action.rawValue]?["custom:newcustomaction"]
        
        // Then
        XCTAssertNotNil(actionDecoder)
        XCTAssert(actionDecoder is TestAction.Type)
    }

    func testDecodeDefaultType() throws {
        // Given
        let expectedText = "some text"
        let jsonData = """
        {
            "_beagleComponent_": "beagle:text",
            "text": "\(expectedText)"
        }
        """.data(using: .utf8)!

        // When
        let text: Text = try sut.decode(from: jsonData)

        // Then
        guard case let .value(string) = text.text else {
            XCTFail("Expected a `.value` property, but got \(String(describing: text.text)).")
            return
        }
        XCTAssertEqual(string, expectedText)
    }

    func testUnknownTypeIsDecodeShouldReturnNil() throws {
        // Given
        let jsonData = """
        {
            "_beagleComponent_": "beagle:unknown",
            "text": "some text"
        }
        """.data(using: .utf8)!

        // When
        let unknown: UnknownComponent = try sut.decode(from: jsonData)

        // Then
        XCTAssertEqual(unknown._beagleComponent_, "beagle:unknown")
    }

    func testDecodeAction() throws {
        let jsonData = """
        {
            "_beagleAction_": "beagle:popStack"
        }
        """.data(using: .utf8)!

        let action: Action = try sut.decode(from: jsonData)

        guard case Navigate.popStack = action else {
            XCTFail("decoding failed"); return
        }
    }
    
    func testRegisterAndDecodeCustomAction() throws {
        let sut = Coder()
        let data = """
        {
            "_beagleAction_":"custom:testaction",
            "value": 42
        }
        """.data(using: .utf8)!

        sut.register(type: TestAction.self)
        enviroment.coder = sut
        let action: TestAction = try sut.decode(from: data)

        XCTAssertNotNil(action)
        XCTAssertEqual(action.value, 42)
    }

    private class TestAction: Action {
        
        let value: Int
        var analytics: ActionAnalyticsConfig?
        
        func execute(controller: BeagleController, origin: UIView) {
            // Intentionally unimplemented...
        }
    }
}

// MARK: - Testing Helpers
struct NewComponent: ServerDrivenComponent {
    var text: String
    
    func toView(renderer: BeagleRenderer) -> UIView {
        return UIView()
    }
}

struct Unknown: ServerDrivenComponent, Equatable {
    func toView(renderer: BeagleRenderer) -> UIView {
        return UIView()
    }
}
