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

class NavigateTests: XCTestCase {
    
    func testCodableOpenExternalUrl() throws {
        let action: Navigate = try componentFromString("""
        {
            "_beagleAction_": "beagle:openexternalurl",
            "url": "schema://domain/path"
        }
        """)

        _assertInlineSnapshotJson(matching: action, with: """
        {
          "_beagleAction_" : "beagle:openexternalurl",
          "url" : "schema:\\/\\/domain\\/path"
        }
        """)
    }
    
    func testCodableOpenNativeRoute() throws {
        let action: Navigate = try componentFromJsonFile(fileName: "opennativeroute")
        assertSnapshotJson(matching: action)
    }
    
    func testCodableResetApplication() throws {
        let action: Navigate = try componentFromString("""
        {
            "_beagleAction_": "beagle:resetapplication",
            "controllerId": "my-controller-id",
            "route": {
                "url": "schema://path"
            }
        }
        """)

        assertSnapshotJson(matching: action)
    }
    
    func testCodableResetStack() throws {
        let action: Navigate = try componentFromString("""
        {
            "_beagleAction_": "beagle:resetstack",
            "route": {
                "url": "schema://path"
            }
        }
        """)
        
        _assertInlineSnapshotJson(matching: action, with: """
        {
          "_beagleAction_" : "beagle:resetstack",
          "route" : {
            "url" : "schema:\\/\\/path"
          }
        }
        """)
    }
    
    func testCodablePushStack() throws {
        let action: Navigate = try componentFromString("""
        {
            "_beagleAction_": "beagle:pushStack",
            "navigationContext": {
                "path": "path",
                "value": {
                    "stringValue": "string",
                    "booleanValue": true,
                    "integerValue": 3
                }
            },
            "route": {
                "screen": {
                    "child" : {
                      "_beagleComponent_" : "custom:beagleschematestscomponent"
                    }
                }
            }
        }
        """)

        assertSnapshotJson(matching: action)
    }
    
    func testCodablePushStackWithControllerId() throws {
        let action: Navigate = try componentFromString("""
        {
            "_beagleAction_": "beagle:pushStack",
            "route": {
                "url": "schema://path"
            },
            "controllerId": "customid"
        }
        """)

        assertSnapshotJson(matching: action)
    }
    
    func testCodablePopStack() throws {
        let jsonString = """
        {
          "_beagleAction_" : "beagle:popstack"
        }
        """
        let action: Navigate = try componentFromString(jsonString)
        _assertInlineSnapshotJson(matching: action, with: jsonString)
    }
    
    func testCodablePushView() throws {
        let action: Navigate = try componentFromJsonFile(fileName: "pushview")
        assertSnapshotJson(matching: action)
    }
    
    func testCodablePushViewWithContext() throws {
        let jsonString = """
        {
          "_beagleAction_" : "beagle:pushview",
          "route" : {
            "url" : "@{test}"
          }
        }
        """
        let action: Navigate = try componentFromString(jsonString)
        _assertInlineSnapshotJson(matching: action, with: jsonString)
    }
    
    func testCodablePopView() throws {
        let jsonString = """
        {
          "_beagleAction_" : "beagle:popview",
          "navigationContext" : {
            "path" : "path",
            "value" : "string"
          }
        }
        """
        let action: Navigate = try componentFromString(jsonString)
        _assertInlineSnapshotJson(matching: action, with: jsonString)
    }
    
    func testCodablePopToView() throws {
        let jsonString = """
        {
          "_beagleAction_" : "beagle:poptoview",
          "route" : "viewId"
        }
        """
        let action: Navigate = try componentFromString(jsonString)
        _assertInlineSnapshotJson(matching: action, with: jsonString)
    }
    
    func testDecodingPushViewWithAdditionalData() throws {
        let action: Navigate = try componentFromJsonFile(fileName: "pushViewWithAdditionalData")
        assertSnapshotJson(matching: action)
    }

    func testNullNewPathInNavigation() {
        // given
        let arrayWithNullNewPaths: [Navigate] = [
            .openExternalURL(""),
            .openNativeRoute(.init(route: "")),
            .popStack(),
            .popView(),
            .popToView("")
        ]
        
        // then
        XCTAssertEqual(arrayWithNullNewPaths.filter { $0.newPath == nil }.count, arrayWithNullNewPaths.count)
    }
    
    func testNotNullNewPathsInNavigation() {
        // given
        let routeMockRemote: Route = .remote(.init(url: "", shouldPrefetch: false, fallback: Screen(child: DumbComponent())))
        let routeMockDeclarative: Route = .declarative(Screen(child: DumbComponent()))
        let array: [Navigate] = [
            .resetApplication(routeMockRemote),
            .resetStack(routeMockRemote),
            .pushStack(routeMockRemote),
            .pushStack(routeMockRemote, controllerId: "customid"),
            .pushView(routeMockRemote),
            .resetStack(routeMockDeclarative)
        ]
        
        // then
        XCTAssertEqual(array.filter { $0.newPath != nil }.count, array.count - 1)
    }

}

private struct DumbComponent: ServerDrivenComponent {
    func toView(renderer: BeagleRenderer) -> UIView {
        return UIView()
    }
}
