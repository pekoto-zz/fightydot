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
    
    private let _nodeNeighbours = [
            [1, 9],           // 0
            [0, 2, 4],        // 1
            [1, 14],          // 2
            [4, 10],          // 3
            [1, 3, 5, 7],     // 4
            [4, 13],          // 5
            [7, 11],          // 6
            [4, 6, 8],        // 7
            [7, 12],          // 8
            [0, 10, 21],      // 9
            [3, 9, 11, 18],   // 10
            [6, 10, 15],      // 11
            [8, 13, 17],      // 12
            [5, 12, 14, 20],  // 13
            [2, 13, 23],      // 14
            [11, 16],         // 15
            [15, 17, 19],     // 16
            [12, 16],         // 17
            [10, 19],         // 18
            [16, 18, 20, 22], // 19
            [13, 19],         // 20
            [9, 22],          // 21
            [19, 21, 23],     // 22
            [14, 22]          // 23
    ]
    
    private let _millNodes = [
            // Horizontal mills, left to right
            [0, 1, 2],      // 0
            [3, 4, 5],      // 1
            [6, 7, 8],      // 2
            [9, 10, 11],    // 3
            [12, 13, 14],   // 4
            [15, 16, 17],   // 5
            [18, 19, 20],   // 6
            [21, 22, 23],   // 7
            
            // Vertical mills, top to bottom
            [0, 9, 21],     // 8
            [3, 10, 18],    // 9
            [6, 11, 15],    // 10
            [1, 4, 7],      // 11
            [16, 19, 22],   // 12
            [8, 12, 17],    // 13
            [5, 13, 20],    // 14
            [2, 14, 23]     // 15
    ]

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
    
    func getNodes(withColour colour: PieceColour) -> [Node] {
        return _nodes.filter { (node) in node.colour == colour }
    }
    
    func getNode(withID id: Int) -> Node? {
        return _nodes.filter { (node) in node.id == id }.first
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
    
    // MARK: - Private functions
    
    private func setup(view: EngineDelegate?) {
        _nodes = setupNodes(view: view)
        _mills = setupMills(view: view)
    }
    
    private func setupNodes(view: EngineDelegate?) -> [Node] {
        let nodes = createNodes(using: _nodeNeighbours, with: view)
        connectNodesTo(nodes: nodes, using: _nodeNeighbours)
        
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
        let mills = createMills(using: _millNodes, nodes: _nodes, with: view)
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
