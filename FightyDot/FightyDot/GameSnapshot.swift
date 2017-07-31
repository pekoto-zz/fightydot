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
    
    // The move used to generate this gamesnapshot
    private var _move: Move?
    
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
    
    init(board: Board, currentPlayer: Player, opponent: Player) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
    }
    
    init(board: Board, currentPlayer: Player, opponent: Player, millFormedLastTurn: Bool = false, generatedBy move: Move? = nil) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
        _move = move
    }
    
    // Return the possible moves based on the state of this game
    func getPossibleMoves() -> [Move] {
        var possibleMoves: [Move] = []
        
        // TODO for each of the moves here, if it's made, work out if it would result in a mill being formed
        // and if it would, clone the move, adding on all the nodes that can be taken
        if (_currentPlayer.state == .PlacingPieces) {
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
        case .MovePiece:
            let destinationNode = board.getNode(withID: move.destinationNode!.id)!
            millFormed = currentPlayer.movePiece(from: targetNode, to: destinationNode)
        }
        
        if(millFormed) {
            let takeableNodes = opponent.takeableNodes
            
            if(takeableNodes.count != 0) {
                opponent.losePiece(node: takeableNodes.randomElement()!)
            }
        }
        
        nextPlayer = opponent
        nextOpponent = currentPlayer
        
        return GameSnapshot(board: board, currentPlayer: nextPlayer, opponent: nextOpponent, millFormedLastTurn: millFormed, generatedBy: move)
    }
    
    func printBoard() {
        _board.print()
    }
    
    func printScore() {
        print("{\(heuristicScore)}")
    }
    
    // MARK: - Private functions

    private func getPlacementMoves() -> [Move] {
        var placementMoves: [Move] = []
        
        for node in _board.getNodes(for: .none) {
            let move = Move(type: .PlacePiece, targetNode: node)
            placementMoves.append(move)
        }
        
        for move in placementMoves {
            let millFormed = _currentPlayer.playPiece(node: move.targetNode)
            
            // If a mill is formed, append all the possible takeable nodes
            // that result from this move.
            if(millFormed) {
                let takeableNodeMoves = getTakeableNodesFor(move: move)
                placementMoves.append(contentsOf: takeableNodeMoves)
            }
            
            // Undo move
            _ = _board.setNode(withID: move.targetNode.id, to: .none)
        }
        
        return placementMoves
    }
    
    private func getTakeableNodesFor(move: Move) -> [Move] {
        var takeableNodeMoves: [Move] = []
        
        let takeableNodes = _opponent.takeableNodes
        
        if(takeableNodes.count > 0) {
            move.nodeToTake = takeableNodes[0]
            
            for i in 1 ..< takeableNodes.count {
                let move = Move(type: move.type, targetNode: move.targetNode, destinationNode: move.destinationNode, nodeToTake: takeableNodes[i])
                takeableNodeMoves.append(move)
            }
        }
        
        return takeableNodeMoves
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
    
    private func getFlyingMoves() -> [Move] {
        var flyingMoves: [Move] = []
        
        for node in _currentPlayer.movableNodes {
            for emptyNode in _board.getNodes(for: .none) {
                let move = Move(type: .MovePiece, targetNode: node, destinationNode: emptyNode)
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
        
        if (state == .PlacingPieces) {
            score = calculatePlacementScore(player: player, opponent: opponent)
        } else if (state == .MovingPieces) {
            score = calculateMovementScore(player: player, opponent: opponent)
        } else {
            score = calculateFlyingScore(player: player, opponent: opponent)
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
    private func calculatePlacementScore(player: Player, opponent: Player) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)
        
        let score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.PlacementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.PlacementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.PlacementPhase.piecesInPlay)
                  + (twoPieceConfigs * HeuristicWeights.PlacementPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.PlacementPhase.threePieceConfigurations)
        
        return score
    }
    
    // Factors:
    //  - closed a mill
    //  - number of mills
    //  - blocked opponent pieces
    //  - number of pieces in play
    //  - opened a mill
    //  - double mill
    private func calculateMovementScore(player: Player, opponent: Player) -> Int {
        let score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.MovementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.MovementPhase.piecesInPlay)
                  + (_board.numOfOpenMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.openMill)
                  + (_board.numOfDoubleMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.doubleMill)
        
        return score
    }
    
    // Factors:
    //  - Two piece configurations (mill can be closed in 1 way)
    //  - Three piece configurations (mill can be closed in 2 ways)
    //  - closed a mill
    private func calculateFlyingScore(player: Player, opponent: Player) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)

        let score = (twoPieceConfigs * HeuristicWeights.FlyingPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.FlyingPhase.threePieceConfigurations)
        
        return score
    }
    
    private func getPlayers() -> (greenPlayer: Player, redPlayer: Player) {
        if(_currentPlayer.colour == .green) {
            return (_currentPlayer, _opponent)
        } else {
            return (_opponent, _currentPlayer)
        }
    }
}
