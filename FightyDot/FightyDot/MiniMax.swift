//
//  MiniMax.swift
//  FightyDot
//
//  Created by Graham McRobbie on 23/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class MiniMax: CalculateMoveProtocol {
    
    func calculateBestMove(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour) -> ScoredMove {
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: gameSnapshot.heuristicScore)
        }
        
        if (playerColour == .green) {
            var bestMove = ScoredMove(move: nil, score: Int.min)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let scoredMove = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .red)
                
                if(scoredMove.score > bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        } else /* red player */ {
            var bestMove = ScoredMove(move: nil, score: Int.max)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let scoredMove = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .green)
                
                if(scoredMove.score < bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        }
    }
    
    func calculateBestMoveWithDebugTree(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, tree: TreeNode<ScoredMove>) -> ScoredMove {
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: gameSnapshot.heuristicScore)
        }
        
        if (playerColour == .green) {
            var bestMove = ScoredMove(move: nil, score: Int.min)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let debugScoredMove = ScoredMove(move: move, score: 0)
                let childNode = tree.addChild(data: debugScoredMove)
                let scoredMove = calculateBestMoveWithDebugTree(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .red, tree: childNode)
                debugScoredMove.score = scoredMove.score
                
                if(scoredMove.score > bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        } else /* red player */ {
            var bestMove = ScoredMove(move: nil, score: Int.max)
            
            for move in gameSnapshot.getPossibleMoves() {
                let nextGameSnapshot = gameSnapshot.make(move: move)
                let debugScoredMove = ScoredMove(move: move, score: 0)
                let childNode = tree.addChild(data: debugScoredMove)
                let scoredMove = calculateBestMoveWithDebugTree(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: .green, tree: childNode)
                debugScoredMove.score = scoredMove.score
                
                if(scoredMove.score < bestMove.score) {
                    bestMove = scoredMove
                }
            }
            
            return bestMove
        }
    }
}
