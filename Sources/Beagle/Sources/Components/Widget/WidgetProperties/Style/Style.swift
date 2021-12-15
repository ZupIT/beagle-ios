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

public class Style: Codable {
    
    // MARK: - Public Properties
    
    /// Set the view background color. Supported formats:  `#RRGGBB[AA]` and `#RGB[A]`.
    public var backgroundColor: Expression<String>?
    
    /// Sets the corner of your view to make it round.
    public var cornerRadius: CornerRadius?
    
    /// Sets the color of your view border. Supported formats:  `#RRGGBB[AA]` and `#RGB[A]`.
    public var borderColor: Expression<String>?
    
    /// Sets the width of your view border
    public var borderWidth: Expression<Double>?
    
    /// Allows  you to specify the size of the element.
    public var size: Size?
    
    /// Allows you to apply a space to the child element.
    public var margin: EdgeValue?
    
    /// Allows you to apply a space to the parent element. So when a child is created it starts with padding-defined spacing.
    public var padding: EdgeValue?
    
    /// Sets the placement of the component in its parent.
    public var position: EdgeValue?

    /// The position type of an element defines how it is positioned within its parent.
    public var positionType: PositionType?

    /// Set the display type of the component, allowing o be flexible or locked.
    public var display: Expression<Display>?
    
    /// Apply positioning using the flex box concept.
    public var flex: Flex?
    
    init(
        backgroundColor: Expression<String>? = nil,
        cornerRadius: CornerRadius? = nil,
        borderColor: Expression<String>? = nil,
        borderWidth: Expression<Double>? = nil,
        size: Size? = nil,
        margin: EdgeValue? = nil,
        padding: EdgeValue? = nil,
        position: EdgeValue? = nil,
        positionType: PositionType? = nil,
        display: Expression<Display>? = nil,
        flex: Flex? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.size = size
        self.margin = margin
        self.padding = padding
        self.position = position
        self.positionType = positionType
        self.display = display
        self.flex = flex
    }
}

/// The CornerRadius apply rounded borders to the widget
public struct CornerRadius: Codable {
    
    /// Defines the default size of the all corner radius
    public var radius: Expression<Double>?
    
    /// Defines the size of the top left radius
    public var topLeft: Expression<Double>?
    
    /// Defines the size of the top right radius
    public var topRight: Expression<Double>?
    
    /// Defines the size of the bottom left radius
    public var bottomLeft: Expression<Double>?
    
    /// Defines the size of the bottom right radius
    public var bottomRight: Expression<Double>?
    
}

extension CornerRadius {
    init(
        radius: Double? = nil,
        topLeft: Double? = nil,
        topRight: Double? = nil,
        bottomLeft: Double? = nil,
        bottomRight: Double? = nil
    ) {
        if let radius = radius {
            self.radius = .value(radius)
        }
        if let topLeft = topLeft {
            self.topLeft = .value(topLeft)
        }
        if let topRight = topRight {
            self.topRight = .value(topRight)
        }
        if let bottomLeft = bottomLeft {
            self.bottomLeft = .value(bottomLeft)
        }
        if let bottomRight = bottomRight {
            self.bottomRight = .value(bottomRight)
        }
    }
}

extension CornerRadius: Equatable {
     public static func == (lhs: CornerRadius, rhs: CornerRadius) -> Bool {
        guard lhs.radius == rhs.radius else { return false }
        guard lhs.topLeft == rhs.topLeft else { return false }
        guard lhs.topRight == rhs.topRight else { return false }
        guard lhs.bottomLeft == rhs.bottomLeft else { return false }
        guard lhs.bottomRight == rhs.bottomRight else { return false }
        return true
    }
}

// MARK: - Display
extension Style {
    public enum Display: String, Codable {
        case flex = "FLEX"
        case none = "NONE"
    }
}

// MARK: - Position
extension Style {
    public enum PositionType: String, Codable {
        case relative = "RELATIVE"
        case absolute = "ABSOLUTE"
    }
}

extension Style: Equatable {
     public static func == (lhs: Style, rhs: Style) -> Bool {
        guard lhs.backgroundColor == rhs.backgroundColor else { return false }
        guard lhs.cornerRadius == rhs.cornerRadius else { return false }
        guard lhs.borderColor == rhs.borderColor else { return false }
        guard lhs.borderWidth == rhs.borderWidth else { return false }
        guard lhs.size == rhs.size else { return false }
        guard lhs.margin == rhs.margin else { return false }
        guard lhs.padding == rhs.padding else { return false }
        guard lhs.position == rhs.position else { return false }
        guard lhs.positionType == rhs.positionType else { return false }
        guard lhs.display == rhs.display else { return false }
        guard lhs.flex == rhs.flex else { return false }
        return true
    }
}
