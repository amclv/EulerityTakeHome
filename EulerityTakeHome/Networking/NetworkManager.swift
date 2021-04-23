//
//  NetworkManager.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/21/21.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case push = "PUSH"
}

class NetworkManager {
    
    private let baseURL = URL(string: "https://eulerity-hackathon.appspot.com")!
    
    func fetchImages(completion: @escaping (Result<[Image], Error>) -> ()) {
        let imageURL = baseURL.appendingPathComponent("image")
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.loadData(using: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            guard let response = response else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                
                print("invalid response in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response.statusCode), \(String(data: data ?? Data(), encoding: .utf8))"])
                
                print("invalid response code in \(#function): \(response.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file). \(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "No Data Received: \(response.statusCode)"])
                print("No Data: \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let imagesData = try jsonDecoder.decode([Image].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(imagesData))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension URLSession {
    /// convenience method to always use.resume and provide default error handling
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
