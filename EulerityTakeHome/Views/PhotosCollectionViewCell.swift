//
//  PhotosCollectionViewCell.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/22/21.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    static var identifier: String = "PhotosCollectionViewCell"
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        configureUI()
    }
    
    func configureUI() {
        if !subviews.contains(thumbnailImageView) {
            contentView.addSubview(thumbnailImageView)
        }
        
        NSLayoutConstraint.activate([
            thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}
