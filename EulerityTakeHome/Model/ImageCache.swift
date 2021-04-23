//
//  ImageCache.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/23/21.
//

import Foundation

class ImageCache<Key: Hashable, Value> {
    var stores = [Key: Value]()
    let queue = DispatchQueue(label: "ImageCacheQueue")
    
    func cache(value: Value, for key: Key) {
        queue.sync {
            self.stores[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return self.stores[key] ?? nil
        }
    }
}
