//
//  ScoredMove.swift
//  FightyDot
//
//  Created by Graham McRobbie on 24/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class ScoredMove {
    
    private var _move: Move?
    private var _score: Int

    var move: Move? {
        get {
            return _move
        }
    }
    
    var score: Int {
        get {
            return _score
        }
    }
    
    init(move: Move?, score: Int) {
        _move = move
        _score = score
    }
    
}
