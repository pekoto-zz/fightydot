//
//  ScoredMove.swift
//  FightyDot
//
//  Created by Graham McRobbie on 24/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  This allows us to pass back both the score and the move from NegaMax.
//  Most implementations will just pass back a score, which is not much use by itself.
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
