//
//  Move.swift
//  FightyDot
//
//  Created by Graham McRobbie on 12/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class Move {
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
    
    init(type: MoveType, targetNode: Node, destinationNode: Node? = nil) {
        _type = type
        _targetNode = targetNode
        _destinationNode = destinationNode
    }
}
