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

import UIKit

public struct Accessibility: Codable, Equatable {
  
    /// A succinct label that identifies the accessibility element, in a localized string.
    public var accessibilityLabel: String?
    
    /// A Boolean value indicating whether the receiver is an accessibility element that an assistive application can access
    public var accessible: Bool = true
    
    /// A Boolean value indicating whether header is available for an element
    public var isHeader: Bool? = false

}
