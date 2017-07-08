//
//  RoundedShadowView.swift
//  Ananke
//
//  Created by Graham McRobbie on 04/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        roundCorners()
        addShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        roundCorners()
        addShadow()
    }
    
    // MARK: - Private functions
    
    private func roundCorners() {
        self.layer.cornerRadius = Constants.View.cornerRadius
    }

    private func addShadow() {
        self.clipsToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.4)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
}
