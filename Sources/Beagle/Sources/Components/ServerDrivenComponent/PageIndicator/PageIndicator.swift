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

/// The PageIndicator is a component to be used with PageView to sinalize the page selected.
public struct PageIndicator: ServerDrivenComponent {
    
    /// Configures the color of the selected dot. Must be filled as HEX (Hexadecimal).
    public var selectedColor: String?
    
    /// Configures the color of the unselected dots. Must be filled as HEX (Hexadecimal).
    public var unselectedColor: String?
    
    /// Numbers of pages of the PageView.
    public var numberOfPages: Int?
    
    /// Integer number that identifies the page selected.
    public var currentPage: Expression<Int>?

}
