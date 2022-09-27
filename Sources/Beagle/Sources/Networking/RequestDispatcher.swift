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

import Foundation

struct RequestDispatcher {
    
    // MARK: Dependencies
    
    @Injected var urlBuilder: UrlBuilderProtocol
    @Injected var logger: LoggerProtocol
    @OptionalInjected var networkClient: NetworkClientProtocol?
    
    // MARK: Internal Methods
    
    init() { }
    
    public init(_ resolver: DependenciesContainerResolving) {
        _urlBuilder = Injected(resolver)
        _logger = Injected(resolver)
        _networkClient = OptionalInjected(resolver)
    }

    @discardableResult
    func dispatchRequest(
        path: String,
        additionalData: HttpAdditionalData?,
        completion: @escaping (Result<NetworkResponse, Request.Error>) -> Void
    ) -> RequestToken? {
        guard let url = urlBuilder.build(path: path) else {
            logger.log(Log.network(.couldNotBuildUrl(url: path)))
            completion(.failure(.urlBuilderError))
            return nil
        }

        guard let networkClient = networkClient else {
            logger.log(Log.network(.networkClientWasNotConfigured))
            completion(.failure(.networkClientWasNotConfigured))
            return nil
        }
        
        let request = Request(url: url, additionalData: additionalData)
        return networkClient.executeRequest(request) { result in
            completion(
                result.mapError { .networkError($0) }
            )
        }
    }
}
