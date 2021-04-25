//
//  NetworkManager.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/21/21.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case push = "PUSH"
}

class NetworkManager {
    
    private let imageCache = ImageCache<URL, Data>()
    var originalImageURL: [Image] = []
    private let baseURL = URL(string: "https://eulerity-hackathon.appspot.com")!
    
    // MARK: - Fetch Methods -
    func fetchImages(completion: @escaping (Result<[Image]?, Error>) -> ()) {
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
                self.originalImageURL.append(contentsOf: imagesData)
                DispatchQueue.main.async {
                    completion(.success(imagesData))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchUploadURL(completion: @escaping (Result<URL?, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("upload")
        let request = URLRequest(url: url)
        URLSession.shared.loadData(using: request) { [weak self] (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
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
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "No Data Received: \(response.statusCode)"])
                
                print("no data received in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let urlObject = try jsonDecoder.decode(Image.self, from: data)
                completion(.success(urlObject.url))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Upload Methods -
    
    // MARK: - Storage Operations -
    func cacheImageData(_ data: Data, for url: URL) {
        imageCache.cache(value: data, for: url)
    }
    
    func getImage(url: URL) -> UIImage? {
        guard let data = imageCache.value(for: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}
