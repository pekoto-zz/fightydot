//
//  NegaMaxWithPruning.swift
//  FightyDot
//
//  Created by Graham McRobbie on 05/08/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  A negamax implementation with alpha/beta pruning
//  https://en.wikipedia.org/wiki/Negamax
//

import Foundation

class NegaMaxWithPruning {
    
    private let _playerColourSign: [PlayerColour: Int] = [PlayerColour.green: 1, PlayerColour.red: -1]
    
    func calculateBestMoveWithPruning(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, alpha: Int, beta: Int) throws -> ScoredMove {
        var alphaValue = alpha
        let betaValue = beta
        
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: _playerColourSign[playerColour]! * gameSnapshot.heuristicScore)
        }
        
        let bestMove = ScoredMove(move: nil, score: Int.min)
        
        // Get the possible moves and sort them.
        // Moves that form mills are probably best. We can use that heuristic to optimize a bit.
        let possibleMoves = gameSnapshot.getPossibleMoves().sorted { $0.formsMill && !$1.formsMill }
        
        for move in possibleMoves {
            // Make the move and get a new game snapshot
            let nextGameSnapshot = try gameSnapshot.getNewSnapshotFrom(move: move)
            let nextPlayerColour = getNextPlayerColour(currentPlayerColour: playerColour)
            
            // Basically do an adversarial search to work out what the best position is for each player
            let scoredMove = try calculateBestMoveWithPruning(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: nextPlayerColour, alpha: betaValue.switchSign(), beta: alphaValue.switchSign())
            scoredMove.score = scoredMove.score.switchSign()
            
            if(scoredMove.score > bestMove.score) {
                bestMove.move = move
                bestMove.score = scoredMove.score
            }
            
            if(scoredMove.score > alphaValue) {
                alphaValue = scoredMove.score
            }
            
            if(alphaValue >= betaValue) {
                // Pruning tree here
                break
            }
        }
        
        return bestMove
    }
    
    // MARK: - Private functions
    
    private func getNextPlayerColour(currentPlayerColour: PlayerColour) -> PlayerColour {
        return currentPlayerColour == .red   ? .green : .red
    }
    
}
