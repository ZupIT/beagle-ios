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
        // swiftlint:disable resolver_change
        CurrentResolver = DependenciesContainer(dependencies: dependencies)
        // swiftlint:enable resolver_change
        AnalyticsService.shared = dependencies.analyticsProvider.ifSome {
            AnalyticsService(provider: $0)
        }
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
    
    public init() { }
}
