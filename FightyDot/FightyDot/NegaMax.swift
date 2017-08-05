//
//  NegaMax.swift
//  FightyDot
//
//  Created by Graham McRobbie on 05/08/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  This is a basic NegaMax algorithm (no pruning)
//  https://en.wikipedia.org/wiki/Negamax
//

import Foundation

class NegaMax: CalculateMoveProtocol {
    
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
        // TODO implementation
        return ScoredMove(move: nil, score: 0)
    }
    
    private func getNextPlayerColour(currentPlayerColour: PlayerColour) -> PlayerColour {
        return currentPlayerColour == .red   ? .green : .red
    }
}
