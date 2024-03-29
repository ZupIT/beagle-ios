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

import UIKit
import YogaKit

final class ListViewCell: UICollectionViewCell {
    
    private(set) var itemHash: Int?
    private(set) var itemKey: String?
    private(set) var viewsIdentifier = [UIView: String]()
    private(set) var viewContexts = [UIView: [Context]]()
    private(set) var templateIndex: Int?
    
    private var bindings = [() -> Void]()
    private var onInits = [(actions: [Action], view: UIView)]()
    private var pendingActions = Set<UUID>()
    
    private var templateContainer: TemplateContainer?
    private weak var listView: ListViewUIComponent?
    
    var hasPendingActions: Bool {
        return !pendingActions.isEmpty
    }
  
    var dataSourceObserver: ContextObserver?
    
    func templateSizeThatFits(_ size: CGSize) -> CGSize {
        let undefined = YGValue(value: .nan, unit: .undefined)
        contentView.configureLayout { layout in
            func maxValue(_ value: CGFloat) -> YGValue {
                guard !value.isNaN, value != .greatestFiniteMagnitude else {
                    return undefined
                }
                return YGValue(value: Float(value), unit: .point)
            }
            layout.maxWidth = maxValue(size.width)
            layout.maxHeight = maxValue(size.height)
        }
        let contentSize = contentView.yoga.calculateLayout(with: size)
        contentView.configureLayout { layout in
            layout.maxWidth = undefined
            layout.maxHeight = undefined
        }
        return contentSize
    }
    
    func configure(
        hash: Int,
        key: String,
        item: DynamicObject,
        templateIndex: Int,
        contexts: DynamicDictionary?,
        listView: ListViewUIComponent
    ) {
        self.itemHash = hash
        self.itemKey = key
        self.listView = listView
        self.templateIndex = templateIndex
        
        let container = templateContainer(for: listView, templateIndex: templateIndex)
        if let contexts = contexts {
            restoreContexts(contexts)
            configContainer(container, key: key, item: item, listView: listView)
            setViewsIdentifier(viewsIdentifier)
        } else {
            initContexts()
            configContainer(container, key: key, item: item, listView: listView)
            setViewsIdentifier(viewsIdentifier)
            onInits.forEach {
                listView.listController.execute(actions: $0.actions, event: "onInit", origin: $0.view)
            }
        }
        
        addBindings()
    }
  
    private func configContainer(
        _ container: TemplateContainer,
        key: String,
        item: DynamicObject,
        listView: ListViewUIComponent
    ) {
        if let dataSourceObserver = dataSourceObserver {
            let observable = container.getContext(with: listView.model.iteratorName)
            observable?.deleteObserver(dataSourceObserver)
        }
      
        container.setContext(Context(id: listView.model.iteratorName, value: item))
        container.setContext(Context(id: listView.model.indexName, value: .string(key)))
      
        guard case let .expression(expression) = listView.model.dataSourceExpression,
           case let .single(single) = expression,
           case let .value(value) = single,
           case let .binding(binding) = value,
           let index = Int(key) else {
             return
        }
        container.beagleConfig = listView.beagleConfig
        let observer = ContextObserver { context in
            let action = SetContext(contextId: binding.context, path: Path(nodes: binding.path.nodes + [.index(index)]), value: context.value)
            action.execute(controller: listView.listController, origin: container)
        }
        container.getContext(with: listView.model.iteratorName)?.addObserver(observer)
        dataSourceObserver = observer
    }
    
    private func setViewsIdentifier(_ viewsIdentifier: [UIView: String]) {
        let suffix = ":\(itemKey ?? "")"
        let extendedIds = viewsIdentifier.reduce(into: [UIView: String]()) { result, entry in
            result[entry.key] = entry.value.appending(suffix)
        }
        let beagleController = listView?.listController.beagleController
        if beagleController is ListViewController {
            Self.cellForView(listView)?.setViewsIdentifier(extendedIds)
        } else {
            for (view, id) in extendedIds {
                beagleController?.setIdentifier(id, in: view)
            }
        }
    }
    
    private func templateContainer(for listView: ListViewUIComponent, templateIndex: Int) -> TemplateContainer {
        if let templateContainer = self.templateContainer {
            return templateContainer
        }
        let flexDirection = listView.model.direction.flexDirection
        let template = listView.renderer.render(listView.model.templates[templateIndex].view)
        let container = TemplateContainer(template: template)
        container.parentContext = listView
        BeagleEnvironment.style(container).setup(
            Style()
                .size(Size().minWidth(1).minHeight(1))
                .flex(Flex().flexDirection(flexDirection).shrink(0))
        )
        templateContainer = container
        contentView.addSubview(container)
        
        contentView.yoga.overflow = .scroll
        BeagleEnvironment.style(contentView).setup(
            Style().flex(Flex().flexDirection(flexDirection))
        )
        
        return container
    }
    
    private func restoreContexts(_ itemContexts: DynamicDictionary) {
        for (view, contexts) in viewContexts {
            contexts
                .map { Context(id: $0.id, value: itemContexts[$0.id, default: $0.value]) }
                .forEach(view.setContext)
        }
    }
    
    private func initContexts() {
        for (view, contexts) in viewContexts {
            contexts.forEach(view.setContext)
        }
    }
    
    static func cellForView(_ view: UIView?) -> Self? {
        guard let view = view else { return nil }
        return (view as? Self) ?? cellForView(view.superview)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        addBindings()
        applyLayout()
        
        if let size = templateContainer?.bounds.size {
            layoutAttributes.size = size
        }
        return layoutAttributes
    }
    
    private func addBindings() {
        while let bind = bindings.popLast() {
            bind()
        }
    }
    
    func applyLayout() {
        if let container = templateContainer, let listView = listView {
            applyLayout(container: container, constrainedBy: listView)
        }
    }
    
    private func applyLayout(container: UIView, constrainedBy listView: ListViewUIComponent) {
        // Ensure yoga won't use cached value
        container.configureLayout { yoga in
            let shrink = yoga.flexShrink
            yoga.flexShrink = shrink + 1
            yoga.flexShrink = shrink
        }
        
        let keyPath: WritableKeyPath<CGSize, CGFloat>
        switch listView.model.direction {
        case .vertical: keyPath = \.width
        case .horizontal: keyPath = \.height
        }
        var rect = listView.bounds
        let spansSpace = rect.size[keyPath: keyPath]
        rect.size[keyPath: keyPath] = (spansSpace / CGFloat(listView.model.spanCount)).rounded(.down)
        
        contentView.frame = rect
        BeagleEnvironment.style(contentView).applyLayout()
        
        let size = container.bounds.size
        contentView.frame.size = size
        
        if let itemHash = itemHash {
            listView.saveSize(container.bounds.size, forItem: itemHash)
        }
    }
}

extension ListViewCell: ListViewDelegate {
    
    var listComponentView: ListViewUIComponent? {
        return listView
    }
    
    func setIdentifier(_ id: String, in view: UIView) {
        viewsIdentifier[view] = id
    }
    
    func setContext(_ context: Context, in view: UIView) {
        viewContexts[view, default: []].append(context)
        view.setContext(context)
    }
    
    func bind<T: Decodable>(_ bind: ContextExpression, view: UIView, update: @escaping (T?) -> Void) {
        bindings.append { [weak self, weak view] in
            guard let self = self else { return }
            view?.configBinding(
                for: bind,
                completion: self.bindBlock(view: view, update: update)
            )
        }
    }
    
    private func bindBlock<T: Decodable>(view: UIView?, update: @escaping (T?) -> Void) -> (T?) -> Void {
        return { [weak self, weak view] value in
            update(value)
            view?.yoga.markDirty()
            if let self = self, let listView = self.listView {
                listView.invalidateSize(cell: self)
                DispatchQueue.main.async {
                    // Called async to avoid UICollectionViewFlowLayout throws `NSRangeException`
                    listView.listController.beagleController?.setNeedsLayout(component: listView)
                }
            }
        }
    }
    
    func onInit(_ onInit: [Action], view: UIView) {
        onInits.append((onInit, view))
    }
    
    func willExecuteAsyncActionIdentifiedBy(_ uuid: UUID) {
        pendingActions.insert(uuid)
    }
    
    func didFinishAsyncActionIdentifiedBy(_ uuid: UUID) {
        pendingActions.remove(uuid)
    }
}

private final class TemplateContainer: UIView {
    
    let template: UIView
    
    init(template: UIView) {
        self.template = template
        super.init(frame: .zero)
        addSubview(template)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
