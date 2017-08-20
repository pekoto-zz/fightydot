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
    private var _targetNodeId: Int
    private var _destinationNodeId: Int? = nil
    private var _nodeToTakeId: Int? = nil
    
    var type: MoveType {
        get {
            return _type
        }
    }
    
    var targetNodeId: Int {
        get {
            return _targetNodeId
        }
    }
    
    var destinationNodeId: Int? {
        get {
            return _destinationNodeId
        }
    }
    
    var nodeToTakeId: Int? {
        get {
            return _nodeToTakeId
        } set {
            _nodeToTakeId = newValue
        }
    }
    
    var formsMill: Bool {
        get {
            return _nodeToTakeId != nil
        }
    }
    
    var description: String {
        if let destinationNodeToPrint = _destinationNodeId {
            return "\(_targetNodeId) -> \(destinationNodeToPrint)"
        } else {
            return "\(_targetNodeId)"
        }
    }
    
    init(type: MoveType, targetNodeId: Int, destinationNodeId: Int? = nil, nodeToTakeId: Int? = nil) {
        _type = type
        _targetNodeId = targetNodeId
        _destinationNodeId = destinationNodeId
        _nodeToTakeId = nodeToTakeId
    }
}
