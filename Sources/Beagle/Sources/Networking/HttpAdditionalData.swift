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

/// RouteAdditionalData can be used on navigate actions to pass additional http data on requests triggered by Beagle.
public class HttpAdditionalData: Codable {
    public var method: HTTPMethod? = .get
    public var headers: [String: String]? = [:]
    public var body: DynamicObject?
    
    public init(
        method: HTTPMethod? = .get,
        headers: [String: String]? = [:],
        body: DynamicObject?
    ) {
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    public init<T: Encodable>(
        method: HTTPMethod? = .get,
        headers: [String: String]? = [:],
        body: T
    ) {
        self.method = method
        self.headers = headers
        self.body = DynamicObject(body)
    }
}

extension HttpAdditionalData: Equatable {
    public static func == (lhs: HttpAdditionalData, rhs: HttpAdditionalData) -> Bool {
       guard lhs.method == rhs.method else { return false }
       guard lhs.headers == rhs.headers else { return false }
       guard lhs.body == rhs.body else { return false }
       return true
   }
}

/// HTTP Method to indicate the desired action to be performed for a given resource
public enum HTTPMethod: String, Codable {
    /// The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
    case get = "GET"
    /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    case post = "POST"
    /// The PUT method replaces all current representations of the target resource with the request payload.
    case put = "PUT"
    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"
    /// The HEAD method asks for a response identical to that of a GET request, but without the response body.
    case head = "HEAD"
    /// The PATCH method is used to apply partial modifications to a resource.
    case patch = "PATCH"
}
