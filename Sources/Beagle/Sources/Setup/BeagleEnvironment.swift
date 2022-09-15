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

import UIKit

public protocol BeagleEnviromentProtocol {
    var coder: CoderProtocol { get }
    var navigator: NavigationProtocol { get }
    var operationsProvider: OperationsProviderProtocol { get }
    var logger: LoggerProtocol { get }
    var globalContext: GlobalContextProtocol { get }
}

protocol EnvironmentProtocol: BeagleEnviromentProtocol {
    var navigatorInternal: NavigationProtocolInternal { get }
    var operationsProviderInternal: OperationsProviderProtocolInternal { get }
    var theme: ThemeProtocol { get }
}

/// Store global dependencies to be used inside extensions and outside Beagle
final class BeagleEnvironment: EnvironmentProtocol {
    @Injected var coder: CoderProtocol
    @Injected var logger: LoggerProtocol
    @Injected var navigatorInternal: NavigationProtocolInternal
    @Injected var operationsProviderInternal: OperationsProviderProtocolInternal
    @Injected var globalContext: GlobalContextProtocol
    @Injected var theme: ThemeProtocol
    
    var navigator: NavigationProtocol {
        navigatorInternal
    }
    
    var operationsProvider: OperationsProviderProtocol {
        operationsProviderInternal
    }
    
    var resolver: DependenciesContainerResolving
    
    init(resolver: DependenciesContainerResolving) {
        self.resolver = resolver
        _coder = Injected(resolver)
        _logger = Injected(resolver)
        _navigatorInternal = Injected(resolver)
        _operationsProviderInternal = Injected(resolver)
        _globalContext = Injected(resolver)
        _theme = Injected(resolver)
    }
    
    // MARK: Builders
    
    static var renderer: (BeagleController) -> BeagleRenderer = {
        return BeagleRenderer(controller: $0)
    }

    static var style: (UIView) -> StyleViewConfiguratorProtocol = {
        return StyleViewConfigurator(view: $0)
    }

    static var viewConfigurator: (UIView) -> ViewConfiguratorProtocol = {
        return ViewConfigurator(view: $0)
    }
}
