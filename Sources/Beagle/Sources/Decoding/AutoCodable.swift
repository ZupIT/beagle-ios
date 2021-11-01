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

// MARK: - AutoCodable
@propertyWrapper
public struct AutoCodable<Value> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension AutoCodable: Codable {
    public init(from decoder: Decoder) throws {
        // swiftlint:disable force_cast
        if Value.self == ServerDrivenComponent.self {
            wrappedValue = try decoder.decode(ServerDrivenComponent.self) as! Value
        } else if Value.self == [ServerDrivenComponent].self {
            wrappedValue = try decoder.decodeArray([ServerDrivenComponent].self) as! Value
        } else if Value.self == ServerDrivenComponent?.self {
            wrappedValue = try decoder.decodeOptional(ServerDrivenComponent?.self) as! Value
        } else if Value.self == [ServerDrivenComponent]?.self {
            wrappedValue = try decoder.decodeOptional([ServerDrivenComponent]?.self) as! Value
        } else if Value.self == Action.self {
            wrappedValue = try decoder.decode(Action.self) as! Value
        } else if Value.self == [Action].self {
            wrappedValue = try decoder.decodeArray([Action].self) as! Value
        } else if Value.self == Action?.self {
            wrappedValue = try decoder.decodeOptional(Action?.self) as! Value
        } else if Value.self == [Action]?.self {
            wrappedValue = try decoder.decodeOptional([Action]?.self) as! Value
        } else {
            throw BeagleCodableError.unsupportedType(String(describing: Value.self))
        }
        // swiftlint:enable force_cast
    }

    public func encode(to encoder: Encoder) throws {
        if let value = wrappedValue as? ServerDrivenComponent {
            try encoder.encode(value)
        } else if let value = wrappedValue as? [ServerDrivenComponent] {
            try encoder.encodeArray(value)
        } else if let value = wrappedValue as? Action {
            try encoder.encode(value)
        } else if let value = wrappedValue as? [Action] {
            try encoder.encodeArray(value)
        } else {
            throw BeagleCodableError.unsupportedType(String(describing: Value.self))
        }
    }
}

// MARK: - BeagleCodable
public protocol BeagleCodable: Codable {}

enum BeagleCodableError: Error, Equatable {
    case unsupportedType(String)
    case unableToFindBeagleTypeKey(String)
    case unableToCast(decoded: String, into: String)
    case unableToRepresentAsBeagleTypeForEncoding
}

enum BeagleMetaContainerKeys: CodingKey {
    case _beagleComponent_
    case _beagleAction_
}

// MARK: - Encoder
extension Encoder {
    func encodeOptional<ValueType>(_ value: ValueType?) throws {
        var container = singleValueContainer()
        if let value = value {
            try container.encode(AutoCodable(wrappedValue: value))
        } else {
            try container.encodeNil()
        }
    }
    
    func encodeArray<ValueType>(_ values: [ValueType]) throws {
        var container = unkeyedContainer()
        for value in values {
            try container.encode(AutoCodable(wrappedValue: value))
        }
    }
    
    func encode<ValueType>(_ value: ValueType) throws {
        guard let value = value as? BeagleCodable else {
            throw BeagleCodableError.unableToRepresentAsBeagleTypeForEncoding
        }
        var container = self.container(
            keyedBy: BeagleMetaContainerKeys.self
        )
        var key: BeagleMetaContainerKeys = ._beagleComponent_
        if value is Action {
            key = ._beagleAction_
        }
        if let identifier = dependencies.coder.name(for: type(of: value)) {
            try container.encode(identifier, forKey: key)
        }
        try value.encode(to: self)
    }
}

// MARK: - Decoder
extension Decoder {
    func decodeOptional<ExpectedType>(_ expectedType: ExpectedType?.Type) throws -> ExpectedType? {
        let container = try singleValueContainer()
        guard !container.decodeNil() else {
            return nil
        }
        return try container.decode(AutoCodable<ExpectedType>.self).wrappedValue
    }
    
    func decodeArray<ExpectedType>(_ expectedType: [ExpectedType].Type) throws -> [ExpectedType] {
        var array: [ExpectedType] = []
        var container = try unkeyedContainer()
        while !container.isAtEnd {
            let wrapper = try container.decode(AutoCodable<ExpectedType>.self)
            array.append(wrapper.wrappedValue)
        }
        return array
    }
    
    func decode<ExpectedType>(_ expectedType: ExpectedType.Type) throws -> ExpectedType {
        let container = try self.container(keyedBy: BeagleMetaContainerKeys.self)
        
        var key: (type: BeagleMetaContainerKeys, base: BeagleCoder.BaseType) = (._beagleComponent_, .component)
        if expectedType == Action.self {
            key = (._beagleAction_, .action)
        }
        let typeID = try container.decode(String.self, forKey: key.type)
        
        guard let matchingType = dependencies.coder.type(for: typeID, baseType: key.base) else {
            return try handleUnknown(expectedType, typeID)
        }
        let decoded = try matchingType.init(from: self)

        guard let decodedValue = decoded as? ExpectedType else {
            throw BeagleCodableError.unableToCast(
                decoded: String(describing: decoded),
                into: String(describing: ExpectedType.self)
            )
        }
        return decodedValue
    }
    
    private func handleUnknown<ExpectedType>(_ expectedType: ExpectedType.Type, _ typeID: String) throws -> ExpectedType {
        // swiftlint:disable force_cast
        if expectedType == ServerDrivenComponent.self {
            return UnknownComponent(_beagleComponent_: typeID) as! ExpectedType
        } else if expectedType == Action.self {
            return UnknownAction(_beagleAction_: typeID) as! ExpectedType
        }
        throw BeagleCodableError.unableToFindBeagleTypeKey(typeID)
        // swiftlint:enable force_cast
    }
}

// MARK: - CustomDebugStringConvertible
extension AutoCodable: CustomDebugStringConvertible {
  public var debugDescription: String {
    return String(describing: wrappedValue)
  }
}
