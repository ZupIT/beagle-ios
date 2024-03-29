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

public var GlobalConfiguration: BeagleConfiguration = BeagleConfiguration(dependencies: BeagleDependenciesFactory())

// MARK: - Environment

/// Used outside beagle to access the environment dependencies
public var Dependencies: BeagleEnviromentProtocol { GlobalConfiguration.environment }

public class BeagleConfiguration {
    public init(dependencies: BeagleDependenciesFactory) {
        resolver = DependenciesContainer(dependencies: dependencies)
        environment = BeagleEnvironment(resolver: resolver)
    }
    
    init(resolver: DependenciesContainerResolving) {
        self.resolver = resolver
        environment = BeagleEnvironment(resolver: resolver)
    }
    
    init(dependencies: BeagleDependencies) {
        resolver = DependenciesContainer(dependencies: dependencies)
        environment = BeagleEnvironment(resolver: resolver)
    }
    
    var resolver: DependenciesContainerResolving
    var environment: EnvironmentProtocol
    public var dependencies: BeagleEnviromentProtocol {
        environment
    }
}
