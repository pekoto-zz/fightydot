//
//  Node.swift
//  Ananke
//
//  Created by Graham McRobbie on 12/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import Foundation
import UIKit

class Node {
 
    private var _id: Int
    private var _neighbours: [Node]
    private var _mills: [Mill]
    private var _colour: PieceColour = PieceColour.none {
        didSet {
            _view?.animate(node: self, to: _colour)
        }
    }
    private var _activeMillCount: Int = 0 // number of active mills this node is a member of
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
    
    var emptyNeighbours: [Node] {
        get {
            return _neighbours.filter { node in node.colour == .none }
        }
    }
    
    var neighbours: [Node] {
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
        _neighbours = [Node]()
        _mills = [Mill]()
    }
    
    // For cloning
    private init(id: Int, neighbours: [Node], mills: [Mill], colour: PieceColour, activeMillCount: Int, isTappable: Bool, isDraggable: Bool) {
        _id = id
        _neighbours = neighbours
        _mills = mills
        _colour = colour
        _activeMillCount = activeMillCount
        _isTappable = isTappable
        _isDraggable = isDraggable
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
    
    func clone() -> Node {
        // TODO need to deep copy mills
        return Node(id: _id, neighbours: _neighbours, mills: _mills, colour: _colour, activeMillCount: _activeMillCount, isTappable: _isTappable, isDraggable: _isDraggable)
    }
}

// MARK: - Equatable

extension Node: Equatable {
    
    // Convenience for remove
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs === rhs
    }
}
