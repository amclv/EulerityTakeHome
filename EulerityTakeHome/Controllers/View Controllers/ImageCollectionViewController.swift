//
//  ImageCollectionViewController.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/22/21.
//

import UIKit

class ImageCollectionViewController: UIViewController {
    
    let networkManager = NetworkManager()
    let operationQueue = OperationQueue()
    var operations = [URL: Operation]()
    
    private var imageURL: [URL] = [] {
        didSet {
            if !imageURL.isEmpty {
                collectionView.reloadData()
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        // Switch to estimateItemSize if we want a dynamic height
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        // Set URLS array which reloads collectionView and starts image fetch operations
        networkManager.fetchImages { (result) in
            switch result {
            case .success(let imageObjects):
                guard let imageObjects = imageObjects else { return }
                self.imageURL = imageObjects.compactMap({ $0.url })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func delegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configUI() {
        view.backgroundColor = .white
        delegates()
        constraints()
    }
}

extension ImageCollectionViewController {
    private func constraints() {
        let safe = view.safeAreaLayoutGuide
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safe.topAnchor, constant: standardPadding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -standardPadding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: standardPadding),
            collectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
        ])
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        
        let url = imageURL[indexPath.item]
        
        // Loads image from cache or image operation
        if let image = networkManager.getImage(url: imageURL[indexPath.item]) {
            cell.imageView.image = image
        } else {
            // Use placeholder image while downloading
            // FIXME: This needs to have an actual placeholder image
            cell.imageView.image = UIImage(systemName: "person")
            
            let fetchOperation = ImageFetchOperation(imageURL: url, networkManager: networkManager)
            let cacheOperation = BlockOperation {
                if let data = fetchOperation.imageData {
                    self.networkManager.cacheImageData(data, for: url)
                }
            }
            
            // Fetch first
            cacheOperation.addDependency(fetchOperation)
            
            operationQueue.addOperations([
                fetchOperation,
                cacheOperation
            ], waitUntilFinished: false)
            
            let imageSetOperation = BlockOperation {
                // Operation will run on main OperationQueue
                if let imageData = fetchOperation.imageData {
                    cell.imageView.image = UIImage(data: imageData)
                }
            }
            
            // Fetch then set
            imageSetOperation.addDependency(fetchOperation)
            
            OperationQueue.main.addOperation(imageSetOperation)
            
            // Sets the operation
            operations[url] = fetchOperation
        }
        return cell
    }
    
    // Cancels image loading after user scrolls past it.
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let url = imageURL[indexPath.item]
        operations[url]?.cancel()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterImageViewController = FilterImageViewController()
        let image = networkManager.getImage(url: imageURL[indexPath.item])
        let originalImageURL = networkManager.originalImageURL[indexPath.item]
        filterImageViewController.imageView.image = image
        filterImageViewController.imageURL = originalImageURL.url
        navigationController?.pushViewController(filterImageViewController, animated: true)
    }
}
