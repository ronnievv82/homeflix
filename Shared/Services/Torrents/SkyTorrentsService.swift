//
//  SkyTorrentsService.swift
//  homeflix
//
//  Created by Martin Púčik on 19/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import Combine
import SwiftSoup

enum SkyTorrentsService {

    private static let base: String = "https://www.skytorrents.lol/"

    static func torrents(show: Show, episode: Episode) -> AnyPublisher<[Torrent], Never> {
        let search = "\(show.name) \(episode.formattedSeasonEpisode)"
            .replacingOccurrences(of: " ", with: "+").lowercased()
        let path: String = "?query=\(search)&sort=seeders"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .tryMap { data in
                let str = String(data: data, encoding: .utf8) ?? ""
                let doc: Document = try SwiftSoup.parse(str)
                return [Torrent]()
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension SkyTorrentsService {
    static func request(path: String) -> URLRequest {
        print(URL(string: "\(base)\(path)")!)
        return URLRequest(url: URL(string: "\(base)\(path)")!)
    }
}
