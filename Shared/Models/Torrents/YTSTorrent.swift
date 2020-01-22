//
//  YTSTorrent.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    case data, movies, torrents, quality, hash, type, size, seeds, peers
}

// MARK: - YTSTorrentResponse

struct YTSTorrentResponse: Decodable {
    let torrents: [YTSTorrent]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let movies = try data.decode([YTSMovie].self, forKey: .movies)
        torrents = movies.first?.torrents ?? []
    }
}

// MARK: - YTSTorrent

final class YTSTorrent: Torrent {

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hash = try container.decode(String.self, forKey: .hash)
        let quality = try container.decode(String.self, forKey: .quality)
        let type = try container.decode(String.self, forKey: .type)
        let name = "\(type): \(quality)"
        let size = try container.decode(String.self, forKey: .size)
        let seedsInt = try container.decode(Int.self, forKey: .seeds)
        let seeds = "\(seedsInt)"
        let peersInt = try container.decode(Int.self, forKey: .peers)
        let peers = "\(peersInt)"
        super.init(hash: hash, seeds: seeds, peers: peers, size: size, name: name)
    }
}

// MARK: - YTSMovie

private struct YTSMovie: Decodable {
    let torrents: [YTSTorrent]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        torrents = try container.decode([YTSTorrent].self, forKey: .torrents)
    }
}
