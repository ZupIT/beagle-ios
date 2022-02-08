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

extension PageView {

    public func toView(renderer: BeagleRenderer) -> UIView {
        let view = UIView()
        let pagesView = PageViewUIComponent(
            model: .init(pages: (children ?? []).map {
                ComponentHostController($0, renderer: renderer)
            }),
            controller: renderer.controller
        )
        pagesView.onPageChange = { [weak view] page in
            guard let view = view else { return }
            renderer.controller?.execute(actions: self.onPageChange, with: "onPageChange", and: .int(page), origin: view)
        }
        renderer.observe(currentPage, andUpdateManyIn: view) { [weak pagesView] page in
            if let page = page {
                pagesView?.swipeToPage(at: page)
            }
        }

        view.backgroundColor = .clear
        CurrentEnviroment.style(view).setup(Style(flex: Flex().flexDirection(.column)))

        view.addSubview(pagesView)
        CurrentEnviroment.style(pagesView).setup(Style(flex: Flex(grow: 1)))

        return view
    }
}
