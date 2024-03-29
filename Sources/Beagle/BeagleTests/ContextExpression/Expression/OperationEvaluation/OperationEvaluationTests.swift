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

typealias Operation = Beagle.Operation

class OperationEvaluationTests: EnvironmentTestCase {
    func evaluateOperations(_ operations: [Operation], contexts: [Context], completion: ([DynamicObject]) -> Void) {
        // Given
        let view = UIView()
        
        // When
        contexts.forEach { view.setContext($0) }
        let evaluatedResults = operations.map {
            $0.evaluate(in: view)
        }
        
        // Then
        completion(evaluatedResults)
    }
}

extension String {
    func toOperation(name: String) -> Operation? {
        Operation(rawValue: name + "(\(self))")
    }
}

extension Array where Element == String {
    func toOperations(name: String) -> [Operation] {
        self.compactMap { $0.toOperation(name: name) }
    }
}
