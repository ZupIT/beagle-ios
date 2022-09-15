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

public protocol NavigationProtocol {
    
    func setDefaultAnimation(_ animation: BeagleNavigatorAnimation)
    
    typealias NavigationBuilder = () -> BeagleNavigationController

    /// Register the default `BeagleNavigationController` to be used when creating a new navigation flow.
    /// - Parameter builder: will be called when a `BeagleNavigationController` custom type needs to be used.
    func registerDefaultNavigationController(builder: @escaping NavigationBuilder)

    /// Register a `BeagleNavigationController` to be used when creating a new navigation flow with the associated `controllerId`.
    /// - Parameters:
    ///   - builder: will be called when a `BeagleNavigationController` custom type needs to be used.
    ///   - controllerId: the cross platform id that identifies the controller in the BFF.
    func registerNavigationController(builder: @escaping NavigationBuilder, forId controllerId: String)

    /// You can use this to the right `BeagleNavigationController` instance depending on the `controllerId` used
    /// - Parameter controllerId: if nil, will return the default navigation controller type
    func navigationController(forId controllerId: String?) -> BeagleNavigationController
}

protocol NavigationProtocolInternal: NavigationProtocol {
    func navigate(action: Navigate, controller: BeagleController, animated: Bool, origin: UIView?)
}

final class Navigator: NavigationProtocolInternal {

    var defaultAnimation: BeagleNavigatorAnimation?
    
    var builders: [String: NavigationBuilder] = [:]
    var defaultBuilder: NavigationBuilder?
    
    // MARK: - Dependencies
    
    @Injected var logger: LoggerProtocol
    @Injected var opener: URLOpenerProtocol
    @Injected var windowManager: WindowManagerProtocol
    @Injected var urlBuilder: UrlBuilderProtocol
    @Injected var viewClient: ViewClientProtocol
    @OptionalInjected var deepLinkHandler: DeepLinkScreenManagerProtocol?
    
    init() { }
    
    init(_ resolver: DependenciesContainerResolving) {
        _logger = Injected(resolver)
        _opener = Injected(resolver)
        _windowManager = Injected(resolver)
        _urlBuilder = Injected(resolver)
        _viewClient = Injected(resolver)
        _deepLinkHandler = OptionalInjected(resolver)
    }
    
    // MARK: - Public Methods

    // MARK: Navigate
    
    func navigate(action: Navigate, controller: BeagleController, animated: Bool = false, origin: UIView?) {
        logger.log(Log.navigation(.didReceiveAction(action)))
        switch action {
        case let .openExternalURL(url, _):
            let path = url.evaluate(with: origin) ?? ""
            openExternalURL(path: path, controller: controller)
        case let .openNativeRoute(nativeRoute, _):
            openNativeRoute(controller: controller, origin: origin, animated: animated, nativeRoute: nativeRoute)
        case let .resetApplication(route, controllerId, navigationContext, _):
            navigate(
                route: route,
                navigationContext: navigationContext,
                controller: controller,
                animated: animated,
                origin: origin
            ) { [weak self] origin, destination, animated in
                self?.resetApplication(origin: origin, destination: destination, controllerId: controllerId, animated: animated)
            }
        case let .resetStack(route, navigationContext, _):
            navigate(route: route, navigationContext: navigationContext, controller: controller, animated: animated, origin: origin, transition: resetStack(origin:destination:animated:))
        case let .pushView(route, navigationContext, _):
            navigate(route: route, navigationContext: navigationContext, controller: controller, animated: animated, origin: origin, transition: pushView(origin:destination:animated:))
        case let .popView(navigationContext, _):
            popView(controller: controller, navigationContext: navigationContext, origin: origin, animated: animated)
        case let .popToView(route, navigationContext, _):
            let identifier = route.evaluate(with: origin) ?? ""
            popToView(identifier: identifier, controller: controller, navigationContext: navigationContext, origin: origin, animated: animated)
        case let .pushStack(route, controllerId, navigationContext, _):
            navigate(route: route,
                     navigationContext: navigationContext,
                     controller: controller,
                     animated: animated,
                     origin: origin) { [weak self] origin, destination, animated in
                self?.pushStack(origin: origin, destination: destination, controllerId: controllerId, animated: animated)
            }
        case let .popStack(navigationContext, _):
            popStack(controller: controller, navigationContext: navigationContext, origin: origin, animated: animated)
        }
    }
    
    // MARK: - Register
    
    func setDefaultAnimation(_ animation: BeagleNavigatorAnimation) {
        self.defaultAnimation = animation
    }

    func registerDefaultNavigationController(builder: @escaping NavigationBuilder) {
        defaultBuilder = builder
    }

    func registerNavigationController(builder: @escaping NavigationBuilder, forId controllerId: String) {
        builders[controllerId] = builder
    }

    func navigationController(forId controllerId: String? = nil) -> BeagleNavigationController {
        if let id = controllerId, let builder = builders[id] {
            return builder()
        } else {
            if let providedBuilder = defaultBuilder {
                return providedBuilder()
            } else {
                return BeagleNavigationController()
            }
        }
    }
    
    // MARK: - Private Methods

    // MARK: Navigate Handle

    private typealias Transition = (BeagleController, UIViewController, Bool) -> Void
    
    private func navigate(route: Route, navigationContext: NavigationContext?, controller: BeagleController, animated: Bool, origin: UIView?, transition: @escaping Transition) {
        viewController(
            route: route,
            controller: controller,
            origin: origin,
            retry: { [weak controller] in
                guard let controller = controller else { return }
                self.navigate(route: route, navigationContext: navigationContext, controller: controller, animated: animated, origin: origin, transition: transition)
            },
            success: {
                transition(controller, $0, animated)
                $0.setNavigationContext(navigationContext, origin: origin)
            }
        )
    }
    
    private func openExternalURL(path: String, controller: BeagleController) {
        opener.tryToOpen(path: path)
    }
    
    private func openNativeRoute(controller: BeagleController, origin: UIView?, animated: Bool, nativeRoute: Navigate.OpenNativeRoute) {
        let path = nativeRoute.route.evaluate(with: origin) ?? ""
        do {
            guard let deepLinkHandler = deepLinkHandler else { return }
            let viewController = try deepLinkHandler.getNativeScreen(with: path, data: nativeRoute.data)
            
            if let transition = defaultAnimation?.getTransition(.push) {
                controller.navigationController?.view.layer.add(transition, forKey: nil)
            }
            
            if nativeRoute.shouldResetApplication {
                windowManager.window?.replace(rootViewController: viewController, animated: animated, completion: nil)
            } else {
                controller.navigationController?.pushViewController(viewController, animated: animated)
            }
        } catch {
            logger.log(Log.navigation(.didNotFindDeepLinkScreen(path: path)))
            return
        }
    }
    
    private func resetApplication(origin: BeagleController, destination: UIViewController, controllerId: String?, animated: Bool) {
        let navigation = navigationController(forId: controllerId)
        navigation.viewControllers = [destination]
        windowManager.window?.replace(rootViewController: navigation, animated: animated, completion: nil)
    }
    
    private func resetStack(origin: BeagleController, destination: UIViewController, animated: Bool) {
        origin.navigationController?.setViewControllers([destination], animated: animated)
    }
    
    private func pushView(origin: BeagleController, destination: UIViewController, animated: Bool) {
        if let transition = defaultAnimation?.getTransition(.push) {
            origin.navigationController?.view.layer.add(transition, forKey: nil)
        }
        origin.navigationController?.pushViewController(destination, animated: animated)
    }
    
    private func popView(controller: BeagleController, navigationContext: NavigationContext?, origin: UIView?, animated: Bool) {
        guard let navigation = controller.navigationController, navigation.viewControllers.count > 1 else {
            popStack(controller: controller, navigationContext: navigationContext, origin: origin, animated: animated)
            return
        }
        if let transition = defaultAnimation?.getTransition(.pop) {
            navigation.view.layer.add(transition, forKey: nil)
        }
        if let destination = navigation.viewControllers[safe: navigation.viewControllers.count - 2] {
            destination.setNavigationContext(navigationContext, origin: origin)
        }
        navigation.popViewController(animated: animated)
    }
    
    private func popToView(identifier: String, controller: BeagleController, navigationContext: NavigationContext?, origin: UIView?, animated: Bool) {
        guard let viewControllers = controller.navigationController?.viewControllers else {
            assertionFailure("Trying to pop when there is nothing to pop"); return
        }

        let last = viewControllers.last {
            isViewController($0, identifiedBy: identifier)
        }

        guard let target = last else {
            logger.log(Log.navigation(.routeDoesNotExistInTheCurrentStack(path: identifier)))
            return
        }
        if let transition = defaultAnimation?.getTransition(.pop) {
            controller.navigationController?.view.layer.add(transition, forKey: nil)
        }
        target.setNavigationContext(navigationContext, origin: origin)
        controller.navigationController?.popToViewController(target, animated: animated)
    }
    
    private func pushStack(origin: BeagleController, destination: UIViewController, controllerId: String? = nil, animated: Bool) {
        let navigationToPresent = navigationController(forId: controllerId)
        navigationToPresent.viewControllers = [destination]
        
        if #available(iOS 13.0, *) {
            navigationToPresent.modalPresentationStyle = defaultAnimation?.modalPresentationStyle ?? .automatic
        } else {
            navigationToPresent.modalPresentationStyle = defaultAnimation?.modalPresentationStyle ?? .fullScreen
        }
        
        if let defaultAnimation = defaultAnimation {
            navigationToPresent.modalTransitionStyle = defaultAnimation.modalTransitionStyle
        }
        
        origin.present(navigationToPresent, animated: animated)
    }
    
    var applicationManager: ApplicationManager = ApplicationManagerDefault()
    
    private func popStack(controller: UIViewController, navigationContext: NavigationContext?, origin: UIView?, animated: Bool) {
        controller.dismiss(animated: animated) {
            if let destination = self.applicationManager.topViewController(
                base: UIApplication.shared.keyWindow?.rootViewController
            ) {
                destination.setNavigationContext(navigationContext, origin: origin)
            }
        }
    }
    
    // MARK: Utils
    
    private func isViewController(
        _ viewController: UIViewController,
        identifiedBy identifier: String
    ) -> Bool {
        guard let controller = viewController as? BeagleController else {
            return false
        }
        switch controller.screenType {
        case .remote(let remote):
            let expectedUrl = absoluteURL(for: identifier, builder: urlBuilder)
            let screenUrl = absoluteURL(for: remote.url, builder: urlBuilder)
            return screenUrl == expectedUrl
        case .declarative(let screen):
            return screen.id == identifier
        case .declarativeText:
            return controller.screen?.id == identifier
        }
    }
    
    private func absoluteURL(for path: String, builder: UrlBuilderProtocol) -> String? {
        return builder.build(path: path)?.absoluteString
    }
    
    private func viewController(
        route: Route,
        controller: BeagleController,
        origin: UIView?,
        retry: @escaping BeagleRetry,
        success: @escaping (BeagleScreenViewController) -> Void
    ) {
        switch route {
        case .remote(let newPath):
            remote(path: newPath, controller: controller, origin: origin, retry: retry, success: success)
        case .declarative(let screen):
            success(
                BeagleScreenViewController(
                    viewModel: .init(screenType: .declarative(screen)),
                    config: controller.config
                )
            )
        }
    }
    
    @discardableResult
    private func remote(
        path: Route.NewPath,
        controller: BeagleController,
        origin: UIView?,
        retry: @escaping BeagleRetry,
        success: @escaping (BeagleScreenViewController) -> Void
    ) -> RequestToken? {
        controller.serverDrivenState = .started
        let newPath: String? = path.url.evaluate(with: origin)
        
        let remote = ScreenType.Remote(url: newPath ?? "", fallback: path.fallback, additionalData: path.httpAdditionalData)
                
        return BeagleScreenViewController.remote(remote, viewClient: viewClient, controller: controller) {
            [weak controller] result in guard let controller = controller else { return }
            controller.serverDrivenState = .finished
            switch result {
            case .success(let viewController):
                controller.serverDrivenState = .success
                success(viewController)
            case .failure(let error):
                controller.serverDrivenState = .error(.remoteScreen(error), retry)
            }
        }
    }    
}

private extension UIViewController {
    func setNavigationContext(_ navigationContext: NavigationContext?, origin: UIView?) {
        guard var navigationContext = navigationContext else { return }
        if let origin = origin {
            navigationContext.value = navigationContext.value.evaluate(with: origin)
        }
        let contextObserver = view.getContext(with: NavigationContext.id)
        if let contextValue = contextObserver?.value.value, let path = navigationContext.path {
            contextObserver?.value = Context(id: NavigationContext.id, value: contextValue.set(navigationContext.value, with: path))
        } else {
            contextObserver?.value = Context(id: NavigationContext.id, value: navigationContext.value)
        }
    }
}

protocol ApplicationManager {
    func topViewController(base: UIViewController?) -> UIViewController?
}

struct ApplicationManagerDefault: ApplicationManager {
    func topViewController(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        } else if let child = base?.children[safe: 0] {
            return topViewController(base: child)
        }
        return base
    }
    
}
