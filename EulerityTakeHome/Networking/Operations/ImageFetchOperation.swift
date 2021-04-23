//
//  ImageFetchOperation.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/23/21.
//

import Foundation

class ImageFetchOperation: ConcurrentOperation {
    // MARK: - Properties -
    let queue = DispatchQueue(label: "ImageFetchQueue")
    var networkManager: NetworkManager
    var dataTask: URLSessionDataTask?
    
    var imageData: Data?
    let imageURL: URL
    
    init(imageURL: URL, networkManager: NetworkManager) {
        self.imageURL = imageURL
        self.networkManager = networkManager
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        fetchImage()
        dataTask?.resume()
    }
    
    override func cancel() {
        state = .isFinished
        dataTask?.cancel()
    }
    
    private func fetchImage() {
        dataTask = URLSession.shared.dataTask(with: imageURL, completionHandler: { [unowned self] (data, _, error) in
            defer {
                self.state = .isFinished
            }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            self.queue.sync {
                self.imageData = data
            }
        })
    }
}
