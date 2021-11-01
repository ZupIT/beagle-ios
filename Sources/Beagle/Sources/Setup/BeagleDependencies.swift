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

import UIKit

public protocol BeagleDependenciesProtocol: DependencyCoder,
    DependencyAnalyticsExecutor,
    DependencyUrlBuilder,
    DependencyNetworkClient,
    DependencyDeepLinkScreenManaging,
    DependencyNavigation,
    DependencyViewConfigurator,
    DependencyStyleViewConfigurator,
    DependencyTheme,
    DependencyPreFetching,
    DependencyAppBundle,
    DependencyViewClient,
    DependencyImageDownloader,
    DependencyLogger,
    DependencyWindowManager,
    DependencyURLOpener,
    DependencyRenderer,
    DependencyGlobalContext,
    DependencyOperationsProvider {
}

open class BeagleDependencies: BeagleDependenciesProtocol {

    public var coder: BeagleCoding
    public var urlBuilder: UrlBuilderProtocol
    public var networkClient: NetworkClient?
    public var appBundle: Bundle
    public var theme: Theme
    public var deepLinkHandler: DeepLinkScreenManaging?
    public var viewClient: ViewClient
    public var imageDownloader: ImageDownloader
    public var analyticsProvider: AnalyticsProvider?
    public var navigation: BeagleNavigation
    public var preFetchHelper: BeaglePrefetchHelping
    public var windowManager: WindowManager
    public var opener: URLOpener
    public var globalContext: GlobalContext
    public var operationsProvider: OperationsProvider
    
    public var logger: BeagleLoggerType {
        didSet {
            logger = BeagleLoggerProxy(logger: logger)
        }
    }

    // MARK: Builders

    public var renderer: (BeagleController) -> BeagleRenderer = {
        return BeagleRenderer(controller: $0)
    }

    public var style: (UIView) -> StyleViewConfiguratorProtocol = {
        return StyleViewConfigurator(view: $0)
    }

    public var viewConfigurator: (UIView) -> ViewConfiguratorProtocol = {
        return ViewConfigurator(view: $0)
    }

    private let resolver: InnerDependenciesResolver

    public init(networkClient: NetworkClient? = nil, logger: BeagleLoggerType? = nil) {
        let resolver = InnerDependenciesResolver()
        self.resolver = resolver

        self.urlBuilder = UrlBuilder()
        self.preFetchHelper = BeaglePreFetchHelper(dependencies: resolver)
        self.appBundle = Bundle.main
        self.theme = AppTheme(styles: [:])
        self.logger = BeagleLoggerProxy(logger: logger)
        self.operationsProvider = OperationsDefault(dependencies: resolver)

        self.coder = BeagleCoder()
        self.windowManager = WindowManagerDefault()
        self.navigation = BeagleNavigator()
        self.globalContext = DefaultGlobalContext()
        
        self.networkClient = networkClient
        self.viewClient = ViewClientDefault(dependencies: resolver)
        self.imageDownloader = ImageDownloaderDefault(dependencies: resolver)
        self.opener = URLOpenerDefault(dependencies: resolver)

        self.resolver.container = { [unowned self] in self }
    }
}

// MARK: Resolver

/// This class helps solving the problem of using the same dependency container to resolve
/// dependencies within dependencies.
/// The problem happened because we needed to pass `self` as dependency before `init` has concluded.
/// - Example: see where `resolver` is being used in the `BeagleDependencies` `init`.
private class InnerDependenciesResolver: ViewClientDefault.Dependencies,
    DependencyDeepLinkScreenManaging,
    DependencyViewClient,
    DependencyWindowManager,
    DependencyURLOpener {
        
    var container: () -> BeagleDependenciesProtocol = {
        fatalError("You should set this closure to get the dependencies container")
    }

    var coder: BeagleCoding { return container().coder }
    var urlBuilder: UrlBuilderProtocol { return container().urlBuilder }
    var networkClient: NetworkClient? { return container().networkClient }
    var navigation: BeagleNavigation { return container().navigation }
    var deepLinkHandler: DeepLinkScreenManaging? { return container().deepLinkHandler }
    var logger: BeagleLoggerType { return container().logger }
    var viewClient: ViewClient { return container().viewClient }
    var windowManager: WindowManager { return container().windowManager }
    var opener: URLOpener { return container().opener }
}
