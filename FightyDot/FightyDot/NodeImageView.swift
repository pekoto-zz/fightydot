//
//  DraggableImageView.swift
//  FightyDot
//
//  Created by Graham McRobbie on 23/01/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation
import UIKit

class NodeImageView: UIImageView {

    // Image dragged around screen when moving/flying
    private var _draggableImg: UIImageView?
    // Image to restore if drag cancelled/invalid
    private var _originalImg: UIImage?
    // ImageViews this node can be dragged to
    private var _validMoveSpots: [NodeImageView]?
    // ImageViews intersecting with the draggable image
    private var _intersectingMoveSpots: [NodeImageView]?
    
    // For placing/taking pieces
    func enableTapDisableDrag() {
        self.gestureRecognizers?[Constants.View.tapGestureRecognizerIndex].isEnabled = true
        self.gestureRecognizers?[Constants.View.dragGestureRecognizerIndex].isEnabled = false
        self.isUserInteractionEnabled = true
        
        if(self.image != #imageLiteral(resourceName: "empty-node")) {
            guard let nodeImg = self.image else {
                return
            }
            
            let nodeColour = Constants.PieceDics.imgColours[nodeImg]
            
            self.addAnimatedShadow(colour: nodeColour?.cgColor)
        }
    }
    
    // For moving/flying
    func enableDragDisableTap() {
        self.gestureRecognizers?[Constants.View.dragGestureRecognizerIndex].isEnabled = true
        self.gestureRecognizers?[Constants.View.tapGestureRecognizerIndex].isEnabled = false
        self.isUserInteractionEnabled = true
        self.addAnimatedShadow()
    }
    
    func disable() {
        self.gestureRecognizers?[Constants.View.tapGestureRecognizerIndex].isEnabled = false
        self.gestureRecognizers?[Constants.View.dragGestureRecognizerIndex].isEnabled = false
        self.isUserInteractionEnabled = false
        self.removeAnimatedShadow()
    }
    
    // MARK: - UIGestureRecognizerState.began behaviours
    
    func startDragging(to validMoveSpots: [NodeImageView]) {
        _validMoveSpots = validMoveSpots
        _intersectingMoveSpots = []
        _draggableImg = createDraggableImg()
        self.topLevelView?.addSubview(_draggableImg!)
        
        _originalImg = self.image
        self.image = #imageLiteral(resourceName: "empty-node")
        
        addAnimatedShadowToMoveSpots()
    }
    
    // MARK: - UIGestureRecognizerState.changed behaviours
    
    func updatePosition(to newPos: CGPoint) {
        _draggableImg?.center = newPos
    }
    
    func updateIntersects() {
        updateIntersectingMoveSpots()
        checkForNewIntersects()
    }
    
    // MARK: - UIGestureRecognizerState.ended/cancelled behaviours
    
    func intersectsWithMoveSpot() -> Bool {
        guard let intersectingMoveSpots = _intersectingMoveSpots else {
            return false
        }
        
        return intersectingMoveSpots.count > 0
    }
    
    func getLastIntersectingMoveSpot() -> NodeImageView? {
        guard let intersectingMoveSpots = _intersectingMoveSpots else {
            return nil
        }
        
        return intersectingMoveSpots.last
    }
    
    func endDrag() {
        removeAnimatedShadowFromMoveSpots()
        resetIntersectingMoveSpots()
        _draggableImg?.removeFromSuperview()
        _draggableImg = nil
    }
    
    func resetOriginalImg () {
        self.image = _originalImg
    }

    // MARK: - Private functions
    
    private func createDraggableImg() -> UIImageView {
        let draggableImg: UIImage? = self.image
        let imageView = UIImageView(image: draggableImg)
        let framePosInSuperview = self.convert(self.bounds, to: self.topLevelView)
        
        imageView.frame = framePosInSuperview
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .center
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 18)
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowRadius = 4
        
        return imageView
    }
    
    private func addAnimatedShadowToMoveSpots() {
        guard let validMoveSpots = _validMoveSpots else {
            return
        }
        
        for moveSpot in validMoveSpots {
            moveSpot.addAnimatedShadow()
        }
    }
    
    private func removeAnimatedShadowFromMoveSpots() {
        guard let validMoveSpots = _validMoveSpots else {
            return
        }
        
        for moveSpot in validMoveSpots {
            moveSpot.removeAnimatedShadow()
        }
    }
    
    private func updateIntersectingMoveSpots() {
        guard let draggableImg = _draggableImg else {
            return
        }
        
        guard let intersectingMoveSpots = _intersectingMoveSpots else {
            return
        }
        
        var intersectingMoveSpotRemoved = false
        
        for intersectingMoveSpot in intersectingMoveSpots {
            if(!intersectingMoveSpot.intersectsIgnoringCoordinateSpace(draggableImg)) {
                removeIntersecting(moveSpot: intersectingMoveSpot)
                intersectingMoveSpotRemoved = true
            }
        }
        
        if(intersectingMoveSpotRemoved) {
            resetMoveSpotAnimations()
        }
    }
    
    private func removeIntersecting(moveSpot: NodeImageView) {
        _intersectingMoveSpots?.remove(object: moveSpot)
        _validMoveSpots?.append(moveSpot)
        moveSpot.image = #imageLiteral(resourceName: "empty-node")
    }
    
    private func resetMoveSpotAnimations() {
        guard let validMoveSpots = _validMoveSpots else {
            return
        }
        
        for moveSpot in validMoveSpots {
            moveSpot.removeAnimatedShadow()
            moveSpot.addAnimatedShadow()
        }
    }
    
    private func checkForNewIntersects() {
        guard let draggableImg = _draggableImg else {
            return
        }
        
        guard let validMoveSpots = _validMoveSpots else {
            return
        }
        
        for moveSpot in validMoveSpots {
            if(moveSpot.intersectsIgnoringCoordinateSpace(draggableImg)) {
                addIntersecting(moveSpot: moveSpot)
            }
        }
    }
    
    private func addIntersecting(moveSpot: NodeImageView) {
        _validMoveSpots?.remove(object: moveSpot)
        moveSpot.removeAnimatedShadow()
        moveSpot.image = #imageLiteral(resourceName: "empty-node-selectable")
        _intersectingMoveSpots?.append(moveSpot)
    }
    
    private func resetIntersectingMoveSpots() {
        guard let intersectingMoveSpots = _intersectingMoveSpots else {
            return
        }
        
        for intersectingMoveSpot in intersectingMoveSpots {
            if(intersectingMoveSpot.image == #imageLiteral(resourceName: "empty-node-selectable")) {
                intersectingMoveSpot.image = #imageLiteral(resourceName: "empty-node")
            }
        }
    }
}
