//
//  Extensions.swift
//  FightyDot
//
//  Created by Graham McRobbie on 30/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension Collection where Index == Int {
    func randomElement() -> Iterator.Element? {
        let randomIndex = Int(arc4random_uniform(UInt32(endIndex)))
        return isEmpty ? nil : self[randomIndex]
    }
}

extension Int {
    
    func isInIdRange() -> Bool {
        return self >= 0 && self < Constants.GameplayNumbers.numOfNodes
    }
    
    func switchSign() -> Int {
        // Int.min * -1 will crash in Swift 3
        // Possibly because Int.min is 1 less than Int.max
        if(self == Int.min) {
            return Int.max
        } else {
            return self * -1
        }
    }
}

extension UIImage{
    
    func alpha(value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIView {
    
    func intersectsIgnoringCoordinateSpace(_ view2: UIView) -> Bool {
        let boundsInView2CoordinaeSpace = self.convert(self.bounds, to: view2)
        return boundsInView2CoordinaeSpace.intersects(view2.bounds)
    }
    
    func updateConstraintWith(id: String, to newValue: CGFloat) {
        guard let constraint = self.constraints.filter( { c in return c.identifier == id }).first else {
            return
        }
        
        constraint.constant = newValue
    }
    
    var topLevelView: UIView? {
        get {
            var topView = self.superview
            
            while(topView?.superview != nil) {
                topView = topView?.superview
            }
            
            return topView
        }
    }
}

extension UIViewController {
    
    func showAlert(title: String, message: String, completion: (() -> ())?) {
        guard let alertView = self.storyboard!.instantiateViewController(withIdentifier: Constants.View.alertVCStoryboardId) as? AlertVC else {
            return
        }
        
        alertView.header = title
        alertView.message = message
        alertView.completion = {
            completion?()
        }
        
        alertView.modalPresentationStyle = .overCurrentContext
        self.present(alertView, animated: false, completion: nil)
    }
    
    func showAlert(title: String, message: String, confirmBtnTitle: String, completion: (() -> ())?) {
        guard let alertView = self.storyboard!.instantiateViewController(withIdentifier: Constants.View.alertVCStoryboardId) as? AlertVC else {
            return
        }
        
        alertView.header = title
        alertView.message = message
        alertView.confirmBtnTitle = confirmBtnTitle
        alertView.completion = {
            completion?()
        }
        
        alertView.modalPresentationStyle = .overCurrentContext
        self.present(alertView, animated: false, completion: nil)
    }
}
