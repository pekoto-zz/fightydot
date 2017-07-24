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
    private var _move: Move?    // Used to return associated move in minimax
    
    private var _millFormedLastTurn: Bool
    
    var heuristicScore: Int {
        get {
            return evaluateHeuristics()
        }
    }
    
    var isInEndState: Bool {
        get {
            return _currentPlayer.lostGame || _opponent.lostGame
        }
    }
    
    var move: Move? {
        get {
            return _move
        }
    }
    
    init(board: Board, currentPlayer: Player, opponent: Player, millFormedLastTurn: Bool = false) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
        _millFormedLastTurn = millFormedLastTurn
    }
    
    // Return the possible moves based on the state of this game
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
    
    // Returns the resulting game snapshot (board & player states) after a certain move is made
    // (We need to store every game state for minimax ranking -- hence why we clone())
    func make(move: Move) -> GameSnapshot {
        _move = move
        
        let board = _board.clone()
        let currentPlayer = _currentPlayer.clone(to: board)
        let opponent = _opponent.clone(to: board)
        
        let targetNode = board.getNode(withID: move.targetNode.id)!
        
        let nextPlayer: Player
        let nextOpponent: Player
        var millFormed = false
        
        switch (move.type) {
        case .PlacePiece:
            millFormed = currentPlayer.playPiece(node: targetNode)
        case .MovePiece, .FlyPiece:
            let destinationNode = board.getNode(withID: move.destinationNode!.id)!
            millFormed = currentPlayer.movePiece(from: targetNode, to: destinationNode)
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
        
        for node in _board.getNodes(for: .none) {
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
            for emptyNode in _board.getNodes(for: .none) {
                let move = Move(type: .FlyPiece, targetNode: node, destinationNode: emptyNode)
                flyingMoves.append(move)
            }
        }
        
        return flyingMoves
    }

    // Reference: http://www.dasconference.ro/papers/2008/B7.pdf
    // Returns Int.max if green is in a winning position (red lost)
    // Return Int.min if red is in a winning position (green lost)
    // Returns green score - red score otherwise
    private func evaluateHeuristics() -> Int {
        let (greenPlayer, redPlayer) = getPlayers()
        var score = 0
        
        if(redPlayer.lostGame) {
            return Int.max
        } else if (greenPlayer.lostGame) {
            return Int.min
        } else {
            let greenPlayerScore = getScorefor(player: greenPlayer, opponent: redPlayer)
            let redPlayerScore = getScorefor(player: redPlayer, opponent: greenPlayer)
            
            score = greenPlayerScore - redPlayerScore
        }
        
        return score
    }
    
    private func getScorefor(player: Player, opponent: Player) -> Int {
        var score = 0
        
        let state = player.state
        let millClosedLastTurn = closedMillLastTurn(player: player)
        
        if (state == .PlacingPieces) {
            score = calculatePlacementScore(player: player, opponent: opponent, millClosedLastTurn: millClosedLastTurn)
        } else if (state == .MovingPieces) {
            score = calculateMovementScore(player: player, opponent: opponent, millClosedLastTurn: millClosedLastTurn)
        } else {
            score = calculateFlyingScore(player: player, opponent: opponent, millClosedLastTurn: millClosedLastTurn)
        }
        
        return score
    }
    
    // Factors:
    //  - closed a mill
    //  - number of mills
    //  - blocked oppoent pieces
    //  - number of pieces in play
    //  - two piece configurations (mill can be closed in 1 way)
    //  - three piece configurations (mill can be closed in 2 ways)
    private func calculatePlacementScore(player: Player, opponent: Player, millClosedLastTurn: Bool) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)
        
        var score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.PlacementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.PlacementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.PlacementPhase.piecesInPlay)
                  + (twoPieceConfigs * HeuristicWeights.PlacementPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.PlacementPhase.threePieceConfigurations)
        
        if(millClosedLastTurn) {
            score += HeuristicWeights.PlacementPhase.closedMill
        }
        
        return score
    }
    
    // Factors:
    //  - closed a mill
    //  - number of mills
    //  - blocked opponent pieces
    //  - number of pieces in play
    //  - TODO opened a mill
    //  - double mill
    private func calculateMovementScore(player: Player, opponent: Player, millClosedLastTurn: Bool) -> Int {
        var score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.MovementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.MovementPhase.piecesInPlay)
                  + (_board.numOfDoubleMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.doubleMill)
        
        if(millClosedLastTurn) {
            score += HeuristicWeights.MovementPhase.closedMill
        }
        
        return score
    }
    
    // Factors:
    //  - Two piece configurations (mill can be closed in 1 way)
    //  - Three piece configurations (mill can be closed in 2 ways)
    //  - closed a mill
    private func calculateFlyingScore(player: Player, opponent: Player, millClosedLastTurn: Bool) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)

        var score = (twoPieceConfigs * HeuristicWeights.FlyingPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.FlyingPhase.threePieceConfigurations)
        
        if(millClosedLastTurn) {
            score += HeuristicWeights.FlyingPhase.closedMill
        }
        
        return score
    }
    
    private func getPlayers() -> (greenPlayer: Player, redPlayer: Player) {
        if(_currentPlayer.colour == .green) {
            return (_currentPlayer, _opponent)
        } else {
            return (_opponent, _currentPlayer)
        }
    }
    
    private func closedMillLastTurn(player: Player) -> Bool {
        return player === _currentPlayer && _millFormedLastTurn
    }
}
