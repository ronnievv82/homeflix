//
//  EZTVTorrent.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    case torrents, filename
}

// MARK: - EZTVTorrentResponse

struct EZTVTorrentResponse: Decodable {

    let torrents: [EZTVTorrent]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        torrents = try container.decode([EZTVTorrent].self, forKey: .torrents)
    }
}

// MARK: - EZTVTorrent

struct EZTVTorrent: Decodable {

    let filename: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filename = try container.decode(String.self, forKey: .filename)
    }
}
