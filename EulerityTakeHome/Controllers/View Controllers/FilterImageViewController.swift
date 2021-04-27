//
//  FilterImageViewController.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/21/21.
//

import UIKit
import CoreImage

class FilterImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties -
    let sliderSize: CGFloat = 200
    let stackSpacing: CGFloat = 20
    let thumbnailSize: CGFloat = 80
    
    var ciImage = CIImage();
    var context = CIContext();
    var outputImage = CIImage();
    
    let networkManager = NetworkManager()
    
    var imageURL: URL?
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    lazy var brightnessLabel = CustomLabel(style: .label, text: "Brightness")
    lazy var contrastLabel = CustomLabel(style: .label, text: "Contrast")
    lazy var saturationLabel = CustomLabel(style: .label, text: "Saturation")
    lazy var brightnessValueLabel = CustomLabel(style: .label, text: "\(brightnessSlider.value)")
    lazy var contrastValueLabel = CustomLabel(style: .label, text: "\(contrastSlider.value)")
    lazy var saturationValueLabel = CustomLabel(style: .label, text: "\(saturationSlider.value)")
    
    lazy var sliderHStack = CustomStackView(style: .horizontal, distribution: .fillEqually, alignment: .fill)
    lazy var brightnessStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    lazy var contrastStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    lazy var saturationStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    lazy var filterButtons = CustomStackView(style: .horizontal, distribution: .fillEqually, alignment: .fill)
    
    lazy var imageTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(drawTextOnImages))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()
    
    var filteredImage: UIImage?
    
    lazy var originalImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)
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
    
    lazy var presetFilterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Text To Image", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemTeal
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = 20
        return button
    }()
    
    let filterScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    let textField: UITextField = {
        let textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.placeholder = "Please enter your text here and click on image"
        return textView
    }()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let cgImage = originalImageView.image?.cgImage
        ciImage = CIImage(cgImage: cgImage!)
        context = CIContext(options: nil)
    }
    
    // MARK: - Helper Functions -
    func configureUI() {
        constraints()
        delegates()
        configureScrollView()
        view.backgroundColor = .white
        navigationItem.title = "Edit Image"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(saveImage))
        
        brightnessStack.spacing = stackSpacing
        contrastStack.spacing = stackSpacing
        saturationStack.spacing = stackSpacing
        filterButtons.spacing = stackSpacing
    }
    
    func delegates() {
        textField.delegate = self
    }
    
    func configureScrollView() {
        var x: CGFloat = 10
        let y: CGFloat = 10
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.showsTouchWhenHighlighted = true
            filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            filterButton.contentMode = .scaleAspectFit
            
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: originalImageView.image!)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!)
            
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            
            x += buttonWidth + gapBetweenButtons
            filterScrollView.addSubview(filterButton)
        }
        
        filterScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount + 2), height: y)
    }
    
    func sliderControls(filter: CIFilter, key: String, sender: UISlider) {
        filter.setValue(NSNumber(value: sender.value), forKey: key)
        outputImage = filter.outputImage!
        
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        filteredImage = UIImage(cgImage: imageRef!)
        originalImageView.image = filteredImage
    }
    
    var photoEdited = false
    
    var userTouch: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: originalImageView)
            userTouch = position
            print(userTouch)
        }
    }
    
    @objc func drawTextOnImages(sender: UITapGestureRecognizer) {
        guard let imageView = originalImageView,
              let userTouch = userTouch else { return }
        
        guard let text = textField.text,
              !text.isEmpty else { return }
        
        guard imageView.bounds.contains(userTouch) else { return }
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        
        // Add object method for things you want to add to image
        textToImage(atPoint: userTouch, text: text, textSizeWidth: 100, textSizeHeight: 100)
        
        // Render image by given context
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = renderedImage
    }
    
    func textToImage(atPoint point: CGPoint, text: String, textSizeWidth: CGFloat, textSizeHeight: CGFloat) {
        let textLabel = DraggableLabel()
        textLabel.frame = CGRect(x: point.x,
                                 y: point.y,
                                 width: textSizeWidth,
                                 height: textSizeHeight)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.black
        
        textLabel.text = text
        originalImageView.addSubview(textLabel)
    }
    
    // MARK: - Actions -
    @objc func brightnessValueChanged(sender: UISlider) {
        let brightnessFilter: CIFilter!
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(ciImage, forKey: "inputImage")
        brightnessValueLabel.text = String(format: "%.02f", brightnessSlider.value)
        sliderControls(filter: brightnessFilter, key: "inputBrightness", sender: sender)
    }
    
    @objc func contrastValueChanged(sender: UISlider) {
        let contrastFilter: CIFilter!
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(ciImage, forKey: "inputImage")
        contrastValueLabel.text = String(format: "%.02f", contrastSlider.value)
        sliderControls(filter: contrastFilter, key: "inputContrast", sender: sender)
    }
    
    @objc func saturationValueChanged(sender: UISlider) {
        let saturationFilter: CIFilter!
        saturationFilter = CIFilter(name: "CIColorControls")
        saturationFilter.setValue(ciImage, forKey: "inputImage")
        saturationValueLabel.text = String(format: "%.02f", saturationSlider.value)
        sliderControls(filter: saturationFilter, key: "inputSaturation", sender: sender)
    }
    
    @objc func saveImage() {
        guard let image = originalImageView.image,
              let imageURL = imageURL else { return }
        
        networkManager.uploadImage(imageData: image.pngData()!, imageURL: imageURL)
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        originalImageView.image = button.backgroundImage(for: .normal)
    }
}

// MARK: - Extensions -
extension FilterImageViewController {
    private func constraints() {
        view.addSubview(originalImageView)
        NSLayoutConstraint.activate([
            originalImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            originalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            originalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            originalImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.5),
            originalImageView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        view.addSubview(filterScrollView)
        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: originalImageView.bottomAnchor, constant: standardPadding),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: standardPadding),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: standardPadding),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -standardPadding),
            textField.heightAnchor.constraint(equalToConstant: 50)
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

extension FilterImageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty  {
            textView.layer.borderColor = UIColor.systemOrange.cgColor
            return
        } else {
            textView.layer.borderColor = UIColor.black.cgColor
        }
    }
}
