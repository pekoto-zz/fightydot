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
                makeMoveFor(aiPlayer: aiPlayer)
            }
        }
    }
    
    init(gameType: GameType, engineView: EngineDelegate) {
        _p1 = try! Player(name: Constants.PlayerData.defaultPvpP1Name, colour: .green, type: .humanLocal, isStartingPlayer: true, playerNum: PlayerNumber.p1, view: engineView.p1View)
        
        if(gameType == .PlayerVsPlayer) {
            _p2 = try! Player(name: Constants.PlayerData.defaultPvpP2Name, colour: .red, type: .humanLocal, isStartingPlayer: false, playerNum: PlayerNumber.p2, view: engineView.p2View)
        } else {
            _p2 = try! AIPlayer(name: Constants.PlayerData.defaultAIName, colour: .red, type: .AI, isStartingPlayer: false, playerNum: PlayerNumber.p2, view: engineView.p2View, thinkTime: 0.5, moveCalculator: MiniMax())
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
            makeMoveFor(aiPlayer: aiPlayer)
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
    // The engine calls won't fail since nodes come from the board
    // rather than the view
    private func makeMoveFor(aiPlayer: AIPlayer) {
        aiPlayer.processingState = .Thinking

        let millFormed = _state == .TakingPiece
        let opponent = nextPlayer()
        var bestMove: Move?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + aiPlayer.artificialThinkTime) {
            if(aiPlayer.hasPlayedNoPieces()) {
                // If there are no nodes placed yet, just pick a random node
                // Keeps things unpredictable and avoids a large pointless minimax tree search
                let targetNode = aiPlayer.pickNodeToPlaceFrom(board: self._board)
                bestMove = Move(type: .PlacePiece, targetNode: targetNode)
            } else {
                bestMove = aiPlayer.getBestMove(board: self._board, opponent: self.nextPlayer(), millFormed: millFormed)
            }
            
            guard let moveToMake = bestMove else {
                self._view?.gameWon(by: opponent)
                return
            }
            
            switch (moveToMake.type) {
            case .PlacePiece:
                aiPlayer.processingState = .Placing
                try! self.placeNodeFor(player: aiPlayer, nodeId: moveToMake.targetNode.id)
            case .TakePiece:
                aiPlayer.processingState = .TakingPiece
                try! self.takeNodeBelongingTo(player: opponent, nodeId: moveToMake.targetNode.id)
            case .MovePiece, .FlyPiece:
                aiPlayer.processingState = .Moving
                
                guard let destinationNode = moveToMake.destinationNode else {
                    self._view?.gameWon(by: opponent)
                    return
                }
                
                try! self.moveNodeFor(player: aiPlayer, from: moveToMake.targetNode.id, to: destinationNode.id)
            }
            
            aiPlayer.processingState = .Waiting
        }
        
        
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
