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
@testable import Beagle

final class ViewClientTests: EnviromentTestCase {

    private lazy var sut = ViewClient()

    private let url = "www.something.com"

    // swiftlint:disable force_unwrapping
    func test_requestWithInvalidURL_itShouldFail() {
        // Given
        let invalidURL = "🥶"
        let viewClient = ViewClient()
        enviroment.urlBuilder = UrlBuilderStub(baseUrl: nil, resultURL: nil)
        
        let fetchComponentExpectation = expectation(description: "fetchComponent")
        var fetchError: Request.Error?
        let expectedError = Request.Error.urlBuilderError
        
        // When
        viewClient.fetch(url: invalidURL, additionalData: nil) {
            if case let .failure(error) = $0 {
                fetchError = error
            }
            fetchComponentExpectation.fulfill()
        }

        wait(for: [fetchComponentExpectation], timeout: 1.0)
                
        // Then
        XCTAssertEqual(expectedError.localizedDescription, fetchError?.localizedDescription)
    }
    
    func test_whenRequestSucceeds_withValidData_itShouldReturnSomeComponent() {
        // Given
        let jsonData = """
        {
            "_beagleComponent_": "beagle:text",
            "text": "some text"
        }
        """.data(using: .utf8)!

        enviroment.networkClient = NetworkClientStub(result:
            .success(.init(data: jsonData, response: URLResponse()))
        )

        let expec = expectation(description: "fetchComponentExpectation")

        // When
        var componentReturned: ServerDrivenComponent?
        sut.fetch(url: url, additionalData: nil) { result in
            if case .success(let component) = result {
                componentReturned = component
            }
            expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)

        // Then
        XCTAssertNotNil(componentReturned)
        XCTAssert(componentReturned is Text)
    }
    
    func test_whenRequestSucceeds_butTheDecodingFailsWithAnError_itShouldThrowDecodingError() {
        // Given
        let decoderStub = BeagleCodingStub()
        
        decoderStub.errorToThrowOnDecode = NSError(domain: "Mock", code: 1, description: "Mock")
        enviroment.networkClient = NetworkClientStub(result:
            .success(.init(data: Data(), response: URLResponse()))
        )
        enviroment.coder = decoderStub

        let expec = expectation(description: "fetch")

        // When
        var errorThrown: Request.Error?

        sut.fetch(url: url, additionalData: nil) { result in
            if case let .failure(error) = result {
                errorThrown = error
            }
            expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)

        // Then
        XCTAssertNotNil(errorThrown)
        guard case .decoding? = errorThrown else {
            XCTFail("Expected a `.decoding` error, but got \(String(describing: errorThrown)).")
            return
        }
    }
    
    func test_shouldAddAdditionalDataToRequest() {
        // Given
        let body = "{}".data(using: .utf8)!
        let clientStub = NetworkClientStub(result: .success(.init(data: body, response: URLResponse())))
        enviroment.networkClient = clientStub

        let additionalData = HttpAdditionalData(
            method: .post,
            headers: ["headerKey": "headerValue"],
            body: .empty
        )

        let expec = expectation(description: "fetch")

        // When
        sut.fetch(url: url, additionalData: additionalData) { _ in
            expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)

        // Then

        XCTAssertEqual(clientStub.executedRequest?.additionalData, additionalData)
        XCTAssertEqual(clientStub.executedRequest?.url.absoluteString, url)
    }
}

// MARK: - Testing Helpers

final class BeagleCodingStub: CoderProtocol {
    func register<T: BeagleCodable>(type: T.Type, named: String?) {}
    
    func decode<T>(from data: Data) throws -> T {
        if let error = errorToThrowOnDecode {
            throw error
        }
        if T.self == Action.self {
            // swiftlint:disable force_cast
            return ActionDummy() as! T
        }
        return ComponentDummy() as! T
        // swiftlint:enable force_cast
    }
    
    func encode<T: BeagleCodable>(value: T) throws -> Data {
        return Data()
    }
    
    func name(for type: BeagleCodable.Type) -> String? { nil }
    
    func type(for name: String, baseType: Coder.BaseType) -> BeagleCodable.Type? { nil }
    
    var errorToThrowOnDecode: Error?
}

final class ViewClientStub: ViewClientProtocol {

    var componentResult: Result<ServerDrivenComponent, Request.Error>?
    var formResult: Result<Action, Request.Error>?

    private(set) var didCallDispatch = false
    private(set) var didCallPrefetch = false
    private(set) var token = Token()

    class Token: RequestToken {
        var didCallCancel = false

        func cancel() {
            didCallCancel = true
        }
    }

    init(
        componentResult: Result<ServerDrivenComponent, Request.Error>? = nil,
        formResult: Result<Action, Request.Error>? = nil
    ) {
        self.componentResult = componentResult
        self.formResult = formResult
    }

    func fetch(
        url: String,
        additionalData: HttpAdditionalData?,
        completion: @escaping (Result<ServerDrivenComponent, Request.Error>) -> Void
    ) -> RequestToken? {
        didCallDispatch = true
        if let result = componentResult {
            completion(result)
        }
        return token
    }
    
    func prefetch(url: String, additionalData: HttpAdditionalData?) {
        didCallPrefetch = true
    }
    
}

class NetworkClientStub: NetworkClientProtocol {

    let result: NetworkClientProtocol.NetworkResult

    private(set) var executedRequest: Request?

    init(result: NetworkClientProtocol.NetworkResult) {
        self.result = result
    }

    func executeRequest(_ request: Request, completion: @escaping RequestCompletion) -> RequestToken? {
        executedRequest = request
        completion(result)
        return nil
    }
}

enum TestErrors: Swift.Error {
    case generic
}

private struct UrlBuilderStub: UrlBuilderProtocol {
    var baseUrl: URL?
    var resultURL: URL?
    
    func build(path: String) -> URL? {
        return resultURL
    }
}
