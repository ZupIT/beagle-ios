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

class HttpAdditionalDataTests: XCTestCase {

    func testInitWithEncodableObject() throws {
        // Given
        let encodableObject = EncodableObject(string: "string", int: 0)
        // When
        let additionalData = HttpAdditionalData(body: encodableObject)
        // Then
        _assertInlineSnapshot(matching: additionalData, as: .dump, with: """
        ▿ HttpAdditionalData
          ▿ body: Optional<DynamicObject>
            - some: [int: 0, string: string]
          ▿ headers: Optional<Dictionary<String, String>>
            - some: 0 key/value pairs
          ▿ method: Optional<HTTPMethod>
            - some: HTTPMethod.get
        """)
    }

}

struct EncodableObject: Encodable {
    let string: String
    let int: Int
}
