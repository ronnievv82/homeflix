//
//  EZTVService.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine
import SwiftSoup

final class EZTVService {
    private static let base: String = "https://eztv.io/api"

    static func torrents(item: MediaItem) -> AnyPublisher<[EZTVTorrent], Never> {
        let id: String = item.imdbID?.replacingOccurrences(of: "tt", with: "") ?? ""
        let path: String = "/get-torrents?imdb_id=\(id)"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .decode(type: EZTVTorrentResponse.self, decoder: JSONDecoder())
            .map { $0.torrents }
            .map { ss in
                print(ss)
                return ss
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    static func torrents(show: Show, episode: Episode) -> AnyPublisher<[Torrent], Never> {
        let search = "\(show.name) \(episode.formattedSeasonEpisode)"
            .replacingOccurrences(of: " ", with: "-").lowercased()

        let path: String = "\(search)/se/desc/"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .tryMap { data in
                let str = String(data: data, encoding: .utf8) ?? ""
                let doc: Document = try SwiftSoup.parse(str)
                print(doc)
                return [Torrent]()
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension EZTVService {
    static func request(path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(base)\(path)")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
