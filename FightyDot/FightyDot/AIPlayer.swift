//
//  AIPlayer.swift
//  Ananke
//
//  Created by Graham McRobbie on 19/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class AIPlayer: Player {

    private var _lookAheadDepth: Int = 1
    private var _moveCalculator: CalculateMoveProtocol
    
    private var _processingState: AIPlayerState = .Waiting {
        didSet {
            view?.update(status: _processingState)
        }
    }
    
    private var _artificialThinkTime: Double
    
    var processingState: AIPlayerState {
        get {
            return _processingState
        } set {
            _processingState = newValue
        }
    }
    
    var artificialThinkTime: Double {
        get {
            return _artificialThinkTime
        }
    }
    
    init(name: String, colour: PlayerColour, type: PlayerType, isStartingPlayer: Bool, playerNum: PlayerNumber, view: PlayerDelegate?, thinkTime: Double, moveCalculator: CalculateMoveProtocol) throws {
        _processingState = .Waiting
        _artificialThinkTime = thinkTime
        _moveCalculator = moveCalculator
        
        try super.init(name: name, colour: colour, type: type, isStartingPlayer: isStartingPlayer, playerNum: playerNum, view: view)
    }
    
    override func reset() {
        super.reset()
        _processingState = .Waiting
    }
    
    func hasPlayedNoPieces() -> Bool {
        return piecesLeftToPlay == Constants.GameplayNumbers.startingPieces
    }
    
    func getBestMove(board: Board, opponent: Player, millFormed: Bool) -> Move? {
        let boardClone = board.clone()
        let playerClone = self.clone(to: boardClone)
        let opponentClone = opponent.clone(to: boardClone)
        
        let gameSnapshot = GameSnapshot(board: boardClone, currentPlayer: playerClone, opponent: opponentClone, millFormedLastTurn: millFormed)
        let bestMove = _moveCalculator.calculateBestMove(gameSnapshot: gameSnapshot, depth: _lookAheadDepth, playerColour: colour)
        
        return bestMove.move
    }
    
    func pickNodeToPlaceFrom(board: Board) -> Node {
        let emptyNodes = board.getNodes(for: .none)
        
        // Since we have more nodes than pieces, there will always be an empty spot
        return emptyNodes.randomElement()!
    }
}
