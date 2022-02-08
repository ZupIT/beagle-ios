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

import Foundation
import UIKit

internal enum ActionAttributes: Equatable {
    case all
    case some([String])
}

extension Action {

    func getAttributes(_ attributes: ActionAttributes, contextProvider: UIView) -> DynamicDictionary {
        if case .some(let array) = attributes, array.isEmpty { return [:] }

        let dynamicObject = transformToDynamicObject(self)
            .evaluate(with: contextProvider)
            // don't use analytics attribute
            .set(.empty, with: analyticsPath)

        let dict = dynamicObject.asDictionary()

        switch attributes {
        case .some(let some):
            return dict.getSomeAttributes(some, contextProvider: contextProvider)

        case .all:
            return dict
        }
    }
}

extension DynamicDictionary {

    func getSomeAttributes(_ attributes: [String], contextProvider: UIView?) -> DynamicDictionary {
        let object = DynamicObject.dictionary(self)

        var values = DynamicDictionary()
        attributes.forEach { attribute in
            guard let path = pathForAttribute(attribute) else { return }

            var value = object[path]
            contextProvider.ifSome {
                value = value.evaluate(with: $0)
            }

            guard value != .empty else { return }
            values[attribute] = value
        }

        return values
    }
}

private func pathForAttribute(_ attribute: String) -> Path? {
    guard let path = Path(rawValue: attribute) else { return nil }

    for node in path.nodes {
        if case .index = node { return nil }
    }
    
    return path
}

// MARK: - JSON Transformation

func transformToDynamicObject<T: Encodable>(_ any: T) -> DynamicObject {
    do {
        let data = try JSONEncoder().encode(any)
        return try JSONDecoder().decode(DynamicObject.self, from: data)
    } catch {
        return .empty
    }
}

// MARK: - Private

private var analyticsPath = Path(nodes: [.key("analytics")])
