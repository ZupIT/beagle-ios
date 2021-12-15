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

final class ListViewTests: XCTestCase {

    private let imageSize = ImageSize.custom(CGSize(width: 300, height: 300))

    private let just3Rows: [ServerDrivenComponent] = [
        Text(text: "Item 1", style: .init(backgroundColor: "#FF0000")),
        Text(text: "Item 2", style: .init(backgroundColor: "#00FF00")),
        Text(text: "Item 3", style: .init(backgroundColor: "#0000FF"))
    ]
    
    private let manyRows: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText("Item \(i)", position: Double(i) / 19)
    }
    
    private let manyLargeRows: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText(
            "< \(i) \(String(repeating: "-", count: 22)) \(i) >",
            position: Double(i) / 19
        )
    }
    
    private let rowsWithDifferentSizes: [ServerDrivenComponent] = (0..<20).map { i in
        return ListViewTests.createText(
            "< \(i) ---\(i % 3 == 0 ? "/↩\n↩\n /" : "")--- \(i) >",
            position: Double(i) / 19
        )
    }
    
    private lazy var controller = BeagleScreenViewController(ComponentDummy())
    
    private func renderListView(_ listComponent: ListView) -> UIView {
        let host = ComponentHostController(listComponent, renderer: controller.renderer)
        return host.view
    }
    
    func createListView(
        direction: ListView.Direction,
        contextValue: DynamicObject? = nil,
        onInit: [Action]? = nil,
        onScrollEnd: [Action]? = nil,
        isScrollIndicatorVisible: Bool? = nil
    ) -> ListView {
        return ListView(
            context: Context(
                id: "initialContext",
                value: contextValue ?? ""
            ),
            onInit: onInit,
            dataSource: Expression("@{initialContext}"),
            direction: direction,
            templates: [
                Template(
                    view: Container(
                        children: [
                            Text(
                                text: "@{item}",
                                style: Style(
                                    backgroundColor: "#bfdcae"
                                )
                            )
                        ],
                        style: Style(
                            backgroundColor: "#81b214",
                            margin: EdgeValue().all(10)
                        )
                    )
                )
            ],
            onScrollEnd: onScrollEnd,
            isScrollIndicatorVisible: isScrollIndicatorVisible,
            style: Style(
                backgroundColor: "#206a5d",
                flex: Flex().grow(1)
            )
        )
    }
    
    // MARK: - Testing Direction
    
    let simpleContext: DynamicObject = ["L", "I", "S", "T", "V", "I", "E", "W"]
    
    func testHorizontalDirection() {
        // Given
        let component = createListView(
            direction: .horizontal,
            contextValue: simpleContext
        )
        
        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }
    
    func testVerticalDirection() {
        // Given
        let component = createListView(
            direction: .vertical,
            contextValue: simpleContext
        )
        
        // When
        let view = renderListView(component)
        
        // Then
        assertSnapshotImage(view, size: imageSize)
    }
    
    // MARK: - Testing Context With Different Sizes
    
    let contextDifferentSizes: DynamicObject = ["LIST", "VIEW", "1", "LIST VIEW", "TEST 1", "TEST LIST VIEW", "12345"]
    
    func testHorizontalDirectionWithDifferentSizes() {
        // Given
        let component = createListView(
            direction: .horizontal,
            contextValue: contextDifferentSizes
        )
        
        // When
        let view = renderListView(component)
        
        // Then
        assertSnapshotImage(view, size: imageSize)
    }
    
    func testVerticalDirectionWithDifferentSizes() {
        // Given
        let component = createListView(
            direction: .vertical,
            contextValue: contextDifferentSizes
        )
        
        // When
        let view = renderListView(component)
        
        // Then
        assertSnapshotImage(view, size: imageSize)
    }
    
    // MARK: - Testing scrollIndicatorEnabled
    
    private func getCollectionView(isScrollIndicatorVisible: Bool) throws -> UICollectionView {
        let component = createListView(
            direction: .horizontal,
            isScrollIndicatorVisible: isScrollIndicatorVisible
        )
        
        let view = component.toView(renderer: controller.renderer)
        let listView = try XCTUnwrap(view as? ListViewUIComponent)
        let collection = listView.listController.collectionView
        
        return collection
    }
    
    func testScrollIndicatorEnabled() throws {
        // Given
        let flag = true
        let collectionView = try getCollectionView(isScrollIndicatorVisible: flag)
        
        // Then
        XCTAssertEqual(collectionView.showsHorizontalScrollIndicator, flag)
        XCTAssertEqual(collectionView.showsVerticalScrollIndicator, flag)
        
    }
    
    func testScrollIndicatorDisabled() throws {
        // Given
        let flag = false
        let collectionView = try getCollectionView(isScrollIndicatorVisible: flag)
        
        // Then
        XCTAssertEqual(collectionView.showsHorizontalScrollIndicator, flag)
        XCTAssertEqual(collectionView.showsVerticalScrollIndicator, flag)
        
    }
    
    // MARK: - Testing Execute Action onScrollEnd
    
    func testVerticalWithAction() {
        // Given
        let expectation = XCTestExpectation(description: "Execute onScrollEnd")
        let action = ActionStub { _, _ in
            expectation.fulfill()
        }
        let component = createListView(
            direction: .vertical,
            contextValue: [.empty],
            onScrollEnd: [action]
        )
        
        // When
        let view = renderListView(component) as? ListViewUIComponent
        view?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        view?.layoutIfNeeded()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(view?.onScrollEndExecuted, true)
    }
    
    func testHorizontalWithAction() {
        // Given
        let expectation = XCTestExpectation(description: "Execute onScrollEnd")
        let action = ActionStub { _, _ in
            expectation.fulfill()
        }
        let component = createListView(
            direction: .horizontal,
            contextValue: [.empty],
            onScrollEnd: [action]
        )
        
        // When
        let view = renderListView(component) as? ListViewUIComponent
        view?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        view?.layoutIfNeeded()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(view?.onScrollEndExecuted, true)
    }
    
    func testSetupSizeDefaultListView() {
        // Given
        let component = ListView(
            dataSource: .value([.empty]),
            templates: [Template(view: ComponentDummy())]
        )
        
        // When
        _ = renderListView(component)
        
        // Then
        XCTAssertNil(component.style?.flex?.grow)
    }
    
    func testDirectionHorizontal() throws {
        // Given
        let component = makeList(just3Rows, .horizontal)
    
        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVertical() throws {
        // Given
        let component = makeList(just3Rows, .vertical)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: - Many Rows

    func testDirectionHorizontalWithManyRows() {
        // Given
        let component = makeList(manyRows, .horizontal)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithManyRows() {
        // Given
        let component = makeList(manyRows, .vertical)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: - Many Large Rows

    func testDirectionHorizontalWithManyLargeRows() {
        // Given
        let component = makeList(manyLargeRows, .horizontal)
    
        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithManyLargeRows() {
        // Given
        let component = makeList(manyLargeRows, .vertical)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    // MARK: Rows with Different Sizes

    func testDirectionHorizontalWithRowsWithDifferentSizes() {
        // Given
        let component = makeList(rowsWithDifferentSizes, .horizontal)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }

    func testDirectionVerticalWithRowsWithDifferentSizes() {
        // Given
        let component = makeList(rowsWithDifferentSizes, .vertical)

        // When
        let view = renderListView(component)

        // Then
        assertSnapshotImage(view, size: imageSize)
    }
    
    func testCodableListViewWithTemplate() throws {
        let component: ListView = try componentFromJsonFile(fileName: "listViewWithTemplate")
        assertSnapshotJson(matching: component)
    }
    
    // MARK: - Helper

    private static func createText(_ string: String, position: Double) -> Text {
        let text = Int(round(position * 255))
        let textColor = "#\(String(repeating: String(format: "%02X", text), count: 3))"
        let background = 255 - text
        let backgroundColor = "#\(String(repeating: String(format: "%02X", background), count: 3))"
        return Text(
            text: .value(string),
            textColor: .value(textColor),
            style: Style(backgroundColor: .value(backgroundColor))
        )
    }
    
    private func templatesForChildren(_ children: [ServerDrivenComponent], _ direction: ScrollAxis?) -> [Template] {
        let style = Style(flex: Flex(flexDirection: direction?.flexDirection))
        return [
            Template(view: Container(children: children, style: style))
        ]
    }
    
    private func makeList(_ children: [ServerDrivenComponent], _ direction: ScrollAxis?) -> ListView {
        ListView(
            dataSource: .value([.empty]),
            direction: direction,
            templates: templatesForChildren(children, direction)
        )
    }
    
}

// MARK: - Testing Helpers

private struct ActionStub: Action {
    
    var analytics: ActionAnalyticsConfig?
    let execute: ((BeagleController, UIView) -> Void)?
    
    init(execute: @escaping (BeagleController, UIView) -> Void) {
        self.execute = execute
    }
    
    init(from decoder: Decoder) throws {
        execute = nil
    }
    
    func encode(to encoder: Encoder) throws {}
    
    func execute(controller: BeagleController, origin: UIView) {
        execute?(controller, origin)
    }
}
