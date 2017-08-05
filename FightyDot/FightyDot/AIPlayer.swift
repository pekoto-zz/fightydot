//
//  AIPlayer.swift
//  Ananke
//
//  Created by Graham McRobbie on 19/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class AIPlayer: Player {

    private var _lookAheadDepth: Int = 2
    private var _moveCalculator: CalculateMoveProtocol
    //private var _turn = 1
    
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
    
    var lookAheadDepth: Int {
        get {
            return _lookAheadDepth
        } set {
            _lookAheadDepth = newValue
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
        //_turn = 1
    }
    
    func hasPlayedNoPieces() -> Bool {
        return piecesLeftToPlay == Constants.GameplayNumbers.startingPieces
    }
    
    func getBestMove(board: Board, opponent: Player, millFormed: Bool) -> Move? {
        //print("AI turn: \(_turn)")
        //_turn = _turn + 1
        
        let boardClone = board.clone()
        let playerClone = self.clone(to: boardClone)
        let opponentClone = opponent.clone(to: boardClone)
        
        let gameSnapshot = GameSnapshot(board: boardClone, currentPlayer: playerClone, opponent: opponentClone)
        
        //let debugTree = TreeNode<ScoredMove>(data: ScoredMove(move: nil, score: 0))
        
        //let bestMove = _moveCalculator.calculateBestMoveWithDebugTree(gameSnapshot: gameSnapshot, depth: _lookAheadDepth, playerColour: colour, tree: debugTree)
        
        //debugTree.data = bestMove
        
        //debugTree.printTree()
        
        let bestMove = _moveCalculator.calculateBestMove(gameSnapshot: gameSnapshot, depth: _lookAheadDepth, playerColour: colour)
        
        return bestMove.move
    }
    
    func pickNodeToPlaceFrom(board: Board) -> Node {
        if(pickIntersection()) {
            return pickRandomIntersectionFrom(board: board)
        } else {
            return pickRandomNodeFrom(board: board)
        }
    }
    
    // MARK: - Private functions
    
    // Usually pick an intersection (arguably the best starting pos)
    // but sometimes pick another node, to stop things being too predictable.
    private func pickIntersection() -> Bool {
        return arc4random_uniform(10) <= 7
    }
    
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
