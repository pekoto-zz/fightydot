//
//  GameState.swift
//  FightyDot
//
//  Created by Graham McRobbie on 11/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Used as nodes in the minimax (negamax) tree to calculate the best possible move.
//  Nine men's morris is different from, e.g., chess or noughts and crosses, since you
//  can both place and move pieces. So the game state needs to include the players' hands
//  as well as the state of the board.
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
    
    // True if the move associated with this snapshot forms a mill
    var formsMill: Bool {
        get {
            if let associatedMove = move {
                return associatedMove.formsMill
            }
            
            return false
        }
    }
    
    init(board: Board, currentPlayer: Player, opponent: Player) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
    }
    
    init(board: Board, currentPlayer: Player, opponent: Player, generatedBy move: Move? = nil) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
        _move = move
    }
    
    // Return the moves that are possible based on the state of this game
    func getPossibleMoves() throws -> [Move] {
        var possibleMoves: [Move] = []
        
        if (_currentPlayer.state == .PlacingPieces) {
            possibleMoves = try getPlacementMoves()
        } else if (_currentPlayer.state == .MovingPieces) {
            possibleMoves = try getMovementMoves()
        } else if (_currentPlayer.state == .FlyingPieces) {
            possibleMoves = try getFlyingMoves()
        } else if (_currentPlayer.state == .GameOver) {
            possibleMoves = []
        }
        
        return possibleMoves
    }
    
    // Returns the resulting game snapshot (board & player states) after a certain move is made
    // (We need to store different game snapshots for minimax/negamax ranking -- hence why we clone())
    func getNewSnapshotFrom(move: Move) throws -> GameSnapshot {
        let board = _board.clone()
        let currentPlayer = _currentPlayer.clone(to: board)
        let opponent = _opponent.clone(to: board)
        
        guard let targetNode = board.getNode(withID: move.targetNodeId) else {
            throw AIError.FailedToGetTargetNode
        }
        
        switch (move.type) {
        case .PlacePiece:
            _ = currentPlayer.playPiece(node: targetNode)
        case .MovePiece:
            guard let moveDestinationNodeId = move.destinationNodeId, let destinationNode = board.getNode(withID: moveDestinationNodeId) else {
                throw AIError.FailedToGetDestinationNode
            }

            _ = currentPlayer.movePiece(from: targetNode, to: destinationNode)
        }
        
        if(move.formsMill) {
            guard let moveNodeToTakeId = move.nodeToTakeId, let nodeToTake = board.getNode(withID: moveNodeToTakeId) else {
                throw AIError.FailedToGetNodeToTake
            }
            
            opponent.losePiece(node: nodeToTake)
        }
        
        return GameSnapshot(board: board, currentPlayer: opponent, opponent: currentPlayer, generatedBy: move)
    }
    
    func printBoard() {
        _board.printState()
    }
    
    func printScore() {
        print("{\(heuristicScore)}")
    }
    
    // MARK: - Private functions

    private func getPlacementMoves() throws -> [Move] {
        var placementMoves: [Move] = []
        
        for node in _board.getNodes(for: .none) {
            let move = Move(type: .PlacePiece, targetNodeId: node.id)
            placementMoves.append(move)
        }
        
        try placementMoves.append(contentsOf: getTakeableNodeMovesFor(moves: placementMoves))
        
        return placementMoves
    }
    
    private func getMovementMoves() throws -> [Move] {
        var movementMoves: [Move] = []
        
        for node in _currentPlayer.movableNodes {
            for emptyNeighbour in node.emptyNeighbours {
                let move = Move(type: .MovePiece, targetNodeId: node.id, destinationNodeId: emptyNeighbour.value.id)
                movementMoves.append(move)
            }
        }
        
        try movementMoves.append(contentsOf: getTakeableNodeMovesFor(moves: movementMoves))
        
        return movementMoves
    }
    
    private func getFlyingMoves() throws -> [Move] {
        var flyingMoves: [Move] = []
        
        for node in _currentPlayer.movableNodes {
            for emptyNode in _board.getNodes(for: .none) {
                let move = Move(type: .MovePiece, targetNodeId: node.id, destinationNodeId: emptyNode.id)
                flyingMoves.append(move)
            }
        }
        
        try flyingMoves.append(contentsOf: getTakeableNodeMovesFor(moves: flyingMoves))
        
        return flyingMoves
    }

    // If a move forms a mill, append more moves based on the opponent
    // nodes that can be taken.
    private func getTakeableNodeMovesFor(moves: [Move]) throws -> [Move] {
        var takeableNodeMoves: [Move] = []
        
        for move in moves {
            let millFormed = try make(move: move)
            
            if(millFormed) {
                takeableNodeMoves.append(contentsOf: getTakeableNodesFor(move: move))
            }
            
            try undo(move: move)
        }
        
        return takeableNodeMoves
    }
    
    private func make(move: Move) throws -> Bool {
        let millFormed: Bool
        
        guard let targetNode = _board.getNode(withID: move.targetNodeId) else {
            throw AIError.FailedToGetTargetNode
        }
        
        switch (move.type) {
        case .PlacePiece:
            millFormed = _currentPlayer.playPiece(node: targetNode)
        case .MovePiece:
            guard let destinationNode = _board.getNode(withID: move.destinationNodeId!) else {
                throw AIError.FailedToGetDestinationNode
            }
            
            millFormed = _currentPlayer.movePiece(from: targetNode, to: destinationNode)
        }
        
        return millFormed
    }
    
    private func getTakeableNodesFor(move: Move) -> [Move] {
        var takeableNodeMoves: [Move] = []
        
        let takeableNodes = _opponent.takeableNodes
        
        if(takeableNodes.count > 0) {
            move.nodeToTakeId = takeableNodes[0].id
            
            for i in 1 ..< takeableNodes.count {
                let move = Move(type: move.type, targetNodeId: move.targetNodeId, destinationNodeId: move.destinationNodeId, nodeToTakeId: takeableNodes[i].id)
                takeableNodeMoves.append(move)
            }
        }
        
        return takeableNodeMoves
    }
    
    private func undo(move: Move) throws {
        guard let targetNode = _board.getNode(withID: move.targetNodeId) else {
            throw AIError.FailedToGetTargetNode
        }
        
        switch(move.type) {
        case .PlacePiece:
            _currentPlayer.undoPlayPiece(node: targetNode)
        case .MovePiece:
            guard let destinationNode = _board.getNode(withID: move.destinationNodeId!) else {
                throw AIError.FailedToGetDestinationNode
            }
            
            _ = _currentPlayer.movePiece(from: destinationNode, to: targetNode)
        }
    }
    
    // MARK: - Heuristic evaluation functions
    // Reference: http://www.dasconference.ro/papers/2008/B7.pdf
    
    // Returns +ve result if snapshot is favourable for green
    // Return -ve result if snapshot is favourable for red
    private func evaluateHeuristics() -> Int {
        let (greenPlayer, redPlayer) = getPlayers()
        var score = 0
        
        if(redPlayer.lostGame) {
            return Constants.WinScores.greenWin
        } else if (greenPlayer.lostGame) {
            return Constants.WinScores.redWin
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
    //  - number of mills
    //  - blocked oppoent pieces
    //  - number of pieces in play
    //  - two piece configurations (mill can be closed in 1 way)
    //  - three piece configurations (mill can be closed in 2 ways)
    //  - closed a mill
    private func calculatePlacementScore(player: Player, opponent: Player) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)
        
        var score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.PlacementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.PlacementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.PlacementPhase.piecesInPlay)
                  + (twoPieceConfigs * HeuristicWeights.PlacementPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.PlacementPhase.threePieceConfigurations)
        
        if(formsMill) {
            score = score + HeuristicWeights.PlacementPhase.closedMill
        }
        
        return score
    }
    
    // Factors:
    //  - number of mills
    //  - blocked opponent pieces
    //  - number of pieces in play
    //  - opened a mill
    //  - double mill
    //  - closed a mill
    private func calculateMovementScore(player: Player, opponent: Player) -> Int {
        var score = (_board.numOfMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.mills)
                  + (opponent.numOfBlockedNodes * HeuristicWeights.MovementPhase.blockedOpponentPieces)
                  + (player.numOfPiecesInPlay * HeuristicWeights.MovementPhase.piecesInPlay)
                  + (_board.numOfOpenMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.openMill)
                  + (_board.numOfDoubleMills(for: player.pieceColour) * HeuristicWeights.MovementPhase.doubleMill)
        
        if(formsMill) {
            score = score + HeuristicWeights.MovementPhase.closedMill
        }
        
        return score
    }
    
    // Factors:
    //  - Two piece configurations (mill can be closed in 1 way)
    //  - Three piece configurations (mill can be closed in 2 ways)
    //  - closed a mill
    private func calculateFlyingScore(player: Player, opponent: Player) -> Int {
        let(twoPieceConfigs, threePieceConfigs) = _board.numOfTwoAndThreePieceConfigurations(for: player.pieceColour)

        var score = (twoPieceConfigs * HeuristicWeights.FlyingPhase.twoPieceConfigurations)
                  + (threePieceConfigs * HeuristicWeights.FlyingPhase.threePieceConfigurations)
        
        if(formsMill) {
            score = score + HeuristicWeights.FlyingPhase.closedMill
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
}
