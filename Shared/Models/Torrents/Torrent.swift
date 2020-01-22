//
//  Torrent.swift
//  homeflix
//
//  Created by Martin Púčik on 21/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

class Torrent: Decodable {
    let hash: String
    let seeds: String
    let peers: String
    let size: String
    let name: String

    init(hash: String, seeds: String, peers: String, size: String, name: String) {
        self.hash = hash
        self.seeds = seeds
        self.peers = peers
        self.size = size
        self.name = name
    }
}

extension Torrent: Identifiable {
    var id: String { hash }
}

extension Torrent: Hashable {
    static func == (lhs: Torrent, rhs: Torrent) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
