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

// MARK: - CurrentResolver

/// Used by injected property wrapper to resolve dependencies
var CurrentResolver: DependenciesContainerResolving = DependenciesContainer.global

// MARK: - CurrentEnviroment

/// Used inside beagle to access the enviroment dependencies
var CurrentEnviroment: EnviromentProtocol = BeagleEnviroment.global

// MARK: - Enviroment

/// Used outside beagle to access the enviroment dependencies
public var Dependencies: BeagleEnviromentProtocol { CurrentEnviroment }
