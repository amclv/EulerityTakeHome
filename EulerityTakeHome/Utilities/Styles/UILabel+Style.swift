//
//  UILabel+Style.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/25/21.
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    enum Style {
        case label
    }

    let style: Style

    init(style: Style, text: String) {
        self.style = style
        super.init(frame: .zero)
        self.text = text
        setupStyling()
    }

    required init?(coder: NSCoder) {
        fatalError("LABEL | init(coder:) has not been implemented")
    }

    private func setupStyling() {
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
        textColor = .label

        switch style {
        case .label:
            textAlignment = .center
        }
    }
}
