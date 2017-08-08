//
//  TreeNode.swift
//  FightyDot
//
//  Created by Graham McRobbie on 27/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  A class to hold a minimax state tree.
//  Not currently used, but you can add it to MiniMax/Negamax
//  for debugging/visual representation, if desired.
//

import Foundation

class TreeNode<T> {
    private var _data: T
    private var _children: [TreeNode<T>]
    
    var data: T {
        get {
            return _data
        } set {
            _data = newValue
        }
    }
    
    init(data: T) {
        _data = data
        _children = []
    }
    
    func addChild(data: T) -> TreeNode<T> {
        let child = TreeNode<T>(data: data)
        _children.insert(child, at: 0)
        
        return child
    }
    
    func printTree(level: Int = 0) {
        for _ in 0 ..< level {
            print("\t", terminator: " ")
        }
        
        print(data)
        
        for child in _children {
            child.printTree(level: level + 1)
        }
    }
}
