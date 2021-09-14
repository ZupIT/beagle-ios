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

import XCTest
import SnapshotTesting
@testable import Beagle

final class LazyComponentTests: XCTestCase {
    
    func test_whenDecodingJson_thenItShouldReturnALazyComponent() throws {
        let component: LazyComponent = try componentFromJsonFile(fileName: "lazyComponent")
        _assertInlineSnapshot(matching: component, as: .dump, with: """
        ▿ LazyComponent
          ▿ initialState: UnknownComponent
            - type: "custom:beagleschematestscomponent"
          - path: "/path"
        """)
    }
    
    func test_initWithInitialStateBuilder_shouldReturnExpectedInstance() {
        // Given / When
        let sut = LazyComponent(
            path: "component",
            initialState: Text(text: "text")
        )

        // Then
        XCTAssert(sut.path == "component")
        XCTAssert(sut.initialState is Text)
    }
    
    func test_lazyLoad_shouldReplaceTheInitialContent() {
        let initialState = Text(text: "Loading...", style: Style().backgroundColor("#00FF00"))
        let sut = LazyComponent(path: "", initialState: initialState)
        let viewClient = LazyViewClientStub()
        let dependecies = BeagleDependencies()
        dependecies.viewClient = viewClient
        
        let screenController = BeagleScreenViewController(viewModel: .init(
            screenType: .declarative(Screen(child: sut)),
            dependencies: dependecies)
        )
        
        let size = CGSize(width: 75, height: 80)
        assertSnapshotImage(screenController, size: .custom(size))
        
        screenController.view.setContext(Context(id: "ctx", value: "value of ctx"))
        let lazyLoaded = Text(text: "Lazy Loaded! @{ctx}", style: Style().backgroundColor("#FFFF00"))
        viewClient.componentCompletion?(.success(lazyLoaded))
        
        let consumeMainQueue = expectation(description: "consumeMainQueue")
        DispatchQueue.main.async { consumeMainQueue.fulfill() }
        waitForExpectations(timeout: 1, handler: nil)
        
        assertSnapshotImage(screenController, size: .custom(size))
    }

    func test_lazyLoad_withUpdatableView_shouldCallUpdate() {
        let initialView = OnStateUpdatableViewSpy()
        let sut = LazyComponent(
            path: "",
            initialState: ComponentDummy(resultView: initialView)
        )
        let viewClient = LazyViewClientStub()
        let controller = BeagleControllerStub(dependencies: BeagleScreenDependencies(viewClient: viewClient))
        let renderer = BeagleRenderer(controller: controller)
        
        let view = sut.toView(renderer: renderer)
        viewClient.componentCompletion?(.success(ComponentDummy()))
        
        XCTAssertEqual(view, initialView)
        XCTAssertTrue(initialView.didCallOnUpdateState)
    }
    
    func test_whenLoadFail_shouldSetNotifyTheScreen() throws {
        // Given
        let hostView = UIView()
        let initialView = UIView()
        let sut = LazyComponent(
            path: "",
            initialState: ComponentDummy(resultView: initialView)
        )
        let viewClient = LazyViewClientStub()
        let controller = BeagleControllerStub(dependencies: BeagleScreenDependencies(viewClient: viewClient))
        let renderer = BeagleRenderer(controller: controller)
        
        // When
        let view = sut.toView(renderer: renderer)
        hostView.addSubview(view)
        viewClient.componentCompletion?(.failure(.urlBuilderError))
        
        // Then
        guard case .error(.lazyLoad(.urlBuilderError), let retry) = controller.serverDrivenState else {
            XCTFail("""
            Expected state .error(.lazyLoad(.urlBuilderError), BeagleRetry)
            but found \(controller.serverDrivenState)
            """)
            return
        }
        XCTAssertEqual(view, initialView)
        XCTAssertEqual(view.superview, hostView)
        
        // When
        viewClient.componentCompletion = nil
        let lazyLoadedContent = UIView()
        let retryLazyLoad = try XCTUnwrap(retry)
        retryLazyLoad()
        
        viewClient.componentCompletion?(.success(ComponentDummy(resultView: lazyLoadedContent)))
        
        let expect = expectation(description: "consume queue")
        DispatchQueue.main.async { expect.fulfill() }
        waitForExpectations(timeout: 1)
        
        XCTAssertNil(view.superview)
        XCTAssertEqual(lazyLoadedContent.superview, hostView)
    }
    
}

class LazyViewClientStub: ViewClient {

    var componentCompletion: ((Result<ServerDrivenComponent, Request.Error>) -> Void)?

    func fetch(
        url: String,
        additionalData: RemoteScreenAdditionalData?,
        completion: @escaping (Result<ServerDrivenComponent, Request.Error>) -> Void
    ) -> RequestToken? {
        componentCompletion = completion
        return nil
    }
    
    func prefetch(url: String, additionalData: RemoteScreenAdditionalData?) {}
    
}

class OnStateUpdatableViewSpy: UIView, OnStateUpdatable {
    private (set) var didCallOnUpdateState = false
    
    func onUpdateState(component: ServerDrivenComponent) -> Bool {
        didCallOnUpdateState = true
        return true
    }
}
