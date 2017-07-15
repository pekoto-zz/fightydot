//
//  BaseEngine.swift
//  Ananke
//
//  Created by Graham McRobbie on 29/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//  
//  A basic nine men's morris engine
//

import Foundation

class Engine {
    
    private var _p1: Player
    private var _p2: Player
    private var _board: Board
    private var _state: GameState = .PlacingPieces {
        didSet {
            _view?.updateTips(state: _state)
        }
    }
    weak private var _view: EngineDelegate?
    
    private var _currentPlayer: Player! {
        didSet {
            if let oldPlayer = oldValue {
                oldPlayer.isCurrentPlayer = false
            }
            _currentPlayer.isCurrentPlayer = true
            
            if let aiPlayer = _currentPlayer as? AIPlayer {
                makeAIMoveFor(player: aiPlayer)
            }
        }
    }
    
    init(gameType: GameType, engineView: EngineDelegate) {
        _p1 = try! Player(name: Constants.PlayerData.defaultPvpP1Name, colour: .green, type: .humanLocal, isStartingPlayer: true, playerNum: PlayerNumber.p1, view: engineView.p1View)
        
        if(gameType == .PlayerVsPlayer) {
            _p2 = try! Player(name: Constants.PlayerData.defaultPvpP2Name, colour: .red, type: .humanLocal, isStartingPlayer: false, playerNum: PlayerNumber.p2, view: engineView.p2View)
        } else {
            _p2 = try! AIPlayer(name: Constants.PlayerData.defaultAIName, colour: .red, type: .AI, isStartingPlayer: false, playerNum: PlayerNumber.p2, view: engineView.p2View, thinkTime: 0.5)
        }
        
        _view = engineView
        _currentPlayer = _p1.isStartingPlayer ? _p1 : _p2
        _board = Board(view: engineView)
    }
    
    func handleNodeTapFor(nodeWithId nodeId: Int) throws {
        guard nodeId.isInIdRange() else {
            throw EngineError.InvalidId
        }
        
        // Prevent double moves
        _board.disableNodes()
        
        switch(_state) {
        case .PlacingPieces:
            try placeNodeFor(player: _currentPlayer, nodeId: nodeId)
        case .TakingPiece:
            try takeNodeBelongingTo(player: nextPlayer(), nodeId: nodeId)
        default:
            throw EngineError.InvalidState
        }
    }
    
    func handleNodeDragged(from oldId: Int, to newId: Int) throws {
        guard oldId.isInIdRange() && newId.isInIdRange() else {
            throw EngineError.InvalidId
        }
        
        // Prevent double moves
        _board.disableNodes()
        
        try moveNodeFor(player: _currentPlayer, from: oldId, to: newId)
    }
    
    func getMovablePositionsFor(nodeWithId id: Int) throws -> [Int]  {
        guard (id.isInIdRange()) else {
            throw EngineError.InvalidId
        }
        
        switch(_state) {
        case .MovingPieces:
            return (_board.getNode(withID: id)?.emptyNeighbours.map { $0.id})!
        case .FlyingPieces:
            return _board.getNodes(for: .none).map { $0.id }
        default:
            throw EngineError.InvalidState
        }
    }
    
    func reset() {
        resetPlayers()
        _board.reset()
        _state = .PlacingPieces
        _view?.playSound(fileName: Constants.Sfx.startGame, type: ".wav")
    }
    
    // MARK: - Private functions
    
    private func placeNodeFor(player: Player, nodeId: Int) throws {
        guard let node = _board.getNode(withID: nodeId) else {
            throw EngineError.InvalidId
        }
        
        let millFormed = player.playPiece(node: node)
        
        if millFormed && nextPlayer().hasTakeableNodes {
            _view?.playSound(fileName: Constants.Sfx.millFormed, type: ".wav")
            try promptToTakePiece()
        } else {
            _view?.playSound(fileName: Constants.Sfx.placePiece, type: ".wav")
            try nextTurn()
        }
    }
    
    private func promptToTakePiece() throws {
        _state = .TakingPiece
        if let aiPlayer = _currentPlayer as? AIPlayer {
            makeAIMoveFor(player: aiPlayer)
        } else {
            try updateSelectableNodes()
        }
        
    }
    
    private func updateSelectableNodes() throws {
        let selectableNodes = getSelectableNodes(state: _state)
        
        switch(_state) {
        case .PlacingPieces, .TakingPiece:
            _board.setNodesTappable(nodes: selectableNodes)
        case .MovingPieces, .FlyingPieces:
            _board.setNodesDraggable(nodes: selectableNodes)
        default:
            throw EngineError.InvalidState
        }
    }
    
    private func getSelectableNodes(state: GameState) -> [Node] {
        switch(state) {
        case .TakingPiece:
            return nextPlayer().takeableNodes
        case .MovingPieces, .FlyingPieces:
            return _currentPlayer.movableNodes
        default:
            return _board.getNodes(for: .none)
        }
    }
    
    private func takeNodeBelongingTo(player: Player, nodeId : Int) throws {
        guard let node = _board.getNode(withID: nodeId) else {
            throw EngineError.InvalidId
        }
        
        player.losePiece(node: node)
        _view?.playSound(fileName: Constants.Sfx.pieceLost, type: ".wav")
        
        try nextTurn()
    }

    // Simulate thinking time and make a move.
    // The engine calls won't fail since nodes come not from the board
    // rather than the view, which could be incorrectly configured.
    private func makeAIMoveFor(player: AIPlayer) {
        
        player.processingState = .Thinking
        
        DispatchQueue.main.asyncAfter(deadline: .now() + player.thinkTime, execute: {
            if(self._state == .PlacingPieces) {
                let spotToPlace = player.pickNodeToPlaceFrom(board: self._board)
                player.processingState = .Moving
                
                try! self.placeNodeFor(player: player, nodeId: spotToPlace.id)
            } else if (self._state == .TakingPiece) {
                let takableNodes = self.nextPlayer().takeableNodes
                let pieceToTake = player.pickNodeToTakeFrom(takableNodes: takableNodes)
                player.processingState = .Moving
                
                try! self.takeNodeBelongingTo(player: self.nextPlayer(), nodeId: pieceToTake!.id)
            } else if (self._state == .MovingPieces) || (self._state == .FlyingPieces) {
                let nodeToMove = player.pickNodeToMove()
                let validMoveSpots = try! self.getMovablePositionsFor(nodeWithId: nodeToMove!.id)
                let spotToMoveTo = player.pickSpotToMoveToFrom(validMoveSpots: validMoveSpots)
                player.processingState = .Moving
                
                try! self.moveNodeFor(player: player, from: nodeToMove!.id, to: spotToMoveTo!)
            }
            
            player.processingState = .Waiting
        })
    }
    
    private func nextTurn() throws {
        _state = nextPlayer().state
        
        if(_state == .GameOver) {
            _view?.gameWon(by: _currentPlayer)
        } else {
            switchPlayers()
            
            if(_currentPlayer.type != .AI) {
                try updateSelectableNodes()
            }
        }
    }
    
    private func moveNodeFor(player: Player, from oldId: Int, to newId: Int) throws {
        guard let oldNode = _board.getNode(withID: oldId) else {
            throw EngineError.InvalidId
        }
        
        guard let newNode = _board.getNode(withID: newId) else {
            throw EngineError.InvalidId
        }
        
        let millFormed = player.movePiece(from: oldNode, to: newNode)
        
        if millFormed && nextPlayer().hasTakeableNodes {
            _view?.playSound(fileName: Constants.Sfx.millFormed, type: ".wav")
            try promptToTakePiece()
        } else {
            _view?.playSound(fileName: Constants.Sfx.placePiece, type: ".wav")
            try nextTurn()
        }
    }
    
    // Sometimes we want to look ahead to check the next player's properties
    // to check if we have a draw, can take a piece, etc.
    private func nextPlayer() -> Player {
        if(_currentPlayer === _p1) {
            return _p2
        } else {
            return _p1
        }
    }
    
    private func switchPlayers() {
        _currentPlayer = nextPlayer()
    }
    
    private func resetPlayers() {
        _p1.reset()
        _p2.reset()
        _currentPlayer = _p1.isStartingPlayer ? _p1 : _p2
    }
}
