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
    let stackSpacing: CGFloat = 20
    let thumbnailSize: CGFloat = 80
    
    var ciImage = CIImage();
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    
    let networkManager = NetworkManager()
    
    // MARK: - Labels -
    lazy var brightnessLabel = CustomLabel(style: .label, text: "Brightness")
    lazy var contrastLabel = CustomLabel(style: .label, text: "Contrast")
    lazy var saturationLabel = CustomLabel(style: .label, text: "Saturation")
    lazy var brightnessValueLabel = CustomLabel(style: .label, text: "\(brightnessSlider.value)")
    lazy var contrastValueLabel = CustomLabel(style: .label, text: "\(contrastSlider.value)")
    lazy var saturationValueLabel = CustomLabel(style: .label, text: "\(saturationSlider.value)")
    
    // MARK: - StackViews -
    lazy var sliderHStack = CustomStackView(style: .horizontal, distribution: .fillEqually, alignment: .fill)
    lazy var brightnessStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    lazy var contrastStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    lazy var saturationStack = CustomStackView(style: .vertical, distribution: .equalSpacing, alignment: .fill)
    
    // MARK: - ImageViews -
    lazy var imageTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()
    
    lazy var originalImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    lazy var presetFilterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Preset Filter", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemTeal
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = 20
//        button.addTarget(self, action: #selector(presetFilterAction), for: .touchUpInside)
        return button
    }()
    
    lazy var filterButtons: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 16
        return stack
    }()
    
    let textView = UITextView(frame: .zero)
    
    let filterScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
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
    
    var imageURL: URL?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let cgImage = originalImageView.image?.cgImage
        ciImage = CIImage(cgImage: cgImage!)
        context = CIContext(options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureScrollView()
    }
    
    // MARK: - Helper Functions -
    func configureUI() {
        constraints()
        delegates()
        view.backgroundColor = .white
        navigationItem.title = "Edit Image"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(saveImage))
        
        brightnessStack.spacing = stackSpacing
        contrastStack.spacing = stackSpacing
        saturationStack.spacing = stackSpacing
    }
    
    func delegates() {
        textView.delegate = self
    }
    
    func configureScrollView() {
        var x: CGFloat = 5
        let y: CGFloat = 5
        let buttonWidth: CGFloat = 70
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
            filterButton.contentMode = .scaleToFill
            
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
        newUIImage = UIImage(cgImage: imageRef!)
        originalImageView.image = newUIImage
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
    
    @objc func imageTapped() {
//        let alertController = UIAlertController(title: "Enter Text \n\n\n\n", message: nil, preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
//            alertController.view.removeObserver(self, forKeyPath: "bounds")
//        }
//        alertController.addAction(cancelAction)
//
//        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) in
//            let entertedText = self.textView.text
//            //            self.addTextToImage(text: entertedText)
//            alertController.view.removeObserver(self, forKeyPath: "bounds")
//        }
//        alertController.addAction(saveAction)
//
//        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
//
//        textView.backgroundColor = UIColor.lightGray
//        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
//        alertController.view.addSubview(self.textView)
//
//        self.present(alertController, animated: true, completion: nil)
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "bounds"{
//            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
//                let margin: CGFloat = 8
//                let xPos = rect.origin.x + margin
//                let yPos = rect.origin.y + 54
//                let width = rect.width - 2 * margin
//                let height: CGFloat = 90
//
//                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
//            }
//        }
//    }
}

// MARK: - Extensions -
extension FilterImageViewController {
    private func constraints() {
        view.addSubview(originalImageView)
        NSLayoutConstraint.activate([
            originalImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: standardPadding),
            originalImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            originalImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            originalImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 3),
            originalImageView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        view.addSubview(filterScrollView)
        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: originalImageView.bottomAnchor, constant: standardPadding),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 100)
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

//extension FilterImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}

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
