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

class URLOpenerTests: XCTestCase {

    func test_invalidURLPath_shouldLogError() {

        // Given
        let loggerStub = LoggerMocked()
        let opener = URLOpener()
        opener.logger = loggerStub

        // When
        opener.tryToOpen(path: "")

        // Then
        assertSnapshot(matching: loggerStub.log, as: .description)
    }
}

class URLOpenerStub: URLOpenerProtocol {

    var hasInvokedTryToOpen = false

    func tryToOpen(path: String) {
        hasInvokedTryToOpen = true
    }
}

class LoggerMocked: LoggerProtocol {
    var logDecodingErrorCalled = false
    
    func logDecodingError(type: String) {
        logDecodingErrorCalled = true
    }
    
    var log: LogType?

    func log(_ log: LogType) {
        self.log = log
    }
}
