//
//  PlayerDelegate.swift
//  FightyDot
//
//  Created by Graham McRobbie on 17/01/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Implemented in PlayerView.swift
//  Like EngineDelegate, these are callbacks made by the engine to update the view.
//


import Foundation

protocol PlayerDelegate: class {
    func setupUIFor(player: Player)
    func update(isCurrentPlayer: Bool)
    func updateNumOfVisibleCounters(to newCount: Int)
    func update(status: AIPlayerState)
}
