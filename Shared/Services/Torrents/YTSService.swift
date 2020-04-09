//
//  YTSService.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

final class YTSService {
    private static let base: String = "https://yts.lt/api/v2"

    static func torrents(item: MediaItem) -> AnyPublisher<[Torrent], Never> {
        guard let imdb = item.imdbID else {
            return Just([]).eraseToAnyPublisher()
        }

        let path: String = "/list_movies.json?query_term=\(imdb)"
        return URLSession.shared.dataTaskPublisher(for: request(path: path))
            .map { $0.data }
            .decode(type: YTSTorrentResponse.self, decoder: JSONDecoder())
            .map { $0.torrents }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension YTSService {
    static func request(path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(base)\(path)")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

