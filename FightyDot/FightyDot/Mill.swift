//
//  Mill.swift
//  FightyDot
//
//  Created by Graham McRobbie on 12/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import Foundation
import UIKit

class Mill {
    
    private var _id: Int
    private var _pieceCounts = Array(repeating: 0, count: 3)
    private var _nodes: [Unowned<Node>] = []
    private var _colour: PieceColour = PieceColour.none {
        didSet {
            if(_colour == .none) {
                _view?.reset(mill: self)
            } else {
                _view?.animate(mill: self, to: _colour)
            }
        }
    }
    
    weak private var _view: EngineDelegate?
    
    var id: Int {
        get {
            return _id
        }
    }
    
    var nodes: [Unowned<Node>] {
        get {
            return _nodes
        } set {
            _nodes = newValue
        }
    }
    
    var colour: PieceColour {
        get {
            return _colour
        }
    }
    
    init(id: Int, view: EngineDelegate?) {
        _id = id
        _pieceCounts[PieceColour.none.rawValue] = Constants.GameplayNumbers.piecesInMill
        _view = view
    }
    
    func reset() {
        _colour = PieceColour.none
        _pieceCounts[PieceColour.none.rawValue] = Constants.GameplayNumbers.piecesInMill
        _pieceCounts[PieceColour.green.rawValue] = 0
        _pieceCounts[PieceColour.red.rawValue] = 0
    }
    
    // Returns true if a mill is formed
    func updatePieceCounts(oldColour: PieceColour, newColour: PieceColour) -> Bool {
        _pieceCounts[oldColour.rawValue] -= 1
        _pieceCounts[newColour.rawValue] += 1
        
        let newColour = getColourFromPieceCounts()
        
        if(_colour != newColour) {
            // If the updated colour is .none > the mill was broken, else it was formed
            let millFormed = newColour != PieceColour.none
            
            for node in nodes {
                if(millFormed) {
                    node.value.incrementActiveMillCount()
                } else {
                    node.value.decrementActiveMillCount()
                }
            }
            
            _colour = newColour
            return millFormed
        }
        
        return false
    }

    func copyValues(from otherMill: Mill) {
        _pieceCounts = otherMill._pieceCounts
        _colour = otherMill._colour
    }
    
    // MARK: - Heuristic evaluation helpers

    func isInDoubleMillConfiguration(for colour: PieceColour) -> Bool {
        if(!isInTwoPieceConfiguration(for: colour)) {
            return false
        }
        
        let emptyNode = _nodes.filter{ node in node.value.colour == .none}.first
        
        for neighbour in (emptyNode?.value.neighbours)! {
            if(neighbour.inActiveMill && neighbour.colour == colour) {
                return true
            }
        }
        
        return false
    }
    
    func isInTwoPieceConfiguration(for colour: PieceColour) -> Bool {
        return (_pieceCounts[PieceColour.none.rawValue] == 1) && (_pieceCounts[colour.rawValue] == 2)
    }
    
    func isOpen(for colour: PieceColour) -> Bool {
        if(!isInTwoPieceConfiguration(for: colour)) {
            return false
        }
        
        let emptyNode = _nodes.filter{ node in node.value.colour == .none}.first
        
        for neighbour in (emptyNode?.value.neighbours)! {
            // Check neighbour is not in the mill we're checking
            if _nodes.contains(where: {node in node.value.id == neighbour.id}) {
                continue
            }
            
            if(neighbour.colour == colour) {
                return true
            }
        }
        
        return false
    }
    
    func intersects(with otherMill: Mill) -> Bool {
        for node in _nodes {
            for otherNode in otherMill.nodes {
                if(node.value.id == otherNode.value.id) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private functions
    
    // Once a mill has 3 pieces of a certain colour, the colour of the mill changes
    private func getColourFromPieceCounts() -> PieceColour{
        if (_pieceCounts[PieceColour.green.rawValue] == Constants.GameplayNumbers.piecesInMill) {
            return PieceColour.green
        } else if (_pieceCounts[PieceColour.red.rawValue] == Constants.GameplayNumbers.piecesInMill){
            return PieceColour.red
        } else {
            return PieceColour.none
        }
    }
}
