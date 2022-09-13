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

public protocol CoderProtocol {
    
    func register<T: BeagleCodable>(type: T.Type, named: String?)
    
    func decode<T>(from data: Data) throws -> T
    
    func encode<T: BeagleCodable>(value: T) throws -> Data
    
    func name(for type: BeagleCodable.Type) -> String?
    
    func type(for name: String, baseType: Coder.BaseType) -> BeagleCodable.Type?
    
}

extension CoderProtocol {
    public func register<T: BeagleCodable>(type: T.Type) {
        register(type: type, named: nil)
    }
}

final public class Coder: CoderProtocol {

    // MARK: - Dependencies
    
    @Injected var logger: LoggerProtocol
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    private(set) var types: [String: [String: BeagleCodable.Type]]
    
    public enum BaseType: String {
        case component = "codable.componentTypes"
        case action = "codable.actionTypes"
    }
    
    private enum Namespace: String {
        case beagle
        case custom
    }
    
    // MARK: - Initialization
    convenience init(_ resolver: DependenciesContainerResolving) {
        self.init()
        _logger = Injected(resolver)
    }
    
    public init() {
        types = [:]
        types[BaseType.action.rawValue] = [:]
        types[BaseType.component.rawValue] = [:]
        
        encoder.userInfo[CodingUserInfoKey.coderKey] = self
        decoder.userInfo[CodingUserInfoKey.coderKey] = self
        
        registerDefaultTypes()
    }
    
    // MARK: - BeagleCoding
    
    public func register<T: BeagleCodable>(type: T.Type, named: String?) {
        let named: String = named?.lowercased() ?? String(describing: type).lowercased()
        if type is Action.Type {
            register(type, key: key(name: named, namespace: .custom), baseType: .action)
        } else {
            register(type, key: key(name: named, namespace: .custom), baseType: .component)
        }
    }
    
    public func decode<T>(from data: Data) throws -> T {
        do {
            if T.self is ServerDrivenComponent.Type {
                return try decodeAndCast(type: ServerDrivenComponent.self, from: data)
            } else if T.self is Action.Type {
                return try decodeAndCast(type: Action.self, from: data)
            }
            return try decoder.decode(AutoCodable<T>.self, from: data).wrappedValue
        } catch let error as BeagleCodableError {
            logger.log(Log.decode(.decodingError(type: String(describing: error))))
            throw error
        } catch {
            logger.log(Log.decode(.decodingError(type: error.localizedDescription)))
            throw error
        }
    }
    
    public func encode<T: BeagleCodable>(value: T) throws -> Data {
        return try encoder.encode(value)
    }
        
    public func name(for type: BeagleCodable.Type) -> String? {
        if type is Action.Type {
            return name(for: type, baseType: .action)
        } else {
            return name(for: type, baseType: .component)
        }
    }
    
    public func type(for name: String, baseType: BaseType) -> BeagleCodable.Type? {
        types[baseType.rawValue]?[name.lowercased()]
    }
    
    // MARK: - Private Functions
    
    private func key(
        name: String,
        namespace: Namespace = .beagle
    ) -> String {
        return "\(namespace):\(name)".lowercased()
    }
    
    private func register(_ type: BeagleCodable.Type, key: String, baseType: BaseType) {
        types[baseType.rawValue]?[key] = type
    }
    
    private func name(for type: BeagleCodable.Type, baseType: BaseType) -> String? {
        guard let types = types[baseType.rawValue] else { return nil }
        return types.first { $0.value == type }?.key
    }
    
    // MARK: - Default Types Registration
    
    private func decodeAndCast<T, W>(type: W.Type, from data: Data) throws -> T {
        let decoded = try decoder.decode(AutoCodable<W>.self, from: data).wrappedValue
        guard let value = decoded as? T else {
            throw BeagleCodableError.unableToCast(decoded: String(describing: decoded), into: String(describing: T.self))
        }
        return value
    }
    
    private func registerDefaultTypes() {
        registerActions()
        registerComponents()
        registerWidgets()
    }
    
    private func registerActions() {
        register(AddChildren.self, key: key(name: "AddChildren"), baseType: .action)
        register(Alert.self, key: key(name: "Alert"), baseType: .action)
        register(Condition.self, key: key(name: "Condition"), baseType: .action)
        register(Confirm.self, key: key(name: "Confirm"), baseType: .action)
        register(Navigate.self, key: key(name: "OpenExternalURL"), baseType: .action)
        register(Navigate.self, key: key(name: "OpenNativeRoute"), baseType: .action)
        register(Navigate.self, key: key(name: "ResetApplication"), baseType: .action)
        register(Navigate.self, key: key(name: "ResetStack"), baseType: .action)
        register(Navigate.self, key: key(name: "PushStack"), baseType: .action)
        register(Navigate.self, key: key(name: "PopStack"), baseType: .action)
        register(Navigate.self, key: key(name: "PushView"), baseType: .action)
        register(Navigate.self, key: key(name: "PopView"), baseType: .action)
        register(Navigate.self, key: key(name: "PopToView"), baseType: .action)
        register(SendRequest.self, key: key(name: "SendRequest"), baseType: .action)
        register(SetContext.self, key: key(name: "SetContext"), baseType: .action)
        register(SubmitForm.self, key: key(name: "SubmitForm"), baseType: .action)
    }
    
    private func registerComponents() {
        register(LazyComponent.self, key: key(name: "LazyComponent"), baseType: .component)
        register(PageIndicator.self, key: key(name: "PageIndicator"), baseType: .component)
        register(PageView.self, key: key(name: "PageView"), baseType: .component)
        register(PullToRefresh.self, key: key(name: "PullToRefresh"), baseType: .component)
        register(Screen.self, key: key(name: "ScreenComponent"), baseType: .component)
        register(ScrollView.self, key: key(name: "ScrollView"), baseType: .component)
        register(TabBar.self, key: key(name: "TabBar"), baseType: .component)
        register(Touchable.self, key: key(name: "Touchable"), baseType: .component)
    }
    
    private func registerWidgets() {
        register(Button.self, key: key(name: "Button"), baseType: .component)
        register(Container.self, key: key(name: "Container"), baseType: .component)
        register(GridView.self, key: key(name: "GridView"), baseType: .component)
        register(Image.self, key: key(name: "Image"), baseType: .component)
        register(ListView.self, key: key(name: "ListView"), baseType: .component)
        register(SimpleForm.self, key: key(name: "SimpleForm"), baseType: .component)
        register(Text.self, key: key(name: "Text"), baseType: .component)
        register(TextInput.self, key: key(name: "TextInput"), baseType: .component)
        register(WebView.self, key: key(name: "WebView"), baseType: .component)
    }
    
}
