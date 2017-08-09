//
//  GradientView.swift
//  FightyDot
//
//  Created by Graham McRobbie on 08/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//
//  Used for the main app background.
//

import UIKit

@IBDesignable
class SkyBlueGradientView: UIView {
    
    override open class var layerClass: AnyClass {
        get {
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradient()
    }
    
    // MARK: - Private functions
    
    private func setGradient() {
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [Constants.Colours.darkBlue.cgColor, Constants.Colours.lightBlue.cgColor]
    }
}
