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
                                    userInfo: [NSLocalizedDescriptionKey: "Response Invalid"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file). \(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
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
                                    userInfo: [NSLocalizedDescriptionKey: "Response Invalid"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
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
    func uploadImage(imageData: Data, imageURL: URL, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        fetchUploadURL { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                guard let url = url else {
                    let error = NSError(domain: #function,
                                        code: 999,
                                        userInfo: [NSLocalizedDescriptionKey: "No valid URL to upload file"])
                    completion(.failure(error))
                    return
                }
                self.uploadImage(data: imageData,
                                 imageURL: imageURL,
                                 to: url,
                                 completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Multipart Upload -
    private func uploadImage(data: Data, imageURL: URL, to url: URL, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.append(convertFileData(email: "toscleveland@gmail.com",
                                    imageURL: imageURL,
                                    mimeType: "image/png",
                                    fileData: data,
                                    using: boundary))
        request.httpBody = body as Data
        
        URLSession.shared.loadData(using: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "Response Invalid"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: response.statusCode])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            print(data)
        }
    }
    
    func convertFileData(email: String, imageURL: URL, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)")
        data.appendString("\r\n")
        data.appendString("Content-Disposition: form-data; name=\"appid\"")
        data.appendString("\r\n")
        data.appendString("\r\n")
        
        data.appendString(email)
        data.appendString("\r\n")
        
        data.appendString("--\(boundary)")
        data.appendString("\r\n")
        data.appendString("Content-Disposition: form-data; name=\"original\"")
        data.appendString("\r\n")
        data.appendString("\r\n")
        
        data.appendString(imageURL.absoluteString)
        data.appendString("\r\n")
        
        data.appendString("--\(boundary)")
        data.appendString("\r\n")
        data.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).png\"")
        data.appendString("\r\n")
        data.appendString("Content-Type: \(mimeType)")
        data.appendString("\r\n")
        data.appendString("\r\n")
        
        data.append(fileData)
        data.appendString("\r\n")
        data.appendString("--\(boundary)--")
        return data as Data
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\""
        fieldString += "\(value)"
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
