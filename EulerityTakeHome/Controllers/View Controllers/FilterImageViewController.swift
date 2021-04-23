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
    let thumbnailSize: CGFloat = 80
    
    var aCIImage = CIImage();
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    
    // MARK: - ImageViews -
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Labels -
    let brightnessLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Brightness"
        label.textAlignment = .center
        return label
    }()
    
    let contrastLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Contrast"
        label.textAlignment = .center
        return label
    }()
    
    let saturationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Saturation"
        label.textAlignment = .center
        return label
    }()
    
    lazy var brightnessValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(brightnessSlider.value)"
        label.textAlignment = .center
        return label
    }()
    
    lazy var contrastValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(contrastSlider.value)"
        label.textAlignment = .center
        return label
    }()
    
    lazy var saturationValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(saturationSlider.value)"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Sliders -
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
    
    // MARK: - StackViews -
    let sliderHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let brightnessStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 20
        return stack
    }()
    
    let contrastStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 20
        return stack
    }()
    
    let saturationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 20
        return stack
    }()

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Edit Image"
        constraints()
        
        let aUIImage = imageView.image
        let aCGImage = aUIImage?.cgImage
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil);
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveImage))
    }
    
    // MARK: - Helper Functions -
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
        brightnessValueLabel.text = "\(brightnessSlider.value)"
        sliderControls(filter: brightnessFilter, key: "inputBrightness", sender: sender)
    }
    
    @objc func contrastValueChanged(sender: UISlider) {
        let contrastFilter: CIFilter!
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        contrastValueLabel.text = "\(contrastSlider.value)"
        sliderControls(filter: contrastFilter, key: "inputContrast", sender: sender)
    }
    
    @objc func saturationValueChanged(sender: UISlider) {
        let saturationFilter: CIFilter!
        saturationFilter = CIFilter(name: "CIColorControls")
        saturationFilter.setValue(aCIImage, forKey: "inputImage")
        saturationValueLabel.text = "\(saturationSlider.value)"
        sliderControls(filter: saturationFilter, key: "inputSaturation", sender: sender)
    }
    
    @objc func saveImage() {
        
    }
}

// MARK: - Extensions -
extension FilterImageViewController {
    private func constraints() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: standardPadding),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.5),
            imageView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        brightnessStack.addArrangedSubview(brightnessValueLabel)
        brightnessStack.addArrangedSubview(brightnessSlider)
        brightnessStack.addArrangedSubview(brightnessLabel)
        view.addSubview(brightnessStack)
                
        contrastStack.addArrangedSubview(contrastValueLabel)
        contrastStack.addArrangedSubview(contrastSlider)
        contrastStack.addArrangedSubview(contrastLabel)
        view.addSubview(contrastStack)
        
        saturationStack.addArrangedSubview(saturationValueLabel)
        saturationStack.addArrangedSubview(saturationSlider)
        saturationStack.addArrangedSubview(saturationLabel)
        view.addSubview(saturationStack)
        
        sliderHStack.addArrangedSubview(brightnessStack)
        sliderHStack.addArrangedSubview(contrastStack)
        sliderHStack.addArrangedSubview(saturationStack)
        view.addSubview(sliderHStack)
        NSLayoutConstraint.activate([
            sliderHStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -standardPadding),
            sliderHStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sliderHStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sliderHStack.heightAnchor.constraint(equalToConstant: sliderSize)
        ])
        
        
    }
}

extension FilterImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}
