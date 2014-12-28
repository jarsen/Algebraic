//
//  Seq.swift
//  Algebraic
//
//  Created by Jason Larsen on 12/28/14.
//  Copyright (c) 2014 Heartbit. All rights reserved.
//

import Foundation

public protocol Seq {
    typealias S
    typealias Element
    
    func head() -> Element?
    func tail() -> S
}