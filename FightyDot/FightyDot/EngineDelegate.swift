//
//  EngineViewProtocol.swift
//  Ananke
//
//  Created by Graham McRobbie on 12/01/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import Foundation

protocol EngineDelegate: class {
    var p1View: PlayerView { get }
    var p2View: PlayerView { get }

    func animate(node: Node, to newColour: PieceColour)
    func animate(mill: Mill, to newColour: PieceColour)
    func enableDragDisableTapFor(node: Node)
    func enableTapDisableDragFor(node: Node)
    func disableInteractionFor(node: Node)
    func reset(mill: Mill)
    func gameWon(by player: Player)
    func playSound(fileName: String, type: String)
    func updateTips(state: GameState)
}
