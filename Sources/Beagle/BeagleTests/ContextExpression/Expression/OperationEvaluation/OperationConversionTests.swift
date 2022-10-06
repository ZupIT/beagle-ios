//
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

// swiftlint:disable force_unwrapping

class OperationConversionTests: XCTestCase {

    func testInt() throws {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "int(1)")!,
            Operation(rawValue: "int(1.1)")!,
            Operation(rawValue: "int('1')")!,
            Operation(rawValue: "int('1.1')")!,
            Operation(rawValue: "int('string')")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            1,
            1,
            1,
            nil,
            nil
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testDouble() throws {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "double(1)")!,
            Operation(rawValue: "double(1.1)")!,
            Operation(rawValue: "double('1')")!,
            Operation(rawValue: "double('1.1')")!,
            Operation(rawValue: "double('string')")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            1.0,
            1.1,
            1.0,
            1.1,
            nil
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testString() throws {
        let view = UIView()
        view.setContext(Context(id: "context", value: ["int": 1, "array": [1, 2]]))
        
        let operations = [
            Operation(rawValue: "string(1)")!,
            Operation(rawValue: "string(1.1)")!,
            Operation(rawValue: "string(true)")!,
            Operation(rawValue: "string('string')")!,
            Operation(rawValue: "string(context.int)")!,
            Operation(rawValue: "string(context.array)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            "1",
            "1.1",
            "true",
            "string",
            "1",
            nil
        ]
        
        XCTAssertEqual(result, expexted)
    }

}
