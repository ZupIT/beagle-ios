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

import XCTest
@testable import Beagle

class ViewConfiguratorTests: XCTestCase {
    
    func testSetupView() {
        // Given
        let view = UIView()
        let colorHex = "#FFFFFF"
        let borderColorHex = "#000000"
        let borderWidthValue: Double = 2
        let style = Style().borderColor(borderColorHex).borderWidth(borderWidthValue).backgroundColor(colorHex)
        let accessibility = Accessibility(accessibilityLabel: "accessibilityLabel", accessible: true)
        let component = Text(text: "text", style: style, accessibility: accessibility)
        let viewConfigurator = ViewConfigurator(view: view)
        let controller = BeagleControllerSpy()
        let renderer = BeagleRenderer(controller: controller)
        
        // When
        viewConfigurator.setupView(of: component, renderer: renderer)
        
        // Then
        // swiftlint:disable force_unwrapping
        XCTAssertEqual(view.backgroundColor, UIColor(hex: colorHex))
        XCTAssertEqual(view.layer.borderWidth, CGFloat(borderWidthValue))
        XCTAssertEqual(view.layer.borderColor, UIColor(hex: borderColorHex)!.cgColor)
        XCTAssertEqual(view.accessibilityLabel, accessibility
                        .accessibilityLabel)
        XCTAssertTrue(view.isAccessibilityElement)
        // swiftlint:enable force_unwrapping
    }
    
    func testSetupViewWithCornerRadius() {
        // Given
        let view = UIView()
        let radius: Double = 2
        let borderColorHex = "#000000"
        let borderWidthValue: Double = 2
        let style = Style().borderColor(borderColorHex).borderWidth(borderWidthValue).cornerRadius(.init(radius: radius))
        let component = Text(text: "text", style: style)
        let viewConfigurator = ViewConfigurator(view: view)
        let controller = BeagleControllerSpy()
        let renderer = BeagleRenderer(controller: controller)
        
        // When
        viewConfigurator.setupView(of: component, renderer: renderer)
        
        // Then
        XCTAssertNotEqual(view.layer.cornerRadius, CGFloat(radius))
        XCTAssertNotEqual(view.layer.borderWidth, CGFloat(borderWidthValue))
        XCTAssertNotEqual(view.layer.borderColor, UIColor(hex: borderColorHex)?.cgColor)
    }
    
    func testApplyAccessibility() {
        // Given
        let button = UIButton()
        button.accessibilityTraits = .button
        let buttonHeader = UIButton()
        var accessibility = Accessibility(accessibilityLabel: "accessibilityLabel", accessible: true)
        
        // When
        ViewConfigurator.applyAccessibility(accessibility, to: button)
        accessibility.isHeader = true
        ViewConfigurator.applyAccessibility(accessibility, to: buttonHeader)
        
        // Then
        XCTAssertEqual(button.accessibilityLabel, accessibility.accessibilityLabel)
        XCTAssertTrue(button.isAccessibilityElement)
        XCTAssertEqual(button.accessibilityTraits, .button)
        XCTAssertEqual(buttonHeader.accessibilityLabel, accessibility.accessibilityLabel)
        XCTAssertTrue(buttonHeader.isAccessibilityElement)
        XCTAssertEqual(buttonHeader.accessibilityTraits, .header)
    }
}
