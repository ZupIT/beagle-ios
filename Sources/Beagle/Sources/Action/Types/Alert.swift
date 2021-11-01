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

/// This action will show an alert natively, such as an error alert, indicating alternative flows, business system errors and others.
public struct Alert: Action {
    
    /// Defines the title on the alert.
    public var title: Expression<String>?
    
    /// Defines the alert message.
    public var message: Expression<String>
    
    /// Defines the action of the button positive in the alert.
    @AutoCodable
    public var onPressOk: [Action]?
    
    /// Defines the text of the button positive in the alert.
    public var labelOk: String?
    
    /// Defines an analytics configuration for this action.
    public var analytics: ActionAnalyticsConfig?

}
