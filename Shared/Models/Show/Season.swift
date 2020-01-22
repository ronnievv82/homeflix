//
//  Season.swift
//  homeflix
//
//  Created by Martin Púčik on 12/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

struct Season: Decodable, Hashable {
    let number: Int
    let title: String
    let episode_count: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
}
