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

import Foundation

import XCTest
import SnapshotTesting
@testable import Beagle

final class AutoCodableTests: EnvironmentTestCase {
    
    // swiftlint:disable force_unwrapping
    
    public override func setUp() {
        super.setUp()
        enviroment.coder.register(type: PolymorphicComponent.self)
        enviroment.coder.register(type: PolymorphicComponentWithoutWrapper.self)
        enviroment.coder.register(type: UnsuportedTypeComponent.self)
        enviroment.coder.register(type: PolymorphicCodableErrorComponent.self)
    }
    
    func testPolymorphicPropertyWrapper() throws {
        let component: PolymorphicComponent = try componentFromJsonFile(fileName: "PolymorphicComponent", coder: enviroment.coder)
        assertSnapshotJson(matching: component)
    }
    
    func testPolymorphicWithoutWrapper() throws {
        let component: PolymorphicComponentWithoutWrapper = try componentFromJsonFile(fileName: "PolymorphicComponentWithoutWrapper", coder: enviroment.coder)
        assertSnapshotJson(matching: component)
    }
    
    func testPolymorphicPropertyWrapperUnsuportepType() throws {
        // Given // When
        var throwError: Error?
        let closure = {
            let _: UnsuportedTypeComponent = try componentFromString("""
            {
                "_beagleComponent_": "custom:UnsuportedTypeComponent",
                "string": "string"
            }
            """, coder: self.enviroment.coder)
        }
        XCTAssertThrowsError(try closure()) {
            throwError = $0
        }
        // Then
        XCTAssertEqual(throwError as? BeagleCodableError, .unsupportedType("String"))
    }
    
    func testUnableToFindPolymorphicKey() throws {
        // Given
        let decoder = JSONDecoder()
        let data = """
        {
            "_beagleComponent_": "unknown"
        }
        """.data(using: .utf8)!
        var throwError: Error?
        // When
        XCTAssertThrowsError(try decoder.decode(PolymorphicCodableErrorStruct.self, from: data)) {
            throwError = $0
        }
        // Then
        XCTAssertEqual(throwError as? BeagleCodableError, .unableToFindBeagleTypeKey("unknown"))
    }
    
    func testUnableToCast() throws {
        // Given // When
        var throwError: Error?
        
        let closure = {
            let _: UnsuportedTypeComponent = try componentFromString("""
            {
                "_beagleComponent_": "custom:unknown"
            }
            """)
        }
        XCTAssertThrowsError(try closure()) {
            throwError = $0
        }
        // Then
        XCTAssertEqual(throwError as? BeagleCodableError, .unableToCast(decoded: "UnknownComponent(_beagleComponent_: \"custom:unknown\")", into: "UnsuportedTypeComponent"))
    }
    
    func testUnableToRepresentAsPolymorphicForEncoding() throws {
        // Given
        let encoder = JSONEncoder()
        let value = PolymorphicCodableErrorStruct()
        var throwError: Error?
        // When
        let closure = {
            _ = try encoder.encode(value)
        }
        XCTAssertThrowsError(try closure()) {
            throwError = $0
        }
        // Then
        XCTAssertEqual(throwError as? BeagleCodableError, .unableToRepresentAsBeagleTypeForEncoding)
    }
}

struct PolymorphicCodableErrorStruct: Codable {
    func encode(to encoder: Encoder) throws {
        try encoder.encode(self)
    }
    
    init(from decoder: Decoder) throws {
        self = try decoder.decode(Self.self)
    }
    init() {}
}

struct PolymorphicCodableErrorComponent: ServerDrivenComponent {
    func encode(to encoder: Encoder) throws {
        try encoder.encode(self)
    }
    
    init(from decoder: Decoder) throws {
        self = try decoder.decode(Self.self)
    }
    
    func toView(renderer: BeagleRenderer) -> UIView {
        fatalError("not implemented")
    }
    init() {}
}

struct PolymorphicComponent: ServerDrivenComponent {
    var string: String
    @AutoCodable
    var component: ServerDrivenComponent
    @AutoCodable
    var optionalComponent: ServerDrivenComponent?
    @AutoCodable
    var arrayComponent: [ServerDrivenComponent]
    @AutoCodable
    var optionalArrayComponent: [ServerDrivenComponent]?
    
    @AutoCodable
    var action: Action
    @AutoCodable
    var optionalAction: Action?
    @AutoCodable
    var arrayAction: [Action]
    @AutoCodable
    var optionalArrayAction: [Action]?
    
    func toView(renderer: BeagleRenderer) -> UIView {
        fatalError("not implemented")
    }
}

struct UnsuportedTypeComponent: ServerDrivenComponent {
    @AutoCodable
    var string: String
    
    func toView(renderer: BeagleRenderer) -> UIView {
        fatalError("not implemented")
    }
}

struct PolymorphicComponentWithoutWrapper: ServerDrivenComponent {
    var string: String
    var component: ServerDrivenComponent
    var optionalComponent: ServerDrivenComponent?
    var arrayComponent: [ServerDrivenComponent]
    var optionalArrayComponent: [ServerDrivenComponent]?
    
    var action: Action
    var optionalAction: Action?
    var arrayAction: [Action]
    var optionalArrayAction: [Action]?
    
    func toView(renderer: BeagleRenderer) -> UIView {
        fatalError("not implemented")
    }
    
    enum CodingKeys: CodingKey {
        case string
        case component
        case optionalComponent
        case arrayComponent
        case optionalArrayComponent
        case action
        case optionalAction
        case arrayAction
        case optionalArrayAction
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(string, forKey: .string)
        try container.encode(component, forKey: .component)
        try container.encodeIfPresent(optionalComponent, forKey: .optionalComponent)
        try container.encode(arrayComponent, forKey: .arrayComponent)
        try container.encodeIfPresent(optionalArrayComponent, forKey: .optionalArrayComponent)
        try container.encode(action, forKey: .action)
        try container.encodeIfPresent(optionalAction, forKey: .optionalAction)
        try container.encode(arrayAction, forKey: .arrayAction)
        try container.encodeIfPresent(optionalArrayAction, forKey: .optionalArrayAction)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.string = try container.decode(String.self, forKey: .string)
        self.component = try container.decode(forKey: .component)
        self.optionalComponent = try container.decodeIfPresent(forKey: .optionalComponent)
        self.arrayComponent = try container.decode(forKey: .arrayComponent)
        self.optionalArrayComponent = try container.decodeIfPresent(forKey: .optionalArrayComponent)
        self.action = try container.decode(forKey: .action)
        self.optionalAction = try container.decodeIfPresent(forKey: .optionalAction)
        self.arrayAction = try container.decode(forKey: .arrayAction)
        self.optionalArrayAction = try container.decodeIfPresent(forKey: .optionalArrayAction)
    }
}
