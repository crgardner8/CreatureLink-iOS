//
//  RandomNumberProviding.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

protocol RandomNumberProviding {
    func int(in range: ClosedRange<Int>) -> Int
    func int(in range: Range<Int>) -> Int
}

struct SystemRandomNumberProvider: RandomNumberProviding {
    func int(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range)
    }
    
    func int(in range: Range<Int>) -> Int {
        Int.random(in: range)
    }
}

extension RandomNumberProviding {
    func element<T>(from array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        let index = int(in: 0..<array.count)
        return array[index]
    }
}
