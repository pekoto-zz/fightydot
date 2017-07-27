//
//  TreeNode.swift
//  FightyDot
//
//  Created by Graham McRobbie on 27/07/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  A class to hold minimax state tree in (for debugging/visual representation, if desired)
//

import Foundation

class TreeNode<T> {
    private var _data: T
    private var _children: [TreeNode<T>]
    
    var data: T {
        get {
            return _data
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
            print("\t")
        }
        
        print("\n")
        
        for child in _children {
            child.printTree(level: level + 1)
        }
    }
}
