//
//  HeuristicWeights.swift
//  FightyDot
//
//  Created by Graham McRobbie on 15/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Roughly based on the results in this paper:
//  http://www.dasconference.ro/papers/2008/B7.pdf (See: "Coefficient sets of best estimators")
//
//  There is no weight for "winning", since minimax should just return a max/min value for this state.
//
//  Ultimately I would like to adjust these dynamically, syncing the best weights over Firebase.
//
//  Two piece configuration (adding one more piece would close a mill:
//  (I.e., 2 mill nodes are the same colour, and the other is empty)
//
//  0) O---------O---------O
//     |         |         |
//  2) |  O------O------O  |
//     |  |      |      |  |
//  3) |  |   O--O--O   |  |
//     |  |   |     |   |  |
//  4) O--O---O     O---O--O
//     |  |   |     |   |  |
//  5) |  |   O--O--O   |  |
//     |  |      |      |  |
//  6) |  O------O------O  |
//     |         |         |
//  7) G---------G--------[O]
//
//  Three piece configuration (two uncompleted mills with a shared piece):
//  (I.e., 2 2-piece-configurations share a node)
//
//  0)[O]--------O---------O
//     |         |         |
//  2) |  O------O------O  |
//     |  |      |      |  |
//  3) |  |   O--O--O   |  |
//     |  |   |     |   |  |
//  4) G--O---O     O---O--O
//     |  |   |     |   |  |
//  5) |  |   O--O--O   |  |
//     |  |      |      |  |
//  6) |  O------O------O  |
//     |         |         |
//  7) G---------G--------[O]
//
//  Double mill (can move pieces back and forth between 2 mills):
//  (I.e., a 2 piece configuration, where the empty node has a neighbour in a mill)
//
//  0) O---------O---------O
//     |         |         |
//  2) |  O------O------O  |
//     |  |      |      |  |
//  3) |  |   O--O--G   |  |
//     |  |   |     |   |  |
//  4) O--O---O     G---O--O
//     |  |   |     |   |  |
//  5) |  |   O-[O]-G   |  |
//     |  |      |      |  |
//  6) |  O------G------O  |
//     |         |         |
//  7) O---------G---------O

import Foundation

struct HeuristicWeights {
    struct PlacementPhase {
        static let closedMill = 18
        static let mills = 26
        static let blockedOpponentPieces = 1
        static let totalPieces = 6
        static let twoPieceConfigurations = 12  // Mill can be closed in one way (see comments)
        static let threePieceConfigurations = 7 // Mill can be closed in two ways (see comments)
    }
    
    struct MovementPhase {
        static let closedMill = 14
        static let mills = 43
        static let blockedOpponentPieces = 10
        static let totalPieces = 8
        static let openedMill = 21
        static let doubleMill = 40  // Moving one piece between mills forms another mill (see comments)
    }
    
    struct FlyingPhase {
        static let twoPieceConfigurations = 12
        static let threePieceConfigurations = 13
        static let closedMill = 16
    }
}
