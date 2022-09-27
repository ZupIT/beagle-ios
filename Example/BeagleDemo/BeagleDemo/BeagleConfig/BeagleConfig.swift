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
import Beagle

import UIKit

enum BeagleConfig {

    static func create() -> BeagleConfiguration {
        let deepLinkHandler = registerDeepLink()

        var dependencies = BeagleDependenciesFactory()
        dependencies.networkClient = Factory { resolver in
            NetworkClientDefault(resolver)
        }
        dependencies.theme = Factory { _ in
            AppTheme.theme
        }
        dependencies.urlBuilder = Factory { _ in
            UrlBuilder(baseUrl: URL(string: .baseURL))
        }
        dependencies.deepLinkHandler = Factory { _ in
            deepLinkHandler
        }
        dependencies.analyticsProvider = Factory { _ in
            AnalyticsProviderDemo()
        }
        dependencies.logger = Factory { _ in
            BeagleLoggerDefault()
        }
        
        let configuration = BeagleConfiguration(dependencies: dependencies)

        registerCustomOperations(in: configuration.dependencies)
        registerCustomComponents(in: configuration.dependencies)
        setupNavigation(in: configuration.dependencies)

        return configuration
    }

    private static func registerDeepLink() -> DeeplinkScreenManager {
        let deepLink = DeeplinkScreenManager.shared
        return deepLink
    }

    private static func registerCustomComponents(in dependencies: BeagleEnviromentProtocol) {
        dependencies.coder.register(type: DSCollection.self)
        dependencies.coder.register(type: CustomText.self, named: "custom-text")
    }

    private static func setupNavigation(in dependencies: BeagleEnviromentProtocol) {
        dependencies.navigator.registerNavigationController(builder: CustomBeagleNavigationController.init, forId: "CustomBeagleNavigation")
        dependencies.navigator.registerNavigationController(builder: CustomPushStackNavigationController.init, forId: "PushStackNavigation")
        dependencies.navigator.setDefaultAnimation(.init(
            pushTransition: .init(type: .fade, subtype: .fromRight, duration: 0.1),
            modalPresentationStyle: .formSheet
        ))
    }
    
    private static func registerCustomOperations(in dependencies: BeagleEnviromentProtocol) {
        dependencies.operationsProvider.register(operationId: "sum") { parameters in
            let anyParameters = parameters.map { $0.asAny() }
            if let integerParameters = anyParameters as? [Int] {
                return .int(integerParameters.reduce(0, +))
            } else if let doubleParameters = anyParameters as? [Double] {
                return .double(doubleParameters.reduce(0.0, +))
            }
            return nil
        }
        
        dependencies.operationsProvider.register(operationId: "SUBTRACT") { parameters in
            let anyParameters = parameters.map { $0.asAny() }
            if let integerParameters = anyParameters as? [Int] {
                return .int(integerParameters.reduce(integerParameters[0] * 2, -))
            } else if let doubleParameters = anyParameters as? [Double] {
                return .double(doubleParameters.reduce(doubleParameters[0] * 2, -))
            }
            return nil
        }
    }
}

struct CustomText: ServerDrivenComponent {
    func toView(renderer: BeagleRenderer) -> UIView {
        let label = UILabel()
        label.text = "customText"
        return label
    }
}
