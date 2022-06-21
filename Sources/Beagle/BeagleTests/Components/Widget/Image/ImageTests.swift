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

class ImageTests: EnviromentTestCase {
    
    override func setUp() {
        super.setUp()
        enviroment.appBundle.bundle = Bundle(for: ImageTests.self)
        enviroment.imageProvider = ImageProvider()
    }
    
    lazy var controller = BeagleControllerStub()
    lazy var renderer = BeagleRenderer(controller: controller)
    
    func testContentMode() {
        // Given
        let value = ImageContentMode.center
        let expected = UIImageView.ContentMode.center
                
        // When
        let result = value.toUIKit()
        
        // Then
        XCTAssertEqual(result, expected)
    }
    
    func testRenderImage() throws {
        // Given
        let image: Image = try componentFromJsonFile(fileName: "ImageComponent")
        
        // When
        let view = renderer.render(image)
        
        // Then
        assertSnapshotImage(view, size: ImageSize.custom(CGSize(width: 400, height: 400)))
    }
    
    func testRenderRemoteImage() {
        let screen = Screen(
            navigationBar: NavigationBar(title: "PageView"),
            child: Container(
                children: [
                    PageIndicator(numberOfPages: 4, currentPage: "@{currentPage}"),
                    PageView(
                        children: [
                            Container(
                                children: [
                                    Text(text: "Text with alignment attribute set to center", alignment: Expression.value(.center)),
                                    Text(text: "Text with alignment attribute set to right", alignment: Expression.value(.right)),
                                    Text(text: "Text with alignment attribute set to left", alignment: Expression.value(.left)),
                                    Image(.remote(.init(url: "https://www.petlove.com.br/images/")))
                                ],
                                style: Style().flex(Flex().justifyContent(.spaceBetween).grow(1))
                            )
                        ],
                        onPageChange: [SetContext(contextId: "currentPage", value: "@{onPageChange}")],
                        currentPage: "@{currentPage}"
                    )
                ],
                context: Context(id: "currentPage", value: 2),
                style: Style().flex(Flex().grow(1))
            )
        )

        enviroment.imageDownloader = ImageDownloaderMock(expectation: expectation(description: "image downloader"))

        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(screen)))

        let size = ImageSize.custom(.init(width: 400, height: 400))
        assertSnapshotImage(controller, size: size)

        self.waitForExpectations(timeout: 3)

        assertSnapshotImage(controller, size: size)
    }
    
    func testCancelRequest() {
        // Given
        let image = Image(.remote(.init(url: "@{url}")))
        let imageDownloader = ImageDownloaderStub(imageResult: .success(Data()))
        enviroment.imageDownloader = imageDownloader
        let container = Container(children: [image])
        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(container.toScreen())))
        let action = SetContext(contextId: "url", value: "www.com.br")
        let view = image.toView(renderer: controller.renderer)
        
        // When
        view.setContext(Context(id: "url", value: "www.beagle.com.br"))
        controller.bindings.config()
        action.execute(controller: controller, origin: view)
        
        // Then
        XCTAssertTrue(imageDownloader.token.didCallCancel)
    }
    
    func testInvalidURL() {
        // Given
        let component = Image(.remote(.init(url: "www.com")))
        // When
        let imageView = renderer.render(component) as? UIImageView
        
        // Then
        XCTAssertNotNil(imageView)
        XCTAssertNil(imageView?.image)
    }
    
    func testPlaceholder() {
        // Given
        let component = Image(.remote(.init(url: "www.com", placeholder: "test_image_square-x")))
 
        // When
        let placeholderView = renderer.render(component) as? UIImageView

        // Then
        XCTAssertNotNil(placeholderView?.image, "Expected placeholder to not be nil.")

    }
    
    func testImageLeak() {
        // Given
        let component = Image(.remote(.init(url: "@{img.path}")), mode: .fitXY)
        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(component.toScreen())))
        
        var view = component.toView(renderer: controller.renderer)
        weak var weakView = view
    
        // When
        controller.bindings.config()
        view = UIView()
        
        // Then
        XCTAssertNil(weakView)
    }
    
    func testImageWithPathCancelRequest() {
        // Given
        let image = Image(path: "@{img.path}")
        let imageDownloader = ImageDownloaderStub(imageResult: .success(Data()))
        enviroment.imageDownloader = imageDownloader
        let container = Container(children: [image])
        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(container.toScreen())))
        let action = SetContext(contextId: "img", path: Path(rawValue: "path"), value: ["_beagleImagePath_": "local", "mobileId": "shuttle"])
        let view = image.toView(renderer: controller.renderer)
        
        // When
        view.setContext(Context(id: "img", value: ["path": ["_beagleImagePath_": "remote", "url": "www.com.br"]]))
        controller.bindings.config()
        action.execute(controller: controller, origin: view)
        
        // Then
        XCTAssertTrue(imageDownloader.token.didCallCancel)
    }
    
    func testLocalImageWithContext() {
        // Given
        let container = Container(
            children: [
                Image(.local("@{mobileId}"))
            ],
            context: Context(id: "mobileId", value: "test_image_square-x")
        )
        
        // When
        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(container.toScreen())))
        
        // Then
        assertSnapshotImage(controller.view, size: ImageSize.custom(CGSize(width: 100, height: 100)))
    }
}

private struct ImageDownloaderMock: ImageDownloaderProtocol {
    var expectation: XCTestExpectation?
    
    func fetchImage(url: String, additionalData: HttpAdditionalData?, completion: @escaping (Result<Data, Request.Error>) -> Void) -> RequestToken? {
        let image = UIImage(named: "shuttle", in: Bundle(for: ImageTests.self), compatibleWith: nil)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            completion(.success(image?.pngData() ?? Data()))
            self.expectation?.fulfill()
        }
        return nil
    }
}
