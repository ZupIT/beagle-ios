//
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

// swiftlint:disable force_cast
// swiftlint:disable force_unwrapping
// Integrated tests
final class DependenciesFactoryTests: XCTestCase {
    
    var dependenciesA: BeagleDependenciesFactory {
        var dependencies = BeagleDependenciesFactory()
        dependencies.networkClient = Factory { resolver in
            NetworkClientA(resolver)
        }
        dependencies.logger = Factory { _ in
            LoggerA()
        }
        return dependencies
    }
    
    var dependenciesB: BeagleDependenciesFactory {
        var dependencies = BeagleDependenciesFactory()
        dependencies.theme = Factory { _ in
            ThemeB()
        }
        return dependencies
    }

    func testLoadDependenciesFactoryController() throws {
        let controller = BeagleScreenViewController(ScreenType.Remote(url: "url"), config: BeagleConfiguration(dependencies: dependenciesA))
        try checkConfig(controller.config)
    }
    
    func testLoadDependenciesFactoryView() throws {
        let view = BeagleView(ScreenType.Remote(url: "url"), config: BeagleConfiguration(dependencies: dependenciesA)) { _ in }
        try checkConfig(view.beagleController.config)
    }
    
    func checkConfig(_ config: BeagleConfiguration) throws {
        let client = try config.resolver.resolve() as NetworkClientProtocol
        let clientA = client as? NetworkClientA
        XCTAssertNotNil(clientA)
        XCTAssertNotNil((clientA?.logger as? LoggerProxy)?.logger as? LoggerA)
    }
    
    func testLoadTwoConfigurations() throws {
        let controllerA = BeagleScreenViewController(ScreenType.Remote(url: "urlA"), config: BeagleConfiguration(dependencies: dependenciesA))
        let controllerB = BeagleScreenViewController(ScreenType.Remote(url: "urlB"), config: BeagleConfiguration(dependencies: dependenciesB))
        
        let client: Injected<NetworkClientProtocol> = Injected(controllerA.config.resolver)
        let clientA = client.wrappedValue as? NetworkClientA
        XCTAssertNotNil(clientA)
        XCTAssertNotNil((clientA?.logger as? LoggerProxy)?.logger as? LoggerA)
        XCTAssertNil(controllerA.config.environment.theme as? ThemeB)
        
        let clientOptional: OptionalInjected<NetworkClientProtocol> = OptionalInjected(controllerB.config.resolver)
        XCTAssertNil(clientOptional.wrappedValue)
        let logger: Injected<LoggerProtocol> = Injected(controllerB.config.resolver)
        XCTAssertNil((logger.wrappedValue as! LoggerProxy).logger)
        XCTAssertNotNil(controllerB.config.environment.theme as? ThemeB)
    }

}

struct LoggerA: LoggerProtocol {
    func log(_ log: Beagle.LogType) { }
}

struct NetworkClientA: NetworkClientProtocol {
    @Injected var logger: LoggerProtocol
    
    init(_ resolver: DependenciesContainerResolving) {
        _logger = Injected(resolver)
    }
    
    func executeRequest(_ request: Beagle.Request, completion: @escaping RequestCompletion) -> Beagle.RequestToken? {
        completion(.failure(.init(error: DummyError(), request: .init(url: URL(string: "domain.com")!))))
        return nil
    }
}

struct DummyError: Error {}

struct ThemeB: ThemeProtocol {
    func applyStyle<T>(for view: T, withId id: String) where T: UIView {
        fatalError("not implemented")
    }
}
