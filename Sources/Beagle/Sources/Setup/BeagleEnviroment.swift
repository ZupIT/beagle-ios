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

import UIKit

public protocol BeagleEnviromentProtocol {
    var coder: CoderProtocol { get }
    var logger: LoggerProtocol { get }
    var globalContext: GlobalContextProtocol { get }
}

protocol EnviromentProtocol: BeagleEnviromentProtocol {
    var navigator: NavigationProtocolInternal { get }
    var operationsProvider: OperationsProviderProtocolInternal { get }
    
    var renderer: (BeagleController) -> BeagleRenderer { get }
    var style: (UIView) -> StyleViewConfiguratorProtocol { get }
    var viewConfigurator: (UIView) -> ViewConfiguratorProtocol { get }
}

/// Store global dependencies to be used inside extensions and outside Beagle
final class BeagleEnviroment: EnviromentProtocol {
    @Injected var coder: CoderProtocol
    @Injected var logger: LoggerProtocol
    @Injected var navigator: NavigationProtocolInternal
    @Injected var operationsProvider: OperationsProviderProtocolInternal
    @Injected var globalContext: GlobalContextProtocol
    
    // MARK: Singleton
    
    static let global: EnviromentProtocol = BeagleEnviroment()
    
    // MARK: Builders
    
    var renderer: (BeagleController) -> BeagleRenderer = {
        return BeagleRenderer(controller: $0)
    }

    var style: (UIView) -> StyleViewConfiguratorProtocol = {
        return StyleViewConfigurator(view: $0)
    }

    var viewConfigurator: (UIView) -> ViewConfiguratorProtocol = {
        return ViewConfigurator(view: $0)
    }
}
