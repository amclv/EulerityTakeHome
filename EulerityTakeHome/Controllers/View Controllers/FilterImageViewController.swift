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
    
    var ciImage = CIImage();
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    var imageURL: URL?
    
    var photoEdited = false
    
    let networkManager = NetworkManager()
    
    // MARK: - ImageViews -
    lazy var imageTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)
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
    
    lazy var presetFilterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Preset Filter", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemTeal
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(presetFilterAction), for: .touchUpInside)
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
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        view.backgroundColor = .white
        navigationItem.title = "Edit Image"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(saveImage))
        textView.delegate = self
        
        let cgImage = imageView.image?.cgImage
        ciImage = CIImage(cgImage: cgImage!)
        context = CIContext(options: nil)
    }
    
    // MARK: - Helper Functions -
    func sliderControls(filter: CIFilter, key: String, sender: UISlider) {
        filter.setValue(NSNumber(value: sender.value), forKey: key)
        outputImage = filter.outputImage!
        
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: imageRef!)
        imageView.image = newUIImage
    }
    
    func addTextToImage(text: String?) {
        guard let image = imageView.image else { return }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let textColor = UIColor.white.cgColor
        let textFont = UIFont.systemFont(ofSize: 16)
        
        let textAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor
        ] as [NSAttributedString.Key : Any]
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        let drawingBounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        
        let textSize = text!.size(withAttributes: [NSAttributedString.Key.font:textFont])
        let textRect = CGRect(x: drawingBounds.size.width/2 - textSize.width/2, y: drawingBounds.size.height/2 - textSize.height/2,
                              width: textSize.width, height: textSize.height)
        
        text!.draw(in: textRect, withAttributes: textAttributes)
        
        let renderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
//    func addText(text: String?) {
//        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
//        let userInput = imageTap.location(in: view)
//
//        guard imageView.bounds.contains(userInput) else { return }
//
//        guard let image = imageView.image else {
//            self.dismiss(animated: true)
//            return
//        }
//
//        guard let text = text,
//              !text.isEmpty else {
//            return
//        }
//
//        let imageScaleWidth = image.size.width / imageView.bounds.width
//        let imageScaleHeight = image.size.height / imageView.bounds.height
//
//        let font = UIFont.systemFont(ofSize: 48 * imageScaleWidth)
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .natural
//        paragraphStyle.lineBreakMode = .byWordWrapping
//
//        let textAttributes = [
//            NSAttributedString.Key.paragraphStyle: paragraphStyle,
//            NSAttributedString.Key.font: font
//        ]
//
//        let attributedText = NSAttributedString(
//            string: text,
//            attributes: textAttributes
//        )
//
//        let imageWidth = image.size.width
//        let imageHeight = image.size.height
//        let textSize = attributedText.size()
//
//        let maxWidth = textSize.width <  imageWidth ? textSize.width : imageWidth
//        let maxHeight = textSize.height < imageHeight ? textSize.height : imageHeight
//
//        let estimatedSize = CGSize(width: maxWidth, height: maxHeight)
//        let estimatedTextRect = attributedText.boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, context: nil)
//
//        let textRect = CGRect(
//            x: (userInput.x * image.scale) - (estimatedTextRect.width / 2),
//            y: (userInput.y * image.scale) - (estimatedTextRect.height / 2),
//            width: estimatedTextRect.width,
//            height: estimatedTextRect.height
//        )
//
//        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//
//        attributedText.draw(in: textRect)
//        UIGraphicsEndImageContext()
//        photoEdited = true
//
//        imageView.image = renderedImage
//    }
    
    /// Used for debugging (text isn't rendering in image)
    func addRedBox(to frame: CGRect) {
        let view = UIView()
        view.frame = frame.integral
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 2
        imageView.addSubview(view)
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
        let image = imageView.image
//        networkManager.uploadImage(imageData: (image?.pngData())!)
//        networkManager.uploadImage(imageData: (image?.pngData())!, imageOriginalURL: imageURL!)
    }
    
    @objc func presetFilterAction() {
        let filterChoices = FilterType.allCases
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Original Photo", style: .default, handler: { (_) in
            self.imageView.image = self.imageView.image
        }))
        
        for choice in filterChoices {
            let filterAction = UIAlertAction(title: choice.names, style: .default) { (_) in
                self.imageView.image = self.imageView.image?.addFilterToImage(filter: choice)
            }
            alert.addAction(filterAction)
        }
        
        
//        alert.addAction(UIAlertAction(title: "Mono", style: .default, handler: { (_) in
//            self.imageView.image = self.imageView.image?.addFilterToImage(filter: .mono)
//        }))
//        alert.addAction(UIAlertAction(title: "Sepia", style: .default, handler: { (_) in
//            self.imageView.image = self.imageView.image?.addFilterToImage(filter: .sepia)
//        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func imageTapped() {
        let alertController = UIAlertController(title: "Enter Text \n\n\n\n", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            let entertedText = self.textView.text
//            self.addText(text: entertedText)
            self.addTextToImage(text: entertedText)
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }
        alertController.addAction(saveAction)
        
        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        
        textView.backgroundColor = UIColor.lightGray
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        alertController.view.addSubview(self.textView)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90
                
                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
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
        
        filterButtons.addArrangedSubview(presetFilterButton)
        view.addSubview(filterButtons)
        NSLayoutConstraint.activate([
            filterButtons.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: standardPadding),
            filterButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: standardPadding),
            filterButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -standardPadding)
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
