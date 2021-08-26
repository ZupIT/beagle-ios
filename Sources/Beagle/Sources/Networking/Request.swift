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

public struct Request {
    public let url: URL
    public let type: RequestType
    public let additionalData: RemoteScreenAdditionalData?

    public init(
        url: URL,
        type: RequestType,
        additionalData: RemoteScreenAdditionalData?
    ) {
        self.url = url
        self.type = type
        self.additionalData = additionalData
    }

    public enum RequestType {
        case fetchComponent
        case fetchImage
        case rawRequest(RequestData)
    }
    
    public struct RequestData {
        public let method: String?
        public let headers: [String: String]?
        public let body: Any?
        
        public init(
            method: String? = "GET",
            headers: [String: String]? = [:],
            body: Any? = nil
        ) {
            self.method = method
            self.headers = headers
            self.body = body
        }
    }

    public enum Error: Swift.Error {
        case networkError(NetworkError)
        case decoding(Swift.Error)
        case loadFromTextError // unused error
        case urlBuilderError

        /// Beagle needs to be configured with your custom NetworkClient that is responsible to do network requests.
        /// So, this error occurs when trying to make a network request and there is no NetworkClient.
        case networkClientWasNotConfigured
    }
}
