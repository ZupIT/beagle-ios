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

public protocol LogType {
    var category: String { get }
    var message: String { get }
    var level: LogLevel { get }
}

public enum LogLevel {
    case error
    case info
}

public enum Log {

    case network(_ network: Network)
    case decode(_ decoding: Decoding)
    case navigation(_ navigator: Navigator)
    case cache(_ cache: Cache)
    case expression(_ expression: Expression)
    case customOperations(_ operation: Operation)
    case collection(_ collection: Collection)

    public enum Decoding {
        case decodingError(type: String)
    }

    public enum Network {
        case httpRequest(request: NetworkRequest)
        case httpResponse(response: NetworkResponse)
        case couldNotBuildUrl(url: String)
        case networkClientWasNotConfigured
    }

    public enum Navigator {
        case didReceiveAction(Navigate)
        case unableToPrefetchWhenUrlIsExpression
        case didNotFindDeepLinkScreen(path: String)
        case routeDoesNotExistInTheCurrentStack(path: String)
        case didNavigateToExternalUrl(path: String)
        case invalidExternalUrl(path: String)
        case unableToOpenExternalUrl(path: String)
    }
    
    public enum Cache {
        case saveContext(description: String)
        case loadPersistentStores(description: String)
        case fetchData(description: String)
        case removeData(description: String)
        case clear(description: String)
    }

    public struct NetworkResponse {
        public let data: Data?
        public let response: URLResponse?

        public var logMessage: String {
            let response = (self.response as? HTTPURLResponse)
            let string = """
            ***HTTP RESPONSE***
            StatusCode= \(response?.statusCode ?? 0)
            Body= \(String(data: data ?? Data(), encoding: .utf8) ?? "")
            Headers= \(response?.allHeaderFields ?? [:])
            """
            return string
        }
        
        public init(
            data: Data? = nil,
            response: URLResponse? = nil
        ) {
            self.data = data
            self.response = response
        }
    }

    public struct NetworkRequest {
        public let url: URLRequest?

        public var logMessage: String {
            let string = """
            ***HTTP REQUEST***:
            Url= \(url?.url?.absoluteString ?? "")
            HttpMethod= \(url?.httpMethod ?? "")
            Headers= \(url?.allHTTPHeaderFields ?? [:])
            Body= \(String(data: url?.httpBody ?? Data(), encoding: .utf8) ?? "empty")
            """
            return string
        }
        
        public init(
            url: URLRequest? = nil
        ) {
            self.url = url
        }
        
    }

    public enum Expression {
        case invalidSyntax
    }
    
    public enum Operation {
        case alreadyExists
        case invalid(name: String)
        case notFound
    }
    
    public enum Collection {
        case templateNotFound(item: String)
    }
}

extension Log: LogType {

    public var category: String {
        switch self {
        case .decode: return "Decoding"
        case .navigation: return "Navigation"
        case .network: return "Network"
        case .cache: return "Cache"
        case .expression: return "Expression"
        case .customOperations: return "CustomOperation"
        case .collection: return "Collection"
        }
    }

    public var message: String {
        switch self {
        case .network(.httpRequest(let request)):
            return request.logMessage
        case .network(.httpResponse(let response)):
            return response.logMessage
        case .network(let log):
            return String(describing: log)

        case .navigation(.didNotFindDeepLinkScreen(let path)):
            return "Beagle Navigator couldn't find a deep link screen with path: \(path). Check your deep link handler, or the path in the navigate action"
        case .navigation(let log):
            return String(describing: log)

        case .decode(.decodingError(let type)):
            return "Could not decode: \(type). Check if that type has been registered."
            
        case .cache(.saveContext(let description)):
            return "Cold not save data in current core data context. error: \(description)"
        case .cache(.loadPersistentStores(let description)):
            return "Cold not load persistent container: \(description)"
        case .cache(.fetchData(let description)):
            return "Cold not load fetch data from cache: \(description)"
        case .cache(.removeData(let description)):
            return "Cold not load remove register from cache: \(description)"
        case .cache(.clear(let description)):
            return "Cold clear registers from cache: \(description)"

        case .expression(.invalidSyntax):
            return "Using Expressions without proper syntax"
            
        case .customOperations(.alreadyExists):
            return "You are replacing a default operation in Beagle, consider using a different name."
        case .customOperations(.invalid(let name)):
            return "\n Invalid custom operation name: \(name) \n Names should have at least 1 character, it can also contain numbers and the character _"
        case .customOperations(.notFound):
            return "Custom operation not registered."

        case .collection(.templateNotFound(let item)):
            return "Could not find a template for `\(item)`."
        }
    }

    public var level: LogLevel {
        switch self {
        case .network(let net):
            switch net {
            case .httpRequest, .httpResponse: return .info
            case .couldNotBuildUrl, .networkClientWasNotConfigured: return .error
            }

        case .decode(.decodingError): return .error

        case .navigation(let nav):
            switch nav {
            case .didNotFindDeepLinkScreen, .routeDoesNotExistInTheCurrentStack, .invalidExternalUrl, .unableToOpenExternalUrl, .unableToPrefetchWhenUrlIsExpression:
                return .error
            case .didReceiveAction, .didNavigateToExternalUrl:
                return .info
            }
        
        case .cache:
            return .error

        case .expression(.invalidSyntax):
            return .info
            
        case .customOperations(let custom):
            switch custom {
            case .alreadyExists, .notFound:
                return .info
            case .invalid:
                return .error
            }

        case .collection(.templateNotFound):
            return .error
        }
    }
}
