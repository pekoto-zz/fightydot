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
    func calculateBestMoveWithPruning(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, alpha: Int, beta: Int) -> ScoredMove
    func calculateBestMoveWithDebugTree(gameSnapshot: GameSnapshot, depth: Int, playerColour: PlayerColour, tree: TreeNode<ScoredMove>) -> ScoredMove
}
