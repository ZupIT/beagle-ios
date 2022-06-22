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

import XCTest
import SnapshotTesting
@testable import Beagle

// MARK: - Dependencies Dummies

final class BundleDummy: BundleProtocol {
    // swiftlint:disable discouraged_direct_init
    var bundle: Bundle = Bundle()
    // swiftlint:enable discouraged_direct_init
}

final class DeepLinkHandlerDummy: DeepLinkScreenManagerProtocol {
    func getNativeScreen(with path: String, data: [String: String]?) throws -> UIViewController {
        return UIViewController()
    }
}

final class CoderDummy: CoderProtocol {
    func register<T: BeagleCodable>(type: T.Type, named: String?) {}
    
    func decode<T>(from data: Data) throws -> T {
        if T.self == Action.self {
            // swiftlint:disable force_cast
            return ActionDummy() as! T
        }
        return ComponentDummy() as! T
        // swiftlint:enable force_cast
    }
    
    func encode<T: BeagleCodable>(value: T) throws -> Data {
        Data()
    }
    
    func name(for type: BeagleCodable.Type) -> String? {
        nil
    }
    
    func type(for name: String, baseType: Coder.BaseType) -> BeagleCodable.Type? {
        nil
    }
}

final class PreFetchHelperDummy: PrefetchHelperProtocol {
    func prefetchComponent(newPath: Route.NewPath) { }
}

struct ComponentDummy: ServerDrivenComponent, CustomStringConvertible {
    
    private let resultView: UIView?
    
    var description: String {
        return "ComponentDummy()"
    }
    
    init(resultView: UIView? = nil) {
        self.resultView = resultView
    }
    
    init(from decoder: Decoder) throws {
        self.resultView = nil
    }
    
    func encode(to encoder: Encoder) throws {}
    
    func toView(renderer: BeagleRenderer) -> UIView {
        return resultView ?? UIView()
    }
}

struct ActionDummy: Action, Equatable {
    var analytics: ActionAnalyticsConfig?
    
    func execute(controller: BeagleController, origin: UIView) {}
}

class NetworkClientDummy: NetworkClientProtocol {
    func executeRequest(_ request: Request, completion: @escaping RequestCompletion) -> RequestToken? {
        return nil
    }
}

final class AppThemeDummy: ThemeProtocol {
    func applyStyle<T>(for view: T, withId id: String) where T: UIView {
    }
}

class NavigatorDummy: NavigationProtocolInternal {
    func setDefaultAnimation(_ animation: BeagleNavigatorAnimation) {
        // Intentionally unimplemented...
    }
    
    func navigate(action: Navigate, controller: BeagleController, animated: Bool, origin: UIView?) {
        // Intentionally unimplemented...
    }

    func registerDefaultNavigationController(builder: @escaping NavigationBuilder) {
        // Intentionally unimplemented...
    }

    func registerNavigationController(builder: @escaping NavigationBuilder, forId controllerId: String) {
        // Intentionally unimplemented...
    }

    func navigationController(forId controllerId: String?) -> BeagleNavigationController {
        return .init()
    }
}

class GlobalContextDummy: GlobalContextProtocol {
    let globalId: String = ""
    let context: Observable<Context> = Observable(value: .init(id: "", value: .empty))
    
    func isGlobal(id: String?) -> Bool { true }
    
    func set(value: DynamicObject, path: String?) {
        // Intentionally unimplemented...
    }
    
    func get(path: String?) -> DynamicObject {
        .init(stringLiteral: "Dummy")
    }
    
    func clear(path: String?) {
        // Intentionally unimplemented...
    }
}

class OperationsProviderDummy: OperationsProviderProtocolInternal {
    func register(operationId: String, handler: @escaping OperationHandler) {
        // Intentionally unimplemented...
    }
    
    func evaluate(with operation: Operation, in view: UIView) -> DynamicObject {
        // Intentionally unimplemented...
        return nil
    }
}

final class LoggerDummy: LoggerProtocol {
    func logDecodingError(type: String) {
        
    }
    
    func log(_ log: LogType) {
        return
    }
}

final class UrlBuilderDummy: UrlBuilderProtocol {
    var baseUrl: URL?
    
    func build(path: String) -> URL? {
        return nil
    }
}

final class AnalyticsProviderDummy: AnalyticsProviderProtocol {
    func getConfig() -> AnalyticsConfig {
        .init()
    }
    
    func createRecord(_ record: AnalyticsRecord) {
        // Intentionally unimplemented...
    }
}

final class ImageDownloaderDummy: ImageDownloaderProtocol {
    func fetchImage(
        url: String,
        additionalData: HttpAdditionalData?,
        completion: @escaping (Result<Data, Request.Error>) -> Void
    ) -> RequestToken? {
        return nil
    }
}

class URLOpenerDummy: URLOpenerProtocol {
    func tryToOpen(path: String) {
        // Intentionally unimplemented...
    }
}

class WindowManagerDummy: WindowManagerProtocol {
    var window: WindowProtocol?
}

class ViewClientDummy: ViewClientProtocol {
    func fetch(url: String, additionalData: HttpAdditionalData?, completion: @escaping (Result<ServerDrivenComponent, Request.Error>) -> Void) -> RequestToken? {
        return nil
    }
    
    func prefetch(url: String, additionalData: HttpAdditionalData?) {
        // Intentionally unimplemented...
    }
}

final class ImageProviderDummy: ImageProviderProtocol {
    func loadImageProvider(id: String) -> UIImage? {
        return nil
    }
}
