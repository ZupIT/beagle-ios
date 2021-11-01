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
import UIKit

/// Typically displayed at the top of the window, containing buttons for navigating within a hierarchy of screens.
public struct NavigationBar: Codable {
    
    /// Defines the title on the navigation bar.
    public let title: String
    
    /// Could define a custom layout for your action bar/navigation bar.
    public var styleId: String?
    
    /// Enables a back button into your action bar/navigation bar.
    public var showBackButton: Bool?
    
    /// Defines accessibility details for the back button.
    public var backButtonAccessibility: Accessibility?
    
    /// Defines a List of navigation bar items.
    public var navigationBarItems: [NavigationBarItem]?

}

/// Defines a item that could be showed in navigation bar.
public struct NavigationBarItem: Codable, AccessibilityComponent {
    
    /// Defines an image for your navigation bar.
    public var image: StringOrExpression?
    
    /// Defines the text of the item.
    public let text: String
    
    /// Defines an action to be called when the item is clicked on.
    @AutoCodable
    public var action: Action
    
    /// Defines Accessibility details for the item.
    public var accessibility: Accessibility?
    
}
