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

import UIKit

public struct BeagleConfigurator {
    public static func setup(dependencies: BeagleDependencies) {
        GlobalConfiguration = BeagleConfiguration(dependencies: dependencies)
    }
}

public struct BeagleDependencies {
    
    // MARK: Custom Dependencies
    public var coder: CoderProtocol = Coder()
    public var urlBuilder: UrlBuilderProtocol = UrlBuilder()
    public var theme: ThemeProtocol = AppTheme()
    public var viewClient: ViewClientProtocol = ViewClient()
    public var imageDownloader: ImageDownloaderProtocol = ImageDownloader()
    public var logger: LoggerProtocol?
    public var analyticsProvider: AnalyticsProviderProtocol?
    public var deepLinkHandler: DeepLinkScreenManagerProtocol?
    public var networkClient: NetworkClientProtocol?
    public var imageProvider: ImageProviderProtocol = ImageProvider()
    
    // MARK: Public Dependencies
    public var appBundle: BundleProtocol = MainBundle()
    public let globalContext: GlobalContextProtocol = GlobalContext()
    public var navigator: NavigationProtocol { internalNavigator }
    public var operationsProvider: OperationsProviderProtocol { internalOperationsProvider }
    
    // MARK: Internal Dependencies
    let preFetchHelper: PrefetchHelperProtocol = PreFetchHelper()
    let windowManager: WindowManagerProtocol = WindowManager()
    let opener: URLOpenerProtocol = URLOpener()
    let internalNavigator: NavigationProtocolInternal = Navigator()
    let internalOperationsProvider: OperationsProviderProtocolInternal = OperationsProvider()
    
    public init() {}
}

public struct BeagleDependenciesFactory {
    // MARK: - Public
    public var coder: Factory<CoderProtocol> = Factory { resolver in
        Coder(resolver)
    }
    public var urlBuilder: Factory<UrlBuilderProtocol> = Factory { _ in
        UrlBuilder()
    }
    public var theme: Factory<ThemeProtocol> = Factory { _ in
        AppTheme()
    }
    public var viewClient: Factory<ViewClientProtocol> = Factory { resolver in
        ViewClient(resolver)
    }
    public var imageDownloader: Factory<ImageDownloaderProtocol> = Factory { resolver in
        ImageDownloader(resolver)
    }
    
    public var logger: Factory<LoggerProtocol>?
    public var analyticsProvider: Factory<AnalyticsProviderProtocol>?
    public var deepLinkHandler: Factory<DeepLinkScreenManagerProtocol>?
    public var networkClient: Factory<NetworkClientProtocol>?
    
    public var imageProvider: Factory<ImageProviderProtocol> = Factory { resolver in
        ImageProvider(resolver)
    }
    public var appBundle: Factory<BundleProtocol> = Factory { _ in
        MainBundle()
    }
    
    public mutating func register<T: BeagleCodable>(type: T.Type, named: String? = nil) {
        types.append((type, named))
    }
    
    public mutating func setDefaultAnimation(_ animation: BeagleNavigatorAnimation) {
        defaultAnimation = animation
    }
    
    /// Register the default `BeagleNavigationController` to be used when creating a new navigation flow.
    /// - Parameter builder: will be called when a `BeagleNavigationController` custom type needs to be used.
    public mutating func registerDefaultNavigationController(builder: @escaping () -> BeagleNavigationController) {
        navigationBuilder = builder
    }

    /// Register a `BeagleNavigationController` to be used when creating a new navigation flow with the associated `controllerId`.
    /// - Parameters:
    ///   - builder: will be called when a `BeagleNavigationController` custom type needs to be used.
    ///   - controllerId: the cross platform id that identifies the controller in the BFF.
    public mutating func registerNavigationController(builder: @escaping () -> BeagleNavigationController, forId controllerId: String) {
        navigations.append((builder, controllerId))
    }
    
    /// Use this function to register your custom operation.
    /// - Warning:
    ///     - Be careful when replacing a default operation in Beagle, consider creating it using `custom()`
    ///     - Custom Operations names must have at least 1 letter. It can also contain numbers and the character _
    /// - Parameters:
    ///   - operation: The custom operation you wish to register.
    ///   - handler: A closure where you tell us what your custom operation should do.
    public mutating func register(operationId: String, handler: @escaping OperationHandler) {
        operations.append((operationId, handler))
    }
    
    public init() { }
    
    // MARK: Internal
    let globalContext: GlobalContextProtocol = GlobalContext()
    let windowManager: WindowManagerProtocol = WindowManager()
    let preFetchHelper: Factory<PrefetchHelperProtocol> = Factory { resolver in
        PreFetchHelper(resolver)
    }
    let opener: Factory<URLOpenerProtocol> = Factory { resolver in
        URLOpener(resolver)
    }
    
    var types: [(BeagleCodable.Type, String?)] = []
    var internalCoder: Factory<CoderProtocol> {
        Factory { resolver in
            let result = self.coder.create(resolver)
            self.types.forEach {
                result.register(type: $0.0, named: $0.1)
            }
            return result
        }
    }
    
    var defaultAnimation: BeagleNavigatorAnimation?
    var navigationBuilder: (() -> BeagleNavigationController)?
    var navigations: [(() -> BeagleNavigationController, String)] = []
    var internalNavigator: Factory<NavigationProtocolInternal> {
        Factory { resolver in
            let result = Navigator(resolver)
            if let defaultAnimation = self.defaultAnimation {
                result.setDefaultAnimation(defaultAnimation)
            }
            if let navigationBuilder = self.navigationBuilder {
                result.registerDefaultNavigationController(builder: navigationBuilder)
            }
            self.navigations.forEach {
                result.registerNavigationController(builder: $0.0, forId: $0.1)
            }
            return result
        }
    }
    
    var operations: [(String, OperationHandler)] = []
    var internalOperationsProvider: Factory<OperationsProviderProtocolInternal> {
        Factory { resolver in
            let result = OperationsProvider(resolver)
            self.operations.forEach {
                result.register(operationId: $0.0, handler: $0.1)
            }
            return result
        }
    }
}

public struct Factory<T> {
    var create: (DependenciesContainerResolving) -> T
    
    public init(_ createBlock: @escaping (DependenciesContainerResolving) -> T) {
        self.create = createBlock
    }
}
