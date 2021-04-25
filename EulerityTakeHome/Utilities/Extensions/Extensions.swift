//
//  Extensions.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/23/21.
//

import Foundation
import UIKit

extension URLSession {
    /// Convenience method to always use.resume and provide default error handling
    /// - Parameters:
    ///   - request: Passes in a URLRequest
    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Networking error with \(String(describing: request.url?.absoluteString)) \n\(error)")
                // could return here if we want to return from errors in the default implementation
            }
            
            completion(data, response as? HTTPURLResponse, error)
        }.resume()
    }
}

extension NSMutableData {
    func append(string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
