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

extension KeyedDecodingContainer {
    
    // MARK: - Action
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> Action {
        try decode(AutoCodable<Action>.self, forKey: key).wrappedValue
    }
    
    public func decodeIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> Action? {
        try decode(AutoCodable<Action?>.self, forKey: key).wrappedValue
    }
    
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> [Action] {
        try decode(AutoCodable<[Action]>.self, forKey: key).wrappedValue
    }
    
    public func decodeIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> [Action]? {
        try decode(AutoCodable<[Action]?>.self, forKey: key).wrappedValue
    }
    
    // MARK: - ServerDrivenComponent
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> ServerDrivenComponent {
        try decode(AutoCodable<ServerDrivenComponent>.self, forKey: key).wrappedValue
    }
    
    public func decodeIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> ServerDrivenComponent? {
        try decode(AutoCodable<ServerDrivenComponent?>.self, forKey: key).wrappedValue
    }
    
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> [ServerDrivenComponent] {
        try decode(AutoCodable<[ServerDrivenComponent]>.self, forKey: key).wrappedValue
    }
    
    public func decodeIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> [ServerDrivenComponent]? {
        try decode(AutoCodable<[ServerDrivenComponent]?>.self, forKey: key).wrappedValue
    }
    
    // MARK: - AutoCodable
    public func decode<T>(_ type: AutoCodable<T?>.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> AutoCodable<T?> {
        return try decodeIfPresent(type, forKey: key) ?? AutoCodable<T?>(wrappedValue: nil)
    }
    
}

extension KeyedEncodingContainer {
    
    // MARK: - Action
    public mutating func encode(_ value: Action, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encodeIfPresent(_ value: Action?, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encode(_ value: [Action], forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encodeIfPresent(_ value: [Action]?, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    // MARK: - ServerDrivenComponent
    public mutating func encode(_ value: ServerDrivenComponent, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encodeIfPresent(_ value: ServerDrivenComponent?, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encode(_ value: [ServerDrivenComponent], forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    public mutating func encodeIfPresent(_ value: [ServerDrivenComponent]?, forKey key: KeyedDecodingContainer<K>.Key) throws {
        try encode(AutoCodable(wrappedValue: value), forKey: key)
    }
    
    // MARK: - AutoCodable
    public mutating func encode<T>(_ value: AutoCodable<T?>, forKey key: KeyedDecodingContainer<K>.Key) throws {
        if value.wrappedValue != nil {
            try encodeIfPresent(value, forKey: key)
        }
    }
}
