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
        //print("Alpha: \(alpha)")
        //print("Beta: \(beta)")
        
        //print("Player colour: \(playerColour)")
        
        var alphaValue = alpha
        var betaValue = beta
        
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: _playerColourSign[playerColour]! * gameSnapshot.heuristicScore)
        }
        
        let bestMove = ScoredMove(move: nil, score: Int.min)
        
        let possibleMoves = gameSnapshot.getPossibleMoves().sorted { $0.formsMill && !$1.formsMill }
        
        for move in possibleMoves {
            let nextGameSnapshot = gameSnapshot.getNewSnapshotFrom(move: move)
            let nextPlayerColour = getNextPlayerColour(currentPlayerColour: playerColour)
            
            let scoredMove = calculateBestMoveWithPruning(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: nextPlayerColour, alpha: betaValue.switchSign(), beta: alphaValue.switchSign())
            scoredMove.score = scoredMove.score.switchSign()
            //print("Score for \(playerColour) move \(move): \(scoredMove.score)")
            
            if(scoredMove.score > bestMove.score) {
                //print("Updating score for \(playerColour): \(scoredMove.score)")
                bestMove.move = move
                bestMove.score = scoredMove.score
            }
            
            // Nice warning here, because basically we should be passing this into the next
            // iteration of the loop. So copy alpha into alphaValue at the start of each call, and then use that. (I think).
            if(scoredMove.score > alphaValue) {
                //print("Updating alpha")
                alphaValue = scoredMove.score
            }
            
            if(alphaValue >= betaValue) {
                print("Pruning")
                break
                //bestMove.score = alphaValue
                //return bestMove
            }
        }
        
        return bestMove
    }
    
    // TODO or should alpha be inout parameters???
    // Hamad's code might be better than wiki's?
    /*func calculateBestMoveWithPruning(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, alpha: inout Int, beta: inout Int) -> ScoredMove {
        print("Alpha: \(alpha)")
        print("Beta: \(beta)")
        
        print("Player colour: \(playerColour)")
        
        if(depth == 0 || gameSnapshot.isInEndState) {
            return ScoredMove(move: gameSnapshot.move, score: _playerColourSign[playerColour]! * gameSnapshot.heuristicScore)
        }
        
        let bestMove = ScoredMove(move: nil, score: Int.min)
        
        for move in gameSnapshot.getPossibleMoves() {
            let nextGameSnapshot = gameSnapshot.getNewSnapshotFrom(move: move)
            let nextPlayerColour = getNextPlayerColour(currentPlayerColour: playerColour)
            
            var newAlpha = beta.switchSign()
            var newBeta = alpha.switchSign()
            
            let scoredMove = calculateBestMoveWithPruning(gameSnapshot: nextGameSnapshot, depth: depth-1, playerColour: nextPlayerColour, alpha: &newAlpha, beta: &newBeta)
            scoredMove.score = scoredMove.score.switchSign()
            print("Score for \(playerColour) move \(move): \(scoredMove.score)")
            
            if(scoredMove.score >= bestMove.score) {
                print("Updating score for \(playerColour): \(scoredMove.score)")
                bestMove.move = move
                bestMove.score = scoredMove.score
            }
            
            if(scoredMove.score >= alpha) {
                print("Updating alpha")
                alpha = scoredMove.score
            }
            
            if(alpha >= beta) {
                print("Breaking")
                // break
                bestMove.score = alpha
                return bestMove
            }
        }
        
        return bestMove
    } */
    
    private func getNextPlayerColour(currentPlayerColour: PlayerColour) -> PlayerColour {
        return currentPlayerColour == .red   ? .green : .red
    }
    
}
