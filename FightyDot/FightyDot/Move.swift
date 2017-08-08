//
//  Move.swift
//  FightyDot
//
//  Created by Graham McRobbie on 12/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  A move that can be made for a player on the board.
//  Note: Moving and taking a piece is counted as a single move.
//

import Foundation

class Move: CustomStringConvertible {
    
    private var _type: MoveType
    private var _targetNode: Node
    private var _destinationNode: Node?
    private var _nodeToTake: Node?
    
    var type: MoveType {
        get {
            return _type
        }
    }
    
    var targetNode: Node {
        get {
            return _targetNode
        }
    }
    
    var destinationNode: Node? {
        get {
            return _destinationNode
        }
    }
    
    var nodeToTake: Node? {
        get {
            return _nodeToTake
        } set {
            _nodeToTake = newValue
        }
    }
    
    var formsMill: Bool {
        get {
            return _nodeToTake != nil
        }
    }
    
    var description: String {
        if let destinationNodeToPrint = _destinationNode {
            return "\(_targetNode.id) -> \(destinationNodeToPrint.id)"
        } else {
            return "\(_targetNode.id)"
        }
    }
    
    init(type: MoveType, targetNode: Node, destinationNode: Node? = nil, nodeToTake: Node? = nil) {
        _type = type
        _targetNode = targetNode
        _destinationNode = destinationNode
        _nodeToTake = nodeToTake
    }
}
