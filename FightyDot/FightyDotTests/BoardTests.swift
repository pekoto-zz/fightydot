//
//  BoardTests.swift
//  FightyDot
//
//  Created by Graham McRobbie on 15/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Mainly for testing heuristic evaluation functions
//

import XCTest
@testable import FightyDot

class BoardTests: XCTestCase {
    
    private var _board: Board!
    
    override func setUp() {
        super.setUp()
        _board = Board(view: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        _board = nil
    }
    
    func testZeroMills() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfMills(for: .green), 0)
        XCTAssertEqual(_board.numOfMills(for: .red), 0)
    }
    
    func testOneMill() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfMills(for: .green), 1)
        XCTAssertEqual(_board.numOfMills(for: .red), 0)
    }
    
    func testMultipleMills() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 9)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 21)!.setColour(newColour: .green)
        
        _ = _board.getNode(withID: 15)!.setColour(newColour: .red)
        _ = _board.getNode(withID: 16)!.setColour(newColour: .red)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .red)
        
        XCTAssertEqual(_board.numOfMills(for: .green), 2)
        XCTAssertEqual(_board.numOfMills(for: .red), 1)
    }
    
    func testZeroDoubleMills() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 3)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 4)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfDoubleMills(for: .green), 0)
    }
    
    func testOneDoubleMill() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 3)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 5)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfDoubleMills(for: .green), 1)
    }
    
    func testMultipleDoubleMills() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 3)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 5)!.setColour(newColour: .green)
        
        _ = _board.getNode(withID: 8)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 12)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 19)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 22)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfDoubleMills(for: .green), 2)
    }
    
    func testZeroTwoPieceConfigurations() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 14)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 22)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).twoPieceCount, 0)
    }
    
    func testOneTwoPieceConfiguration() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).twoPieceCount, 1)
    }
    
    func testMultipleTwoPieceConfigurations() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        
        _ = _board.getNode(withID: 8)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 12)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).twoPieceCount, 2)
    }
    
    func testZeroThreePieceConfigurations() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).threePieceCount, 0)
    }
    
    func testOneThreePieceConfiguration() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 9)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).threePieceCount, 1)
    }
    
    func testMultipleThreePieceConfigurations() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 9)!.setColour(newColour: .green)
        
        _ = _board.getNode(withID: 12)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 16)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfTwoAndThreePieceConfigurations(for: .green).threePieceCount, 2)
    }
    
    func testZeroOpenMills() {
        _ = _board.getNode(withID: 19)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 22)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .red)
        
        XCTAssertEqual(_board.numOfOpenMills(for: .green), 0)
    }
    
    func testOneOpenMill() {
        _ = _board.getNode(withID: 19)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 22)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfOpenMills(for: .green), 1)
    }
    
    func testMultipleOpenMills() {
        _ = _board.getNode(withID: 19)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 22)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 17)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 23)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 9)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.numOfOpenMills(for: .green), 2)
    }
    
    func testClonesDifferent() {
        _ = _board.getNode(withID: 0)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 1)!.setColour(newColour: .green)
        _ = _board.getNode(withID: 2)!.setColour(newColour: .green)
        
        let clonedBoard = _board.clone()
        
        _ = clonedBoard.getNode(withID: 9)!.setColour(newColour: .green)
        
        XCTAssertEqual(_board.getNodes(for: .green).count, 3)
        XCTAssertEqual(clonedBoard.getNodes(for: .green).count, 4)
    }
    
    func testClonePerformance() {
        self.measure {
            _ = self._board.getNode(withID: 0)!.setColour(newColour: .green)
            _ = self._board.getNode(withID: 1)!.setColour(newColour: .green)
            _ = self._board.getNode(withID: 2)!.setColour(newColour: .green)
            
            _ = self._board.clone()
        }
    }
}
