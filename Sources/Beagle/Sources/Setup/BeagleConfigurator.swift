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
        GlobalConfig = BeagleConfig(dependencies: dependencies)
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
    // MARK: Custom
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
    
    // MARK: Internal
    let globalContext: GlobalContextProtocol = GlobalContext()
    let windowManager: WindowManagerProtocol = WindowManager()
    let preFetchHelper: Factory<PrefetchHelperProtocol> = Factory { resolver in
        PreFetchHelper(resolver)
    }
    let opener: Factory<URLOpenerProtocol> = Factory { resolver in
        URLOpener(resolver)
    }
    let internalNavigator: Factory<NavigationProtocolInternal> = Factory { resolver in
        Navigator(resolver)
    }
    let internalOperationsProvider: Factory<OperationsProviderProtocolInternal> = Factory { resolver in
        OperationsProvider(resolver)
    }
    
    public init() { }
}

public struct Factory<T> {
    var create: (DependenciesContainerResolving) -> T
    
    public init(_ createBlock: @escaping (DependenciesContainerResolving) -> T) {
        self.create = createBlock
    }
}
