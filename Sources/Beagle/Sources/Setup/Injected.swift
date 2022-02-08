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

var injectedFailureHandler: (Error) -> Void = { error in
    fatalError(error.localizedDescription)
}

@propertyWrapper
public class Injected<Dependency> {
    
    // swiftlint:disable implicitly_unwrapped_optional
    private var dependency: Dependency!
    // swiftlint:enable implicitly_unwrapped_optional
    
    public init() {}
    
    public var wrappedValue: Dependency {
        get {
            if dependency == nil {
                do {
                    let resolvedDependency: Dependency = try CurrentResolver.resolve()
                    dependency = resolvedDependency
                } catch {
                    injectedFailureHandler(error)
                }
            }
            
            return dependency
        }
        
        set {
            dependency = newValue
        }
    }
}

@propertyWrapper
public class OptionalInjected<Dependency> {
    
    private var dependency: Dependency?
    
    public init() {}
    
    public var wrappedValue: Dependency? {
        get {
            if dependency == nil {
                do {
                    let resolvedDependency: Dependency = try CurrentResolver.resolve()
                    dependency = resolvedDependency
                } catch {
                    return nil
                }
            }
            
            return dependency
        }
        
        set {
            dependency = newValue
        }
    }
}
