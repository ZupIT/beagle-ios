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

final class AddChildrenTests: EnviromentTestCase {
    
    func testDecodingAddChildrenWithDefaultMode() throws {
        let action: AddChildren = try componentFromString("""
        {
            "_beagleAction_": "beagle:addChildren",
            "componentId": "id",
            "value": [
                {
                    "_beagleComponent_": "beagle:text",
                    "text": "sample"
                }
            ]
        }
        """)
        assertSnapshot(matching: action, as: .dump)
    }
    
    func testDecodingAddChildren() throws {
        let action: AddChildren = try componentFromString("""
        {
            "_beagleAction_": "beagle:addChildren",
            "componentId": "id",
            "value": [
                {
                    "_beagleComponent_": "beagle:text",
                    "text": "sample"
                }
            ],
            "mode": "PREPEND"
        }
        """)
        assertSnapshot(matching: action, as: .dump)
    }

    func testModeAppend() {
        runTest(mode: .append)
    }

    func testModePrepend() {
        runTest(mode: .prepend)
    }

    func testModeReplace() {
        runTest(mode: .replace)
    }

    func testModeAppendWithContext() {
        runTest(mode: .append, text: Text(text: "@{contextId}"))
    }

    func testModeReplaceWithContext() {
        runTest(mode: .replace, text: Text(text: "@{contextId}"))
    }

    func testIfDefaultIsAppend() {
        let sut = AddChildren(componentId: "id", value: [])
        XCTAssertEqual(sut.mode, .append)
    }
    
    // Integrated
    func testValueExpression() {
        let sut = BeagleScreenViewController("""
        {
            "_beagleComponent_": "beagle:container",
            "children": [],
            "onInit": [
                {
                    "_beagleAction_": "beagle:addChildren",
                    "componentId": "containerId",
                    "value": [
                        {
                            "_beagleComponent_": "beagle:text",
                            "text": "global: @{global}"
                        }
                    ],
                    "mode": "REPLACE"
                }
            ],
            "id": "containerId"
        }
        """)
        
        dependencies = BeagleDependencies()
        assertSnapshotImage(sut, size: imageSize)
        
<<<<<<< HEAD
        enviroment.globalContext.set("value")
=======
        dependencies.globalContext.set("value")
>>>>>>> 154ea6374c801c4658b3f060456421fba5ff0612
        assertSnapshotImage(sut, size: imageSize)
    }

    private func runTest(
        mode: AddChildren.Mode,
        text: Text = Text(text: "NEW"),
        testName: String = #function,
        line: UInt = #line
    ) {
        // Given
        let sut = AddChildren(componentId: "componentId", value: [text], mode: mode)

        let controller = BeagleScreenViewController(Container(
            children: [Text(text: "initial")],
            context: Context(id: "contextId", value: "CONTEXT"),
            id: "componentId"
        ))

        assertSnapshotImage(controller, size: imageSize, testName: testName, line: line)

        // When
        sut.execute(controller: controller, origin: UIView())

        // Then
        assertSnapshotImage(controller, size: imageSize, testName: testName, line: line)
    }

    private let imageSize = ImageSize.custom(CGSize(width: 80, height: 60))
}
