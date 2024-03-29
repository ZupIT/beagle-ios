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

extension UIView {
    private static var contextMapKey = "contextMapKey"
    private static var expressionLastValueMapKey = "expressionLastValueMapKey"
    private static var parentContextKey = "parentContextKey"
    private static var componentType = "componentType"
    
    private static var beagleConfigKey = "beagleConfigKey"
    
    private class ObjectWrapper<T> {
        let object: T?
        
        init(_ object: T?) {
            self.object = object
        }
    }
    
    var contextMap: [String: Observable<Context>] {
        get {
            return (objc_getAssociatedObject(self, &UIView.contextMapKey) as? ObjectWrapper)?.object ?? [String: Observable<Context>]()
        }
        set {
            objc_setAssociatedObject(self, &UIView.contextMapKey, ObjectWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var expressionLastValueMap: DynamicDictionary {
        get {
            return (objc_getAssociatedObject(self, &UIView.expressionLastValueMapKey) as? ObjectWrapper)?.object ?? DynamicDictionary()
        }
        set {
            objc_setAssociatedObject(self, &UIView.expressionLastValueMapKey, ObjectWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var componentType: ServerDrivenComponent.Type? {
        get {
            return (objc_getAssociatedObject(self, &UIView.componentType) as? ObjectWrapper)?.object
        }
        set {
            objc_setAssociatedObject(self, &UIView.componentType, ObjectWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    weak var parentContext: UIView? {
        get {
            objc_getAssociatedObject(self, &UIView.parentContextKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &UIView.parentContextKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    unowned var beagleConfig: BeagleConfiguration {
        get {
            objc_getAssociatedObject(self, &UIView.beagleConfigKey) as? BeagleConfiguration ?? GlobalConfiguration
        }
        set {
            objc_setAssociatedObject(self, &UIView.beagleConfigKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    // MARK: Context Expression
    
    func configBinding<T: Decodable>(for expression: ContextExpression, completion: @escaping (T?) -> Void) {
        switch expression {
        case let .single(expression):
            configBinding(for: expression, completion: completion)
        case let .multiple(expression):
            configBinding(for: expression, completion: completion)
        }
    }
    
    // MARK: Single Expression
    
    private func configBinding<T: Decodable>(_ binding: Binding, in expression: SingleExpression, completion: @escaping (T?) -> Void) {
        guard let context = getContext(with: binding.context) else { return }
        let closure: (Context) -> Void = { [weak self] _ in
            completion(self?.evaluateSingle(expression).transform())
        }
        let contextObserver = ContextObserver(onContextChange: closure)
        context.addObserver(contextObserver)
    }
    
    private func configBinding<T: Decodable>(_ operation: Operation, in expression: SingleExpression, completion: @escaping (T?) -> Void) {
        for parameter in operation.parameters {
            switch parameter {
            case let .value(.binding(binding)):
               configBinding(binding, in: expression, completion: completion)
            case let .operation(operation):
                configBinding(operation, in: expression, completion: completion)
            default: break
            }
        }
    }
    
    private func configBinding<T: Decodable>(for expression: SingleExpression, completion: @escaping (T?) -> Void) {
        switch expression {
        case let .value(.binding(binding)):
            configBinding(binding, in: expression, completion: completion)
        case let .value(.literal(literal)):
            completion(literal.evaluate().transform())
        case let .operation(operation):
            configBinding(operation, in: expression, completion: completion)
        }
        completion(evaluateSingle(expression).transform())
    }
    
    // MARK: Multiple Expression
    
    private func configBinding<T: Decodable>(_ binding: Binding, in expression: MultipleExpression, completion: @escaping (T?) -> Void) {
        guard let context = getContext(with: binding.context) else { return }
        let closure: (Context) -> Void = { [weak self] _ in
            let value: T? = self?.evaluateMultiple(expression, contextId: binding.context).transform()
            completion(value)
        }
        let contextObserver = ContextObserver(onContextChange: closure)
        context.addObserver(contextObserver)
    }
    
    private func configBinding<T: Decodable>(_ operation: Operation, in expression: MultipleExpression, completion: @escaping (T?) -> Void) {
        for parameter in operation.parameters {
            switch parameter {
            case let .value(.binding(binding)):
               configBinding(binding, in: expression, completion: completion)
            case let .operation(operation):
                configBinding(operation, in: expression, completion: completion)
            default: break
            }
        }
    }
    
    private func configBinding<T: Decodable>(for expression: MultipleExpression, completion: @escaping (T?) -> Void) {
        expression.nodes.forEach {
            if case let .expression(single) = $0 {
                switch single {
                case let .value(.binding(binding)):
                    configBinding(binding, in: expression, completion: completion)
                case let .operation(operation):
                    configBinding(operation, in: expression, completion: completion)
                default: break
                }
            }
        }
        completion(evaluateMultiple(expression).transform())
    }
    
    // MARK: Get/Set Context
    
    func getContext(with id: String) -> Observable<Context>? {
        if beagleConfig.environment.globalContext.isGlobal(id: id) {
            return beagleConfig.environment.globalContext.context
        }
        guard let context = contextMap[id] else {
            let observable = (parentContext ?? superview)?.getContext(with: id)
            return observable
        }
        return context
    }
    
    func setContext(_ context: Context) {
        guard !beagleConfig.environment.globalContext.isGlobal(id: context.id) else {
            beagleConfig.environment.globalContext.set(context.value)
            return
        }
        if let contextObservable = contextMap[context.id] {
            contextObservable.value = context
        } else {
            contextMap[context.id] = Observable(value: context)
        }
    }
    
    func getContextValue(_ contextId: String) -> DynamicObject? {
        guard !beagleConfig.environment.globalContext.isGlobal(id: contextId) else {
            return beagleConfig.environment.globalContext.context.value.value
        }
        return contextMap[contextId]?.value.value
    }
}

extension DynamicObject {

    internal func transform<T: Decodable>() -> T? {
        switch T.self {
        case is String.Type:
            return description as? T
        case is DynamicObject.Type:
            return self as? T
        default:
            return transformByDecoding()
        }
    }

    private func transformByDecoding<T: Decodable>() -> T? {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        if #available(iOS 13.0, *) {
            guard let data = try? encoder.encode(self) else { return nil }
            return try? decoder.decode(T.self, from: data)
        } else {
            // here we use array as a wrapper because iOS 12 (or prior) JSONEncoder/Decoder bug
            // https://bugs.swift.org/browse/SR-6163
            guard let data = try? encoder.encode([self]) else { return nil }
            return try? decoder.decode([T].self, from: data).first
        }
    }
}
