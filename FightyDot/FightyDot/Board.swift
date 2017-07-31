//
//  Board.swift
//  Ananke
//
//  Created by Graham McRobbie on 23/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
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

import Foundation

class Board {
    
    private var _nodes: [Node]
    private var _mills: [Mill]
    
    init(view: EngineDelegate?) {
        _nodes = []
        _mills = []
        setup(view: view)
    }
    
    func setNodesTappable(nodes: [Node]) {
        for node in nodes {
            node.isTappable = true
        }
    }
    
    func setNodesDraggable(nodes: [Node]) {
        for node in nodes {
            node.isDraggable = true
        }
    }
    
    func getNodes(for colour: PieceColour) -> [Node] {
        return _nodes.filter { (node) in node.colour == colour }
    }
    
    func getNode(withID id: Int) -> Node? {
        return _nodes.filter { (node) in node.id == id }.first
    }
    
    func setNode(withID id: Int, to colour: PieceColour) -> Bool {
        return (getNode(withID: id)?.setColour(newColour: colour))!
    }
    
    func disableNodes() {
        for node in _nodes {
            node.disable()
        }
    }
    
    func reset() {
        for node in _nodes {
            node.reset()
        }
        
        for mill in _mills {
            mill.reset()
        }
    }
    
    func print() {
        Swift.print("\(_nodes[0].printColour())---------\(_nodes[1].printColour())---------\(_nodes[2].printColour())")
        Swift.print("|         |         |")
        Swift.print("|  \(_nodes[3].printColour())------\(_nodes[4].printColour())------\(_nodes[5].printColour())  |")
        Swift.print("|  |      |      |  |")
        Swift.print("|  |   \(_nodes[6].printColour())--\(_nodes[7].printColour())--\(_nodes[8].printColour())   |  |")
        Swift.print("|  |   |     |   |  |")
        Swift.print("\(_nodes[9].printColour())--\(_nodes[10].printColour())---\(_nodes[11].printColour())     \(_nodes[12].printColour())---\(_nodes[13].printColour())--\(_nodes[14].printColour())")
        Swift.print("|  |   |     |   |  |")
        Swift.print("|  |   \(_nodes[15].printColour())--\(_nodes[16].printColour())--\(_nodes[17].printColour())   |  |")
        Swift.print("|  |      |      |  |")
        Swift.print("|  \(_nodes[18].printColour())------\(_nodes[19].printColour())------\(_nodes[20].printColour())  |")
        Swift.print("|         |         |")
        Swift.print("\(_nodes[21].printColour())---------\(_nodes[22].printColour())---------\(_nodes[23].printColour())")
    }
    
    func clone() -> Board {
        // Clones are used for building game trees/predicting the best move,
        // so they don't need view delegates.
        let board = Board(view: nil)
        
        for i in 0...board._nodes.count-1 {
            board._nodes[i].copyValues(from: _nodes[i])
        }
        
        for i in 0...board._mills.count-1 {
            board._mills[i].copyValues(from: _mills[i])
        }
        
        return board
    }
    
    // MARK: - Heuristic evaluation helpers
    
    func numOfMills(for colour: PieceColour) -> Int {
        return _mills.filter{ mill in mill.colour == colour }.count
    }
    
    func numOfDoubleMills(for colour: PieceColour) -> Int {
        return _mills.filter{ mill in mill.isInDoubleMillConfiguration(for: colour) }.count
    }
    
    func numOfOpenMills(for colour: PieceColour) -> Int {
        return _mills.filter{ mill in mill.isOpen(for: colour) }.count
    }
    
    // We always use these together when evaluating, so it's more efficient to group the calculations
    func numOfTwoAndThreePieceConfigurations(for colour: PieceColour) -> (twoPieceCount: Int, threePieceCount: Int) {
        
        var threePieceCount = 0
        
        let twoPieceMills = _mills.filter{ mill in mill.isInTwoPieceConfiguration(for: colour) }
    
        // The number of two piece mills will always be fairly small
        if(twoPieceMills.count >= 2) {
            for i in 0...twoPieceMills.count-2 {
                for j in i+1...twoPieceMills.count-1 {
                    if(twoPieceMills[i].intersects(with: twoPieceMills[j])) {
                        threePieceCount += 1
                    }
                }
            }
        }
        
        return (twoPieceMills.count, threePieceCount)
    }
    
    // MARK: - Private functions
    
    private func setup(view: EngineDelegate?) {
        _nodes = setupNodes(view: view)
        _mills = setupMills(view: view)
    }
    
    private func setupNodes(view: EngineDelegate?) -> [Node] {
        let nodes = createNodes(using: Constants.BoardSetup.nodeNeighbours, with: view)
        connectNodesTo(nodes: nodes, using: Constants.BoardSetup.nodeNeighbours)
        
        return nodes
    }
    
    private func createNodes(using nodeNeighbours: [[Int]], with view: EngineDelegate?) -> [Node] {
        var nodes = [Node]()
        
        for i in 0...nodeNeighbours.count-1 {
            nodes.append(Node(id: i, view: view))
        }
        
        return nodes
    }
    
    // Connect nodes to other nodes
    private func connectNodesTo(nodes: [Node], using nodeNeighbours: [[Int]]) {
        for i in 0...nodeNeighbours.count-1 {
            for neighbourIndex in nodeNeighbours[i] {
                nodes[i].neighbours.append(nodes[neighbourIndex])
            }
        }
    }
    
    private func setupMills(view: EngineDelegate?) -> [Mill] {
        let mills = createMills(using: Constants.BoardSetup.millNodes, nodes: _nodes, with: view)
        connectNodesIn(mills: mills)
        
        return mills
    }
    
    private func createMills(using millNodes: [[Int]], nodes: [Node], with view: EngineDelegate?) -> [Mill] {
        var mills = [Mill]()
        
        for i in 0...millNodes.count-1 {
            let nodeIndices = millNodes[i]
            let mill = Mill(id: i, view: view)
            
            for nodeIndex in nodeIndices {
                mill.nodes.append(Unowned<Node>(value: nodes[nodeIndex]))
            }
            
            mills.append(mill)
        }
        
        return mills
    }
    
    // Connect the nodes and the mills together
    private func connectNodesIn(mills: [Mill]){
        for mill in mills {
            for node in mill.nodes {
                node.value.mills.append(mill)
            }
        }
    }

}
