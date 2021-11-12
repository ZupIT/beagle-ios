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

/// Handles screens navigations actions of the application.
public enum Navigate: Action {
    
    /// Opens up an available browser on the device and navigates to a specified URL as Expression.
    case openExternalURL(Expression<String>, analytics: ActionAnalyticsConfig? = nil)
    
    /// Opens a screen that is defined completely local in your app (does not depend on Beagle) which will be retrieved using `DeeplinkScreenManager`.
    case openNativeRoute(OpenNativeRoute, analytics: ActionAnalyticsConfig? = nil)

    /// Resets the application's root navigation stack with a new navigation stack that has `Route` as the first view
    case resetApplication(Route, controllerId: String? = nil, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Resets the views stack to create a new flow with the passed route.
    case resetStack(Route, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Presents a new screen that comes from a specified route starting a new flow.
    /// You can specify a controllerId, describing the id of navigation controller used for the new flow.
    case pushStack(Route, controllerId: String? = nil, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Unstacks the current view stack.
    case popStack(navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)

    /// Opens a new screen for the given route and stacks that at the top of the hierarchy.
    case pushView(Route, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Dismisses the current view.
    case popView(navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Returns the stack of screens in the application flow for a given screen in a route specified as String.
    case popToView(Expression<String>, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    public struct OpenNativeRoute: Codable {
        
        /// Deeplink identifier.
        public let route: Expression<String>
        
        /// Data that could be passed between screens.
        public let data: [String: String]?
        
        /// Allows customization of the behavior of restarting the application view stack.
        public let shouldResetApplication: Bool

        public init(
            route: StringOrExpression,
            data: [String: String]? = nil,
            shouldResetApplication: Bool = false
        ) {
            self.route = Expression(stringLiteral: route)
            self.data = data
            self.shouldResetApplication = shouldResetApplication
        }
    }
    
    public var analytics: ActionAnalyticsConfig? {
        switch self {
        case .openExternalURL(_, analytics: let analytics),
             .openNativeRoute(_, analytics: let analytics),
             .resetApplication(_, _, _, analytics: let analytics),
             .resetStack(_, _, analytics: let analytics),
             .pushStack(_, _, _, analytics: let analytics),
             .popStack(_, analytics: let analytics),
             .pushView(_, _, analytics: let analytics),
             .popView(_, analytics: let analytics),
             .popToView(_, _, analytics: let analytics):
            return analytics
        }
    }
    
}

public struct NavigationContext: Codable {
    public var path: Path?
    public var value: DynamicObject
    
    static let id = "navigationContext"
}

/// Defines a navigation route type which can be `remote` or `declarative`.
public enum Route {
    
    /// Navigates to a remote content on a specified path.
    case remote(NewPath)
    
    /// Navigates to a specified screen.
    case declarative(Screen)
}

extension Route {
    
    /// Constructs a new path to a remote screen.
    public struct NewPath: Codable {
        
        /// Contains the navigation endpoint.
        public let url: Expression<String>
        
        /// Changes _when_ this screen is requested.
        ///
        /// - If __false__, Beagle will only request this screen when the Navigate action gets triggered (e.g: user taps a button).
        /// - If __true__, Beagle will trigger the request as soon as it renders the component that have
        /// this action. (e.g: when a button appears on the screen it will trigger)
        public var shouldPrefetch: Bool?
        
        /// A screen that should be rendered in case of request fail.
        public var fallback: Screen?

        /// Used to pass additional http data on requests
        public var httpAdditionalData: HttpAdditionalData?

    }
}

// MARK: Codable

extension Navigate: Codable {
    
    enum CodingKeys: CodingKey {
        case _beagleAction_
        case analytics
        case route
        case url
        case controllerId
        case navigationContext
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: ._beagleAction_)
        let analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
        let navigationContext = try container.decodeIfPresent(NavigationContext.self, forKey: .navigationContext)
        switch type.lowercased() {
        case "beagle:openexternalurl":
            self = .openExternalURL(try container.decode(Expression<String>.self, forKey: .url), analytics: analytics)
        case "beagle:opennativeroute":
            self = .openNativeRoute(try .init(from: decoder), analytics: analytics)
        case "beagle:resetapplication":
            self = .resetApplication(
                try container.decode(Route.self, forKey: .route),
                controllerId: try container.decodeIfPresent(String.self, forKey: .controllerId),
                navigationContext: navigationContext,
                analytics: analytics
            )
        case "beagle:resetstack":
            self = .resetStack(try container.decode(Route.self, forKey: .route), navigationContext: navigationContext, analytics: analytics)
        case "beagle:pushstack":
            self = .pushStack(
                try container.decode(Route.self, forKey: .route),
                controllerId: try container.decodeIfPresent(String.self, forKey: .controllerId),
                navigationContext: navigationContext,
                analytics: analytics
            )
        case "beagle:popstack":
            self = .popStack(navigationContext: navigationContext, analytics: analytics)
        case "beagle:pushview":
            self = .pushView(try container.decode(Route.self, forKey: .route), navigationContext: navigationContext, analytics: analytics)
        case "beagle:popview":
            self = .popView(navigationContext: navigationContext, analytics: analytics)
        case "beagle:poptoview":
            self = .popToView(
                try container.decode(Expression<String>.self, forKey: .route),
                navigationContext: navigationContext,
                analytics: analytics
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: ._beagleAction_,
                                                   in: container,
                                                   debugDescription: "Can't decode '\(type)'")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(analytics, forKey: .analytics)
        
        switch self {
        case let .openExternalURL(expression, _):
            try container.encode("beagle:openexternalurl", forKey: ._beagleAction_)
            try container.encode(expression, forKey: .url)
        case let .openNativeRoute(openNativeRoute, _):
            try container.encode("beagle:opennativeroute", forKey: ._beagleAction_)
            try openNativeRoute.encode(to: encoder)
        case let .resetApplication(route, controllerId, navigationContext, _):
            try container.encode("beagle:resetapplication", forKey: ._beagleAction_)
            try container.encode(route, forKey: .route)
            try container.encodeIfPresent(controllerId, forKey: .controllerId)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .resetStack(route, navigationContext, _):
            try container.encode("beagle:resetstack", forKey: ._beagleAction_)
            try container.encode(route, forKey: .route)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .pushStack(route, controllerId, navigationContext, _):
            try container.encode("beagle:pushstack", forKey: ._beagleAction_)
            try container.encode(route, forKey: .route)
            try container.encodeIfPresent(controllerId, forKey: .controllerId)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .popStack(navigationContext, _):
            try container.encode("beagle:popstack", forKey: ._beagleAction_)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .pushView(route, navigationContext, _):
            try container.encode("beagle:pushview", forKey: ._beagleAction_)
            try container.encode(route, forKey: .route)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .popView(navigationContext, _):
            try container.encode("beagle:popview", forKey: ._beagleAction_)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        case let .popToView(expression, navigationContext, _):
            try container.encode("beagle:poptoview", forKey: ._beagleAction_)
            try container.encode(expression, forKey: .route)
            try container.encodeIfPresent(navigationContext, forKey: .navigationContext)
        }
        
    }
}

extension Route: Codable {
    
    enum CodingKeys: CodingKey {
        case screen
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let screen = try? container.decode(Screen.self, forKey: .screen) {
            self = .declarative(screen)
        } else {
            let newPath: Route.NewPath = try .init(from: decoder)
            self = .remote(newPath)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .remote(let newPath):
            try newPath.encode(to: encoder)
        case .declarative(let screen):
            try container.encode(screen, forKey: .screen)
        }
    }
}
