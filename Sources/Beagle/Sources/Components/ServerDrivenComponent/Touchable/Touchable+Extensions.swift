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

import UIKit

extension Touchable {
    
    public func toView(renderer: BeagleRenderer) -> UIView {
        let childView = renderer.render(child)
        register(actions: onPress, inView: childView, controller: renderer.controller)
        prefetchComponent(helper: renderer.dependencies.preFetchHelper)
        return childView
    }
    
    private func register(actions: [Action], inView view: UIView, controller: BeagleController?) {
        let actionsGestureRecognizer = ActionsGestureRecognizer(
            actions: actions,
            controller: controller
        )
        view.addGestureRecognizer(actionsGestureRecognizer)
        view.isUserInteractionEnabled = true
    }
    
    private func prefetchComponent(helper: BeaglePrefetchHelping?) {
        onPress.forEach { action in
            guard let newPath = (action as? Navigate)?.newPath else { return }
            helper?.prefetchComponent(newPath: newPath)
        }
    }
}

final class ActionsGestureRecognizer: UITapGestureRecognizer {
    let actions: [Action]
    weak var controller: BeagleController?
    
    init(actions: [Action], controller: BeagleController?) {
        self.actions = actions
        self.controller = controller
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(triggerActions))
    }
    
    @objc func triggerActions() {
        if let origin = view {
            controller?.execute(actions: actions, event: "onPress", origin: origin)
        }
    }
}
