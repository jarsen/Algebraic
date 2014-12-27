//
//  BST.swift
//  Algebraic
//
//  Created by Jason Larsen on 12/26/14.
//  Copyright (c) 2014 Heartbit. All rights reserved.
//

import Foundation

//public enum JSON {
//    case Null
//    case Bool(NSNumber)
//    case Number(NSNumber)
//    case Str(String)
//    case Object([String:JSON])
//    case Array([JSON])
//}

public enum BST<T: Comparable> {
    case Leaf
    case Tree(Box<BST<T>>, T, Box<BST<T>>)
}

public func bst<T>(element: T) -> BST<T> {
    return .Tree(Box(.Leaf), element, Box(.Leaf))
}

public func count<T>(tree: BST<T>) -> Int {
    switch tree {
    case .Leaf:
        return 0;
    case let .Tree(leftBox, _, rightBox):
        return 1 + count(leftBox.unbox) + count(rightBox.unbox)
    }
}

public func elements<T>(tree: BST<T>) -> List<T> {
    switch tree {
    case .Leaf:
        return .Nil
    case let .Tree(leftBox, x, rightBox):
        return elements(leftBox.unbox) ++ [x] ++ elements(rightBox.unbox)
    }
}

public func contains<T>(tree: BST<T>, element: T) -> Bool {
    switch tree {
    case .Leaf:
        return false
    case let .Tree(_, x, _) where x == element:
        return true
    case let .Tree(leftBox, x, _) where x < element:
        return contains(leftBox.unbox, element)
    case let .Tree(_, x, rightBox) where x > element:
        return contains(rightBox.unbox, element)
    default:
        assert(false, "impossible condition")
    }
}

public func setInsert<T>(tree: BST<T>, element: T) -> BST<T> {
    switch tree {
    case .Leaf:
        return bst(element)
    case let .Tree(leftBox, x, rightBox) where x == element:
        return tree
    case let .Tree(leftBox, x, rightBox) where x < element:
        return .Tree(Box(setInsert(leftBox.unbox, element)), x, rightBox)
    case let .Tree(leftBox, x, rightBox) where x > element:
        return .Tree(leftBox, x, Box(setInsert(rightBox.unbox, x)))
    default:
        assert(false, "impossible condition")
    }
}