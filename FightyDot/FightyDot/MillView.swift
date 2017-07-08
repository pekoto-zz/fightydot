//
//  MillImageView.swift
//  Ananke
//
//  Created by Graham McRobbie on 07/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import UIKit

class MillView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setColourEmpty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setColourEmpty()
    }
    
    func animate(to newColour: UIColor, completion: (() -> ())?) {
        let constraintId = getConstraintId()
        let animationDirection = getAnimationDirection()
        
        self.updateConstraintWith(id: constraintId, to: Constants.Constraints.activeMillThickness)
        self.changeColour(to: newColour, direction: animationDirection) {
            completion?()
        }
    }
    
    func reset() {
        let constraintId = getConstraintId()
        var animationDirection = getAnimationDirection()
        animationDirection.reverse()
        
        self.updateConstraintWith(id: constraintId, to: Constants.Constraints.defaultMillThickness)
        self.changeColour(to: Constants.Colours.emptyMillColour, direction: animationDirection)
    }
    
    // MARK: - Private functions

    // Used to normalize colour space (required when comparing colours)
    private func setColourEmpty() {
        self.backgroundColor = Constants.Colours.emptyMillColour
    }
    
    // Vertical views change their width, horizontal views change their height
    private func getConstraintId() -> String {
        if(isVerticalMill()) {
            return Constants.Constraints.widthId
        } else {
            return Constants.Constraints.heightId
        }
    }
    
    private func getAnimationDirection() -> AnimationDirection {
        if(isVerticalMill()) {
            if(isTopMillHalf()) {
                return .Up
            } else {
                return.Down
            }
        } else {
            if(isLeftMillHalf()) {
                return .Left
            } else {
                return .Right
            }
        }
    }
    
    private func isTopMillHalf() -> Bool {
        return (self.tag % 2) == 0
    }
    
    private func isLeftMillHalf() -> Bool {
        return (self.tag % 2) == 0
    }
    
    private func isVerticalMill() -> Bool {
        return getParentId() >= Constants.GameplayNumbers.verticalMillStartIndex
    }
    
    // A single mill is made of two images.
    // So to get the parent ID of the images, we just divide by 2.
    private func getParentId() -> Int {
        return self.tag/2
    }
}
