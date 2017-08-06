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
//  There is no weight for "winning", since we just return a max/min value for this state.
//
//  Later, I would like to adjust these dynamically, syncing the best weights over Firebase.
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
//  Open mill (can move a piece next turn to close this mill):
// (I.e., a 2 piece configuration, where the empty node has a neighbour of the same colour)
//
//  0) O---------O---------O
//     |         |         |
//  2) |  O------O------O  |
//     |  |      |      |  |
//  3) |  |   O--O--0   |  |
//     |  |   |     |   |  |
//  4) O--O---O     0---O--O
//     |  |   |     |   |  |
//  5) |  |   O-[O]-G   |  |
//     |  |      |      |  |
//  6) |  O------G------O  |
//     |         |         |
//  7) O---------G---------O
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
        static let piecesInPlay = 9
        static let twoPieceConfigurations = 10  // Mill can be closed in one way
        static let threePieceConfigurations = 7 // Mill can be closed in two ways
    }
    
    struct MovementPhase {
        static let closedMill = 14
        static let mills = 43
        static let blockedOpponentPieces = 10
        static let piecesInPlay = 11
        static let openMill = 8
        static let doubleMill = 36  // Moving one piece between mills forms another mill
    }
    
    struct FlyingPhase {
        static let twoPieceConfigurations = 15
        static let threePieceConfigurations = 1
        static let closedMill = 16
    }
}
