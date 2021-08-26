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

/// Input is a component that displays an editable text area for the user. These text fields are used to collect
/// inputs that the user insert using the keyboard.
public struct TextInput: Widget, AutoDecodable {
    
    /// Item referring to the input value that will be entered in the editable text area of the `TextInput`.
    public var value: Expression<String>?
    
    /// Text that is displayed when nothing has been entered in the editable text field.
    public var placeholder: Expression<String>?
    
    /// Enables or disables the field.
    public var enabled: Expression<Bool>?
    
    /// Check if the Input will be editable or read only.
    public var readOnly: Expression<Bool>?
    
    /// This attribute identifies the type of text that we will receive in the editable text area.
    /// On Android and iOS, this field also assigns the type of keyboard that will be displayed to the us.
    public var type: Expression<TextInputType>?
    
    /// References a style configured to be applied on this view.
    public var styleId: String?
    
    /// Actions array that this field can trigger when its value is altered.
    public var onChange: [Action]?
    
    /// Action array that this field can trigger when its focus is removed.
    public var onBlur: [Action]?
    
    /// Actions array that this field can trigger when this field is on focus.
    public var onFocus: [Action]?
    
    /// Is a text that should be rendered, below the text input. It tells the user about the error.
    /// This text is visible only if showError is true
    public var error: Expression<String>?
    
    /// Controls weather to make the error of the input visible or not.
    /// The error will be visible only if showError is true.
    public var showError: Expression<Bool>?
    
    /// Properties that all widgets have in common.
    public var widgetProperties: WidgetProperties = WidgetProperties()
    
}

public enum TextInputType: String, Decodable {
    case date = "DATE"
    case email = "EMAIL"
    case password = "PASSWORD"
    case number = "NUMBER"
    case text = "TEXT"
}
