//
//  MiniMax.swift
//  FightyDot
//
//  Created by Graham McRobbie on 23/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class MiniMax {
    
    static func calculateBestMove(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour) -> ScoredMove {
        if(depth == 0 || gameSnapshot.isInEndState) {
            print("Score: \(gameSnapshot.heuristicScore) Depth: \(depth)")
            return ScoredMove(move: gameSnapshot.move, score: gameSnapshot.heuristicScore)
        }
        
        if (playerColour == .green) {
            var bestMove = ScoredMove(move: nil, score: Int.min)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                print("Green move get... Depth: \(depth)")
                let scoredMove = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .red)
                print("Green move done. Depth: \(depth)")
                
                if(scoredMove.score > bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        } else /* red player */ {
            var bestMove = ScoredMove(move: nil, score: Int.max)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                
                print("Red move get... Depth: \(depth)")
                let scoredMove = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .green)
                print("Red move done. Depth: \(depth)")
                
                if(scoredMove.score < bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        }
    }
}
