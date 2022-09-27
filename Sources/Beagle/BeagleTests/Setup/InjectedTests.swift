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

import Foundation
import XCTest
@testable import Beagle

final class InjectedTests: EnvironmentTestCase {
    // swiftlint:disable force_cast
    
    class InjectedTestClass {
        @Injected var coder: CoderProtocol
        @OptionalInjected var networkClient: NetworkClientProtocol?
    }
    
    func testInjectedGet() {
        // Given
        let sut = InjectedTestClass()
        let coderInstance = Coder()
        
        // When
        enviroment.coder = coderInstance
        injectedFailureHandler = { _ in fatalError("should not throw any error") }
        
        // Then
        assertIdentical(coderInstance, sut.coder as! Coder)
    }
    
    func testInjectedSet() {
        // Given
        let newCoder = Coder()
        let enviromentCoder = enviroment.coder
        let sut = InjectedTestClass()
        
        // When
        injectedFailureHandler = { _ in fatalError("should not throw any error") }
        
        // Then
        assertIdentical(enviromentCoder as! Coder, sut.coder as! Coder)
        sut.coder = newCoder
        assertIdentical(newCoder, sut.coder as! Coder)
    }
    
    func testOptionalInjectedGet() {
        // Given // When
        let clientInstance = NetworkClientDummy()
        let sut = InjectedTestClass()
        
        // When
        enviroment.networkClient = clientInstance
        injectedFailureHandler = { _ in fatalError("should not throw any error") }
        
        // Then
        assertIdentical(clientInstance, sut.networkClient as! NetworkClientDummy)
    }
    
    func testOptionalInjectedSet() {
        // Given
        let newClient = NetworkClientDummy()
        let sut = InjectedTestClass()
        
        // When
        injectedFailureHandler = { _ in fatalError("should not throw any error") }
        
        // Then
        XCTAssertNil(sut.networkClient)
        sut.networkClient = newClient
        assertIdentical(newClient, sut.networkClient as! NetworkClientDummy)
    }
    
    func testInjectedWithResolver() {
        // Given
        let resolver = Resolver()
        let sut = InjectedTestWithResolver(resolver)
        
        // When/Then
        XCTAssertNotNil(sut.dummy)
        XCTAssertNotNil(sut.optionalDummy)
    }
    
    private func assertIdentical(_ a: AnyObject, _ b: AnyObject) {
        XCTAssertTrue(a === b)
    }
}

class InjectedTestWithResolver {
    @Injected var dummy: DependencyDummy
    @OptionalInjected var optionalDummy: DependencyDummy?
    
    init(_ resolver: DependenciesContainerResolving) {
        _dummy = Injected(resolver)
        _optionalDummy = OptionalInjected(resolver)
    }
}

struct Resolver: DependenciesContainerResolving {
    func resolve<Dependency>() throws -> Dependency {
        DependencyDummy() as! Dependency
    }
}

struct DependencyDummy {}
