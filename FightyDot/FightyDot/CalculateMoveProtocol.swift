//
//  CalculateMoveProtocol.swift
//  FightyDot
//
//  Created by Graham McRobbie on 25/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

protocol CalculateMoveProtocol {
    func calculateBestMove(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour) -> ScoredMove
}