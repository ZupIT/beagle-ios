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
@testable import Beagle
import XCTest

class TestEnviroment: DependenciesContainerResolving, EnviromentProtocol {
    
    // MARK: - Dependencies
    
    var coder: CoderProtocol = Coder()
    var urlBuilder: UrlBuilderProtocol = UrlBuilder()
    var appBundle: BundleProtocol = MainBundle()
    var theme: ThemeProtocol = AppTheme()
    var viewClient: ViewClientProtocol = ViewClient()
    var imageDownloader: ImageDownloaderProtocol = ImageDownloader()
    var navigator: NavigationProtocolInternal = Navigator()
    var preFetchHelper: PrefetchHelperProtocol = PreFetchHelper()
    var windowManager: WindowManagerProtocol = WindowManager()
    var opener: URLOpenerProtocol = URLOpener()
    var globalContext: GlobalContextProtocol = GlobalContext()
    var operationsProvider: OperationsProviderProtocolInternal = OperationsProvider()
    var logger: LoggerProtocol = LoggerProxy(logger: nil)
    var analyticsProvider: AnalyticsProviderProtocol?
    var deepLinkHandler: DeepLinkScreenManagerProtocol?
    var networkClient: NetworkClientProtocol?
    var imageProvider: ImageProviderProtocol = ImageProvider()
    
    // MARK: - Builders
    
    var renderer: (BeagleController) -> BeagleRenderer = {
        return BeagleRenderer(controller: $0)
    }
    
    var style: (UIView) -> StyleViewConfiguratorProtocol = {
        return StyleViewConfigurator(view: $0)
    }
    
    var viewConfigurator: (UIView) -> ViewConfiguratorProtocol = {
        return ViewConfigurator(view: $0)
    }
    
    // MARK: Instance Map
    
    lazy var instances: [String: () -> Any?] = [
        mapKey(for: CoderProtocol.self): { self.coder },
        mapKey(for: UrlBuilderProtocol.self): { self.urlBuilder },
        mapKey(for: BundleProtocol.self): { self.appBundle },
        mapKey(for: ThemeProtocol.self): { self.theme },
        mapKey(for: ViewClientProtocol.self): { self.viewClient } ,
        mapKey(for: ImageDownloaderProtocol.self): { self.imageDownloader },
        mapKey(for: NavigationProtocolInternal.self): { self.navigator },
        mapKey(for: PrefetchHelperProtocol.self): { self.preFetchHelper },
        mapKey(for: WindowManagerProtocol.self): { self.windowManager },
        mapKey(for: URLOpenerProtocol.self): { self.opener } ,
        mapKey(for: GlobalContextProtocol.self): { self.globalContext },
        mapKey(for: OperationsProviderProtocolInternal.self): { self.operationsProvider },
        mapKey(for: LoggerProtocol.self): { self.logger },
        mapKey(for: NetworkClientProtocol.self): { self.networkClient },
        mapKey(for: DeepLinkScreenManagerProtocol.self): { self.deepLinkHandler },
        mapKey(for: AnalyticsProviderProtocol.self): { self.analyticsProvider },
        mapKey(for: ImageProviderProtocol.self): { self.imageProvider }
    ]
    
    // MARK: - DependenciesContainerResolving
    
    func resolve<Dependency>() throws -> Dependency {
        guard let instance = instances[mapKey(for: Dependency.self)],
              let typedInstace = instance() as? Dependency
        else {
            throw TestEnviromentError.couldNotResolveDependency(dependency: mapKey(for: Dependency.self))
        }
        
        return typedInstace
    }
    
    enum TestEnviromentError: Error {
        case couldNotResolveDependency(dependency: String)
    }
    
    // MARK: - Private Functions
    
    private func mapKey<T>(for type: T) -> String {
        String(describing: type)
    }
}

// MARK: - Enviroment Test Case

class EnviromentTestCase: XCTestCase {
    
    var enviroment = TestEnviroment()
    
    override func setUp() {
        CurrentResolver = enviroment
        CurrentEnviroment = enviroment
        super.setUp()
    }
    
    override func tearDown() {
        enviroment = TestEnviroment()
        CurrentResolver = DependenciesContainer.global
        CurrentEnviroment = BeagleEnviroment.global
        super.tearDown()
    }
}
