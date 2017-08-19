//
//  BaseEngine.swift
//  FightyDot
//
//  Created by Graham McRobbie on 29/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//  
//  A basic nine men's morris engine.
//  This class handles the game logic and calls back to the relevent views.
//

import Foundation
import Firebase

class Engine {
    
    private var _p1: Player
    private var _p2: Player
    private var _board: Board
    
    private var _state: GameState = .PlacingPieces {
        didSet {
            if(_state != .TakingPiece && nextPlayer().type == .AI) {
                _view?.updateTips(state: .AITurn)
            } else {
                _view?.updateTips(state: _state)
            }
        }
    }
    weak private var _view: EngineDelegate?
    
    private var _currentPlayer: Player! {
        didSet {
            if let oldPlayer = oldValue {
                oldPlayer.isCurrentPlayer = false
            }
            _currentPlayer.isCurrentPlayer = true
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
        
       //dummyState()
    }
    
    func dummyState() {
        
        // CRASH STATE 1
        /*_ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 23)!)

        
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 1)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 23)!)

        
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 13)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 21)!)
        
    
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        
        _p2.losePiece(node: _board.getNode(withID: 0)!)
        _p2.losePiece(node: _board.getNode(withID: 1)!)
        _p2.losePiece(node: _board.getNode(withID: 2)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        
        _p2.losePiece(node: _board.getNode(withID: 0)!)
        _p2.losePiece(node: _board.getNode(withID: 1)!)
        _p2.losePiece(node: _board.getNode(withID: 2)!)

        
        _ = _p2.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 10)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)*/
        
        // CRASH STATE 2
        /*_ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 8)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 20)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        _p2.losePiece(node: _board.getNode(withID: 22)!)
        
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 13)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 14)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 23)!)
        
        _ = _p1.playPiece(node: _board.getNode(withID: 22)!)
        _p1.losePiece(node: _board.getNode(withID: 22)!) */
        
        // CRASH STATE 3
        /*_ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 10)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        _p2.losePiece(node: _board.getNode(withID: 0)!)
        _p2.losePiece(node: _board.getNode(withID: 2)!)
        
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 14)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 15)!)

        _ = _p1.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 23)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)

        _p1.losePiece(node: _board.getNode(withID: 21)!)
        _p1.losePiece(node: _board.getNode(withID: 22)!)
        _p1.losePiece(node: _board.getNode(withID: 19)!)
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)*/

        _state = .MovingPieces
    }
    
    func handleNodeTapFor(nodeWithId nodeId: Int) throws {
        guard nodeId.isInIdRange() else {
            throw EngineError.InvalidId
        }
        
        // Prevent double taps/drags
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
        
        // Prevent double taps/drags
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
        _view?.updateTips(state: _state)
        _view?.playSound(fileName: Constants.Sfx.startGame, type: ".wav")
       // dummyState()
    }
    
    // For error reporting
    func uploadStateToFirebase(msg: String) {
        var paramDict = Dictionary<String, Any>()
        paramDict["state"] = "\(_state)"
        paramDict["msg"] = msg
        
        Analytics.logEvent(Constants.FirebaseEvents.engineState, parameters: paramDict)
        Analytics.logEvent(Constants.FirebaseEvents.boardState, parameters: _board.toDict())
        Analytics.logEvent(Constants.FirebaseEvents.playerOneState, parameters: _p1.toDict())
        Analytics.logEvent(Constants.FirebaseEvents.playerTwoState, parameters: _p2.toDict())
    }
    
    // MARK: - Private functions
    
    private func placeNodeFor(player: Player, nodeId: Int) throws {
        guard let node = _board.getNode(withID: nodeId) else {
            throw EngineError.InvalidId
        }
        
        let millFormed = player.playPiece(node: node)
        
        if (millFormed)  {
            _view?.playSound(fileName: Constants.Sfx.millFormed, type: ".wav")
            
            if(player.type == .humanLocal && nextPlayer().hasTakeableNodes) {
                try promptToTakePiece()
            }
        } else {
            _view?.playSound(fileName: Constants.Sfx.placePiece, type: ".wav")
            try nextTurn()
        }
    }
    
    private func promptToTakePiece() throws {
        _state = .TakingPiece
        try updateSelectableNodes()
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
    
    private func nextTurn() throws {
        _state = nextPlayer().state
        
        if(_state == .GameOver) {
            _view?.gameWon(by: _currentPlayer)
        } else {
            switchPlayers()
            
            if(_currentPlayer.type != .AI) {
                try updateSelectableNodes()
            } else {
                makeMoveFor(aiPlayer: (_currentPlayer as? AIPlayer)!)
            }
        }
    }
    
    // Because the AI move is handled in a dispatch block, it cannot throw errors in Swift 3.
    // Therefore, error handling is done in the method itself, and fatal errors are returned
    // to the view immediately.
    private func makeMoveFor(aiPlayer: AIPlayer) {
        aiPlayer.processingState = .Thinking
        
        let opponent = nextPlayer()
        var bestMove: Move?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + aiPlayer.artificialThinkTime) {
            
            // Get the move to make
            if(aiPlayer.hasPlayedNoPieces()) {
                let targetNode = aiPlayer.pickStartingNodeFrom(board: self._board)
                bestMove = Move(type: .PlacePiece, targetNode: targetNode)
            } else {
                do {
                    try bestMove = aiPlayer.getBestMove(board: self._board, opponent: self.nextPlayer())
                } catch {
                    self._view?.handleEngineError(logMsg: "Failed to calculate move for AI player. (\(error))")
                }
            }
            
            guard let moveToMake = bestMove else {
                self._view?.handleEngineError(logMsg: "Failed to unwrap move for AI player.")
                return
            }
            
            // Make the move
            switch (moveToMake.type) {
            case .PlacePiece:
                aiPlayer.processingState = .Placing
                do {
                    try self.placeNodeFor(player: aiPlayer, nodeId: moveToMake.targetNode.id)
                } catch {
                    self._view?.handleEngineError(logMsg: "Failed to place piece with id \(moveToMake.targetNode.id) for AI player. (\(error))")
                }
            case .MovePiece:
                aiPlayer.processingState = .Moving
                
                guard let destinationNode = moveToMake.destinationNode else {
                    self._view?.handleEngineError(logMsg: "Failed to get destination node for AI player.")
                    return
                }
                
                do {
                    try self.moveNodeFor(player: aiPlayer, from: moveToMake.targetNode.id, to: destinationNode.id)
                } catch {
                    self._view?.handleEngineError(logMsg: "Failed to move piece from \(moveToMake.targetNode.id) to \(destinationNode.id) for AI player. (\(error))")
                }
            }
            
            // Take a piece
            if(moveToMake.formsMill) {
                DispatchQueue.main.asyncAfter(deadline: .now() + aiPlayer.artificialThinkTime) {
                    aiPlayer.processingState = .TakingPiece
                    
                    if let nodeToTake = moveToMake.nodeToTake {
                        do {
                            try self.takeNodeBelongingTo(player: opponent, nodeId: nodeToTake.id)
                        } catch {
                            self._view?.handleEngineError(logMsg: "Failed to take piece \(nodeToTake.id) for AI player. (\(error))")

                        }
                    }
                }
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
        
        if (millFormed) {
            _view?.playSound(fileName: Constants.Sfx.millFormed, type: ".wav")
            
            if(player.type == .humanLocal && nextPlayer().hasTakeableNodes) {
                try promptToTakePiece()
            }
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
        
        if let aiPlayer = nextPlayer() as? AIPlayer {
            aiPlayer.processingState = .Waiting
        }
    }
    
    private func resetPlayers() {
        _p1.reset()
        _p2.reset()
        _currentPlayer = _p1.isStartingPlayer ? _p1 : _p2
    }
}
