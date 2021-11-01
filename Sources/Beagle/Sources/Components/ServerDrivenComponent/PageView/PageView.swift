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

/// The PageView component is a specialized container to hold pages (views) that will be displayed horizontally.
public struct PageView: ServerDrivenComponent, HasContext {
    
    /// Defines a List of components (views) that are contained on this PageView.
    @AutoCodable
    public var children: [ServerDrivenComponent]?
    
    /// Defines the contextData that be set to pageView.
    public var context: Context?
    
    /// List of actions that are performed when you are on the selected page.
    @AutoCodable
    public var onPageChange: [Action]?
    
    /// Integer number that identifies that selected.
    public var currentPage: Expression<Int>?
    
}
