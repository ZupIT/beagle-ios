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

/// SendRequest is used to make HTTP requests.
public struct SendRequest: Action {
    
    /// Server URL.
    public var url: Expression<String>
    
    /// HTTP method.
    public var method: Expression<HTTPMethod>?
    
    /// Content that will be delivered with the request.
    public var data: DynamicObject?
    
    /// Header items for the request.
    public var headers: Expression<[String: String]>?
    
    /// Actions to be executed in request success case.
    @AutoCodable
    public var onSuccess: [Action]?
    
    /// Actions to be executed in request error case.
    @AutoCodable
    public var onError: [Action]?
    
    /// Actions to be executed in request completion case.
    @AutoCodable
    public var onFinish: [Action]?
    
    /// Defines an analytics configuration for this action.
    public var analytics: ActionAnalyticsConfig?
    
}
