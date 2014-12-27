//
//  Box.swift
//  Algebraic
//
//  Created by Jason Larsen on 12/26/14.
//  Copyright (c) 2014 Heartbit. All rights reserved.
//

import Foundation

public class Box<T> {
    public let unbox: T
    init(_ value: T) {
        self.unbox = value
    }
}