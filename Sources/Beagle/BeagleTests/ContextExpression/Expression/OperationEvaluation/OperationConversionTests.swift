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

class OperationConversionTests: XCTestCase {

    func testInt() throws {
        XCTAssertEqual(evalOperation("int(1)"), 1)
        XCTAssertEqual(evalOperation("int(1.1)"), 1)
        XCTAssertEqual(evalOperation("int('1')"), 1)
        XCTAssertEqual(evalOperation("int('1.1')"), 1)
        XCTAssertEqual(evalOperation("int('string')"), nil)
    }
    
    func testDouble() throws {
        XCTAssertEqual(evalOperation("double(1)"), 1.0)
        XCTAssertEqual(evalOperation("double(1.1)"), 1.1)
        XCTAssertEqual(evalOperation("double('1')"), 1.0)
        XCTAssertEqual(evalOperation("double('1.1')"), 1.1)
        XCTAssertEqual(evalOperation("double('string')"), nil)
    }
    
    func testString() throws {
        XCTAssertEqual(evalOperation("string(1)"), "1")
        XCTAssertEqual(evalOperation("string(1.1)"), "1.1")
        XCTAssertEqual(evalOperation("string(true)"), "true")
        XCTAssertEqual(evalOperation("string('string')"), "string")
                                     
        XCTAssertEqual(evalOperation("string(context.int)", Context(id: "context", value: ["int": 1])), "1")
        XCTAssertEqual(evalOperation("string(context.array)", Context(id: "context", value: ["array": [1, 2]])), nil)
    }

}
