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

/// Defines a button natively using the server driven information received through Beagle.
public struct Button: Widget, AutoDecodable {
    
    /// Defines the button text content.
    public let text: Expression<String>
    
    /// References a native style configured to be applied on this button.
    public var styleId: String?
    
    /// Attribute to define actions when this component is pressed.
    public var onPress: [Action]?
    
    /// Enables or disables the button.
    public var enabled: Expression<Bool>?
    
    public var id: String?
    public var style: Style?
    public var accessibility: Accessibility?
    
}
