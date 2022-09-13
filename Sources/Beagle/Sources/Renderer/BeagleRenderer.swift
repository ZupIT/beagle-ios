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
import YogaKit

private let yogaTranslator = YogaTranslating()

/// Use this class whenever you want to transform a Component into a UIView
public struct BeagleRenderer {
    
    // MARK: Dependencies
    
    @Injected public var viewClient: ViewClientProtocol
    @Injected public var mainBundle: BundleProtocol
    @Injected public var preFetchHelper: PrefetchHelperProtocol
    @Injected public var imageDownloader: ImageDownloaderProtocol
    @Injected public var imageProvider: ImageProviderProtocol

    // MARK: Properties
    
    public private(set) weak var controller: BeagleController?
    public var appBundle: Bundle {
        mainBundle.bundle
    }
    
    // MARK: Init

    internal init(controller: BeagleController) {
        self.controller = controller
        _viewClient = Injected(controller.config.resolver)
        _mainBundle = Injected(controller.config.resolver)
        _preFetchHelper = Injected(controller.config.resolver)
        _imageDownloader = Injected(controller.config.resolver)
        _imageProvider = Injected(controller.config.resolver)
    }
    
    // MARK: Public Functions

    public func render(_ children: [ServerDrivenComponent]) -> [UIView] {
        return children.map { render($0) }
    }
    
    /// main function of this class. Call it to transform a Component into a UIView
    public func render(_ component: ServerDrivenComponent) -> UIView {
        let view = component.toView(renderer: self)
        view.beagleConfig = controller?.config ?? GlobalConfig
        return setupView(resolve(view: view), of: component)
    }
    
    // MARK: Private Functions
    
    private func resolve(view: UIView) -> UIView {
        return mustBeWrapped(view: view) ? AutoLayoutWrapper(view: view) : view
    }
    
    private func mustBeWrapped(view: UIView) -> Bool {
        let isAutoLayoutView = view.constraints.count > 0
        let isAutoLayoutWrapper = view is AutoLayoutWrapper
        
        guard isAutoLayoutView && !isAutoLayoutWrapper else { return false }
        
        let size: CGSize = .init(width: 100, height: 100)
        let sizeThatFitsImplemented = view.sizeThatFits(size) == view.systemLayoutSizeFitting(size)
        
        return !sizeThatFitsImplemented
    }

    private func setupView(_ view: UIView, of component: ServerDrivenComponent) -> UIView {
        view.beagle.setupView(of: component, renderer: self)
        view.componentType = type(of: component)
        
        if let id = (component as? IdentifiableComponent)?.id {
            controller?.setIdentifier(id, in: view)
        }
        if let context = (component as? HasContext)?.context {
            controller?.setContext(context, in: view)
        }
        if let onInit = (component as? InitiableComponent)?.onInit {
            controller?.addOnInit(onInit, in: view)
        }
        if let style = (component as? StyleComponent)?.style {
            if style.cornerRadius != nil && style.cornerRadius != CornerRadius() {
                return createBorderView(view, style)
            } else {
                observe(style: style, contextView: view, updateView: view)
            }
        }
        return view
    }
    
    private func createBorderView(_ view: UIView, _ style: Style) -> UIView {
        let border = BorderView(content: view)
        border.observe(style: style, renderer: self)
        
        observe(style: style, contextView: view, updateView: border, hasPadding: false)
        
        StyleObserver(style: style, renderer: self, contextView: view, updateView: view)
            .observePadding()

        view.yoga.margin = 0
        view.yoga.marginTop = 0
        view.yoga.marginLeft = 0
        view.yoga.marginRight = 0
        view.yoga.marginBottom = 0
        return border
    }
    
    private func observe(style: Style, contextView: UIView, updateView: UIView, hasPadding: Bool = true) {
        observeIfSome(style.display, andUpdateManyIn: contextView) { [weak updateView] display in
            updateView?.yoga.display = yogaTranslator.translate(display)
        }

        let styleObserver = StyleObserver(style: style, renderer: self, contextView: contextView, updateView: updateView)
        styleObserver.observeMargin()
        if hasPadding {
            styleObserver.observePadding()
        }
        styleObserver.observePosition()
        styleObserver.observeSize()

        // basis
        observeUnitValue(style.flex?.basis, andUpdateYoga: \.flexBasis, contextView: contextView, updateView: updateView)
    }
    
}

// MARK: - Observe Expressions

public extension BeagleRenderer {

    typealias Mapper<From, To> = (From) -> To

    // MARK: Property of same Expression's Value

    func observe<Value, View: UIView>(
        _ expression: Expression<Value>?,
        andUpdate keyPath: ReferenceWritableKeyPath<View, Value?>,
        in view: View,
        map: Mapper<Value?, Value?>? = nil
    ) {
        if let expression = expression {
            expression.observe(view: view, controller: controller) { [weak view] value in
                view?[keyPath: keyPath] = map?(value) ?? value
            }
        } else if let map = map {
            view[keyPath: keyPath] = map(nil)
        }
    }

    // MARK: Property with different type than expression

    func observe<Value, View: UIView, Property>(
        _ expression: Expression<Value>?,
        andUpdate keyPath: ReferenceWritableKeyPath<View, Property>,
        in view: View,
        map: @escaping Mapper<Value?, Property>
    ) {
        observe(expression, andUpdateManyIn: view) { [weak view] in
            view?[keyPath: keyPath] = map($0)
        }
    }

    // MARK: Update various properties (not just 1) in view

    /// will call `updateFunction` even when `expression` is nil
    func observe<Value>(
        _ expression: Expression<Value>?,
        andUpdateManyIn view: UIView,
        updateFunction: @escaping (Value?) -> Void
    ) {
        if let exp = expression {
            exp.observe(view: view, controller: controller, updateFunction: updateFunction)
        } else {
            updateFunction(nil)
        }
    }

    func observe<Value>(
        _ expression: Expression<Value>,
        andUpdateManyIn view: UIView,
        updateFunction: @escaping (Value?) -> Void
    ) {
        expression.observe(view: view, controller: controller, updateFunction: updateFunction)
    }

}

typealias YogaKeyPath = ReferenceWritableKeyPath<YGLayout, YGValue>

internal extension BeagleRenderer {

    func observeIfSome<Value>(
        _ expression: Expression<Value>?,
        andUpdateManyIn view: UIView,
        updateFunction: @escaping (Value) -> Void
    ) {
        observe(expression, andUpdateManyIn: view) { value in
            value.ifSome(updateFunction)
        }
    }

    func observeUnitValue(
        _ value: UnitValue?,
        andUpdateYoga keyPath: YogaKeyPath,
        contextView: UIView,
        updateView: UIView
    ) {
        observeIfSome(value?.value, andUpdateManyIn: contextView) { [weak updateView] newValue in
            updateView?.yoga[keyPath: keyPath] = yogaTranslator.translate(
                UnitValue(value: newValue, type: value?.type ?? .real)
            )
        }
    }
}

private struct StyleObserver {
    let style: Style
    let renderer: BeagleRenderer
    weak var contextView: UIView?
    weak var updateView: UIView?

    func observeMargin() {
        observe(style.margin?.all, andUpdate: \.margin)
        observe(style.margin?.horizontal, andUpdate: \.marginHorizontal)
        observe(style.margin?.vertical, andUpdate: \.marginVertical)
        observe(style.margin?.top, andUpdate: \.marginTop)
        observe(style.margin?.bottom, andUpdate: \.marginBottom)
        observe(style.margin?.left, andUpdate: \.marginLeft)
        observe(style.margin?.right, andUpdate: \.marginRight)
    }

    func observePadding() {
        observe(style.padding?.all, andUpdate: \.padding)
        observe(style.padding?.horizontal, andUpdate: \.paddingHorizontal)
        observe(style.padding?.vertical, andUpdate: \.paddingVertical)
        observe(style.padding?.top, andUpdate: \.paddingTop)
        observe(style.padding?.bottom, andUpdate: \.paddingBottom)
        observe(style.padding?.left, andUpdate: \.paddingLeft)
        observe(style.padding?.right, andUpdate: \.paddingRight)
    }

    func observePosition() {
        observe(style.position?.all, andUpdate: [\.left, \.right, \.top, \.bottom])
        observe(style.position?.horizontal, andUpdate: [\.left, \.right])
        observe(style.position?.vertical, andUpdate: [\.top, \.bottom])
        observe(style.position?.top, andUpdate: \.top)
        observe(style.position?.bottom, andUpdate: \.bottom)
        observe(style.position?.left, andUpdate: \.left)
        observe(style.position?.right, andUpdate: \.right)
    }

    func observeSize() {
        observe(style.size?.height, andUpdate: \.height)
        observe(style.size?.width, andUpdate: \.width)
        observe(style.size?.maxHeight, andUpdate: \.maxHeight)
        observe(style.size?.maxWidth, andUpdate: \.maxWidth)
        observe(style.size?.minHeight, andUpdate: \.minHeight)
        observe(style.size?.minWidth, andUpdate: \.minWidth)
    }

    private func observe(_ value: UnitValue?, andUpdate keyPath: YogaKeyPath) {
        guard let contextView = contextView, let updateView = updateView else { return }
        renderer.observeUnitValue(value, andUpdateYoga: keyPath, contextView: contextView, updateView: updateView)
    }

    private func observe(_ value: UnitValue?, andUpdate keyPaths: [YogaKeyPath]) {
        guard let contextView = contextView else { return }
        renderer.observeIfSome(value?.value, andUpdateManyIn: contextView) { [weak updateView] newValue in
            keyPaths.forEach {
                updateView?.yoga[keyPath: $0] = yogaTranslator.translate(
                    UnitValue(value: newValue, type: value?.type ?? .real)
                )
            }
        }
    }
}
