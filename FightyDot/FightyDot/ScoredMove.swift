//
//  ScoredMove.swift
//  FightyDot
//
//  Created by Graham McRobbie on 24/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class ScoredMove: CustomStringConvertible {
    
    private var _move: Move?
    private var _score: Int

    var move: Move? {
        get {
            return _move
        } set {
            _move = newValue
        }
    }
    
    var score: Int {
        get {
            return _score
        } set {
            _score = newValue
        }
    }
    
    var description: String {
        if let moveToPrint = move {
            return "[\(moveToPrint)] \(score)"
        } else {
            return "[nil] \(score)"
        }
    }
    
    init(move: Move?, score: Int) {
        _move = move
        _score = score
    }
    
}
