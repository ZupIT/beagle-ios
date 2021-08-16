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

/// The screen element will help you define the screen view structure.
/// By using this component you can define configurations like whether or
/// not you want to use safe areas or display a tool bar/navigation bar.
@available(*, deprecated, message: "Since version 1.10. Declarative screen construction will be removed in 2.0")
public struct Screen: HasContext {
    
    /// identifies your screen globally inside your application so that it could have actions set on itself.
    public let identifier: String?
    
    /// Enables a few visual options to be changed.
    public let style: Style?
    
    /// Enables safe area to help you place your views within the visible portion of the overall interface.
    public let safeArea: SafeArea?
    
    /// Enables a action bar/navigation bar into your view. By default it is set as null.
    public let navigationBar: NavigationBar?
    
    /// Defines the child elements on this screen.
    public let child: ServerDrivenComponent
    
    /// Defines the context that be set to screen.
    public let context: Context?
    
    public init(
        identifier: String? = nil,
        style: Style? = nil,
        safeArea: SafeArea? = nil,
        navigationBar: NavigationBar? = nil,
        child: ServerDrivenComponent,
        context: Context? = nil
    ) {
        self.identifier = identifier
        self.style = style
        self.safeArea = safeArea
        self.navigationBar = navigationBar
        self.child = child
        self.context = context
    }

}
