//
//  ImageCollectionViewController.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/22/21.
//

import UIKit

class ImageCollectionViewController: UIViewController {
    
    let networkManager = NetworkManager()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 200)
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
        
        networkManager.fetchImages { (imageData) in
            DispatchQueue.global().async {
                <#code#>
            }
        }
        
//        networkManager.fetchImages {
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
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
            collectionView.topAnchor.constraint(equalTo: safe.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
        ])
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        let imageIndex = networkManager.imageDataArray[indexPath.item]
        let imageURL = URL(string: imageIndex.url ?? "")!
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageFilterViewController = FilterImageViewController()
        let imageIndex = networkManager.imageDataArray[indexPath.item]
        let imageURL = URL(string: imageIndex.url ?? "")!
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                imageFilterViewController.imageView.image = image
                self.navigationController?.pushViewController(imageFilterViewController, animated: true)
            }
        }
    }
}
