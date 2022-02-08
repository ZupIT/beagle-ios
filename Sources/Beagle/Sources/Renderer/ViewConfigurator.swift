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

public protocol ViewConfiguratorProtocol: AnyObject {
    var view: UIView? { get set }

    func setup(style: Style?, renderer: BeagleRenderer)
    func setup(id: String?)
    func setup(accessibility: Accessibility?)
    func applyStyle<T: UIView>(for view: T, styleId: String, with controller: BeagleController?)
    func setupView(of component: ServerDrivenComponent, renderer: BeagleRenderer)
}

public extension UIView {

    var beagle: ViewConfiguratorProtocol {
        return CurrentEnviroment.viewConfigurator(self)
    }
}

class ViewConfigurator: ViewConfiguratorProtocol {
    
    // MARK: Dependencies
    
    @Injected var theme: ThemeProtocol
    
    // MARK: Properties

    weak var view: UIView?
    
    // MARK: Init

    init(view: UIView) {
        self.view = view
    }
    
    // MARK: ViewConfiguratorProtocol
    
    func setupView(of component: ServerDrivenComponent, renderer: BeagleRenderer) {
        view?.style.isFlexEnabled = true
        
        if let c = component as? AccessibilityComponent {
            setup(accessibility: c.accessibility)
        }
        
        if let c = component as? StyleComponent {
            setup(style: c.style, renderer: renderer)
            view?.style.setup(c.style)
        }
    }

    func setup(style: Style?, renderer: BeagleRenderer) {
        guard let view = view else { return }
        renderer.observeIfSome(style?.backgroundColor, andUpdateManyIn: view) { background in
            view.backgroundColor = UIColor(hex: background)
        }
        if style?.cornerRadius == nil || style?.cornerRadius == CornerRadius() {
            renderer.observeIfSome(style?.borderWidth, andUpdateManyIn: view) { borderWidth in
                view.layer.borderWidth = CGFloat(borderWidth)
            }
            renderer.observeIfSome(style?.borderColor, andUpdateManyIn: view) { borderColor in
                view.layer.borderColor = UIColor(hex: borderColor)?.cgColor
            }
        }
    }

    func setup(id: String?) {
        if let id = id {
            view?.accessibilityIdentifier = id
        }
    }

    func applyStyle<T: UIView>(for view: T, styleId: String, with controller: BeagleController?) {
        theme.applyStyle(for: view, withId: styleId)
    }
    
    func setup(accessibility: Accessibility?) {
        ViewConfigurator.applyAccessibility(accessibility, to: view)
    }
    
    static func applyAccessibility(_ accessibility: Accessibility?, to object: NSObject?) {
        guard let accessibility = accessibility else { return }
        if let label = accessibility.accessibilityLabel {
            object?.accessibilityLabel = label
        }
        object?.isAccessibilityElement = accessibility.accessible
        
        if let isHeader = accessibility.isHeader {
            object?.accessibilityTraits = isHeader ? .header : .none
        }
    }
}
