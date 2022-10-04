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
@testable import Beagle

// swiftlint:disable force_unwrapping

final class OperationComparisonEvaluationTests: OperationEvaluationTests {
    
    func testGt() {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "gt(2, 1)")!,
            Operation(rawValue: "gt(1, 1)")!,
            Operation(rawValue: "gt(1, 2)")!,
            
            Operation(rawValue: "gt(2.0, 1.0)")!,
            Operation(rawValue: "gt(2.0, 1)")!,
            Operation(rawValue: "gt(1.0, 1)")!,
            Operation(rawValue: "gt(1.0, 2)")!,
            
            Operation(rawValue: "gt('2', 1.0)")!,
            Operation(rawValue: "gt('2', 1)")!,
            Operation(rawValue: "gt('2', '1')")!,
            Operation(rawValue: "gt('1', '1')")!,
            Operation(rawValue: "gt('1', '1.0')")!,
            Operation(rawValue: "gt('1.0', 2.0)")!,
            Operation(rawValue: "gt('1.0', '2.0')")!,
            
            Operation(rawValue: "gt(true, 2)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            true,
            false,
            false,
            
            true,
            true,
            false,
            false,
            
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            
            false
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testGte() {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "gte(2, 1)")!,
            Operation(rawValue: "gte(1, 1)")!,
            Operation(rawValue: "gte(1, 2)")!,
            
            Operation(rawValue: "gte(2.0, 1.0)")!,
            Operation(rawValue: "gte(2.0, 1)")!,
            Operation(rawValue: "gte(1.0, 1)")!,
            Operation(rawValue: "gte(1.0, 2)")!,
            
            Operation(rawValue: "gte('2', 1.0)")!,
            Operation(rawValue: "gte('2', 1)")!,
            Operation(rawValue: "gte('2', '1')")!,
            Operation(rawValue: "gte('1', '1')")!,
            Operation(rawValue: "gte('1', '1.0')")!,
            Operation(rawValue: "gte('1.0', 2.0)")!,
            Operation(rawValue: "gte('1.0', '2.0')")!,
            
            Operation(rawValue: "gte(true, 2)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            true,
            true,
            false,
            
            true,
            true,
            true,
            false,
            
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            
            false
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testLt() {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "lt(2, 1)")!,
            Operation(rawValue: "lt(1, 1)")!,
            Operation(rawValue: "lt(1, 2)")!,
            
            Operation(rawValue: "lt(2.0, 1.0)")!,
            Operation(rawValue: "lt(2.0, 1)")!,
            Operation(rawValue: "lt(1.0, 1)")!,
            Operation(rawValue: "lt(1.0, 2)")!,
            
            Operation(rawValue: "lt('2', 1.0)")!,
            Operation(rawValue: "lt('2', 1)")!,
            Operation(rawValue: "lt('2', '1')")!,
            Operation(rawValue: "lt('1', '1')")!,
            Operation(rawValue: "lt('1', '1.0')")!,
            Operation(rawValue: "lt('1.0', 2.0)")!,
            Operation(rawValue: "lt('1.0', '2.0')")!,
            
            Operation(rawValue: "lt(true, 2)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            false,
            false,
            true,
            
            false,
            false,
            false,
            true,
            
            false,
            false,
            false,
            false,
            false,
            true,
            true,
            
            false
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testLte() {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "lte(2, 1)")!,
            Operation(rawValue: "lte(1, 1)")!,
            Operation(rawValue: "lte(1, 2)")!,
            
            Operation(rawValue: "lte(2.0, 1.0)")!,
            Operation(rawValue: "lte(2.0, 1)")!,
            Operation(rawValue: "lte(1.0, 1)")!,
            Operation(rawValue: "lte(1.0, 2)")!,
            
            Operation(rawValue: "lte('2', 1.0)")!,
            Operation(rawValue: "lte('2', 1)")!,
            Operation(rawValue: "lte('2', '1')")!,
            Operation(rawValue: "lte('1', '1')")!,
            Operation(rawValue: "lte('1', '1.0')")!,
            Operation(rawValue: "lte('1.0', 2.0)")!,
            Operation(rawValue: "lte('1.0', '2.0')")!,
            
            Operation(rawValue: "lte(true, 2)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            false,
            true,
            true,
            
            false,
            false,
            true,
            true,
            
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            
            false
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
    func testEq() {
        let view = UIView()
        
        let operations = [
            Operation(rawValue: "eq(2, 1)")!,
            Operation(rawValue: "eq(1, 1)")!,
            Operation(rawValue: "eq(1, 2)")!,
            
            Operation(rawValue: "eq(2.0, 1.0)")!,
            Operation(rawValue: "eq(2.0, 1)")!,
            Operation(rawValue: "eq(1.0, 1)")!,
            Operation(rawValue: "eq(1.0, 2)")!,
            
            Operation(rawValue: "eq('2', 1.0)")!,
            Operation(rawValue: "eq('2', 1)")!,
            Operation(rawValue: "eq('2', '1')")!,
            Operation(rawValue: "eq('1', '1')")!,
            Operation(rawValue: "eq('1', '1.0')")!,
            Operation(rawValue: "eq('1.0', 2.0)")!,
            Operation(rawValue: "eq('1.0', '2.0')")!,
            
            Operation(rawValue: "eq(true, true)")!,
            Operation(rawValue: "eq(true, false)")!,
            Operation(rawValue: "eq('no', 'no')")!,
            Operation(rawValue: "eq('no', 'yes')")!,
            Operation(rawValue: "eq(true, 2)")!
        ]
        
        let result = operations.map { $0.evaluate(in: view) }
        
        let expexted: [DynamicObject] = [
            false,
            true,
            false,
            
            false,
            false,
            true,
            false,
            
            false,
            false,
            false,
            true,
            true,
            false,
            false,
            
            true,
            false,
            true,
            false,
            false
        ]
        
        XCTAssertEqual(result, expexted)
    }
    
}
