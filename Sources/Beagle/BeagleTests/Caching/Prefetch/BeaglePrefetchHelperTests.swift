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

final class BeaglePrefetchHelperTests: XCTestCase {

    private let decoder = Coder()
    private let jsonData = """
    {
      "_beagleComponent_": "beagle:text",
      "text": "cache",
      "style": {
        "backgroundColor": "#4000FFFF"
      }
    }
    """.data(using: .utf8) ?? Data()

    func testPrefetch() {
        // Given
        guard let remoteComponent = decodeComponent(from: jsonData) else {
            XCTFail("Could not decode component.")
            return
        }
        let viewClientStub = ViewClientStub(componentResult: .success(remoteComponent))
        let sut = PreFetchHelper()
        let url = "url-test"

        sut.viewClient = viewClientStub
        
        // When
        sut.prefetchComponent(newPath: .init(url: "\(url)", shouldPrefetch: true))
        
        // Then
        XCTAssertTrue(viewClientStub.didCallPrefetch)
    }

    func testNavigationIsPrefetchable() {
        // Given // When
        let path = "path"
        let data = ["data": "value"]
        let container = Container(children: [])

        let actions: [Navigate] = [
            Navigate.openExternalURL("http://localhost"),
            Navigate.openNativeRoute(.init(route: path)),
            Navigate.openNativeRoute(.init(route: path, data: data)),

            Navigate.resetApplication(.declarative(Screen(child: container))),
            Navigate.resetApplication(.remote(.init(url: "\(path)", shouldPrefetch: true))),
            Navigate.resetApplication(.remote(.init(url: "\(path)", shouldPrefetch: false))),

            Navigate.resetStack(.declarative(Screen(child: container))),
            Navigate.resetStack(.remote(.init(url: "\(path)", shouldPrefetch: true))),
            Navigate.resetStack(.remote(.init(url: "\(path)", shouldPrefetch: false))),

            Navigate.pushStack(.declarative(Screen(child: container))),
            Navigate.pushStack(.remote(.init(url: "\(path)", shouldPrefetch: true))),
            Navigate.pushStack(.remote(.init(url: "\(path)", shouldPrefetch: false))),

            Navigate.pushStack(.declarative(Screen(child: container)), controllerId: "customId"),
            Navigate.pushStack(.remote(.init(url: "\(path)", shouldPrefetch: true)), controllerId: "customId"),
            Navigate.pushStack(.remote(.init(url: "\(path)", shouldPrefetch: false)), controllerId: "customId"),

            Navigate.pushView(.declarative(Screen(child: container))),
            Navigate.pushView(.remote(.init(url: "\(path)", shouldPrefetch: true))),
            Navigate.pushView(.remote(.init(url: "\(path)", shouldPrefetch: false))),

            Navigate.popStack(),
            Navigate.popView(),
            Navigate.popToView(.init(stringLiteral: path))
        ]
        let bools = actions.map { $0.newPath }
        let result: String = zip(actions, bools).reduce("") { partial, zip in
            "\(partial)  \(zip.0)  -->  \(descriptionWithoutOptional(zip.1)) \n\n"
        }

        // Then
        assertSnapshot(matching: result, as: .description)
    }
    
    func testNavigateWithContextShouldNotPrefetch() {
        // Given
        let viewClientStub = ViewClientStub(componentResult: .success(ComponentDummy()))
        let sut = PreFetchHelper()
        
        sut.viewClient = viewClientStub

        // When
        sut.prefetchComponent(newPath: .init(url: "@{url}", shouldPrefetch: true))

        // Then
        XCTAssertFalse(viewClientStub.didCallPrefetch)
    }

    private func decodeComponent(from data: Data) -> ServerDrivenComponent? {
        do {
            return try decoder.decode(from: data)
        } catch {
            return nil
        }
    }
}
