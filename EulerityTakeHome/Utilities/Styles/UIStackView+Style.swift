//
//  UIStackView+Style.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/25/21.
//

import Foundation
import UIKit

class CustomStackView: UIStackView {
    enum Style {
        case horizontal, vertical
    }
    
    enum Distribution {
        case fill, equalSpacing, equalCentering, fillEqually, fillProportionally, `nil`
    }
    
    enum Alignment {
        case top, bottom, trailing, leading, lastBaseline, firstBaseline, fill, center, `nil`
    }
    
    let style: Style
    
    init(style: Style, distribution: UIStackView.Distribution, alignment: UIStackView.Alignment) {
        self.style = style
        super.init(frame: .zero)
        self.distribution = distribution
        self.alignment = alignment
        setupStyling()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyling() {
        translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .horizontal:
            axis = .horizontal
        case .vertical:
            axis = .vertical
        }
    }
}
