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
import Beagle

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        BeagleConfig.start()
        
        let deepLinkHandler = DeeplinkScreenManager.shared

//        var dependencies = BeagleDependencies()
//        dependencies.networkClient = NetworkClientDefault()
//        dependencies.theme = AppTheme.theme
//        dependencies.urlBuilder = UrlBuilder(baseUrl: URL(string: .baseURL))
//        dependencies.deepLinkHandler = deepLinkHandler
//
//        dependencies.analyticsProvider = AnalyticsProviderDemo()
//
//        registerCustomOperations(in: dependencies)
//        registerCustomComponents(in: dependencies)
//        setupNavigation(in: dependencies)

        var beagleDependencies = BeagleDependenciesFactory()
        
        beagleDependencies.networkClient = Factory { _ in
            NetworkClientDefault()
        }
        beagleDependencies.theme = Factory { _ in
            AppTheme.theme
        }
        beagleDependencies.urlBuilder = Factory { _ in
            UrlBuilder(baseUrl: URL(string: .baseURL))
        }
        beagleDependencies.deepLinkHandler = Factory { _ in
            deepLinkHandler
        }
        beagleDependencies.analyticsProvider = Factory { _ in
            AnalyticsProviderDemo()
        }
        beagleDependencies.logger = Factory { _ in
            BeagleLoggerDefault()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let controller = BeagleScreenViewController(ScreenType.Remote(url: .componentsEndpoint), config: Beagle.BeagleConfig(dependencies: beagleDependencies))
        
//        controller.config.environment.coder.register(type: <#T##BeagleCodable.Protocol#>)
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        return true
    }
}
