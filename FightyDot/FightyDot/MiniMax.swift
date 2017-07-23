//
//  MiniMax.swift
//  FightyDot
//
//  Created by Graham McRobbie on 23/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class MiniMax {
    
    private var _bestMove: Move?
    
    var bestMove: Move? {
        get {
            return _bestMove
        }
    }
    
    func calculateBestMove(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour) -> Int {
        if(depth == 0 || gameSnapshot.isInEndState) {
            return gameSnapshot.heuristicScore
        }
        
        if (playerColour == .green) {
            var bestValue = Int.min
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let value = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .red)
                if(value > bestValue) {
                    bestValue = value
                    _bestMove = move
                }
            }
            
            return bestValue
        } else /* red player */ {
            var bestValue = Int.max
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let value = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .green)
                if(value < bestValue) {
                    bestValue = value
                    _bestMove = move
                }
            }
            
            return bestValue
        }
    }
}
