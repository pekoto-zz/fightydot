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

    init(board: Board, currentPlayer: Player, opponent: Player) {
        _board = board
        _currentPlayer = currentPlayer
        _opponent = opponent
    }
    
    func getPossibleMoves() -> [Move] {
        var possibleMoves: [Move]
        
        let state = _currentPlayer.state
        
        switch (state) {
        case .PlacingPieces:
            possibleMoves = getPlacementMoves()
        case .MovingPieces, .MovingPieces_PieceSelected:
            possibleMoves = getMovementMoves()
        case .TakingPiece:
            possibleMoves = getTakingMoves()
        case .FlyingPieces, .FlyingPieces_PieceSelected:
            possibleMoves = getFlyingMoves()
        case .GameOver:
            possibleMoves = []
        }
        
        return possibleMoves
    }
    
    func make(move: Move) -> GameSnapshot? {
        // TODO: clone board/players and update them based on move
        // TODO: GameSnapshot(board...update, opponent, currentPlayer)    (switch player argument order)
        return nil
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
}
