//
//  Move.swift
//  FightyDot
//
//  Created by Graham McRobbie on 12/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class Move: CustomStringConvertible {
    private var _type: MoveType
    private var _targetNode: Node
    private var _destinationNode: Node?
    
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
    
    var description: String {
        if let destinationNodeToPrint = _destinationNode {
            return "\(_targetNode.id) -> \(destinationNodeToPrint.id)"
        } else {
            return "\(_targetNode.id)"
        }
    }
    
    init(type: MoveType, targetNode: Node, destinationNode: Node? = nil) {
        _type = type
        _targetNode = targetNode
        _destinationNode = destinationNode
    }
    
    func clone() -> Move {
        let targetNodeClone = Node(id: _targetNode.id, view: nil)
        
        if let destinationNodeClone = destinationNode {
            return Move(type: _type, targetNode: targetNodeClone, destinationNode: destinationNodeClone)
        } else {
            return Move(type: _type, targetNode: targetNodeClone)
        }
    }
}
