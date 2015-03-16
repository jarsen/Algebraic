//
//  List.swift
//  Algebraic
//
//  Created by Jason Larsen on 12/26/14.
//  Copyright (c) 2014 Heartbit. All rights reserved.
//

import Foundation

public enum List<T> {
    case Nil
    case Cons(Box<T>, Box<List<T>>)
    
    init(_ head: T, _ tail: List<T>) {
        self = .Cons(Box(head), Box(tail))
    }
}

extension List : Printable {
    public var description: String {
        get {
            switch self {
            case Nil:
                return "[]"
            case let .Cons(headBox, tailBox):
                return "\(headBox.unbox) \(tailBox.unbox.description)"
            }
        }
    }
}

// MARK: head & tail

public func head<T>(list: List<T>) -> T? {
    switch list {
    case .Nil:
        return nil
    case let .Cons(head, _):
        return head.unbox
    }
}

public func tail<T>(list: List<T>) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(_, tailBox):
        return tailBox.unbox
    }
}

// Mark: Building Lists

public func cons<T>(element: T, _ list: List<T>=List.Nil) -> List<T> {
    return List(element, list)
}

// equivalent to haskell's infix cons operator: `:`
// use like: `let numbers = 1 => 2 => 3 => List.Nil`
infix operator => {
    associativity right
    precedence 150
}

public func => <T>(lhs: T, rhs: List<T>) -> List<T> {
    return cons(lhs, rhs)
}

public func fromCollection<C : CollectionType where C.Index : BidirectionalIndexType>(array: C) -> List<C.Generator.Element> {
    return reduce(reverse(array), List.Nil) { acc, x in
        x => acc
    }
}

 extension List : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        self = fromCollection(elements)
    }
}

public extension List {
    public init(array: [T]) {
        self = fromCollection(array)
    }
}

// MARK: Appending Lists

infix operator ++ {
    associativity right
    precedence 150
}

public func ++<T>(lhs: List<T>, rhs: List<T>) -> List<T> {
    return append(lhs, rhs)
}

public func append<T>(lhs: List<T>, rhs: List<T>) -> List<T> {
    return appendHelper(lhs, rhs, .Nil)
}

func appendHelper<T>(lhs: List<T>, rhs: List<T>, list: List<T>) -> List<T> {
    switch lhs {
    case .Nil:
        switch rhs {
        case .Nil:
            return list
        case let .Cons(head, tailBox):
            return head.unbox => appendHelper(lhs, tail(rhs), list)
        }
    case let .Cons(head, tailBox):
        return head.unbox => appendHelper(tail(lhs), rhs, list)
    }
}

// MARK: map, filter, fold

public func map<T,U>(list: List<T>, f:T->U) -> List<U> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        return f(head.unbox) => map(tail(list), f)
    }
}

public func filter<T>(list: List<T>, f:T->Bool) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        if f(head.unbox) {
            return head.unbox => filter(tail(list), f)
        }
        else {
            return filter(tail(list), f)
        }
    }
}

public func foldl<T,U>(list: List<T>, accumulator: U, f:(U,T)->U) -> U {
    switch list {
    case .Nil:
        return accumulator
    case let .Cons(head, tailBox):
        return foldl(tail(list), f(accumulator, head.unbox), f)
    }
}

public func foldr<T,U>(list: List<T>, accumulator: U, f:(T,U)->U) -> U {
    switch list {
    case .Nil:
        return accumulator
    case let .Cons(head, tailBox):
        return f(head.unbox, foldr(tail(list), accumulator, f))
    }
}

// Mark: Indices

infix operator !! {}

public func !!<T>(lhs: List<T>, n: Int) -> T {
    return elementAtIndex(lhs, n)
}

public func elementAtIndex<T>(list: List<T>, n: Int) -> T {
    switch list {
    case .Nil:
        assert(false, "Error: \(n) is out of bounds of list")
    case let .Cons(head, tailBox):
        if n == 0 {
            return head.unbox
        }
        else {
            return elementAtIndex(tailBox.unbox, n - 1)
        }
    }
}

// MARK: take

public func take<T>(list: List<T>, n: Int) -> List<T> {
    if n <= 0 {
        return .Nil
    }
    if let h = head(list) {
        return h => take(tail(list), n-1)
    }
    else {
        return .Nil
    }
}

public func takeWhile<T>(list: List<T>, f: T->Bool) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        if f(head.unbox) {
            return head.unbox => takeWhile(tail(list), f)
        }
        else {
            return .Nil
        }
    }
}

// MARK: drop

public func drop<T>(list: List<T>, n: Int) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        if n > 0 {
            return drop(tail(list), n - 1)
        }
        else {
            return head.unbox => drop(tail(list), n)
        }
    }
}

public func dropWhile<T>(list: List<T>, f:T->Bool) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        if f(head.unbox) {
            return dropWhile(tail(list), f)
        }
        else {
            return list
        }
    }
}

// Mark:

public func count<T>(list: List<T>) -> Int {
    switch list {
    case .Nil:
        return 0
    case let .Cons(_, tailBox):
        return 1 + count(tailBox.unbox)
    }
}

public func any<T>(list: List<T>, f:T->Bool) -> Bool {
    switch list {
    case .Nil:
        return false
    case let .Cons(head, tailBox):
        if f(head.unbox) {
            return true
        }
        else {
            return any(tailBox.unbox, f)
        }
    }
}

public func all<T>(list: List<T>, f:T->Bool) -> Bool {
    switch list {
    case .Nil:
        return true
    case let .Cons(head, tailBox):
        if !f(head.unbox) {
            return false
        }
        else {
            return all(tailBox.unbox, f)
        }
    }
}

public func contains<T: Equatable>(list: List<T>, element: T) -> Bool {
    switch list {
    case .Nil:
        return false
    case let .Cons(head, tailBox):
        if head.unbox == element {
            return true
        }
        else {
            return contains(tailBox.unbox, element)
        }
    }
}

public func replicate<T>(times: Int, element: T) -> List<T> {
    if times <= 0 {
        return .Nil
    }
    return element => replicate(times - 1, element)
}

public func intersperse<T>(list: List<T>, element: T) -> List<T> {
    return foldr(list, .Nil) { x, acc in
        return x => element => acc
    }
}

public func reverse<T>(list: List<T>) -> List<T> {
    return foldl(list, .Nil) { acc, x in
        return x => acc
    }
}

public func concat<T>(list: List<List<T>>) -> List<T> {
    return foldr(list, .Nil, ++)
}

public func delete<T: Equatable>(list: List<T>, element: T) -> List<T> {
    return filter(list) { $0 != element }
}

public func replace<T>(list: List<T>, with: T, f:T->Bool) -> List<T> {
    switch list {
    case .Nil:
        return .Nil
    case let .Cons(head, tailBox):
        if f(head.unbox) {
            return with => replace(tail(list), with, f)
        }
        else {
            return head.unbox => replace(tail(list), with, f)
        }
    }
}

public func replace<T: Equatable>(list: List<T>, with: T, replaceItem: T) -> List<T> {
    return replace(list, with) { $0 == replaceItem }
}

// MARK: min & max

public func minElement<T: Comparable>(list: List<T>) -> T? {
    if let initial = head(list) {
        return foldr(list, initial, min)
    }
    return nil
}

public func maxElement<T: Comparable>(list: List<T>) -> T? {
    if let initial = head(list) {
        return foldr(list, initial, max)
    }
    return nil
}

public func minElementBy<T, U:Comparable>(list: List<T>, f:T->U) -> T? {
    if let initial = head(list) {
        let (min, _) = foldr(tail(list), (initial, f(initial))) { x, mins in
            let (min, fmin) = mins
            let fx = f(x)
            return fx < fmin ? (x, fx) : (min, fmin)
        }
        return min
    }
    return nil
}

public func maxElementBy<T, U:Comparable>(list: List<T>, f:T->U) -> T? {
    if let initial = head(list) {
        let (max, _) = foldr(tail(list), (initial, f(initial))) { x, maxs in
            let (max, fmax) = maxs
            let fx = f(x)
            return fx > fmax ? (x, fx) : (max, fmax)
        }
        return max
    }
    return nil
}

// TODO: scanl/scanr