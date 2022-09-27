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

import YogaKit

public protocol StyleViewConfiguratorProtocol: AnyObject {
    var view: UIView? { get set }

    func setup(_ style: Style?)
    
    func applyLayout()
    func markDirty()
    
    var isFlexEnabled: Bool { get set }
}

extension UIView {
    public var style: StyleViewConfiguratorProtocol {
        return BeagleEnvironment.style(self)
    }
}

// MARK: - Implementation

final class StyleViewConfigurator: StyleViewConfiguratorProtocol {
    
    // MARK: - Dependencies

    weak var view: UIView?

    private let yogaTranslator: YogaTranslator
    
    // MARK: - Initialization
    
    init(
        view: UIView,
        yogaTranslator: YogaTranslator = YogaTranslating()
    ) {
        self.view = view
        self.yogaTranslator = yogaTranslator
    }
    
    // MARK: - Public Methods

    func setup(_ style: Style?) {
        guard let yoga = view?.yoga else { return }

        isFlexEnabled = true
        applyYogaProperties(from: style ?? Style(), to: yoga)
    }
    
    func applyLayout() {
        isFlexEnabled = true
        view?.yoga.applyLayout(preservingOrigin: true)
    }
    
    var isFlexEnabled: Bool {
        get { return view?.yoga.isEnabled ?? false }
        set { view?.yoga.isEnabled = newValue }
    }
        
    func markDirty() {
        view?.yoga.markDirty()
        var view = self.view
        while let currentView = view {
            if !(currentView.superview?.yoga.isEnabled ?? false) {
                view?.setNeedsLayout()
            }
            view = view?.superview
        }
    }
    
    // MARK: - Private Methods
    
    private func applyYogaProperties(from style: Style, to layout: YGLayout) {
        applyYogaProperties(from: style.flex ?? Flex(), to: layout)
        layout.position = yogaTranslator.translate(style.positionType ?? .relative)
        if case .value(let display) = style.display {
            layout.display = yogaTranslator.translate(display)
        }
        setSize(style.size, to: layout)
        setMargin(style.margin, to: layout)
        setPadding(style.padding, to: layout)
        setPosition(style.position, to: layout)
    }

    private func applyYogaProperties(from flex: Flex, to layout: YGLayout) {
        layout.flexDirection = yogaTranslator.translate(flex.flexDirection ?? .column)
        layout.flexWrap = yogaTranslator.translate(flex.flexWrap ?? .noWrap)
        layout.justifyContent = yogaTranslator.translate(flex.justifyContent ?? .flexStart)
        layout.alignItems = yogaTranslator.translate(flex.alignItems ?? .stretch)
        layout.alignSelf = yogaTranslator.translate(flex.alignSelf ?? .auto)
        layout.alignContent = yogaTranslator.translate(flex.alignContent ?? .flexStart)
        if case .value(_) = flex.basis?.value {
            layout.flexBasis = yogaTranslator.translate(flex.basis ?? .auto)
        }
        if let flexValue = flex.flex {
            layout.flex = CGFloat(flexValue)
            if let grow = flex.grow {
                layout.flexGrow = CGFloat(grow)
            }
            if let shrink = flex.shrink {
                layout.flexShrink = CGFloat(shrink)
            }
        } else {
            layout.flex = .nan
            layout.flexGrow = CGFloat(flex.grow ?? 0)
            layout.flexShrink = CGFloat(flex.shrink ?? 1)
        }
    }
    
    // MARK: - Flex Layout Methods
    
    private func setSize(_ size: Size?, to layout: YGLayout) {
        guard let size = size else {
            return
        }
        if let width = size.width, case .value(_) = size.width?.value {
            layout.width = yogaTranslator.translate(width)
        }
        if let height = size.height, case .value(_) = size.height?.value {
            layout.height = yogaTranslator.translate(height)
        }
        if let maxWidth = size.maxWidth, case .value(_) = size.maxWidth?.value {
            layout.maxWidth = yogaTranslator.translate(maxWidth)
        }
        if let maxHeight = size.maxHeight, case .value(_) = size.maxHeight?.value {
            layout.maxHeight = yogaTranslator.translate(maxHeight)
        }
        if let minWidth = size.minWidth, case .value(_) = size.minWidth?.value {
            layout.minWidth = yogaTranslator.translate(minWidth)
        }
        if let minHeight = size.minHeight, case .value(_) = size.minHeight?.value {
            layout.minHeight = yogaTranslator.translate(minHeight)
        }
        if let aspectRatio = size.aspectRatio {
            layout.aspectRatio = CGFloat(aspectRatio)
        }
    }
    
    private func setMargin(_ margin: EdgeValue?, to layout: YGLayout) {
        guard let margin = margin else {
            return
        }
        if let all = margin.all, case .value(_) = margin.all?.value {
            layout.margin = yogaTranslator.translate(all)
        }
        if let left = margin.left, case .value(_) = margin.left?.value {
            layout.marginLeft = yogaTranslator.translate(left)
        }
        if let top = margin.top, case .value(_) = margin.top?.value {
            layout.marginTop = yogaTranslator.translate(top)
        }
        if let right = margin.right, case .value(_) = margin.right?.value {
            layout.marginRight = yogaTranslator.translate(right)
        }
        if let bottom = margin.bottom, case .value(_) = margin.bottom?.value {
            layout.marginBottom = yogaTranslator.translate(bottom)
        }
        if let horizontal = margin.horizontal, case .value(_) = margin.horizontal?.value {
            layout.marginHorizontal = yogaTranslator.translate(horizontal)
        }
        if let vertical = margin.vertical, case .value(_) = margin.vertical?.value {
            layout.marginVertical = yogaTranslator.translate(vertical)
        }
    }
    
    private func setPadding(_ padding: EdgeValue?, to layout: YGLayout) {
        guard let padding = padding else {
            return
        }
        if let all = padding.all, case .value(_) = padding.all?.value {
            layout.padding = yogaTranslator.translate(all)
        }
        if let left = padding.left, case .value(_) = padding.left?.value {
            layout.paddingLeft = yogaTranslator.translate(left)
        }
        if let top = padding.top, case .value(_) = padding.top?.value {
            layout.paddingTop = yogaTranslator.translate(top)
        }
        if let right = padding.right, case .value(_) = padding.right?.value {
            layout.paddingRight = yogaTranslator.translate(right)
        }
        if let bottom = padding.bottom, case .value(_) = padding.bottom?.value {
            layout.paddingBottom = yogaTranslator.translate(bottom)
        }
        if let horizontal = padding.horizontal, case .value(_) = padding.horizontal?.value {
            layout.paddingHorizontal = yogaTranslator.translate(horizontal)
        }
        if let vertical = padding.vertical, case .value(_) = padding.vertical?.value {
            layout.paddingVertical = yogaTranslator.translate(vertical)
        }
    }
    
    private func setPosition(_ position: EdgeValue?, to layout: YGLayout) {
        guard let position = position else {
            return
        }
        if let all = position.all, case .value(_) = position.all?.value {
            layout.left = yogaTranslator.translate(all)
            layout.right = yogaTranslator.translate(all)
            layout.top = yogaTranslator.translate(all)
            layout.bottom = yogaTranslator.translate(all)
        }
        if let left = position.left, case .value(_) = position.left?.value {
            layout.left = yogaTranslator.translate(left)
        }
        if let top = position.top, case .value(_) = position.top?.value {
            layout.top = yogaTranslator.translate(top)
        }
        if let right = position.right, case .value(_) = position.right?.value {
            layout.right = yogaTranslator.translate(right)
        }
        if let bottom = position.bottom, case .value(_) = position.bottom?.value {
            layout.bottom = yogaTranslator.translate(bottom)
        }
        if let vertical = position.vertical, case .value(_) = position.vertical?.value {
            layout.top = yogaTranslator.translate(vertical)
            layout.bottom = yogaTranslator.translate(vertical)
        }
        if let horizontal = position.horizontal, case .value(_) = position.horizontal?.value {
            layout.left = yogaTranslator.translate(horizontal)
            layout.right = yogaTranslator.translate(horizontal)
        }
    }
}
