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

class AnalyticsService {

    var provider: AnalyticsProviderProtocol
    @Injected var logger: LoggerProtocol
    
    var resolver: DependenciesContainerResolving?

    init(provider: AnalyticsProviderProtocol) {
        self.provider = provider
    }
    
    init(_ resolver: DependenciesContainerResolving, provider: AnalyticsProviderProtocol) {
        self.provider = provider
        _logger = Injected(resolver)
        self.resolver = resolver
    }

    // MARK: - Create Events

    func createRecord(screen: ScreenType, rootId: String? = nil) {
        makeScreenRecord(
            screen: screen,
            rootId: rootId,
            isScreenEnabled: provider.getConfig().enableScreenAnalytics
        )
        .ifSome(provider.createRecord(_:))
    }

    func createRecord(action: ActionInfo) {
        ActionRecordFactory(
            resolver ?? GlobalConfig.resolver,
            info: action,
            globalConfig: provider.getConfig().actions
        )
        .makeRecord()
        .ifSome(provider.createRecord(_:))
    }

    struct ActionInfo {
        let action: Action
        let event: String?
        let origin: UIView
        let controller: BeagleControllerProtocol
    }
}
