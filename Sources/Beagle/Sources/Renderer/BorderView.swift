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

class BorderView: UIView {
    let content: UIView
    
    var topLeftRadius: CGFloat = 0
    var topRightRadius: CGFloat = 0
    var bottomLeftRadius: CGFloat = 0
    var bottomRightRadius: CGFloat = 0
    
    var borderWidth: CGFloat = 0
    var borderColor: CGColor? = UIColor.clear.cgColor
    
    private var border: CAShapeLayer
    
    init(content: UIView) {
        self.content = content
        
        self.border = CAShapeLayer()
        super.init(frame: .zero)

        yoga.isEnabled = true
        yoga.flexGrow = content.yoga.flexGrow
        
        backgroundColor = .clear
        
        addSubview(content)
        layer.addSublayer(border)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        applyCorners()
    }
    
    private func applyCorners() {
        let rect = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height
        )
        let path = UIBezierPath(rect, topRightRadius, topLeftRadius, bottomRightRadius, bottomLeftRadius)
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.masksToBounds = true
        layer.mask = mask

        border.path = path.cgPath
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = borderColor
        border.lineWidth = 2 * borderWidth
    }
    
}

private extension UIBezierPath {
    convenience init(_ rect: CGRect, _ topRightRadius: CGFloat, _ topLeftRadius: CGFloat, _ bottomRightRadius: CGFloat, _ bottomLeftRadius: CGFloat) {
        self.init()
        move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
        addArc(withCenter: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle: 3 * .pi / 2, endAngle: 0, clockwise: true)
        addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
        addArc(withCenter: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius), radius: bottomRightRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
        addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
        addArc(withCenter: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
        addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        addArc(withCenter: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: true)
        close()
    }
}

// Observe
extension BorderView {
    func observe(style: Style, renderer: BeagleRenderer) {
        // Radius
        observe(style.cornerRadius?.radius, renderer: renderer) { [weak self] radius in
            self?.topLeftRadius = CGFloat(radius)
            self?.topRightRadius = CGFloat(radius)
            self?.bottomLeftRadius = CGFloat(radius)
            self?.bottomRightRadius = CGFloat(radius)
        }
        observe(style.cornerRadius?.topLeft, renderer: renderer) { [weak self] radius in
            self?.topLeftRadius = CGFloat(radius)
        }
        observe(style.cornerRadius?.topRight, renderer: renderer) { [weak self] radius in
            self?.topRightRadius = CGFloat(radius)
        }
        observe(style.cornerRadius?.bottomLeft, renderer: renderer) { [weak self] radius in
            self?.bottomLeftRadius = CGFloat(radius)
        }
        observe(style.cornerRadius?.bottomRight, renderer: renderer) { [weak self] radius in
            self?.bottomRightRadius = CGFloat(radius)
        }
        // Border
        observe(style.borderWidth, renderer: renderer) { [weak self] borderWidth in
            self?.borderWidth = CGFloat(borderWidth)
        }
        observe(style.borderColor, renderer: renderer) { [weak self] borderColor in
            self?.borderColor = UIColor(hex: borderColor)?.cgColor
        }
    }
    
    private func observe<Value>(
        _ expression: Expression<Value>?,
        renderer: BeagleRenderer,
        updateFunction: @escaping (Value) -> Void
    ) {
        renderer.observe(expression, andUpdateManyIn: self.content) { [weak self] value in
            guard let value = value else { return }
            updateFunction(value)
            self?.layoutSubviews()
        }
    }
}
