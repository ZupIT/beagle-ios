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

/// The screen element will help you define the screen view structure.
/// By using this component you can define configurations like whether or
/// not you want to use safe areas or display a tool bar/navigation bar.
public struct Screen: ServerDrivenComponent, StyleComponent, HasContext {
    
    /// identifies your screen globally inside your application so that it could have actions set on itself.
    public var id: String?
    
    /// Enables a few visual options to be changed.
    public var style: Style?
    
    /// Enables safe area to help you place your views within the visible portion of the overall interface.
    public var safeArea: SafeArea? = SafeArea(top: true, leading: true, bottom: true, trailing: true)
    
    /// Enables a action bar/navigation bar into your view. By default it is set as null.
    public var navigationBar: NavigationBar?
    
    /// Defines the child elements on this screen.
    @AutoCodable
    public var child: ServerDrivenComponent
    
    /// Defines the context that be set to screen.
    public var context: Context?

}

extension Screen {

    enum CodingKeys: String, CodingKey {
        case id
        case style
        case safeArea
        case navigationBar
        case child
        case context
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        safeArea = try container.decodeIfPresent(SafeArea.self, forKey: .safeArea) ??
            SafeArea(top: true, leading: true, bottom: true, trailing: true)
        navigationBar = try container.decodeIfPresent(NavigationBar.self, forKey: .navigationBar)
        child = try container.decode(forKey: .child)
        context = try container.decodeIfPresent(Context.self, forKey: .context)
    }
}
