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

class PageViewTests: XCTestCase {
    
    func test_whenDecodingJson_thenItShouldReturnAPageView() throws {
        let component: PageView = try componentFromJsonFile(fileName: "PageViewWith3Pages")
        _assertInlineSnapshot(matching: component, as: .dump, with: """
        ▿ PageView
          ▿ children: Optional<Array<ServerDrivenComponent>>
            ▿ some: 3 elements
              ▿ UnknownComponent
                - type: "custom:beagleschematestscomponent"
              ▿ UnknownComponent
                - type: "custom:beagleschematestscomponent"
              ▿ UnknownComponent
                - type: "custom:beagleschematestscomponent"
          - context: Optional<Context>.none
          - currentPage: Optional<Expression<Int>>.none
          - onPageChange: Optional<Array<Action>>.none
        """)
    }

    func test_whenDecodingInvalidJson() throws {
        XCTAssertThrowsError(
            try componentFromJsonFile(componentType: PageView.self, fileName: "PageViewInvalid")
        )
    }
    
    private let indicator = PageIndicator(selectedColor: "#d1cebd", unselectedColor: "#f6eedf")

    private let page = Container(children: [
        Text(text: "First text"),
        Button(text: "Button"),
        Text(text: "Second text")
    ]).applyFlex(Flex(flexDirection: .column, justifyContent: .center))

    func test_viewWithPages() {
        let pageView = PageView(
            children: Array(repeating: page, count: 5)
        )

        let screen = BeagleScreenViewController(pageView)
        assertSnapshotImage(screen)
    }
    
    func test_viewWithNoPages() {
        let pageView = PageView(
            children: []
        )

        let screen = BeagleScreenViewController(pageView)
        assertSnapshotImage(screen)
    }
    
    func test_pageViewWithContext() {
        let pageView = PageView(
            children: [Text(text: "Context: @{ctx}")],
            context: Context(id: "ctx", value: "value of ctx")
        )
        
        let screen = BeagleScreenViewController(pageView)
        assertSnapshotImage(screen, size: .custom(CGSize(width: 100, height: 50)))
    }
    
    func test_PageViewChildShouldNotCreateNewNavigationController() {
        let navigation = BeagleNavigationController()
        let controller = BeagleScreenViewController(ComponentDummy())
        navigation.viewControllers = [controller]
        
        let pageView = PageView(children: [ComponentDummy()])
        let view = pageView.toView(renderer: controller.renderer)
        let componentView = view.subviews.compactMap {
            $0 as? PageViewUIComponent
        }.first
        let page = componentView?.pageViewController.viewControllers?.first
        
        XCTAssertEqual(page?.navigationController, navigation)
    }
    
    func test_viewShouldBeReleased() {
        // Given
        let controller = BeagleScreenViewController(ComponentDummy())
        var strongReference: UIView? = PageView(
            children: [ComponentDummy()],
            context: .init(id: "context", value: 0),
            onPageChange: [ActionDummy()],
            currentPage: "@{context}"
        ).toView(renderer: controller.renderer)
        
        // When
        weak var weakReference = strongReference
        // Then
        XCTAssertNotNil(weakReference)
        
        // When
        strongReference = nil
        // Then
        XCTAssertNil(weakReference)
    }

}
