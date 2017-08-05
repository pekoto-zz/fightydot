//
//  NegaMaxWithPruning.swift
//  FightyDot
//
//  Created by Graham McRobbie on 05/08/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class NegaMaxWithPruning: CalculateMoveProtocol {
    
    private let _playerColourSign: [PlayerColour: Int] = [PlayerColour.green: 1, PlayerColour.red: -1]

    func calculateBestMove(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour) -> ScoredMove {
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: _playerColourSign[playerColour]! * gameSnapshot.heuristicScore)
        }
        
        let bestMove = ScoredMove(move: nil, score: Int.min)
        
        for move in gameSnapshot.getPossibleMoves() {
            let nextGameSnapshot = gameSnapshot.getNewSnapshotFrom(move: move)
            let nextPlayerColour = getNextPlayerColour(currentPlayerColour: playerColour)
            let scoredMove = calculateBestMove(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: nextPlayerColour)
            scoredMove.score = scoredMove.score.switchSign()
            
            if(scoredMove.score >= bestMove.score) {
                bestMove.move = move
                bestMove.score = scoredMove.score
            }
        }
        
        return bestMove
    }
    
    func calculateBestMoveWithDebugTree(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, tree: TreeNode<ScoredMove>) -> ScoredMove {
        return ScoredMove(move: nil, score: 0)
    }
    
    func calculateBestMoveWithPruning(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, alpha: Int, beta: Int) -> ScoredMove {
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: _playerColourSign[playerColour]! * gameSnapshot.heuristicScore)
        }
        
        let bestMove = ScoredMove(move: nil, score: Int.min)
        
        for move in gameSnapshot.getPossibleMoves() {
            let nextGameSnapshot = gameSnapshot.getNewSnapshotFrom(move: move)
            let nextPlayerColour = getNextPlayerColour(currentPlayerColour: playerColour)
            
            let scoredMove = calculateBestMoveWithPruning(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: nextPlayerColour, alpha: beta.switchSign(), beta: alpha.switchSign())
            scoredMove.score = scoredMove.score.switchSign()
            
            if(scoredMove.score >= bestMove.score) {
                bestMove.move = move
                bestMove.score = scoredMove.score
            }
            
            var alphaVal = alpha
            
            if(scoredMove.score >= alphaVal) {
                alphaVal = scoredMove.score
            }
            
            if(alphaVal >= beta) {
                break
            }
        }
        
        return bestMove
    }
    
    private func getNextPlayerColour(currentPlayerColour: PlayerColour) -> PlayerColour {
        return currentPlayerColour == .red   ? .green : .red
    }
    
}
