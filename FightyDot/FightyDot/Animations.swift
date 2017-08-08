//
//  Animations.swift
//  FightyDot
//
//  Created by Graham McRobbie on 01/01/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func popTo(img: UIImage) {
        self.image = img
        pop()
    }
}

extension UIView {
    
    func addAnimatedShadow(colour: CGColor? = nil) {
        addShadow(colour: colour)
        animateShadow()
    }
    
    func addShadow(colour: CGColor? = nil) {
        if let userColour = colour {
            self.layer.shadowColor = userColour
        } else {
            self.layer.shadowColor = Constants.Colours.defaultGlowColour.cgColor
        }
        
        self.clipsToBounds = false
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 1.0
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
    
    func animateShadow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = 0
        animation.toValue = 1.0
        animation.repeatCount = .infinity
        animation.duration = 0.7
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.layer.add(animation, forKey: Constants.AnimationKeys.glowingShadow)
    }
    
    func removeAnimatedShadow() {
        self.layer.shadowOpacity = 0.0
        self.layer.removeAnimation(forKey: Constants.AnimationKeys.glowingShadow)
    }
    
    func changeColour(to newColour: UIColor, direction: AnimationDirection, completion: (() -> ())? = nil) {
        let layer = CAGradientLayer()
        
        guard let currentColour = self.backgroundColor?.cgColor else {
            return
        }
        
        // Improves the visuals when animating opaque -> transparent colour
        if(newColour.cgColor.alpha < 1) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(newColour.cgColor.alpha)
        }
        
        layer.colors = [newColour.cgColor, currentColour]
        layer.locations = [0.0, 0.0]
        
        let animationPoints = getStartPointEnd(for: direction)
        layer.startPoint = animationPoints.0
        layer.endPoint = animationPoints.1
        
        layer.frame = self.bounds
        
        self.layer.addSublayer(layer)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.backgroundColor = newColour
            layer.removeFromSuperlayer()
            if let completionBlock = completion {
                completionBlock()
            }
        })
        
        let anim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        anim.fromValue = [0.0, 0.0]
        anim.toValue = [1.0, 2.0]
        anim.duration = 0.4
        layer.add(anim, forKey: Constants.AnimationKeys.locations)
        layer.locations = [1.0, 2.0]
        CATransaction.commit()
    }
    
    func fadeIn(toAlpha: CGFloat) {
        self.alpha = 0.0
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [],
            animations: {
                self.alpha = toAlpha
        })
    }
    
    func fall(completion: (() -> ())?) {
        // Fall off screen...
        let translation = CGAffineTransform(translationX: 1.0, y: 600.0)
        // ...while rotating
        let rotatation = CGAffineTransform(rotationAngle: 15 * CGFloat(Double.pi/180))
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveLinear,
            animations: { [weak self] in
                if let _self = self {
                    _self.transform = rotatation.concatenating(translation)
                }
            }, completion: { finished in
                completion?()
        })
    }
    
    func pop() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.duration = 0.7
        animation.isAdditive = true
        self.layer.add(animation, forKey: Constants.AnimationKeys.pop)
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [UIViewAnimationOptions.curveLinear],
                        animations: { }
        )
    }
    
    func zoomIn() {
        self.isHidden = false
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        zoom(alpha: 1.0, scale: 1.0, completion: nil)
    }
    
    func zoomOut() {
        self.alpha = 1.0
        zoom(alpha: 0.0, scale: 2.0) {
            self.isHidden = true
        }
    }
    
    // MARK: - Private functions
    
    /////////////////////////////////////////////////
    //
    //      Animation directions:
    //
    //      0, 0 ---- 1, 0
    //       |          |
    //       |          |
    //      0, 1 ---- 1, 1
    //
    //      .Up    (bottom to top) = (1, 1) -> (1, 0)
    //      .Down  (top to bottom) = (1, 0) -> (1, 1)
    //      .Left  (right to left) = (1, 1) -> (0, 1)
    //      .Right (left to right) = (0, 1) -> (1, 1)
    //
    /////////////////////////////////////////////////
    private func getStartPointEnd(for direction: AnimationDirection) -> (CGPoint, CGPoint) {
        var startPoint: CGPoint
        var endPoint: CGPoint
        
        switch(direction) {
        case .Up:
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        case .Down:
            startPoint = CGPoint(x: 1.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        case .Left:
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        case .Right:
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        return (startPoint, endPoint)
    }
    
    private func zoom(alpha: CGFloat, scale: CGFloat, completion: (() -> ())?) {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: .curveLinear,
            animations: { [weak self] in
                if let _self = self {
                    _self.alpha = alpha
                    _self.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }, completion: { finished in
                completion?()
        })
    }
}
