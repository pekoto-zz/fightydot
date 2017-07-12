//
//  Player.swift
//  Ananke
//
//  Created by Graham McRobbie on 14/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import Foundation

class Player {
    
    private var _name: String
    private var _colour: PlayerColour
    private var _type: PlayerType
    private var _piecesOnBoard: [Node] = []
    private var _playerNum: PlayerNumber
    private var _isStartingPlayer: Bool
    private var _isCurrentPlayer: Bool {
        didSet {
            _view?.update(isCurrentPlayer: _isCurrentPlayer)
        }
    }
    private var _piecesLeftToPlay = Constants.GameplayNumbers.startingPieces {
        didSet {
            _view?.updateNumOfVisibleCounters(to: _piecesLeftToPlay)
        }
    }
    weak private var _view: PlayerDelegate?
    
    var name: String {
        get {
            return _name
        }
    }

    var colour: PlayerColour {
        get {
            return _colour
        }
    }
    
    var type: PlayerType {
        get {
            return _type
        }
    }
    
    var pieceColour: PieceColour {
        get {
            return PieceColour(rawValue: _colour.rawValue)!
        }
    }
    
    var playerNumInitial: String {
        get {
            return String(_playerNum.rawValue + 1)
        }
    }
    
    var isStartingPlayer: Bool {
        get {
            return _isStartingPlayer
        }
    }
    
    var isCurrentPlayer: Bool {
        get {
            return _isCurrentPlayer
        } set {
            _isCurrentPlayer = newValue
        }
    }
    
    var piecesLeftToPlay: Int {
        get {
            return _piecesLeftToPlay
        }
    }
    
    var movableNodes: [Node] {
        get {
            if(canFly()) {
                return _piecesOnBoard
            } else {
                return _piecesOnBoard.filter{ (node) in node.hasEmptyNeighbours }
            }
        }
    }
    
    var hasTakeableNodes: Bool {
        return takeableNodes.count > 0
    }
    
    var takeableNodes: [Node] {
        get {
            // Players must take pieces not in mills first
            let piecesNotInMill: [Node] = _piecesOnBoard.filter { (node) in !node.inActiveMill }
        
            // If all pieces are in mills, they can take any piece
            if(piecesNotInMill.count == 0) {
                return _piecesOnBoard
            } else {
                return piecesNotInMill
            }
        }
    }
    
    var state: GameState {
        get {
            if canPlacePiece() {
                return .PlacingPieces
            } else if canMove() {
              return .MovingPieces
            } else if canFly() {
                return .FlyingPieces
            } else {
                return .GameOver
            }
        }
    }
    
    var view: PlayerDelegate? {
        get {
            return _view
        }
    }
    
    init(name: String, colour: PlayerColour, type: PlayerType, isStartingPlayer: Bool, playerNum: PlayerNumber, view: PlayerDelegate?) throws {
        guard !name.isEmpty else {
            throw PlayerError.EmptyName
        }
        
        _name = name
        _colour = colour
        _type = type
        _playerNum = playerNum
        _isStartingPlayer = isStartingPlayer
        _isCurrentPlayer = isStartingPlayer
        _view = view
        
        _view?.setupUIFor(player: self)
    }
    
    // For cloning
    private init(name: String, colour: PlayerColour, type: PlayerType, isStartingPlayer: Bool, playerNum: PlayerNumber, piecesLeftToPlay: Int, isCurrentPlayer: Bool) {
        _name = name
        _colour = colour
        _type = type
        _isStartingPlayer = isStartingPlayer
        _playerNum = playerNum
        _piecesLeftToPlay = piecesLeftToPlay
        _isCurrentPlayer = isCurrentPlayer
    }
    
    // Returns true if mill formed
    func playPiece(node: Node) -> Bool {
        _piecesLeftToPlay = _piecesLeftToPlay - 1
        _piecesOnBoard.append(node)
        return node.setColour(newColour: pieceColour)
    }
    
    // Returns true if mill formed
    func movePiece(from oldNode: Node, to newNode: Node) -> Bool {
        losePiece(node: oldNode)
        _piecesOnBoard.append(newNode)
        return newNode.setColour(newColour: pieceColour)
    }
    
    func losePiece(node: Node) {
        _piecesOnBoard.remove(object: node)
        
        // A mill will never be formed when losing a piece
        _ = node.setColour(newColour: PieceColour.none)
    }
    
    func reset() {
        _piecesLeftToPlay = Constants.GameplayNumbers.startingPieces
        _piecesOnBoard = []
    }
    
    func clone(to board: Board) -> Player {
        let player = Player(name: _name, colour: _colour, type: _type, isStartingPlayer: _isStartingPlayer, playerNum: _playerNum, piecesLeftToPlay: _piecesLeftToPlay, isCurrentPlayer: _isCurrentPlayer)
        
        for i in 0..._piecesOnBoard.count-1 {
            let nodeId = _piecesOnBoard[i].id
            
            if let nodeToAdd = board.getNode(withID: nodeId) {
                player._piecesOnBoard.append(nodeToAdd)
            }
        }
        
        return player
    }
    
    // MARK: - Private functions
    
    private func canPlacePiece() -> Bool {
        return _piecesLeftToPlay > 0
    }
    
    private func canMove() -> Bool {
        return (_piecesLeftToPlay == 0) && (_piecesOnBoard.count > Constants.GameplayNumbers.loseThreshold) && _piecesOnBoard.count > Constants.GameplayNumbers.flyingThreshold && (movableNodes.count > 0)
    }
    
    private func canFly() -> Bool {
        return (_piecesLeftToPlay == 0) && (_piecesOnBoard.count == Constants.GameplayNumbers.flyingThreshold)
    }
    
    private func hasLost() -> Bool {
        return ((_piecesLeftToPlay == 0) && (_piecesOnBoard.count <= Constants.GameplayNumbers.loseThreshold)) || (movableNodes.count == 0)
    }
}
