//
//  Enums.swift
//  Ananke
//
//  Created by Graham McRobbie on 12/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import Foundation

enum AIPlayerState: String {
    case Moving = "Moving..."
    case Placing = "Placing..."
    case TakingPiece = "Taking piece..."
    case Thinking = "Thinking..."
    case Waiting = "Waiting"
}

enum AnimationDirection {
    case Up
    case Down
    case Left
    case Right
    
    mutating func reverse() {
        switch(self) {
        case .Up:
            self = .Down
        case .Down:
            self = .Up
        case .Left:
            self = .Right
        case .Right:
            self = .Left
        }
    }
}

enum DifficultyLookaheads: Int {
    case Easy = 1
    case Normal = 2
    case Hard = 3
    case Harder = 4
}

enum GameState {
    case AITurn
    case PlacingPieces
    case MovingPieces
    case MovingPieces_PieceSelected
    case FlyingPieces
    case FlyingPieces_PieceSelected
    case TakingPiece
    case GameOver
}

enum GameType: Int {
    case PlayerVsAI = 0
    case PlayerVsPlayer = 1
}

enum MoveType {
    case PlacePiece
    case MovePiece
}

enum PieceColour: Int {
    case none = 0
    case green = 1
    case red = 2
}

enum PlayerColour: Int {
    case green = 1
    case red = 2
}

enum PlayerNumber: Int {
    case p1 = 0
    case p2 = 1
}

enum PlayerType {
    case humanLocal
    case AI
}
