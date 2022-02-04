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

class PullToRefreshTests: XCTestCase {
    
    private let imageSize = ImageSize.custom(CGSize(width: 80, height: 40))
    
    func testCodablePullToRefresh() throws {
        let component: PullToRefresh = try componentFromJsonFile(fileName: "PullToRefresh")
        assertSnapshotJson(matching: component)
    }

    func testPullToRefreshSnapshot() throws {
        // Given // When
        let component = PullToRefresh(
            isRefreshing: false,
            color: "#FF0000",
            child: Text(text: "Text")
        )
        
        let controller = BeagleScreenViewController(component)
        
        // Then
        assertSnapshotImage(controller, size: imageSize)
    }
    
    func testPullToRefreshConfigWithList() {
        // Given // When
        let controller = BeagleScreenViewController(ComponentDummy())
        let view = PullToRefresh(
            child: ListView(
                dataSource: .value(
                    [ ["value": "text"] ]
                ),
                templates: [ Template(view: Text(text: "@{item.value}")) ]
            )
        ).toView(renderer: controller.renderer)
        
        // Then
        XCTAssert(view is ListViewUIComponent)
    }
    
    func testPullToRefreshConfigWithScroll() {
        // Given // When
        let controller = BeagleScreenViewController(ComponentDummy())
        let view = PullToRefresh(
            child: ScrollView(children: [Text(text: "text")])
        ).toView(renderer: controller.renderer)
        
        // Then
        XCTAssert(view is BeagleContainerScrollView)
        XCTAssert(view.subviews[0].subviews[0] is UITextView)
    }
    
    func testPullToRefreshConfigWithoutScroll() {
        // Given // When
        let controller = BeagleScreenViewController(ComponentDummy())
        let view = PullToRefresh(
            child: Text(text: "text")
        ).toView(renderer: controller.renderer)
        
        // Then
        XCTAssert(view is BeagleContainerScrollView)
        XCTAssert(view.subviews[0].subviews[0] is UITextView)
    }

}
