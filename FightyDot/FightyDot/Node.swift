//
//  Node.swift
//  FightyDot
//
//  Created by Graham McRobbie on 12/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//
//  A node (spot) on the board
//

import Foundation
import UIKit

class Node {
 
    private var _id: Int
    private var _neighbours: [Unowned<Node>]
    private var _mills: [Mill]
    private var _colour: PieceColour = PieceColour.none {
        didSet {
            _view?.animate(node: self, to: _colour)
        }
    }
    
    // number of active mills this node is a member of
    private var _activeMillCount: Int = 0
    private var _isTappable: Bool = true {
        didSet {
            if(_isTappable) {
                _view?.enableTapDisableDragFor(node: self)
            }
        }
    }
    private var _isDraggable: Bool = false {
        didSet {
            if(_isDraggable) {
                _view?.enableDragDisableTapFor(node: self)
            }
        }
    }
    weak private var _view: EngineDelegate?
    
    var colour: PieceColour {
        get {
            return _colour
        }
    }
    
    var emptyNeighbours: [Unowned<Node>] {
        get {
            
            return _neighbours.filter { node in node.value.colour == .none }
        }
    }
    
    var blocked: Bool {
        get {
            return emptyNeighbours.count == 0
        }
    }
    
    var neighbours: [Unowned<Node>] {
        get {
            return _neighbours
        } set {
            _neighbours = newValue
        }
    }
    
    var mills: [Mill] {
        get {
            return _mills
        } set {
            _mills = newValue
        }
    }
    
    var inActiveMill: Bool {
        get {
            return _activeMillCount > 0
        }
    }
    
    func incrementActiveMillCount() {
        _activeMillCount = _activeMillCount + 1;
    }
    
    func decrementActiveMillCount() {
        _activeMillCount = _activeMillCount - 1;
    }
    
    var id: Int {
        get {
            return _id
        }
    }
    
    var hasEmptyNeighbours: Bool {
        get {
            return emptyNeighbours.count > 0
        }
    }
    
    var isTappable: Bool {
        get {
            return _isTappable
        } set {
            _isTappable = newValue
        }
    }
    
    var isDraggable: Bool {
        get {
            return _isDraggable
        } set {
            _isDraggable = newValue
        }
    }
    
    init(id: Int, view: EngineDelegate?) {
        _id = id
        _view = view
        _neighbours = [Unowned<Node>]()
        _mills = [Mill]()
    }
    
    func disable() {
        _isTappable = false
        _isDraggable = false
        _view?.disableInteractionFor(node: self)
    }
    
    func reset() {
        _colour = PieceColour.none
        _isTappable = true
        _isDraggable = false
        _activeMillCount = 0
    }
    
    // Returns true if mill formed
    // A mill is formed when all 3 nodes in that mill have the same colour
    // Every node exists in 2 mills
    func setColour(newColour: PieceColour) -> Bool {
        var millFormedResult: Bool = false
        
        for mill in mills {
            let millFormed = mill.updatePieceCounts(oldColour: _colour, newColour: newColour)
            
            if(millFormed) {
                millFormedResult = true
            }
        }
        
        _colour = newColour
        
        return millFormedResult
    }
    
    func printColour() -> String {
        if(_colour == .none) {
            return "O"
        } else if (_colour == .green) {
            return "g"
        } else {
            return "r"
        }
    }
    
    func copyValues(from otherNode: Node) {
        _colour = otherNode._colour
        _activeMillCount = otherNode._activeMillCount
        _isTappable = otherNode._isTappable
        _isDraggable = otherNode._isDraggable
    }
    
}

// MARK: - Equatable

extension Node: Equatable {
    
    // Convenience for remove
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs === rhs
    }
}
