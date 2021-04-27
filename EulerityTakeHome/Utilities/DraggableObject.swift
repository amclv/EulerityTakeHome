//
//  DraggableObject.swift
//  EulerityTakeHome
//
//  Created by Aaron Cleveland on 4/27/21.
//

import Foundation
import UIKit

class DraggableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        #warning("Pleae remove if you dont want to see the test window")
        self.layer.borderColor = UIColor.yellow.cgColor
        self.layer.borderWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self.superview)
        if (location != nil) {
            self.frame.origin = CGPoint(x: location!.x - self.frame.size.width / 2,
                                        y: location!.y - self.frame.size.height / 2)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}
