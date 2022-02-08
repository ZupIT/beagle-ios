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

public protocol ViewClientProtocol {
    @discardableResult
    func fetch(
        url: String,
        additionalData: HttpAdditionalData?,
        completion: @escaping (Result<ServerDrivenComponent, Request.Error>) -> Void
    ) -> RequestToken?
    
    func prefetch(url: String, additionalData: HttpAdditionalData?)
}

// MARK: - Default

public struct ViewClient: ViewClientProtocol {
    
    // MARK: Dependencies
    
    @Injected var coder: CoderProtocol
    
    var dispatcher = RequestDispatcher()
    
    let cache = Cache<String, Result<ServerDrivenComponent>>()
    
    // MARK: Initialization
    
    public init() { }
    
    // MARK: Public Methods

    public typealias Result<Success> = Swift.Result<Success, Request.Error>

    @discardableResult
    public func fetch(
        url: String,
        additionalData: HttpAdditionalData?,
        completion: @escaping (Result<ServerDrivenComponent>) -> Void
    ) -> RequestToken? {
        fetch(url: url, additionalData: additionalData, cacheInsert: false, completion: completion)
    }
    
    public func prefetch(url: String, additionalData: HttpAdditionalData?) {
        fetch(url: url, additionalData: additionalData, cacheInsert: true) { _ in }
    }
    
    // MARK: Private Methods
    
    @discardableResult
    private func fetch(
        url: String,
        additionalData: HttpAdditionalData?,
        cacheInsert: Bool,
        completion: @escaping (Result<ServerDrivenComponent>) -> Void
    ) -> RequestToken? {
        if let value = cache.value(forKey: url) {
            cache.removeValue(forKey: url)
            completion(value)
            return nil
        }
        
        return dispatcher.dispatchRequest(path: url, additionalData: additionalData) {  result in
            let mapped = result
                .flatMap { self.decodeComponent(from: $0.data) }
            
            if cacheInsert, case .success(_) = mapped {
                self.cache.insert(mapped, forKey: url)
            }
            
            DispatchQueue.main.async { completion(mapped) }
        }
    }

    private func decodeComponent(from data: Data) -> Result<ServerDrivenComponent> {
        do {
            return .success(try coder.decode(from: data))
        } catch {
            return .failure(.decoding(error))
        }
    }

}

/// A thin wrapper around NSCache
final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
    
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
