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
    func uploadImage(imageData: Data, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        fetchUploadURL { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                guard let url = url else {
                    let error = NSError(domain: #function, code: 999, userInfo: [NSLocalizedDescriptionKey: "unable to get valid URL to upload file with"])
                    completion(.failure(error))
                    return
                }
                self.uploadImage(data: imageData, url: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func uploadImage(data: Data, url: URL, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let uuidString = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(uuidString)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let boundary = "Boundary-\(uuidString)"
        // Default email
        body.append(convertData(email: "toscleveland@gmail.com", url: url, mime: "image/jpeg", fileData: data, boundary: boundary))
        
        URLSession.shared.loadData(using: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response else {
                let error = NSError(domain: "\(#file) \(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                print("Invalid Response \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file) \(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response.statusCode), \(String(data: data ?? Data(), encoding: .utf8))"])
                print("\(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file) \(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "No Data: \(response.statusCode)"])
                print("No Data: \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            print(data)
        }
    }
    
    func convertData(email: String, url: URL, mime: String, fileData: Data, boundary: String) -> Data {
        let data = NSMutableData()
        // TODO: clean this up using convertFormField?
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"appid\"\r\n")
        
        data.append(string: email)
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"original\"\r\n")
        
        data.append(string: url.absoluteString)
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"file\"")
        data.append(string: "Content-Type: \(mime)\r\n\r\n")
        
        data.append(fileData)
        data.append(string:"\r\n")
        data.append(string: "--\(boundary)-")
        return data as Data
    }
    
    private func convertFormField(name: String, value: String, using boundary: String) -> String {
        let fieldString =
        """
        --\(boundary)
        Content-Disposition: form-data; name=\"\(name)\"

        \(value)
        
        """
        return fieldString
    }
    
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
