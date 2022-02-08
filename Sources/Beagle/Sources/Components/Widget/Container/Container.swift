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

/// The container component is a general container that can hold other components inside.
public struct Container: Widget, HasContext, InitiableComponent {
    
    /// Defines a list of components that are part of the container.
    @AutoCodable
    public var children: [ServerDrivenComponent]?
    
    /// it is a parameter that allows you to define a list of actions to be performed when the Widget is displayed.
    @AutoCodable
    public var onInit: [Action]?
    
    /// Defines the contextData that be set to container.
    public var context: Context?
    
    /// References a native style configured to be applied on this container.
    public var styleId: String?
    
    public var id: String?
    public var style: Style?
    public var accessibility: Accessibility?

}
