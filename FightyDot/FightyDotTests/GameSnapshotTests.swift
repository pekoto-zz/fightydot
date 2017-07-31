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
    
    // MARK: - Get moves tests
    // Place some pieces and then check we get a
    // list of valid moves back depending on state
    
    func testGetPlacementMoves() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 20) // all empty nodes returned
        XCTAssertEqual(moves.filter {move in move.type == .PlacePiece }.count, 20)  // all move types are for placing a piece
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 3 }.count, 1)    // empty node is included
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 0 }.count, 0)    // filled node not included
    }
    
    func testGetMovementMoves() {
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
    
    func testGetFlyingMoves() {
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
        XCTAssertEqual(moves.filter {move in move.type == .MovePiece }.count, 36)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 6 }.count, 12)
        XCTAssertEqual(moves.filter {move in move.destinationNode!.id == 0 }.count, 3)
        XCTAssertEqual(moves.filter {move in move.destinationNode!.id == 6 }.count, 0)
    }
    
    // MARK: - Make move tests
    // Feed in some move and check the resulting game snapshot is correct
    
    func testPlacePiece() {
        let move = Move(type: .PlacePiece, targetNode: _board.getNode(withID: 1)!)
        let nextGameSnapshot = _gameSnapshot.make(move: move)
        
        let moves = nextGameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 23)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 1 }.count, 0)
    }
    
    func testPlaceMultiplePieces() {
        let greenMoveOne = Move(type: .PlacePiece, targetNode: _board.getNode(withID: 1)!)
        let greenTurnOne = _gameSnapshot.make(move: greenMoveOne)
        
        let redMoveOne = Move(type: .PlacePiece, targetNode: _board.getNode(withID: 0)!)
        let redTurnOne = greenTurnOne.make(move: redMoveOne)
        
        let moves = redTurnOne.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 22)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 0 }.count, 0)
        XCTAssertEqual(moves.filter {move in move.targetNode.id == 1 }.count, 0)
    }
    
    func testPlacePiece_MillFormed() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        
        let moves = _gameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 21)
        XCTAssertEqual(moves.filter {move in move.formsMill }.count, 2)
    }
    
    func testMovePiece() {
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
        
        let move = Move(type: .MovePiece, targetNode: _board.getNode(withID: 0)!, destinationNode: _board.getNode(withID: 9)!)
        let nextGameSnapshot = _gameSnapshot.make(move: move)
        
        let moves = nextGameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 5)
        XCTAssertEqual(moves.filter {move in move.type == .MovePiece }.count, 5)
    }
    
    func testMovePiece_MillFormed() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 20)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        
        let move = Move(type: .MovePiece, targetNode: _board.getNode(withID: 12)!, destinationNode: _board.getNode(withID: 8)!)
        let nextGameSnapshot = _gameSnapshot.make(move: move)
        
        let moves = nextGameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 9)
        XCTAssertEqual(moves.filter {move in move.type == .MovePiece }.count, 9)
    }
    
    func testFlyPiece() {
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
        
        let move = Move(type: .MovePiece, targetNode: _board.getNode(withID: 6)!, destinationNode: _board.getNode(withID: 0)!)
        let nextGameSnapshot = _gameSnapshot.make(move: move)
        
        let moves = nextGameSnapshot.getPossibleMoves()
        
        XCTAssertEqual(moves.count, 6)
        XCTAssertEqual(moves.filter {move in move.type == .MovePiece }.count, 6)
    }
    
    // MARK: - Heuristic evaluation score tests
    
    func testHeuristic_ScoreEven() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        
        XCTAssertEqual(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_GreenWinState() {
        _ = _p2.playPiece(node: _board.getNode(withID: 15)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 16)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 20)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        
        _p2.losePiece(node: _board.getNode(withID: 15)!)
        _p2.losePiece(node: _board.getNode(withID: 16)!)
        _p2.losePiece(node: _board.getNode(withID: 17)!)
        _p2.losePiece(node: _board.getNode(withID: 18)!)
        _p2.losePiece(node: _board.getNode(withID: 19)!)
        _p2.losePiece(node: _board.getNode(withID: 20)!)
        _p2.losePiece(node: _board.getNode(withID: 21)!)
        
        XCTAssertEqual(_gameSnapshot.heuristicScore, Int.max)
    }
    
    func testHeuristic_RedWinState() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 6)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 7)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 1)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 3)!)
        _p1.losePiece(node: _board.getNode(withID: 4)!)
        _p1.losePiece(node: _board.getNode(withID: 5)!)
        _p1.losePiece(node: _board.getNode(withID: 6)!)
        
        XCTAssertEqual(_gameSnapshot.heuristicScore, Int.min)
    }
    
    func testHeuristic_PlacingGreenWinning() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 4)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 10)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 18)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 19)!)
        
        XCTAssertGreaterThan(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_PlacingRedWinning() {
        _ = _p1.playPiece(node: _board.getNode(withID: 23)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 5)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 18)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 4)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 10)!)
        
        XCTAssertLessThan(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_MovementGreenWinning() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 1)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 3)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 23)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 13)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 14)!)
        
        _p2.losePiece(node: _board.getNode(withID: 0)!)
        _p2.losePiece(node: _board.getNode(withID: 1)!)
        _p2.losePiece(node: _board.getNode(withID: 2)!)
        _p2.losePiece(node: _board.getNode(withID: 9)!)
        _p2.losePiece(node: _board.getNode(withID: 23)!)
        
        XCTAssertGreaterThan(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_MovementRedWinning() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 19)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 8)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 12)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 17)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 3)!)
        
        _p1.losePiece(node: _board.getNode(withID: 0)!)
        _p1.losePiece(node: _board.getNode(withID: 1)!)
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 3)!)
        _p1.losePiece(node: _board.getNode(withID: 22)!)
        _p1.losePiece(node: _board.getNode(withID: 8)!)
        
        _ = _p2.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 3)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 21)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 22)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 13)!)
        _ = _p2.playPiece(node: _board.getNode(withID: 14)!)
        
        _p2.losePiece(node: _board.getNode(withID: 23)!)
        _p2.losePiece(node: _board.getNode(withID: 14)!)
        _p2.losePiece(node: _board.getNode(withID: 21)!)
        _p2.losePiece(node: _board.getNode(withID: 13)!)
        _p2.losePiece(node: _board.getNode(withID: 14)!)
        
        XCTAssertLessThan(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_FlyingGreenWinning() {
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
        _p1.losePiece(node: _board.getNode(withID: 2)!)
        _p1.losePiece(node: _board.getNode(withID: 3)!)
        _p1.losePiece(node: _board.getNode(withID: 5)!)
        _p1.losePiece(node: _board.getNode(withID: 6)!)
        _p1.losePiece(node: _board.getNode(withID: 7)!)
        
        _p2.losePiece(node: _board.getNode(withID: 15)!)
        _p2.losePiece(node: _board.getNode(withID: 16)!)
        _p2.losePiece(node: _board.getNode(withID: 17)!)
        _p2.losePiece(node: _board.getNode(withID: 18)!)
        _p2.losePiece(node: _board.getNode(withID: 19)!)
        _p2.losePiece(node: _board.getNode(withID: 20)!)
        
        XCTAssertGreaterThan(_gameSnapshot.heuristicScore, 0)
    }
    
    func testHeuristic_FlyingRedWinning() {
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
        
        _p2.losePiece(node: _board.getNode(withID: 15)!)
        _p2.losePiece(node: _board.getNode(withID: 16)!)
        _p2.losePiece(node: _board.getNode(withID: 17)!)
        _p2.losePiece(node: _board.getNode(withID: 18)!)
        _p2.losePiece(node: _board.getNode(withID: 21)!)
        _p2.losePiece(node: _board.getNode(withID: 23)!)
        
        XCTAssertLessThan(_gameSnapshot.heuristicScore, 0)
    }
    
}
