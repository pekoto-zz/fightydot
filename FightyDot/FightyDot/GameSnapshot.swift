//
//  GameState.swift
//  FightyDot
//
//  Created by Graham McRobbie on 11/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Used as nodes in a minimax tree to calculate the best
//  possible move. Nine men's morris is different from
//  e.g., chess or noughts and crosses, since you can both
//  place and move pieces. So the game state needs to include
//  the players' hands as well as the state of the board.
//

import Foundation

class GameSnapshot {
  
    private var _board: Board
    private var _currentPlayer: Player
    private var _opponent: Player
    
    private var _millFormedLastTurn: Bool
    
    var heuristicEvaluation: Int {
        get {
            return evaluateHeuristics()
        }
    }
    
    init(board: Board, currentPlayer: Player, opponent: Player, millFormedLastTurn: Bool = false) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
        _millFormedLastTurn = millFormedLastTurn
    }
    
    // Return the possible based on the state of this game
    func getPossibleMoves() -> [Move] {
        var possibleMoves: [Move] = []
        
        if(_millFormedLastTurn) {
            possibleMoves = getTakingMoves()
        } else if (_currentPlayer.state == .PlacingPieces) {
            possibleMoves = getPlacementMoves()
        } else if (_currentPlayer.state == .MovingPieces) {
            possibleMoves = getMovementMoves()
        } else if (_currentPlayer.state == .FlyingPieces) {
            possibleMoves = getFlyingMoves()
        } else if (_currentPlayer.state == .GameOver) {
            possibleMoves = []
        }
        
        return possibleMoves
    }
    
    // What the game will look like if we make this move
    // (We need to store every game state for ranking -- hence why we clone())
    func make(move: Move) -> GameSnapshot {
        
        let board = _board.clone()
        let currentPlayer = _currentPlayer.clone(to: board)
        let opponent = _opponent.clone(to: board)
        
        let nextPlayer: Player
        let nextOpponent: Player
        var millFormed = false
        
        switch (move.type) {
        case .PlacePiece:
            millFormed = currentPlayer.playPiece(node: move.targetNode)
        case .MovePiece, .FlyPiece:
            millFormed = currentPlayer.movePiece(from: move.targetNode, to: move.destinationNode!)
        case .TakePiece:
            opponent.losePiece(node: move.targetNode)
        }
        
        if(millFormed) {
            nextPlayer = currentPlayer
            nextOpponent = opponent
        } else {
            nextPlayer = opponent
            nextOpponent = currentPlayer
        }
        
        return GameSnapshot(board: board, currentPlayer: nextPlayer, opponent: nextOpponent, millFormedLastTurn: millFormed)
    }
    
    // MARK: - Private functions

    private func getPlacementMoves() -> [Move] {
        var placementMoves: [Move] = []
        
        for node in _board.getNodes(withColour: .none) {
            let move = Move(type: .PlacePiece, targetNode: node)
            placementMoves.append(move)
        }
        
        return placementMoves
    }
    
    private func getMovementMoves() -> [Move] {
        var movementMoves: [Move] = []
        
        for node in _currentPlayer.movableNodes {
            for emptyNeighbour in node.emptyNeighbours {
                let move = Move(type: .MovePiece, targetNode: node, destinationNode: emptyNeighbour)
                movementMoves.append(move)
            }
        }
        
        return movementMoves
    }
    
    private func getTakingMoves() -> [Move] {
        var takingMoves: [Move] = []
        
        for node in _opponent.takeableNodes {
            let move = Move(type: .TakePiece, targetNode: node)
            takingMoves.append(move)
        }
        
        return takingMoves
    }
    
    private func getFlyingMoves() -> [Move] {
        var flyingMoves: [Move] = []
        
        for node in _currentPlayer.movableNodes {
            for emptyNode in _board.getNodes(withColour: .none) {
                let move = Move(type: .FlyPiece, targetNode: node, destinationNode: emptyNode)
                flyingMoves.append(move)
            }
        }
        
        return flyingMoves
    }
    
    private func evaluateHeuristics() -> Int {
        let (greenPlayer, redPlayer) = getPlayers()
        var heuristicScore = 0
        
        // Red wins
        if(greenPlayer.lostGame) {
            heuristicScore = Int.min
        } // Green wins
        else if (redPlayer.lostGame) {
            heuristicScore = Int.max
        } else {
            // References: http://www.dasconference.ro/papers/2008/B7.pdf
            // Some example weights here: https://kartikkukreja.wordpress.com/2014/03/17/heuristicevaluation-function-for-nine-mens-morris/
            // https://arxiv.org/pdf/1408.0032.pdf
            
            // Possible factors (can use differences for some of these):
            // If you/your opponent closed a mill -- DONE
            // Number of morrises -- DONE
            // Number of blocked pieces -- DONE
            // Number of pieces -- DONE
            // Number of 2-piece configurations -- one way to close this mill
            // Number of 3-piece configurations -- two ways to close this mill
            // Number of double morrises -- two morrises share a common piece
            
            // (The evaluation function differs depending on game state.
            //  For exmaple, there are no blocked nodes while flying.)
        }
        
        return heuristicScore
    }
    
    private func getPlayers() -> (greenPlayer: Player, redPlayer: Player) {
        if(_currentPlayer.colour == .green) {
            return (_currentPlayer, _opponent)
        } else {
            return (_opponent, _currentPlayer)
        }
    }
}
