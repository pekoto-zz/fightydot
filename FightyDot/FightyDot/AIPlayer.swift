//
//  AIPlayer.swift
//  FightyDot
//
//  Created by Graham McRobbie on 19/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  An AI player. Uses NegaMax with pruning to calculate which moves to make.
//  The first move is random, to cut down on excessive tree calls and to keep things interesting.
//

import Foundation

class AIPlayer: Player {

    // Loaded from difficulty setting in init
    private var _lookAheadDepth: Int = -1
    private var _moveCalculator: NegaMaxWithPruning = NegaMaxWithPruning()
    private var _artificialThinkTime: Double = -1
    
    private var _processingState: AIPlayerState = .Waiting {
        didSet {
            view?.update(status: _processingState)
        }
    }

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
    
    var lookAheadDepth: Int {
        get {
            return _lookAheadDepth
        } set {
            _lookAheadDepth = newValue
        }
    }
    
    init(name: String, colour: PlayerColour, type: PlayerType, isStartingPlayer: Bool, playerNum: PlayerNumber, view: PlayerDelegate?, thinkTime: Double) throws {

        try super.init(name: name, colour: colour, type: type, isStartingPlayer: isStartingPlayer, playerNum: playerNum, view: view)
        
        _processingState = .Waiting
        _artificialThinkTime = thinkTime
        _moveCalculator = NegaMaxWithPruning()
        _lookAheadDepth = getLookaheadDepth()
        
    }
    
    override func reset() {
        super.reset()
        _processingState = .Waiting
        _lookAheadDepth = getLookaheadDepth()
    }
    
    func hasPlayedNoPieces() -> Bool {
        return piecesLeftToPlay == Constants.GameplayNumbers.startingPieces
    }
    
    func getBestMove(board: Board, opponent: Player) throws -> Move? {
        let boardClone = board.clone()
        let playerClone = self.clone(to: boardClone)
        let opponentClone = opponent.clone(to: boardClone)
        
        let gameSnapshot = GameSnapshot(board: boardClone, currentPlayer: playerClone, opponent: opponentClone)
        
        let bestMove = try _moveCalculator.calculateBestMoveWithPruning(gameSnapshot: gameSnapshot, depth: _lookAheadDepth, playerColour: colour, alpha: Int.min, beta: Int.max)
                
        return bestMove.move
    }
    
    
    // If there are no nodes placed yet, just pick a random node.
    // Keeps things unpredictable and avoids a large pointless negamax search
    func pickStartingNodeFrom(board: Board) -> Node {
        if(pickIntersection()) {
            return pickRandomIntersectionFrom(board: board)
        } else {
            return pickRandomNodeFrom(board: board)
        }
    }
    
    // MARK: - Private functions
    
    private func getLookaheadDepth() -> Int {
        let difficulty = UserDefaults.standard.object(forKey: Constants.Settings.difficulty)
        
        if(difficulty == nil) {
            return Difficulty.Normal.rawValue
        } else {
            return difficulty as! Int
        }
    }
    
    // Usually pick an intersection (arguably the best starting pos)
    // but sometimes pick another node, to stop things being too predictable.
    private func pickIntersection() -> Bool {
        return arc4random_uniform(10) <= 7
    }
    
    // Picks an intersection if available
    private func pickRandomIntersectionFrom(board: Board) -> Node {
        let emptyIntersections = board.getNodes(for: .none).filter{ Constants.BoardSetup.intersections.contains($0.id) }
        
        if(emptyIntersections.count == 0) {
            return pickRandomNodeFrom(board: board)
        }
        
        return emptyIntersections.randomElement()!
    }
    
    private func pickRandomNodeFrom(board: Board) -> Node {
        let emptyNodes = board.getNodes(for: .none)
        
        // Since we have more nodes than pieces, there will always be an empty spot
        return emptyNodes.randomElement()!
    }
}
