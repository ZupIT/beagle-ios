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
import SnapshotTesting

// swiftlint:disable force_cast
final class DependenciesContainerTests: XCTestCase {
    
    private let sut: DependenciesContainer = {
        var dependencies = BeagleDependencies()
        // swiftlint:disable discouraged_direct_init
        dependencies.appBundle.bundle = Bundle()
        dependencies.imageProvider = ImageProvider()
        
        return DependenciesContainer(dependencies: dependencies)
    }()
    
    func testDefaultDependencies() {
        assertSnapshot(matching: sut, as: .dump)
    }
    
    func testCustomDependencies() {
        // Given // When
        var customDependencies = BeagleDependencies()
        customDependencies.networkClient = NetworkClientDummy()
        customDependencies.appBundle = BundleDummy()
        customDependencies.logger = LoggerDummy()
        customDependencies.coder = CoderDummy()
        customDependencies.urlBuilder = UrlBuilderDummy()
        customDependencies.deepLinkHandler = DeepLinkHandlerDummy()
        customDependencies.analyticsProvider = AnalyticsProviderDummy()
        customDependencies.imageDownloader = ImageDownloaderDummy()
        customDependencies.theme = AppThemeDummy()
        customDependencies.viewClient = ViewClientDummy()
        customDependencies.imageProvider = ImageProviderDummy()
        
        let sut = DependenciesContainer(dependencies: customDependencies)
        
        // Then
        assertSnapshot(matching: sut, as: .dump)
    }
    
    func testCustomDependenciesFactory() {
        // Given // When
        var customDependencies = BeagleDependenciesFactory()
        customDependencies.networkClient = Factory { _ in
            NetworkClientDummy()
        }
        customDependencies.appBundle = Factory { _ in
            BundleDummy()
        }
        customDependencies.logger = Factory { _ in
            LoggerDummy()
        }
        customDependencies.coder = Factory { _ in
            CoderDummy()
        }
        customDependencies.urlBuilder = Factory { _ in
            UrlBuilderDummy()
        }
        customDependencies.deepLinkHandler = Factory { _ in
            DeepLinkHandlerDummy()
        }
        customDependencies.analyticsProvider = Factory { _ in
            AnalyticsProviderDummy()
        }
        customDependencies.imageDownloader = Factory { _ in
            ImageDownloaderDummy()
        }
        customDependencies.theme = Factory { _ in
            AppThemeDummy()
        }
        customDependencies.viewClient = Factory { _ in
            ViewClientDummy()
        }
        customDependencies.imageProvider = Factory { _ in
            ImageProviderDummy()
        }
        
        let sut = DependenciesContainer(dependencies: customDependencies)
        
        // Then
        assertSnapshot(matching: sut, as: .dump)
    }
    
    func testResolve() {
        // Given // When
        let block = { let _: CoderProtocol = try self.sut.resolve() }
        
        // Then
        XCTAssertNoThrow(try block())
    }
    
    func testResolveForUnresolvedDependency() {
        // Given // When
        let block = { let _: DummyDependency = try self.sut.resolve() }
        
        // Then
        XCTAssertThrowsError(try block(), "Should throw error for unregistered dependencies") { error in
            guard case DependenciesContainer.ContainerError.couldNotFindInstanceForType = error else {
                XCTFail("Should throw couldNotFindInstanceForType error")
                return
            }
        }
    }
    
    // MARK: - Integrated
    func testResolveForFactory() {
        // Given // When
        var customDependencies = BeagleDependenciesFactory()
        customDependencies.deepLinkHandler = Factory { _ in
            DeepLinkHandlerDummy()
        }
        customDependencies.analyticsProvider = Factory { _ in
            AnalyticsProviderDummy()
        }
        let sut = DependenciesContainer(dependencies: customDependencies)
        let block = {
            let _: CoderProtocol = try sut.resolve()
            let _: BundleProtocol = try sut.resolve()
            let _: WindowManagerProtocol = try sut.resolve()
            let _: OperationsProviderProtocolInternal = try sut.resolve()
            let _: ThemeProtocol = try sut.resolve()
            let _: PrefetchHelperProtocol = try sut.resolve()
            let _: URLOpenerProtocol = try sut.resolve()
            let _: ImageDownloaderProtocol = try sut.resolve()
            let _: ImageProviderProtocol = try sut.resolve()
            let _: AnalyticsProviderProtocol = try sut.resolve()
            let _: AnalyticsService = try sut.resolve()
            let _: DeepLinkScreenManagerProtocol = try sut.resolve()
        }
        
        // Then
        XCTAssertNoThrow(try block())
    }
    
    func testDependenciesFactoryCoder() {
        let coderSpy = CoderSpy()
        var customDependencies = BeagleDependenciesFactory()
        customDependencies.coder = Factory { _ in
            coderSpy
        }
        
        let configuration = BeagleConfiguration(dependencies: customDependencies)
        configuration.dependencies.coder.register(type: ComponentDummy.self)
        
        assertSnapshot(matching: coderSpy.types, as: .dump)
    }
    
    func testDependenciesFactoryNavigator() {
        let customDependencies = BeagleDependenciesFactory()
        let navDummy = NavigationDummy()
        
        let configuration = BeagleConfiguration(dependencies: customDependencies)
        
        configuration.dependencies.navigator.setDefaultAnimation(BeagleNavigatorAnimation())
        configuration.dependencies.navigator.registerDefaultNavigationController { navDummy }
        configuration.dependencies.navigator.registerNavigationController(builder: { navDummy }, forId: "dummy")
        
        let navigator = configuration.dependencies.navigator as! Navigator
        
        assertSnapshot(matching: navigator.defaultAnimation, as: .dump)
        
        XCTAssertTrue(navigator.defaultBuilder?() === navDummy)
        XCTAssertTrue(navigator.builders["dummy"]?() === navDummy)
    }
    
    func testDependenciesFactoryOperations() {
        let customDependencies = BeagleDependenciesFactory()
        
        let configuration = BeagleConfiguration(dependencies: customDependencies)
        configuration.environment.operationsProvider.register(operationId: "dummy") { _ in .empty }
        
        let provider = configuration.environment.operationsProvider as! OperationsProvider
        
        XCTAssertNotNil(provider.operations["dummy"])
    }
}

protocol DummyDependency { }

class NavigationDummy: BeagleNavigationController {}

class CoderSpy: CoderProtocol {
    var types: [(BeagleCodable.Type, String?)] = []
    func register<T>(type: T.Type, named: String?) where T: Beagle.BeagleCodable {
        types.append((type, named))
    }
    
    func decode<T>(from data: Data) throws -> T {
        fatalError("unimplemented")
    }
    
    func encode<T>(value: T) throws -> Data where T: Beagle.BeagleCodable {
        fatalError("unimplemented")
    }
    
    func name(for type: Beagle.BeagleCodable.Type) -> String? {
        fatalError("unimplemented")
    }
    
    func type(for name: String, baseType: Beagle.Coder.BaseType) -> Beagle.BeagleCodable.Type? {
        fatalError("unimplemented")
    }
}
