//
//  7TorrentsService.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 21/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine
import SwiftSoup

final class SevenTorrentsService {
    private static let base: String = "https://www.7torrents.cc"

    static func torrents<T: MediaItemProtocol>(item: T) -> AnyPublisher<[Torrent], Never> {
        let path: String = "/search?query=\(item.name)+\(item.year)"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .tryMap { try mapDataToTorrents($0) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    static func torrents(show: Show, episode: Episode) -> AnyPublisher<[Torrent], Never> {
        let path: String = "/search?query=\(show.name)+\(episode.formattedSeasonEpisode.lowercased())"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .tryMap { try mapDataToTorrents($0) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension SevenTorrentsService {
    static func request(path: String) -> URLRequest {
        var str = path.replacingOccurrences(of: " ", with: "+")
        str = str.replacingOccurrences(of: ".", with: "")
        str = str.replacingOccurrences(of: "-", with: "")
        str = str.replacingOccurrences(of: " ", with: "")
        str = str.replacingOccurrences(of: "…", with: "")
        return URLRequest(url: URL(string: "\(base)\(str)")!)
    }

    static func mapDataToTorrents(_ data: Data) throws -> [Torrent] {
        let str = String(data: data, encoding: .utf8) ?? ""
        let doc: Document = try SwiftSoup.parse(str)
        let results = try doc.getElementById("results")
        let media = try results?.getElementsByClass("media").array() ?? []
        var torrents: [Torrent] = []
        for item in media {
            guard
                let name = try? item.attr("data-name"),
                let size = try? item.attr("data-size"),
                let seed = try? item.attr("data-seeders"),
                let leech = try? item.attr("data-leechers"),
                let click = try? item.attr("onclick")
            else {
                continue
            }

            let endIndex = click.index(click.startIndex, offsetBy: 24)
            let hash = click[endIndex...].dropLast().dropLast()
            let sizeformat = ByteCountFormatter.string(fromByteCount: Int64(Int(size) ?? 0),
                                                       countStyle: .decimal)

            torrents.append(SevenTorrent(hash: String(hash), seeds: seed, peers: leech,
                                         size: sizeformat, name: name))
        }
        return torrents
    }
}
