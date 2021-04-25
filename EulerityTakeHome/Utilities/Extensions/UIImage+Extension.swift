//
//  UIImage+Extension.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/24/21.
//

import Foundation
import UIKit

enum FilterType: String, CaseIterable {
    case sepia = "CISepiaTone"
    case mono = "CIPhotoEffectMono"
    case chrome = "CIPhotoEffectChrome"
    case fade = "CIPhotoEffectFade"
    case instant = "CIPhotoEffectInstant"
    case noir = "CIPhotoEffectNoir"
    case process = "CIPhotoEffectProcess"
    case tonal = "CIPhotoEffectTonal"
    case transfer = "CIPhotoEffectTransfer"
    
    var names: String {
        switch self {
        case .sepia:
            return "Sepia"
        case .mono:
            return "Mono"
        case .chrome:
            return "Chrome"
        case .fade:
            return "Fade"
        case .instant:
            return "Instant"
        case .noir:
            return "Noir"
        case .process:
            return "Process"
        case .tonal:
            return "Tonal"
        case .transfer:
            return "Transfer"
        }
    }
}

extension UIImage {
    /// Adds filter image from the selected filter.
    /// - Parameter filter: Filter comes from the FilterType enum
    /// - Returns: Returns UIImage that has been processed with a new filter.
    func addFilterToImage(filter: FilterType) -> UIImage {
        let filter = CIFilter(name: filter.rawValue)
        
        // Convert UIImage to CIImage
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        // Get output CIImage, render as CGImage to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        
        // Be nice to move this out and make it viable to a lot more functions because it takes a lot of resources.
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        
        // Return image
        return UIImage(cgImage: cgImage!, scale: self.scale, orientation: self.imageOrientation)
    }
}
