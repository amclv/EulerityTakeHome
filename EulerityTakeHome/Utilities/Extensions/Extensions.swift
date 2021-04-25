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
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

extension UIViewController {
    
    /// Show an alert with a title, message, and OK button
    /// - Parameters:
    ///   - title: The Alert's Title
    ///   - message: The Alert's Message
    func presentAlert(title: String, message: String, completion: @escaping (UIAlertAction) -> Void = {_ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
