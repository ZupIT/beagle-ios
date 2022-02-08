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

final class TouchableTests: XCTestCase {
    
    func testCodableTouchable() throws {
        let component: Touchable = try componentFromJsonFile(fileName: "TouchableDecoderTest")
        assertSnapshotJson(matching: component)
    }

    func testTouchableView() {
        // Given // When
        let touchable = Touchable(onPress: [Navigate.popView()], child: Text(text: "Touchable"))
        let controller = BeagleControllerStub()
        let renderer = BeagleRenderer(controller: controller)
        let view = renderer.render(touchable)
        
        // Then
        assertSnapshotImage(view, size: .custom(CGSize(width: 100, height: 80)))
    }
    
    func testIsUserInteractionEnabled() {
        // Given
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        let child = ComponentDummy(resultView: view)
        let touchable = Touchable(onPress: [ActionDummy()], child: child)
        let controller = BeagleControllerStub()
        let renderer = BeagleRenderer(controller: controller)
        
        // When
        let resultView = touchable.toView(renderer: renderer)
        
        // Then
        XCTAssertEqual(resultView, view)
        XCTAssertTrue(resultView.isUserInteractionEnabled)
    }
    
    func testActionTrigger() {
        // Given
        let controller = BeagleControllerStub()
        let action = ActionSpy()
        let touchable = Touchable(onPress: [action], child: Text(text: "mocked text"))
        let view = touchable.toView(renderer: BeagleRenderer(controller: controller))
        
        let actionsGesture = view.gestureRecognizers?
            .compactMap { $0 as? ActionsGestureRecognizer }
            .first
        
        // When
        actionsGesture?.triggerActions()
        
        // Then
        XCTAssertEqual(action.executionCount, 1)
        XCTAssertTrue(action.lastOrigin as AnyObject === view)
    }
}
