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

public class BeagleScreenViewModel {
    
    // MARK: Properties
        
    var screenType: ScreenType {
        didSet {
            screenAppearEventIsPending = true
            screen = nil
        }
    }
    var screen: Screen?
    var state: ServerDrivenState {
        didSet { stateObserver?.didChangeState(state) }
    }
    
    public var beagleViewStateObserver: BeagleViewStateObserver?
    private var screenAppearEventIsPending = true
    
    // MARK: Dependencies
    
    @Injected var coder: CoderProtocol
    @Injected var viewClient: ViewClientProtocol
    @OptionalInjected var analyticsService: AnalyticsService?

    // MARK: Observer

    weak var stateObserver: BeagleScreenStateObserver? {
        didSet { stateObserver?.didChangeState(state) }
    }

    // MARK: Init
    
    internal static func remote(
        _ remote: ScreenType.Remote,
        viewClient: ViewClientProtocol,
        resolver: DependenciesContainerResolving,
        completion: @escaping (Result<BeagleScreenViewModel, Request.Error>) -> Void
    ) -> RequestToken? {
        
        return fetchScreen(remote: remote, viewClient: viewClient) { result in
            let viewModel = BeagleScreenViewModel(screenType: .remote(remote), resolver: resolver)
            switch result {
            case .success(let screen):
                viewModel.handleRemoteScreenSuccess(screen)
                completion(.success(viewModel))
            case .failure(let error):
                viewModel.handleRemoteScreenFailure(error)
                if viewModel.screen == nil {
                    completion(.failure(error))
                } else {
                    completion(.success(viewModel))
                }
            }
        }
    }

    internal required init(
        screenType: ScreenType,
        resolver: DependenciesContainerResolving = GlobalConfiguration.resolver
    ) {
        self.screenType = screenType
        self.state = .started
        _coder = Injected(resolver)
        _viewClient = Injected(resolver)
        _analyticsService = OptionalInjected(resolver)
    }
    
    internal convenience init(
        screenType: ScreenType,
        resolver: DependenciesContainerResolving = GlobalConfiguration.resolver,
        beagleViewStateObserver: @escaping BeagleViewStateObserver
    ) {
        self.init(screenType: screenType, resolver: resolver)
        self.beagleViewStateObserver = beagleViewStateObserver
    }
    
    public func loadScreen() {
        guard screen == nil else { return }
        switch screenType {
        case .remote(let remote):
            loadRemoteScreen(remote)
        case .declarative(let screen):
            self.screen = screen
            state = .success
        case .declarativeText(let text):
            tryToLoadScreenFromText(text)
        }
    }
    
    public func trackEventOnScreenAppeared() {
        screenAppearEventIsPending = false
        analyticsService?.createRecord(screen: screenType, rootId: screen?.id)
    }
    
    public func trackEventOnScreenDisappeared() {}

    // MARK: Core
    
    func tryToLoadScreenFromText(_ text: String) {
        guard let loadedScreen = loadScreenFromText(text) else {
            state = .error(.declarativeText)
            return
        }

        screen = loadedScreen
        state = .success
    }

    func loadScreenFromText(_ text: String) -> Screen? {
        guard let data = text.data(using: .utf8) else { return nil }
        let component: ServerDrivenComponent? = try? coder.decode(from: data)
        return component?.toScreen()
    }

    func loadRemoteScreen(_ remote: ScreenType.Remote) {
        state = .started

        Self.fetchScreen(remote: remote, viewClient: viewClient) {
            [weak self] result in guard let self = self else { return }
            
            switch result {
            case .success(let screen):
                self.handleRemoteScreenSuccess(screen)
                if self.screenAppearEventIsPending {
                    self.trackEventOnScreenAppeared()
                }
            case .failure(let error):
                self.handleRemoteScreenFailure(error)
            }
        }
    }
    
    @discardableResult
    private static func fetchScreen(
        remote: ScreenType.Remote,
        viewClient: ViewClientProtocol,
        completion: @escaping (Result<Screen, Request.Error>) -> Void
    ) -> RequestToken? {
        return viewClient.fetch(
            url: remote.url,
            additionalData: remote.additionalData
        ) {
            completion($0.map { $0.toScreen() })
        }
    }
    
    private func handleRemoteScreenSuccess(_ screen: Screen) {
        self.screen = screen
        state = .success
    }
    
    private func handleRemoteScreenFailure(_ error: Request.Error) {
        if case let .remote(remote) = screenType, let fallback = remote.fallback {
            screen = fallback
            state = .success
        } else {
            state = .error(.remoteScreen(error))
        }
    }
}

// MARK: - Observer

protocol BeagleScreenStateObserver: AnyObject {
    typealias ViewModel = BeagleScreenViewModel

    func didChangeState(_ state: ServerDrivenState)
}
