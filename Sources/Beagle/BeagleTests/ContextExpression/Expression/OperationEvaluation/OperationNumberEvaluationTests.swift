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

final class OperationNumberEvaluationTests: OperationEvaluationTests {

    func testEvaluateSum() {
        XCTAssertEqual(evalOperation("sum(6, 4)"), 10)
        XCTAssertEqual(evalOperation("sum(4.5, 6.0)"), 10.5)
        XCTAssertEqual(evalOperation("sum(4, 6, 4)"), 14)
        XCTAssertEqual(evalOperation("sum(2.8, 4.5, 6.0)"), 13.3)
        XCTAssertEqual(evalOperation("sum(1, 1.5)"), 2.5)
        XCTAssertEqual(evalOperation("sum(2.0, 1)"), 3.0)
        XCTAssertEqual(evalOperation("sum('1', 1.0)"), 2.0)
        XCTAssertEqual(evalOperation("sum(2.5, '1.0')"), 3.5)
        XCTAssertEqual(evalOperation("sum('1', '1')"), 2)
        XCTAssertEqual(evalOperation("sum('2', 1)"), 3)
        XCTAssertEqual(evalOperation("sum('3.5', 2)"), 5.5)
        XCTAssertEqual(evalOperation("sum(1, true)"), nil)
        XCTAssertEqual(evalOperation("sum()"), nil)
    }
    
    func testEvaluateSubtract() {
        XCTAssertEqual(evalOperation("subtract(6, 4)"), 2)
        XCTAssertEqual(evalOperation("subtract(4.5, 6.0)"), -1.5)
        XCTAssertEqual(evalOperation("subtract(4, 6, 4)"), -6)
        XCTAssertEqual(evalOperation("subtract(2.8, 4.5, 6.0)"), -7.7)
        XCTAssertEqual(evalOperation("subtract(1, 1.5)"), -0.5)
        XCTAssertEqual(evalOperation("subtract(2.0, 1)"), 1.0)
        XCTAssertEqual(evalOperation("subtract('1', 1.0)"), 0.0)
        XCTAssertEqual(evalOperation("subtract(2.5, '1.0')"), 1.5)
        XCTAssertEqual(evalOperation("subtract('1', '1')"), 0)
        XCTAssertEqual(evalOperation("subtract('2', 1)"), 1)
        XCTAssertEqual(evalOperation("subtract('3.5', 2)"), 1.5)
        XCTAssertEqual(evalOperation("subtract(1, true)"), nil)
        XCTAssertEqual(evalOperation("subtract()"), nil)
    }
    
    func testEvaluateMultiply() {
        XCTAssertEqual(evalOperation("multiply(6, 4)"), 24)
        XCTAssertEqual(evalOperation("multiply(4.5, 6.0)"), 27.0)
        XCTAssertEqual(evalOperation("multiply(4, 6, 4)"), 96)
        XCTAssertEqual(evalOperation("multiply(2.8, 4.5, 6.0)"), 75.6)
        XCTAssertEqual(evalOperation("multiply(1, 1.5)"), 1.5)
        XCTAssertEqual(evalOperation("multiply(2.0, 1)"), 2.0)
        XCTAssertEqual(evalOperation("multiply('1', 1.0)"), 1.0)
        XCTAssertEqual(evalOperation("multiply(2.5, '1.0')"), 2.5)
        XCTAssertEqual(evalOperation("multiply('1', '1')"), 1)
        XCTAssertEqual(evalOperation("multiply('2', 1)"), 2)
        XCTAssertEqual(evalOperation("multiply('3.5', 2)"), 7.0)
        XCTAssertEqual(evalOperation("multiply(1, true)"), nil)
        XCTAssertEqual(evalOperation("multiply()"), nil)
    }
    
    func testEvaluateDivide() {
        XCTAssertEqual(evalOperation("divide(6, 4)"), 1.5)
        XCTAssertEqual(evalOperation("divide(4.5, 6.0)"), 0.75)
        XCTAssertEqual(evalOperation("divide(4, 6, 4)"), 0.16666666666666666)
        XCTAssertEqual(evalOperation("divide(2.8, 4.5, 6.0)"), 0.1037037037037037)
        XCTAssertEqual(evalOperation("divide(1, 1.5)"), 0.6666666666666666)
        XCTAssertEqual(evalOperation("divide(2.0, 1)"), 2.0)
        XCTAssertEqual(evalOperation("divide('1', 1.0)"), 1.0)
        XCTAssertEqual(evalOperation("divide(2.5, '1.0')"), 2.5)
        XCTAssertEqual(evalOperation("divide('1', '1')"), 1.0)
        XCTAssertEqual(evalOperation("divide('2', 1)"), 2.0)
        XCTAssertEqual(evalOperation("divide('3.5', 2)"), 1.75)
        XCTAssertEqual(evalOperation("divide(1, true)"), nil)
        XCTAssertEqual(evalOperation("divide()"), nil)
    }
}

// swiftlint:disable force_unwrapping
func evalOperation(_ string: String, _ context: Context? = nil) -> DynamicObject {
    let view = UIView()
    if let context = context {
        view.setContext(context)
    }
    return Operation(rawValue: string)!.evaluate(in: view)
}
