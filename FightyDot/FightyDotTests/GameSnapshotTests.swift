//
//  GameSnapshotTests.swift
//  FightyDot
//
//  Created by Graham McRobbie on 22/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  The board looks like this:
//
//  0) 0---------1---------2
//     |         |         |
//  2) |  3------4------5  |
//     |  |      |      |  |
//  3) |  |   6--7--8   |  |
//     |  |   |     |   |  |
//  4) 9--10--11    12--13-14
//     |  |   |     |   |  |
//  5) |  |   15-16-17  |  |
//     |  |      |      |  |
//  6) |  18-----19-----20 |
//     |         |         |
//  7) 21--------22-------23
//
import XCTest
@testable import FightyDot

class GameSnapshotTests: XCTestCase {
    
    private var _gameSnapshot: GameSnapshot!
    private var _board: Board!
    private var _p1: Player!
    private var _p2: Player!
        
    override func setUp() {
        super.setUp()
        _board = Board(view: nil)
        _p1 = try! Player(name: Constants.PlayerData.defaultPvpP1Name, colour: .green, type: .humanLocal, isStartingPlayer: true, playerNum: .p1, view: nil)
        _p2 = try! Player(name: Constants.PlayerData.defaultPvpP2Name, colour: .red, type: .humanLocal, isStartingPlayer: false, playerNum: .p2, view: nil)
        
        _gameSnapshot = GameSnapshot(board: _board, currentPlayer: _p1, opponent: _p2)
    }
    
    override func tearDown() {
        super.tearDown()
        _p1 = nil
        _p2 = nil
        _board = nil
        _gameSnapshot = nil
    }
    
    // MARK: - Movement tests
    // Place some pieces and then check we get a
    // list of valid moves back depending on state
    
    func testPlacementMoves() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 18) // all empty nodes returned
        XCTAssertEqual(moves.filter {move in move.type == .PlacePiece }.count, 18)  // all move types are for placing a piece
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 3 }.count, 1)    // empty node is included
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 0 }.count, 0)    // filled node not included
    }
    
    func testMovementMoves() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 6)
        XCTAssertEqual(moves.filter {move in move.type == .MovePiece }.count, 6)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 0 }.count, 1)
        XCTAssertEqual(moves.filter {move in move.destinationNode!.id == 9 }.count, 1)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 1 }.count, 0)    // Node is blocked
    }
    
    func testFlyingMoves() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 20)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 1)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 3)!)
        _p1.losePiece(node: _board.getNode(withID: 4)!)
        _p1.losePiece(node: _board.getNode(withID: 5)!)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        // 3 nodes left * 12 empty spaces = 36 possible moves
        XCTAssertEqual(moves.count, 36)
        XCTAssertEqual(moves.filter {move in move.type == .FlyPiece }.count, 36)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 6 }.count, 12)
        XCTAssertEqual(moves.filter {move in move.destinationNode!.id == 0 }.count, 3)
        XCTAssertEqual(moves.filter {move in move.destinationNode!.id == 6 }.count, 0)
    }
    
    func testTakingMoves_NonMillPiece() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        
        _gameSnapshot = GameSnapshot(board: _board, currentPlayer: _p1, opponent: _p2, millFormedLastTurn: true)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 1)
        XCTAssertEqual(moves.filter {move in move.type == .TakePiece }.count, 1)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 18 }.count, 1)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 15 }.count, 0)   // Nodes in mill not takeable
    }
    
    func testTakingMoves_MillPieces() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        
        _gameSnapshot = GameSnapshot(board: _board, currentPlayer: _p1, opponent: _p2, millFormedLastTurn: true)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 3)
        XCTAssertEqual(moves.filter {move in move.type == .TakePiece }.count, 3)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 15 }.count, 1)
    }
}
