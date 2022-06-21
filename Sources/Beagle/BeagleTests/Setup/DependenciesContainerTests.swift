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
}

protocol DummyDependency { }
