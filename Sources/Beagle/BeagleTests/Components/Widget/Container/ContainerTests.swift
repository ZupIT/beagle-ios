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

// swiftlint:disable force_unwrapping

import XCTest
import SnapshotTesting
@testable import Beagle

final class ContainerTests: EnviromentTestCase {
    
    private lazy var theme = AppTheme(
        styles: [
           "test.container.style": containerStyle
        ]
    )
    
    override func setUp() {
        super.setUp()
        enviroment.theme = theme
    }
    
    private lazy var controller = BeagleControllerStub()
    private lazy var renderer = BeagleRenderer(controller: controller)
    
    private func containerStyle() -> (UIView?) -> Void {
        return {
            $0?.layer.cornerRadius = 5
            $0?.backgroundColor = .cyan
            $0?.alpha = 0.7
        }
    }
    
    func testCodableContainer() throws {
        let component: Container = try componentFromJsonFile(fileName: "Container")
        assertSnapshotJson(matching: component)
    }
    
    func testCodableContainerWithoutChildren() throws {
        let component: Container = try componentFromJsonFile(fileName: "ContainerWithoutChildren")
        assertSnapshotJson(matching: component)
    }
    
    func test_toView_shouldReturnTheExpectedView() throws {
        // Given
        let numberOfChildren = 3
        let containerChildren = Array(repeating: ComponentDummy(), count: numberOfChildren)
        let container = Container(children: containerChildren)
        
        // When
        let resultingView = renderer.render(container)
        
        // Then
        XCTAssert(resultingView.subviews.count == numberOfChildren)
    }
    
    func test_renderContainer() throws {
        let container = Container(
            children: [
                Text(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum et felis tortor. Maecenas laoreet metus in augue mattis, quis imperdiet urna ornare. Sed commodo fringilla massa, sit amet molestie nunc. Quisque euismod eros felis. Nam dapibus venenatis consequat."),
                Text(text: "Donec orci elit, scelerisque vel mattis at, ornare in libero. Cras vestibulum justo et lacus accumsan malesuada. Pellentesque gravida risus tincidunt sapien commodo iaculis. Praesent eget consectetur ligula, vitae fringilla urna. Donec erat arcu, fermentum sed orci in, euismod dictum augue. Aenean ac ullamcorper ante, sit amet commodo elit. Mauris et nibh ac ante luctus fermentum varius nec mauris."),
                Text(text: "Sed vel nisl tortor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec fringilla velit vulputate ultricies auctor. Sed et enim lacinia risus hendrerit efficitur vitae vel tellus.")
            ],
            style: .init(
                backgroundColor: "#0000FF50",
                cornerRadius: .init(radius: 30.0),
                margin: EdgeValue().horizontal(20),
                flex: Flex().grow(1).justifyContent(.spaceEvenly)
            )
        )

        let screen = BeagleScreenViewController(container)
        assertSnapshotImage(screen, size: .custom(ViewImageConfig.iPhoneXr.size!))
    }
    
    func test_renderContainer_withBorder() throws {
        // Given
        let container = Container(
            children: [Text(text: "Content")],
            style: .init(
                backgroundColor: "#0000FF50",
                cornerRadius: .init(topLeft: 15, topRight: 35, bottomLeft: 25, bottomRight: 50),
                borderColor: "#FF0000",
                borderWidth: .value(4),
                size: .init(width: 100%, height: 100%),
                padding: EdgeValue().all(4)
            )
        )
        
        // When
        let screen = BeagleScreenViewController(container)
        
        // Then
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
    }
    
    func test_actionExecuting() {
        // Given
        
        let expectation = self.expectation(description: "ActionExetuting")
        let controllerSpy = BeagleControllerSpy()
        controllerSpy.expectation = expectation
        
        let renderer = BeagleRenderer(controller: controllerSpy)
        let sut = Container(children: [], onInit: [])
        
        // When

        _ = renderer.render(sut)
        
        // Then
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(controllerSpy.didCalledExecute)
    }
    
    func test_containerStyleId() {
        // Given
        let theme = ThemeSpy()
        enviroment.theme = theme
        
        let style = "test.container.style"
        let container = Container(
            children: [Text(text: "teste", textColor: "#FFFFFF")],
            styleId: style,
            style: Style().size(Size().width(100).height(100))
        )

        // When
        let view = renderer.render(container)

        // Then
        XCTAssertEqual(view, theme.styledView)
        XCTAssertEqual(style, theme.styleApplied)
    }
    
    func testContainerWithBorderAndExpression() throws {
        // Given
        let containerId = "containerSample"
        let container = Container(
            children: [Text(text: "Content")],
            context: Context(id: "context", value: [
                "backgroundColor": "#0000FF50",
                "borderColor": "#0000FF",
                "borderWidth": 2,
                "topLeft": 15,
                "topRight": 35.0,
                "bottomLeft": 25.0,
                "bottomRight": 50.0
            ]),
            id: containerId,
            style: .init(
                backgroundColor: "@{context.backgroundColor}",
                cornerRadius: .init(
                    radius: "@{context.radius}",
                    topLeft: "@{context.topLeft}",
                    topRight: "@{context.topRight}",
                    bottomLeft: "@{context.bottomLeft}",
                    bottomRight: "@{context.bottomRight}"
                ),
                borderColor: "@{context.borderColor}",
                borderWidth: "@{context.borderWidth}",
                size: .init(width: 100%, height: 100%),
                padding: EdgeValue().all(4)
            )
        )
        let action = SetContext(contextId: "context", value: [
            "backgroundColor": "#00000050",
            "borderColor": "#00FF00",
            "borderWidth": 4,
            "radius": 8
        ])
        
        // When // Then
        let screen = BeagleScreenViewController(container)
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
        
        screen.execute(actions: [action], event: "event", origin: screen.view.getView(by: containerId) ?? UIView())
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
    }
    
    func testContainerWithMarginPaddingAndExpression() throws {
        // Given
        let containerId = "containerSample"
        let container = Container(
            children: [
                Container(
                    style: .init(
                        backgroundColor: "#00FF0050",
                        flex: Flex().grow(1)
                    )
                )
            ],
            context: Context(id: "context", value: [
                "marginTop": 4,
                "marginBottom": 4,
                "marginLeft": 2,
                "marginRight": 2,
                "paddingTop": 2,
                "paddingBottom": 2,
                "paddingLeft": 6,
                "paddingRight": 6
            ]),
            id: containerId,
            style: .init(
                backgroundColor: "#0000FF50",
                cornerRadius: .init(radius: 6),
                margin: EdgeValue(
                    left: .init(value: "@{context.marginLeft}", type: .real),
                    top: .init(value: "@{context.marginTop}", type: .real),
                    right: .init(value: "@{context.marginRight}", type: .real),
                    bottom: .init(value: "@{context.marginBottom}", type: .real)
                ),
                padding: EdgeValue(
                    left: .init(value: "@{context.paddingLeft}", type: .real),
                    top: .init(value: "@{context.paddingTop}", type: .real),
                    right: .init(value: "@{context.paddingRight}", type: .real),
                    bottom: .init(value: "@{context.paddingBottom}", type: .real)
                ),
                flex: Flex().grow(1)
            )
        )
        let action = SetContext(contextId: "context", value: [
            "marginTop": 20,
            "marginBottom": 20,
            "marginLeft": 20,
            "marginRight": 20,
            "paddingTop": 20,
            "paddingBottom": 20,
            "paddingLeft": 20,
            "paddingRight": 20
        ])
        
        // When // Then
        let screen = BeagleScreenViewController(container)
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
        
        screen.execute(actions: [action], event: "event", origin: screen.view.getView(by: containerId) ?? UIView())
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
    }
    
    func testContainerWithSizePositionAndExpression() throws {
        // Given
        let containerId = "containerSample"
        let container = Container(
            context: Context(id: "context", value: [
                "width": 40,
                "height": 40,
                "top": 10,
                "left": 10
            ]),
            id: containerId,
            style: .init(
                backgroundColor: "#0000FF50",
                cornerRadius: .init(radius: 6),
                size: Size(
                    width: .init(value: "@{context.width}", type: .real),
                    maxHeight: .init(value: "@{context.height}", type: .real)
                ),
                position: EdgeValue(
                    left: .init(value: "@{context.left}", type: .real),
                    top: .init(value: "@{context.top}", type: .real)
                ),
                flex: Flex().grow(1)
            )
        )
        let action = SetContext(contextId: "context", value: [
            "width": 60,
            "height": 60,
            "top": 20,
            "left": 20
        ])
        
        // When // Then
        let screen = BeagleScreenViewController(container)
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
        
        screen.execute(actions: [action], event: "event", origin: screen.view.getView(by: containerId) ?? UIView())
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 100)))
    }
}

class BeagleControllerSpy: BeagleController {
    
    var serverDrivenState: ServerDrivenState = .finished
    var screenType: ScreenType = .declarativeText("")
    var screen: Screen?
    
    var expectation: XCTestExpectation?
    
    var bindings: [() -> Void] = []
    
    func execute(action: Action, sender: Any) { }
    
    private(set) var didCalledExecute = false
    private(set) var lastImplicitContext: Context?
    
    func addOnInit(_ onInit: [Action], in view: UIView) {
        execute(actions: onInit, event: "onInit", origin: view)
    }
    
    func addBinding<T: Decodable>(expression: ContextExpression, in view: UIView, update: @escaping (T?) -> Void) {
        // Intentionally unimplemented...
    }
    
    func execute(actions: [Action]?, event: String?, origin: UIView) {
        didCalledExecute = true
        expectation?.fulfill()
    }
    
    func execute(actions: [Action]?, with contextId: String, and contextValue: DynamicObject, origin: UIView) {
        lastImplicitContext = Context(id: contextId, value: contextValue)
        didCalledExecute = true
        expectation?.fulfill()
    }
    
}
