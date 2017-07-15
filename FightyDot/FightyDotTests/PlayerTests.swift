//
//  FightyDotTests.swift
//  FightyDotTests
//
//  Created by Graham McRobbie on 15/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Mainly for testing heuristic evaluation functions
//

import XCTest
@testable import FightyDot

class PlayerTests: XCTestCase {
    
    private var _p1: Player!
    private var _board: Board!
    
    override func setUp() {
        super.setUp()
        _p1 = try! Player(name: Constants.PlayerData.defaultPvpP1Name, colour: .green, type: .humanLocal, isStartingPlayer: true, playerNum: .p1, view: nil)
        
        _board = Board(view: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        _p1 = nil
        _board = nil
    }
    
    func testZeroBlockedNodes() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 21)!)
        
        XCTAssertEqual(_p1.numOfBlockedNodes, 0)
    }
    
    func testOneBlockedNodes() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        
        XCTAssertEqual(_p1.numOfBlockedNodes, 1)
    }

    func testTwoBlockedNodes() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 2)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 14)!)
        
        XCTAssertEqual(_p1.numOfBlockedNodes, 2)
    }
    
    func testClonesDifferent() {
        _ = _p1.playPiece(node: _board.getNode(withID: 0)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 1)!)
        _ = _p1.playPiece(node: _board.getNode(withID: 9)!)
        
        let newBoard = _board.clone()
        
        let clonedPlayer = _p1.clone(to: newBoard)
        
        _ = clonedPlayer.playPiece(node: _board.getNode(withID: 14)!)
        
        XCTAssertEqual(_p1.takeableNodes.count, 3)
        XCTAssertEqual(clonedPlayer.takeableNodes.count, 4)
    }
    
    func testClonePerformance() {
        self.measure {
            _ = self._p1.playPiece(node: self.self._board.getNode(withID: 0)!)
            _ = self._p1.playPiece(node: self._board.getNode(withID: 1)!)
            _ = self._p1.playPiece(node: self._board.getNode(withID: 9)!)
            
            let newBoard = self._board.clone()
            
            _ = self._p1.clone(to: newBoard)
        }
    }
    
}
