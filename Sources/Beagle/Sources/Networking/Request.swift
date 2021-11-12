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
    public let additionalData: HttpAdditionalData?

    public init(
        url: URL,
        additionalData: HttpAdditionalData?
    ) {
        self.url = url
        self.additionalData = additionalData
    }

    public enum Error: Swift.Error {
        case networkError(NetworkError)
        case decoding(Swift.Error)
        case urlBuilderError

        /// Beagle needs to be configured with your custom NetworkClient that is responsible to do network requests.
        /// So, this error occurs when trying to make a network request and there is no NetworkClient.
        case networkClientWasNotConfigured
    }
}
