//
//  FilterImageViewController.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/21/21.
//

import UIKit
import CoreImage

class FilterImageViewController: UIViewController {
    
    // MARK: - Properties -
    let sliderSize: CGFloat = 200
    let standardPadding: CGFloat = 20
    let thumbnailSize: CGFloat = 80
    
    var aCIImage = CIImage();
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    
    lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: thumbnailSize, height: thumbnailSize)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        slider.setValue(0.5, animated: true)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = .green
        slider.addTarget(self, action: #selector(brightnessValueChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var contrastSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        slider.setValue(0.5, animated: true)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = .green
        slider.addTarget(self, action: #selector(contrastValueChanged), for: .valueChanged)
        return slider
    }()
    
    lazy var saturationSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        slider.setValue(0.5, animated: true)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = .green
        slider.addTarget(self, action: #selector(saturationValueChanged), for: .valueChanged)
        return slider
    }()
    
    let sliderHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Edit Image"
        constraints()
        delegates()
        
        let aUIImage = imageView.image
        let aCGImage = aUIImage?.cgImage
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil);
    }
    
    // MARK: - Helper Functions -
    func delegates() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    func sliderControls(filter: CIFilter, key: String, sender: UISlider) {
        filter.setValue(NSNumber(value: sender.value), forKey: key)
        outputImage = filter.outputImage!
        
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: imageRef!)
        imageView.image = newUIImage
    }
    
    // MARK: - Actions -
    @objc func brightnessValueChanged(sender: UISlider) {
        let brightnessFilter: CIFilter!
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        sliderControls(filter: brightnessFilter, key: "inputBrightness", sender: sender)
    }
    
    @objc func contrastValueChanged(sender: UISlider) {
        let contrastFilter: CIFilter!
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        sliderControls(filter: contrastFilter, key: "inputContrast", sender: sender)
    }
    
    @objc func saturationValueChanged(sender: UISlider) {
        let saturationFilter: CIFilter!
        saturationFilter = CIFilter(name: "CIColorControls")
        saturationFilter.setValue(aCIImage, forKey: "inputImage")
        sliderControls(filter: saturationFilter, key: "inputSaturation", sender: sender)
    }
}

// MARK: - Extensions -
extension FilterImageViewController {
    private func constraints() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.5),
            imageView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        view.addSubview(photoCollectionView)
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: standardPadding),
            photoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        sliderHStack.addArrangedSubview(brightnessSlider)
        sliderHStack.addArrangedSubview(contrastSlider)
        sliderHStack.addArrangedSubview(saturationSlider)
        view.addSubview(sliderHStack)
        NSLayoutConstraint.activate([
            sliderHStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -standardPadding),
            sliderHStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sliderHStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sliderHStack.heightAnchor.constraint(equalToConstant: sliderSize)
        ])
    }
}

extension FilterImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as! PhotosCollectionViewCell
        cell.thumbnailImageView.image = imageView.image
        cell.layer.cornerRadius = 10
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Took away the leading and trailing constraint on the collectionview itself. added an edge inset here to give a better look to the view.
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
}

extension FilterImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}
