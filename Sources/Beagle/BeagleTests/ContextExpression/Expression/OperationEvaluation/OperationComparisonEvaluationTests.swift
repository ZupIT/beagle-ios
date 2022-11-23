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

final class OperationComparisonEvaluationTests: OperationEvaluationTests {
    
    func testGt() {
        XCTAssertEqual(evalOperation("gt(2, 1)"), true)
        XCTAssertEqual(evalOperation("gt(1, 1)"), false)
        XCTAssertEqual(evalOperation("gt(1, 2)"), false)
        
        XCTAssertEqual(evalOperation("gt(2.0, 1.0)"), true)
        XCTAssertEqual(evalOperation("gt(2.0, 1)"), true)
        XCTAssertEqual(evalOperation("gt(1.0, 1)"), false)
        XCTAssertEqual(evalOperation("gt(1.0, 2)"), false)
        
        XCTAssertEqual(evalOperation("gt('2', 1.0)"), true)
        XCTAssertEqual(evalOperation("gt('2', 1)"), true)
        XCTAssertEqual(evalOperation("gt('2', '1')"), true)
        XCTAssertEqual(evalOperation("gt('1', '1')"), false)
        XCTAssertEqual(evalOperation("gt('1', '1.0')"), false)
        XCTAssertEqual(evalOperation("gt('1.0', 2.0)"), false)
        XCTAssertEqual(evalOperation("gt('1.0', '2.0')"), false)
        
        XCTAssertEqual(evalOperation("gt(true, 2)"), false)
    }
    
    func testGte() {
        XCTAssertEqual(evalOperation("gte(2, 1)"), true)
        XCTAssertEqual(evalOperation("gte(1, 1)"), true)
        XCTAssertEqual(evalOperation("gte(1, 2)"), false)
        
        XCTAssertEqual(evalOperation("gte(2.0, 1.0)"), true)
        XCTAssertEqual(evalOperation("gte(2.0, 1)"), true)
        XCTAssertEqual(evalOperation("gte(1.0, 1)"), true)
        XCTAssertEqual(evalOperation("gte(1.0, 2)"), false)
        
        XCTAssertEqual(evalOperation("gte('2', 1.0)"), true)
        XCTAssertEqual(evalOperation("gte('2', 1)"), true)
        XCTAssertEqual(evalOperation("gte('2', '1')"), true)
        XCTAssertEqual(evalOperation("gte('1', '1')"), true)
        XCTAssertEqual(evalOperation("gte('1', '1.0')"), true)
        XCTAssertEqual(evalOperation("gte('1.0', 2.0)"), false)
        XCTAssertEqual(evalOperation("gte('1.0', '2.0')"), false)
        
        XCTAssertEqual(evalOperation("gte(true, 2)"), false)
    }
    
    func testLt() {
        XCTAssertEqual(evalOperation("lt(2, 1)"), false)
        XCTAssertEqual(evalOperation("lt(1, 1)"), false)
        XCTAssertEqual(evalOperation("lt(1, 2)"), true)
        
        XCTAssertEqual(evalOperation("lt(2.0, 1.0)"), false)
        XCTAssertEqual(evalOperation("lt(2.0, 1)"), false)
        XCTAssertEqual(evalOperation("lt(1.0, 1)"), false)
        XCTAssertEqual(evalOperation("lt(1.0, 2)"), true)
        
        XCTAssertEqual(evalOperation("lt('2', 1.0)"), false)
        XCTAssertEqual(evalOperation("lt('2', 1)"), false)
        XCTAssertEqual(evalOperation("lt('2', '1')"), false)
        XCTAssertEqual(evalOperation("lt('1', '1')"), false)
        XCTAssertEqual(evalOperation("lt('1', '1.0')"), false)
        XCTAssertEqual(evalOperation("lt('1.0', 2.0)"), true)
        XCTAssertEqual(evalOperation("lt('1.0', '2.0')"), true)
        
        XCTAssertEqual(evalOperation("lt(true, 2)"), false)
    }
    
    func testLte() {
        XCTAssertEqual(evalOperation("lte(2, 1)"), false)
        XCTAssertEqual(evalOperation("lte(1, 1)"), true)
        XCTAssertEqual(evalOperation("lte(1, 2)"), true)
        
        XCTAssertEqual(evalOperation("lte(2.0, 1.0)"), false)
        XCTAssertEqual(evalOperation("lte(2.0, 1)"), false)
        XCTAssertEqual(evalOperation("lte(1.0, 1)"), true)
        XCTAssertEqual(evalOperation("lte(1.0, 2)"), true)
        
        XCTAssertEqual(evalOperation("lte('2', 1.0)"), false)
        XCTAssertEqual(evalOperation("lte('2', 1)"), false)
        XCTAssertEqual(evalOperation("lte('2', '1')"), false)
        XCTAssertEqual(evalOperation("lte('1', '1')"), true)
        XCTAssertEqual(evalOperation("lte('1', '1.0')"), true)
        XCTAssertEqual(evalOperation("lte('1.0', 2.0)"), true)
        XCTAssertEqual(evalOperation("lte('1.0', '2.0')"), true)
        
        XCTAssertEqual(evalOperation("lte(true, 2)"), false)
    }
    
    func testEq() {
        XCTAssertEqual(evalOperation("eq(2, 1)"), false)
        XCTAssertEqual(evalOperation("eq(1, 1)"), true)
        XCTAssertEqual(evalOperation("eq(1, 2)"), false)
        
        XCTAssertEqual(evalOperation("eq(2.0, 1.0)"), false)
        XCTAssertEqual(evalOperation("eq(2.0, 1)"), false)
        XCTAssertEqual(evalOperation("eq(1.0, 1)"), true)
        XCTAssertEqual(evalOperation("eq(1.0, 2)"), false)
        
        XCTAssertEqual(evalOperation("eq('2', 1.0)"), false)
        XCTAssertEqual(evalOperation("eq('2', 1)"), false)
        XCTAssertEqual(evalOperation("eq('2', '1')"), false)
        XCTAssertEqual(evalOperation("eq('1', '1')"), true)
        XCTAssertEqual(evalOperation("eq('1', '1.0')"), true)
        XCTAssertEqual(evalOperation("eq('1.0', 2.0)"), false)
        XCTAssertEqual(evalOperation("eq('1.0', '2.0')"), false)
        
        XCTAssertEqual(evalOperation("eq(true, true)"), true)
        XCTAssertEqual(evalOperation("eq(true, false)"), false)
        XCTAssertEqual(evalOperation("eq('no', 'no')"), true)
        XCTAssertEqual(evalOperation("eq('no', 'yes')"), false)
        XCTAssertEqual(evalOperation("eq(true, 2)"), false)
    }
    
}
