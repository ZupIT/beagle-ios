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

extension NavigationBarItem {
    
    func toBarButtonItem(
        controller: BeagleScreenViewController
    ) -> UIBarButtonItem {
        let barButtonItem = NavigationBarButtonItem(barItem: self, controller: controller)
        return barButtonItem
    }
    
    final private class NavigationBarButtonItem: UIBarButtonItem {
        
        private let barItem: NavigationBarItem
        private weak var controller: BeagleScreenViewController?
        
        init(
            barItem: NavigationBarItem,
            controller: BeagleScreenViewController
        ) {
            self.barItem = barItem
            self.controller = controller
            super.init()
            if let localImage = barItem.image {
                handleContextOnNavigationBarImage(icon: localImage)
                accessibilityHint = barItem.text
            } else {
                title = barItem.text
            }
            target = self
            action = #selector(triggerAction)
            ViewConfigurator.applyAccessibility(barItem.accessibility, to: self)
        }
        
        private func handleContextOnNavigationBarImage(icon: String) {
            let expression: Expression<String> = "\(icon)"
            
            // Since `BeagleScreenViewController` creates a different view hierarchy, to get the correct hierarchy we need to use the `view` from our `controller`.
            guard case .view(let view) = controller?.content else { return }
            
            if let renderer = controller?.renderer {
                renderer.observe(expression, andUpdateManyIn: view) { icon in
                    guard let icon = icon else { return }
                    self.image = renderer.imageProvider.loadImageProvider(id: icon)?.withRenderingMode(.alwaysOriginal)
                }
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func triggerAction() {
            if case .view(let view) = controller?.content {
                controller?.execute(actions: barItem.onPress, event: nil, origin: view)
            }
        }
    }
}
