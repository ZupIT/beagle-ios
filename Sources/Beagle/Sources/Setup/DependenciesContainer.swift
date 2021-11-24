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

import Foundation

protocol DependenciesContainerResolving {
    func resolve<Dependency>() throws -> Dependency
}

final class DependenciesContainer: DependenciesContainerResolving {
    
    // MARK: Dependencies Store
    
    private var instancesMap: [String: DependencyResolver] = [:]
    
    // MARK: Init
    
    init(dependencies: BeagleDependencies) {
        registerBeagleDependencies(dependencies)
    }
    
    // MARK: Singleton
    
    static let global: DependenciesContainerResolving = DependenciesContainer(dependencies: BeagleDependencies())
    
    // MARK: Public Functions
    
    func resolve<Dependency>() throws -> Dependency {
        let mapKey = key(for: Dependency.self)
        
        guard let resolver = instancesMap[mapKey] else {
            throw ContainerError.couldNotFindInstanceForType(type: mapKey)
        }
        
        guard let instance: Dependency = resolver.resolve() else {
            throw ContainerError.couldNotCastInstanceToRequestedType(type: mapKey)
        }
        
        if case .lazy = resolver {
            instancesMap[mapKey] = .instance(obj: instance)
        }
        
        return instance
    }
    
    // MARK: Private Functions
    
    private func registerLazy<Dependency>(
        _ type: Dependency.Type,
        block: @autoclosure @escaping () -> Dependency
    ) {
        register(key: key(for: type), resolver: .lazy(block: block))
    }
    
    private func registerFactory<Dependency>(
        _ type: Dependency.Type,
        block: @autoclosure @escaping () -> Dependency
    ) {
        register(key: key(for: type), resolver: .factory(block: block))
    }
    
    private func register(key: String, resolver: DependencyResolver) {
        instancesMap[key] = resolver
    }
    
    private func key<T>(for type: T) -> String {
        String(describing: type)
    }
    
    private func registerBeagleDependencies(_ dependencies: BeagleDependencies) {
        registerLazy(UrlBuilderProtocol.self, block: dependencies.urlBuilder)
        registerLazy(GlobalContextProtocol.self, block: dependencies.globalContext)
        registerLazy(NavigationProtocolInternal.self, block: dependencies.internalNavigator)
        registerLazy(BundleProtocol.self, block: dependencies.appBundle)
        registerLazy(WindowManagerProtocol.self, block: dependencies.windowManager)
        registerLazy(CoderProtocol.self, block: dependencies.coder)
        registerLazy(OperationsProviderProtocolInternal.self, block:
                        dependencies.internalOperationsProvider)
        registerLazy(PrefetchHelperProtocol.self, block: dependencies.preFetchHelper)
        registerLazy(URLOpenerProtocol.self, block: dependencies.opener)
        
        registerFactory(LoggerProtocol.self, block: LoggerProxy(logger: dependencies.logger))
        registerFactory(ThemeProtocol.self, block: dependencies.theme)
        registerFactory(ViewClientProtocol.self, block: dependencies.viewClient)
        registerFactory(ImageDownloaderProtocol.self, block: dependencies.imageDownloader)
        
        if let analyticsProvider = dependencies.analyticsProvider {
            registerLazy(AnalyticsProviderProtocol.self, block: analyticsProvider)
        }
        
        if let deepLinkHandler = dependencies.deepLinkHandler {
            registerLazy(DeepLinkScreenManagerProtocol.self, block: deepLinkHandler)
        }
        
        if let networkClient = dependencies.networkClient {
            registerLazy(NetworkClientProtocol.self, block: networkClient)
        }
    }
    
    // MARK: ContainerError
    
    enum ContainerError: Error {
        case couldNotFindInstanceForType(type: String)
        case couldNotCastInstanceToRequestedType(type: String)
    }
}
