//
//  AIPlayer.swift
//  Ananke
//
//  Created by Graham McRobbie on 19/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

class AIPlayer: Player {

    private var _processingState: AIPlayerState = .Waiting {
        didSet {
            view?.update(status: _processingState)
        }
    }
    
    private var _thinkTime: Double
    
    var processingState: AIPlayerState {
        get {
            return _processingState
        } set {
            _processingState = newValue
        }
    }
    
    var thinkTime: Double {
        get {
            return _thinkTime
        }
    }
    
    init(name: String, colour: PlayerColour, type: PlayerType, isStartingPlayer: Bool, playerNum: PlayerNumber, view: PlayerDelegate?, thinkTime: Double) throws {
        _processingState = .Waiting
        _thinkTime = thinkTime
        
        try super.init(name: name, colour: colour, type: type, isStartingPlayer: isStartingPlayer, playerNum: playerNum, view: view)
    }
    
    override func reset() {
        super.reset()
        _processingState = .Waiting
    }
    
    func pickNodeToPlaceFrom(board: Board) -> Node {
        let emptyNodes = board.getNodes(withColour: .none)
        
        // Since we have more nodes than pieces, there will always be an empty spot
        return emptyNodes.randomElement()!
    }
    
    func pickNodeToTakeFrom(takableNodes: [Node]) -> Node? {
        return takableNodes.randomElement()
    }
    
    
    func pickNodeToMove() -> Node? {
        return movableNodes.randomElement()
    }
    
    func pickSpotToMoveToFrom(validMoveSpots: [Int]) -> Int? {
        return validMoveSpots.randomElement()
    }
    
    // That's true. It probably belongs in the player class.
    
    // func getBestMove()
    
    // generate all the moves, and then get the best one?
    
    // Check out how other people do it for nine men's morris minimax
    
    //// NOTE: These can be simplified a bit to negamax
    let maxDepth = 4
    
    private func greenValue(board: Board, depth: Int) -> Int {
        if(/*gameOver || */ depth > maxDepth) {
            return analyse(board: board)
        }
        
        // var max = Int.min
        
        // for move in board.getPossibleMoves() {
            // copy board to newBoard
            // newBoard.makeMove(move)
            // int value = RedValue(newBoard, depth+1)
            // if (value > max) max = value
        // }
        
        // return max
        
        return -1
    }
    
    private func redValue(board: Board, depth: Int) -> Int {
        if(/*gameOver || */ depth > maxDepth) {
            return analyse(board: board)
        }
        
        // var min = Int.max
        
        // for move in board.getPossibleMoves() {
            // copy board to newBoard
            // newBoard.makeMove(move)
            // int value = BlueValue(newBoard, depth+1)
            // if (value < min) min = value
        // }
        
        // return min
        
        return -1
    }
    
    private func analyse(board: Board) -> Int {
        // if green has won, return Int.max
        // if red has won, return Int.min
        
        // So the better the position for green, the higher th enumber
        // the better the position for red, the lower the number
        
        return -1;
    }
    
    
    
    
}
