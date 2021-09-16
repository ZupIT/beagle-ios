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
import Beagle

struct DSCollection: Widget {

    let dataSource: DSCollectionDataSource
    var id: String?
    var style: Style?
    var accessibility: Accessibility?

}

struct DSCollectionDataSource: Decodable, AutoEquatable {
    
    struct Card: Decodable, Equatable {
        let name: String
        let age: Int
    }
    
    let cards: [Card]
}

extension DSCollection: Renderable {
    func toView(renderer: BeagleRenderer) -> UIView {
        let view = DSCollectionUIComponent(dataSource: dataSource)
        view.style.setup(style)
        return view
    }
}
